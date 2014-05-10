firefox-homepage-generator
--------------------

Tool to generate a dynamic version of a firefox "homepage" with tag cloud of
bookmarks and a backlog.

Idea so far:

 - Have tags from bookmarks form some sort of dynamic (very much js) tag cloud,
   which should be easy to navigate and find stuff in without redirects or much lag.

 - Have a short list of random items from "backlog" - either picked from
   bookmarks by tag or from external sources - to click on and read when bored
   or feel like learning something useful (ha ha).

 - Optional page tabs with a full list of both things.


Templates and static assets in the "parts" directory will be used to construct
result in one of a few ways:

 * Build html file and copy it along with separate static "assets" files into a
   target directory.

 * Build one "fat" html file with all the assets embedded in it.

 * Produce a single "lean" html file with asset links to various external CDN
   sources (really bad idea).

Difference between these is caching, but likely irrelevant when loaded from a
local disk anyway.


Work in progress, not really usable yet.



Usage
--------------------

Doesn't need to be "installed" - just put the contents of the repo/package
anywhere, run the script to generate the page (and/or copy/link assets) in the
output path (configurable via --output-path, see also --output-format).

Examples:
```console
	./ffhomegen.py
	./ffhomegen.py -o ~/media/ffhome
	./ffhomegen.py -b ~/media/links.yaml
	firefox $(./ffhomegen.py -v)
```

### Requirements

 * Python 2.7 (not 3.X)
 * (optional) [yaml](http://pyyaml.org/) for parsing of "backlog" file

See http://pip2014.com/ for help with python modules' packaging.



Links
--------------------

 * [bookmarkshome addon](http://bookmarkshome.mozdev.org/) (really old).

 * [mybookmarks addon](http://www.catsyawn.net/ma2ten/soft/mybookmarks_en.html) -
   remake of bookmarkshome.

 * [bookmarks_html addon](https://addons.mozilla.org/en-US/firefox/addon/bookmarks_html/) -
   another random example of a similar addon.

 * FF even has similar thing built-in (but default-disabled for ages now) -
   [browser.bookmarks.autoExportHTML](http://kb.mozillazine.org/Browser.bookmarks.autoExportHTML).

 * [Helpful explaination of how ff bookmarks are organized in places.sqlite](http://stackoverflow.com/a/740183).

 * There are some interesting upsides of building such page by hand -
   [blog post](http://utcc.utoronto.ca/~cks/space/blog/web/BookmarksAlternative) (not mine).
