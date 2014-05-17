# XXX: tag font-size range, canvas size, etc should probably be configurable

assert = (condition, message) ->
	# console.assert is kinda useless, as it doesn't actually stop the script
	if not condition then throw message or 'Assertion failed'

# Data
for own tag, data of ffhome_tags
	data.links.sort((a, b) -> b.frecency - a.frecency)
tags =
	indexed: ffhome_tags
	sorted:\
		( {tag: tag, value: data.value, links: data.links}\
			for own tag, data of ffhome_tags ).sort((a, b) -> b.value - a.value)
	edges:
		sorted: ffhome_tag_edges.sort((a, b) -> a[2] - b[2])
		indexed: do ->
			index = {}
			for [t1, t2, v] in ffhome_tag_edges
				for [t1, t2] in [[t1, t2], [t2, t1]]
					if not index[t1]? then index[t1] = {}
					index[t1][t2] = v
			return index
	highlight: null

links =
	indexed: do ->
		index = {}
		for own tag, data of ffhome_tags
			for link in data.links
				index[link.url] = index[link.url] or do ->
					link_copy = {tags: []}
					for own k,v of link
						link_copy[k] = v
					return link_copy
				index[link.url].tags.push(tag)
		return index
	box: d3.select('#tag-links')

vis =
	fill: d3.scale.category20()
	box: d3.select('#vis')
	data: null # cached from draw for draw_hl_fade
	status: d3.select('#vis-status div')
	status_counter: 0
	opacity:
		highlight: 1
		unrelated: 0.15
		scale_ranges:
			1: d3.scale.linear().range([0.3, 0.5])
			# 2: d3.scale.linear().range([0.2, 0.27])
		scale_for: (order, domain) ->
			if typeof(domain) == 'object' then domain = d3.values(domain)
			if typeof(domain) == 'array' then domain = d3.extent(domain)
			assert(domain)
			scale = vis.opacity.scale_ranges[order].copy().domain(domain)
			[a, b] = domain
			if a == b
			then do (v=scale.range()[1]) -> (any) -> v
			else scale

# Canvas
[vis.w, vis.h] = [
	vis.box.node().clientWidth,
	vis.box.node().clientHeight ]
vis.svg = vis.box.select('svg').attr('width', vis.w).attr('height', vis.h)
vis.bg = vis.svg.append('g')
	.classed(background: true)
vis.cloud = vis.svg.append('g')
	.classed('tag-cloud': true)
	.attr('transform', 'translate(' + [vis.w >> 1, vis.h >> 1] + ')')
vis.graph = vis.svg.append('g')
	.classed('tag-graph': true)
assert(vis.h > 100 and vis.w > 100, vis) # hangs d3-cloud layout

# Font-size scale
vis.font_scale = vis.box.style('font-size')
assert(vis.font_scale.match(/px$/), vis)
vis.font_scale = parseInt(vis.font_scale)
vis.font_scale = d3.scale.linear()
	.range([vis.font_scale, vis.font_scale * 3])
	.domain([+tags.sorted[tags.sorted.length - 1].value, +tags.sorted[0].value])


# Layout, transitions

draw_hl_fade = (selection) ->
	assert(selection? or vis.data)
	hl_check = (d) -> not tags.highlight or d.tag == tags.highlight
	edges = tags.edges.indexed[tags.highlight] or {}
	opacity_scale = vis.opacity.scale_for(1, edges)
	if not selection?
		selection = vis.cloud.selectAll('text')
			.data(vis.data, (d) -> d.tag)
	selection.transition()
		.duration(1000)
		.style 'opacity', (d) ->
			if hl_check(d) then return vis.opacity.highlight
			if not edges[d.tag]? then return vis.opacity.unrelated
			opacity_scale(edges[d.tag])

draw = (data, bounds) ->
	scale = if bounds\
		then Math.min(
			vis.w / Math.abs(bounds[0].x - vis.w / 2),
			vis.w / Math.abs(bounds[1].x - vis.w / 2),
			vis.h / Math.abs(bounds[0].y - vis.h / 2),
			vis.h / Math.abs(bounds[1].y - vis.h / 2) ) / 2\
		else 1
	vis.data = data
	vis.status_counter = 0

	text = vis.cloud.selectAll('text')
		.data(data, (d) -> d.tag)
	text_transition = text.transition()
		.duration(1000)
		.attr('transform', (d) -> 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')')
		.style('font-size', (d) -> d.size + 'px')
	draw_hl_fade(text_transition) # must be chained to transition

	text_transition = text.enter().append('text')
		.attr('text-anchor', 'middle')
		.attr('transform', (d) -> 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')')
		.style('font-size', (d) -> d.size + 'px')
		.on('click', (d) -> focus(d))
		.style('opacity', 1e-6)
	draw_hl_fade(text_transition) # must be chained to transition

	text.style('font-family', (d) -> d.font)
		.style('fill', (d) -> vis.fill(d.tag))
		.attr('title', (d) -> d.tag)
		.text((d) -> d.tag)

	exit_group = vis.bg.append('g')
		.attr('transform', vis.cloud.attr('transform'))
	exit_group_node = exit_group.node()
	text.exit()
		.each(-> exit_group_node.appendChild(this))
	exit_group.transition()
		.duration(1000)
		.style('opacity', 1e-6)
		.remove()

	vis.cloud.transition()
		.delay(250)
		.duration(750)
		.attr('transform', 'translate(' + [vis.w >> 1, vis.h >> 1] + ')scale(' + scale + ')')

draw_status = ->
	vis.status_counter += 1
	vis.status.style('width', ((vis.status_counter / tags.sorted.length) * 100) + '%')

cloud = d3.layout.cloud()
	.size([vis.w, vis.h])
	.spiral('archimedean') # archimedean, rectangular
	.font('Impact')
	.fontSize((d) -> vis.font_scale(d.value))
	.timeInterval(Infinity)
	.words(tags.sorted)
	.text((d) -> d.tag)
	.on('word', draw_status)
	.on('end', draw)
	.start()


# Tag links, controls

d3.select('#vis-shuffle')
	.on 'click', (d) ->
		tags.highlight = null
		cloud.stop().start()
		links.box.style('display', 'none')

focus = (d) ->
	tags.highlight = d.tag
	draw_hl_fade()

	text = links.box.select('ul')
		.selectAll('li')
			.data(tags.indexed[d.tag].links, (d, i) -> d.url)
	text.enter()
		.append('li')
			.append('a')
				.attr('href', (d) -> d.url)
				.attr('title', (d) ->
					"frecency: #{d.frecency}\n" +
						'tags: ' + links.indexed[d.url].tags.join(', '))
				.text((d) -> d.title or d.url)
	text.exit().remove()

	links.box.style('display', 'block')


# Backlog

if ffhome_links? and ffhome_links.length
	backlog = d3.select('#backlog')
	backlog.select('ul')
		.selectAll('li')
			.data(ffhome_links)
		.enter().append('li')
			.append('a')
				.attr('href', (d) -> d.url)
				.text((d) -> d.title or d.url)
	backlog.style('display', 'block')
