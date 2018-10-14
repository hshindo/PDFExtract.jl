# PDFExtract
[![Build Status](https://travis-ci.org/hshindo/PDFExtract.jl.svg?branch=master)](https://travis-ci.org/hshindo/PDFExtract.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/stqspi4ysuwr5d8h?svg=true)](https://ci.appveyor.com/project/hshindo/pdfextract-jl)

## Requirements
* Java 8
* Julia 1.0

## Setup
### DeepFigures
Install [deepfigures-open](https://github.com/allenai/deepfigures-open).  
Note that [pull request #3](https://github.com/allenai/deepfigures-open/pull/3) should be merged before installation.

Extract figures and tables from pdf:
```bash
$ python manage.py build
$ python manage.py detectfigures [out directory] [pdf file]
```

Change owner of deepfigures' output:
```bash
$ sudo chown -R [username] [out directory]
```

### PDFExtract
Install Julia 1.0.x.  
Run julia and press `]`, then
```
pkg> add https://github.com/hshindo/PDFExtract.jl.git
```

## Using PDFExtract
Put `xxx.pdf` and the `xxxdeepfigures-results.json`(deepfigures' output) in the same directory.  
Then
```
using PDFExtract

pdfpath = "/home/xxx"
pdf2xml(pdfpath)
```
