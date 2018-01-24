export readpdf, readtexts, readimages, saveimages, extract

function downloadjar()
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-0.1.6.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v0.1.6/pdfextract-0.1.6.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

function readpdf(path::String; options=["-text","-bounding","-glyph","-fontName","-draw","-image"])
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
            char = PDText(page, c, xywh..., [])
            push!(pdcontents, char)
        elseif content == "DRAW"
            op = items[4]
            props = map(i -> parse(Float64,items[i]), 5:length(items))
            draw = PDDraw(page, op, props, [])
            push!(pdcontents, draw)
        elseif content == "IMAGE"
            xywh = map(i -> parse(Float64,items[i]), 4:7)
            image = PDImage(page, xywh..., [])
            push!(pdcontents, image)
        end
    end
    pdcontents
end

readtexts(path::String) = readpdf(path, options=["-text", "-bounding"])
readimages(path::String) = readpdf(path, options=["-image"])
readdraws(path::String) = readpdf(path, options=["-draw"])

function saveimages(inpath::String; options=[""])
    jar = downloadjar()
    command = `java -classpath $jar ImageExtractor $inpath $options`
    run(command)
end

function Base.write(path::String, contents::Vector{T}) where T<:PDContent
    open(path, "w") do f
        for i = 1:length(contents)
            print(f, "$i\t")
            println(f, string(contents[i]))
        end
    end
end

function extract(path::String; options=[])
    files = String[]
    if isfile(path)
        @assert endswith(path,".pdf")
        push!(files, path)
    elseif isdir(path)
        for file in readdir(path)
            endswith(file,".pdf") || continue
            println(file)
            push!(files, joinpath(path,file))
        end
    end

    for file in files
        if isempty(options)
            contents = readpdf(path)
        else
            contents = readpdf(path, options=options)
        end
        write("$path.txt", contents)
    end
end
