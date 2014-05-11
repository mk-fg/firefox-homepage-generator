# XXX: tag font-size range, canvas size, etc should be configurable via templating

tags = d3.entries(ffhome_tags).sort((a, b) -> return b.value - a.value)
fill = d3.scale.category20()

vis_box = d3.select('#vis')
[w, h] = [vis_box.node().clientWidth, vis_box.node().clientHeight]
console.assert(h > 100 and w > 100, [w, h]) # hangs d3-cloud layout
svg = vis_box.append('svg')
	.attr('width', w)
	.attr('height', h)
vis_bg = svg.append('g')
vis = svg.append('g')
	.attr('transform', 'translate(' + [w >> 1, h >> 1] + ')')

font_scale = vis_box.style('font-size')
console.assert(font_scale.match(/px$/), font_scale)
font_scale = parseInt(font_scale)
font_scale = [font_scale, font_scale * 3]
font_scale = d3.scale['linear']().range(font_scale) # log, sqrt, linear
font_scale.domain([+tags[tags.length - 1].value or 1, +tags[0].value])

tag_links = ffhome_tag_links
tag_links_box = d3.select('#tag-links')
tag_highlight = null

draw_data = null # cached from draw for draw_hl_fade

draw_hl_fade = (selection) ->
	console.assert(selection? or draw_data)
	hl_check = (d) -> not tag_highlight or d.text == tag_highlight
	if not selection?
		selection = vis.selectAll('text')
			.data(draw_data, (d) -> d.text)
	selection.transition()
		.duration(1000)
		.style('opacity', (d) -> if hl_check(d) then 1 else 0.2)

draw = (data, bounds) ->
	scale = if bounds\
		then Math.min(
			w / Math.abs(bounds[0].x - w / 2),
			w / Math.abs(bounds[1].x - w / 2),
			h / Math.abs(bounds[0].y - h / 2),
			h / Math.abs(bounds[1].y - h / 2) ) / 2\
		else 1
	draw_data = data

	text = vis.selectAll('text')
		.data(data, (d) -> d.text)
	text_transition = text.transition()
		.duration(1000)
		.attr('transform', (d) -> 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')')
		.style('font-size', (d) -> d.size + 'px')
	draw_hl_fade(text_transition)

	text_transition = text.enter().append('text')
		.attr('text-anchor', 'middle')
		.attr('transform', (d) -> 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')')
		.style('font-size', (d) -> d.size + 'px')
		.on('click', (d) -> focus(d))
		.style('opacity', 1e-6)
	draw_hl_fade(text_transition)

	text.style('font-family', (d) -> d.font)
		.style('fill', (d) -> fill(d.text.toLowerCase()))
		.text((d) -> d.text)

	exit_group = vis_bg.append('g')
		.attr('transform', vis.attr('transform'))
	exit_group_node = exit_group.node()
	text.exit()
		.each(-> exit_group_node.appendChild(this))
	exit_group.transition()
		.duration(1000)
		.style('opacity', 1e-6)
		.remove()

	vis.transition()
		.delay(250)
		.duration(750)
		.attr('transform', 'translate(' + [w >> 1, h >> 1] + ')scale(' + scale + ')')

layout = d3.layout.cloud()
	.size([w, h])
	.spiral('archimedean') # archimedean, rectangular
	.font('Impact')
	.fontSize((d) -> font_scale(d.value))
	.timeInterval(Infinity)
	.words(tags)
	.text((d) -> d.key)
	# XXX: draw build progress as a css bar
	# .on('word', status)
	.on('end', draw)
	.start()


d3.select('#vis-shuffle')
	.on('click', (d) ->
		draw_data = null
		layout.stop().start())

focus = (tag) ->
	tag_highlight = tag.key
	draw_hl_fade()

	links = tag_links_box.select('ul')
		.selectAll('li')
			.data(tag_links[tag.key], (d, i) -> d.url)
	links.enter()
		.append('li')
			.append('a')
				.attr('href', (d) -> d.url)
				.text((d) -> d.title or d.url)
	links.exit().remove()
	tag_links_box.style('display', 'block')

	# XXX: show graph of linked tags on top of that, with some easy way back


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
