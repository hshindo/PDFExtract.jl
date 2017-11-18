using Base.Test
using PDFExtract

contents = readpdf("sample.pdf")

images = saveimages("sample.pdf", options=["-dpi","100"])
