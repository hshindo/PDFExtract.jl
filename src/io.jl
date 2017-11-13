export readpdf, readtext, readimage

function readpdf(path::String, option="-text -bounding -draw -image")
    jarpath = realpath(joinpath(dirname(@__FILE__),"../deps"))
    jarfile = "$jarpath/pdfextract-0.1.3.jar")
    if !isfile(jarfile)
        println("Downloading $jarfile...")
        download("https://github.com/paperai/pdfextract/releases/download/v0.1.3/pdfextract-0.1.3.jar", jarpath)
    end

    pdfstr = readstring(`java -classpath $jarfile PDFExtractor $path $option`)
    pdcontents = PDContent[]
    lines = split(pdfstr, "\n")
    push!(lines, "")
    for line in lines
        isempty(line) && continue
        items = Vector{String}(split(line,'\t'))
        page = parse(Int, items[1])
        content = items[2]
        if content == "TEXT"
            c = items[3]
            coords = map(i -> parse(Float64,items[i]), 4:7)
            char = PDChar(page, c, coords...)
            push!(pdcontents, char)
        elseif content == "DRAW"
            op = items[3]
            coords = map(i -> parse(Float64,items[i]), 4:length(items))
            draw = PDDraw(page, op, coords)
            push!(pdcontents, draw)
        elseif content == "IMAGE"
            coords = map(i -> parse(Float64,items[i]), 3:6)
            image = PDImage(page, coords...)
            push!(pdcontents, image)
        end
    end
    pdcontents
end

function readtext()
end

function readimage(path::String)
    Vector{PDImage}(readpdf(path,"-image"))
end
