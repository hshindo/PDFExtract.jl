export readpdf, readtext, readimage, saveimages

using BinDeps

function downloadjar()
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-0.1.6.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v0.1.6/pdfextract-0.1.6.jar"
        println("Downloading $url")
        #download(url, jarfile)
        run(download_cmd(url, jarfile))
    end
    jarfile
end

function readpdf(path::String; options=["-text","-bounding"])
    jar = downloadjar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $path $options`)
    pdcontents = PDContent[]
    lines = split(pdfstr, "\n")
    push!(lines, "")
    for line in lines
        isempty(line) && continue
        items = Vector{String}(split(line,'\t'))
        id = parse(Int, items[1])
        page = parse(Int, items[2])
        content = items[3]
        if content == "TEXT"
            c = items[4]
            xywh = map(i -> parse(Float64,items[i]), 5:8)
            char = PDText(page, c, xywh...)
            push!(pdcontents, char)
        elseif content == "DRAW"
            op = items[4]
            props = map(i -> parse(Float64,items[i]), 5:length(items))
            draw = PDDraw(page, op, props)
            push!(pdcontents, draw)
        elseif content == "IMAGE"
            xywh = map(i -> parse(Float64,items[i]), 4:7)
            image = PDImage(page, xywh...)
            push!(pdcontents, image)
        end
    end
    pdcontents
end

readtexts(path::String) = readpdf(path, options=["-text", "-bounding"])

function saveimages(inpath::String; options=[""])
    jar = downloadjar()
    command = `java -classpath $jar ImageExtractor $inpath $options`
    run(command)
end
