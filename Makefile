BACKLOG =
LINKS =
NOTES =
DESTDIR =
DEBUG =

OPTS =
PARTS_PATH = parts

JS_PATH = $(PARTS_PATH)/js
JS_FILES = $(wildcard $(JS_PATH)/*.js)
CSS_PATH = $(PARTS_PATH)/css
CSS_FILES = $(wildcard $(CSS_PATH)/*.css)
HTML_PATH = $(PARTS_PATH)
HTML_FILES = $(wildcard $(HTML_PATH)/*.html)


all: home


coffee: $(JS_FILES)
sass: $(CSS_FILES)
jade: $(HTML_FILES)

%.js: %.coffee
	coffee -c $<

%.css: %.scss
	PYTHONIOENCODING=utf-8 sassc -I $(dir $<) $< >$@.new
	mv $@.new $@

%.html: %.jade
	./_jade_tpl_render.py $< $@


ffhomegen_args= $(OPTS)
ifdef BACKLOG
	ffhomegen_args += -b $(BACKLOG)
endif
ifdef LINKS
	ffhomegen_args += -l $(LINKS)
endif
ifdef NOTES
	ffhomegen_args += -n $(NOTES)
endif
ifdef DESTDIR
	ffhomegen_args += -o $(DESTDIR)
endif
ifdef DEBUG
	ffhomegen_args += --debug
endif

home: coffee sass jade
	./ffhomegen.py $(ffhomegen_args)

home-only:
	./ffhomegen.py $(ffhomegen_args)


.PHONY: coffee sass jade home home-only
