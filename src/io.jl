export readpdf, readtext, readimage, extract_images

function downloadjar()
    jarfile = realpath(joinpath(@__DIR__,"pdfextract-0.1.4.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v0.1.4/pdfextract-0.1.4.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

function readpdf(path::String, option="-text -bounding -draw -image")
    jar = getjar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $path $option`)
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
            xywh = map(i -> parse(Float64,items[i]), 4:7)
            char = PDChar(page, c, xywh...)
            push!(pdcontents, char)
        elseif content == "DRAW"
            op = items[3]
            coords = map(i -> parse(Float64,items[i]), 4:length(items))
            draw = PDDraw(page, op, coords)
            push!(pdcontents, draw)
        elseif content == "IMAGE"
            xywh = map(i -> parse(Float64,items[i]), 3:6)
            image = PDImage(page, xywh...)
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

function extract_images(inpath::String; o="", dpi="")
    jar = downloadjar()
    command = `java -classpath $jar ImageExtractor $inpath`
    isempty(o) || (command = `$command -o $o`)
    isempty(dpi) || (command = `$command -dpi $dpi`)
    run(command)
end
