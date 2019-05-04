#!/usr/bin/env bash

R -e "rmarkdown::render('README.Rmd', 'md_document')"

rm -f README.html

R -e "rmarkdown::render('README.Rmd', 'html_document', output_file='index.html')"
