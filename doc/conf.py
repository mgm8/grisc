#
# conf.py
#
# Copyright The GRISC Contributors.
#
# GRISC Documentation
#
# This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
# International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.
#
#

import sys
import ast

# Project information
project     = 'grisc'
copyright   = 'The GRISC Contributors'
author      = 'Gabriel Mariano Marcelino'
release     = 'v0.1'
title       = 'GRISC'
doc_id      = 'grisc'

# General configuration
numfig = True

extensions = ['sphinxcontrib.bibtex']

# Path to your .bib file
bibtex_bibfiles = ['references.bib']

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# Identify the Sphinx builder being used
if '-b' in sys.argv:
    builder = sys.argv[sys.argv.index('-b') + 1]
elif '-M' in sys.argv:
    builder = sys.argv[sys.argv.index('-M') + 1]
else:
    builder = 'html'  # Default builder

# Options for HTML output
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# Navigation bar title
html_title = "GRISC Documentation"
html_short_title = "GRISC Documentation"
