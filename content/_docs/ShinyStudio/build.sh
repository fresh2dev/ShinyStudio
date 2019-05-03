#!/usr/bin/env bash

R -e "rmarkdown::render('README.Rmd', 'github_document')"

rm -f README.html
