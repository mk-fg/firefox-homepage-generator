BACKLOG =
DESTDIR =

JS_PATH = parts/js
JS_FILES = $(wildcard $(JS_PATH)/*.js)

CSS_PATH = parts/css
CSS_FILES = $(wildcard $(CSS_PATH)/*.css)

all: coffee sass home

coffee: $(JS_FILES)
sass: $(CSS_FILES)

%.js: %.coffee
	coffee -c $<

%.css: %.scss
	PYTHONIOENCODING=utf-8 sassc -I $(dir $<) $< >$@.new
	mv $@.new $@


ffhomegen_args=
ifdef BACKLOG
	ffhomegen_args += -b $(BACKLOG)
endif
ifdef DESTDIR
	ffhomegen_args += -o $(DESTDIR)
endif

home:
	./ffhomegen.py -v $(ffhomegen_args)
