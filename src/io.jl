export readpdf, readpdftxt, readtexts, readimages, saveimages, pdfextract

function downloadjar()
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-0.2.0.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v0.2.0/pdfextract-0.2.0.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

function readpdf(path::String; options=["-text","-bounding","-glyph","-fontName","-draw","-image"])
    jar = downloadjar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $path $options`)
    readpdfstr(pdfstr)
end

readpdftxt(path::String) = readpdfstring(open(readstring,path))

function readpdfstr(pdfstr::String)
    pdcontents = PDContent[]
    lines = split(pdfstr, "\n")
    push!(lines, "")
    for line in lines
        if isempty(line)
            push!(pdcontents, PDEmpty())
            continue
        end
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
        id = 1
        for c in contents
            if isa(c,PDEmpty)
                println(f, "")
            else
                print(f, "$id\t")
                println(f, string(c))
                id += 1
            end
        end
    end
end

function pdfextract(path::String; options=[])
    files = String[]
    if isfile(path)
        @assert endswith(path,".pdf")
        push!(files, path)
    elseif isdir(path)
        for file in readdir(path)
            endswith(file,".pdf") || continue
            push!(files, joinpath(path,file))
        end
    end

    for file in files
        try
            println(file)
            if isempty(options)
                contents = readpdf(file)
            else
                contents = readpdf(file, options=options)
            end
            write("$file.txt", contents)
        catch
            println("$file skipped.")
        end
    end
end
