#!/usr/bin/env python
# -*- coding: utf-8 -*-

from contextlib import contextmanager
from tempfile import NamedTemporaryFile
from os.path import basename, dirname
import os, sys

import jinja2, pyjade

tpl_path, dst_path = sys.argv[1:]
tpl_dir, tpl_file = dirname(tpl_path), basename(tpl_path)

env = jinja2.Environment(
	extensions=['pyjade.ext.jinja.PyJadeExtension'],
	loader=jinja2.FileSystemLoader(tpl_dir) )

@contextmanager
def dump_tempfile(path):
	kws = dict( suffix='.', delete=False,
		dir=dirname(path), prefix=basename(path) )
	with NamedTemporaryFile(**kws) as tmp:
		try:
			yield tmp
			tmp.flush()
			os.rename(tmp.name, path)
		finally:
			try: os.unlink(tmp.name)
			except (OSError, IOError): pass

with dump_tempfile(dst_path) as dst:
	html = env.get_template(tpl_file).render().encode('utf-8')
	dst.write(html)
	if not html.endswith('\n'): dst.write('\n')
