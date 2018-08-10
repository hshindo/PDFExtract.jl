function readtex(path::String)
    str = open(readstring, path)
end

function pdflatex(path::String)
    run(`java -classpath $jar PDFExtractor $filename`)
end
