#!/usr/bin/env bash

R -e "rmarkdown::render('README.Rmd', 'github_document')"

rm -f README.html

R -e "rmarkdown::render('README.Rmd', output_file='index.html')"
