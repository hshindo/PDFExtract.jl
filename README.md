# PDFExtract
[![Build Status](https://travis-ci.org/hshindo/PDFExtract.jl.svg?branch=master)](https://travis-ci.org/hshindo/PDFExtract.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/stqspi4ysuwr5d8h?svg=true)](https://ci.appveyor.com/project/hshindo/pdfextract-jl)

A [Julia](http://julialang.org/) wrapper for [pdfextract](https://github.com/paperai/pdfextract).  
Currently, `pdfextract-0.1.6` is supported.

## Requirements
* java
* julia 0.6

## Instllation
```julia
Pkg.add("PDFExtract")
```

## Types
* `PDText`: text and its coordinates
* `PDDraw`: draw and its coordinates
* `PDImage`: image coordinates

## Functions
* `readpdf(path::String, [options])`: read texts, draws, and images extracted from pdf.
* `readtexts(path::String, [options])`: read texts
* `readimages(path::String, [options])`: read images
* `readdraws(path::String, [options])`: read draws
* `extract(path::String, [options])`: readpdf + write
* `saveimages(path::String, [options])`: save PNG images extracted from pdf.

See [pdfextract](https://github.com/paperai/pdfextract) for details.
