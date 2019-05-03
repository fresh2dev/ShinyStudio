#!/usr/bin/env pwsh

param(
    [switch]$OverwriteIndex
)

### Converts all *.ipynb files in this directory to html.

[string]$dir = "$PSScriptRoot/*.ipynb"

& jupyter nbconvert $dir --to html -y --template full

# Shiny Server will auto-load "index.html" if it exists.
# if "index.html" does not already exist, see if one should be created.
if (-not $OverwriteIndex -and -not (Test-Path "$PSScriptRoot/index.html")) {
    # if there is only one notebook, rename html output to "index.html".
    [string[]]$nbs = Get-ChildItem $dir | Select-Object -ExpandProperty FullName

    if ($nbs.Length -eq 1) {
        $target = [System.IO.Path]::GetFileNameWithoutExtension($nbs[0]) + '.html'
        Move-Item -Path "$PSScriptRoot/$target" -Destination "$PSScriptRoot/index.html"
    }
}
