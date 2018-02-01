export readpdf, readpdftxt, readtexts, readimages, saveimages, pdfextract

function downloadjar()
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-0.2.1.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v0.2.1/pdfextract-0.2.1.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

function readpdf(path::String)
    jar = downloadjar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $path`)
    readpdfstr(pdfstr)
end

readpdftxt(path::String) = readpdfstr(open(readstring,path))

function readpdfstr(pdfstr::String)
    contents = PDFContent[]
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
            font = parse(Rectangle, items[5])
            glyph = parse(Rectangle, items[6])
            fontname = items[7]
            t = PDFText(page, c, font, glyph, fontname, [])
            push!(contents, t)
        elseif content == "DRAW"
            op = items[4]
            props = map(i -> parse(Float64,items[i]), 5:length(items))
            draw = PDFDraw(page, op, props, [])
            push!(contents, draw)
        elseif content == "IMAGE"
            rect = parse(Rectangle, items[4])
            image = PDFImage(page, rect, [])
            push!(contents, image)
        end
    end
    contents
end

function saveimages(inpath::String; options=[])
    jar = downloadjar()
    command = `java -classpath $jar ImageExtractor $inpath $options`
    run(command)
end

#=
function Base.write(path::String, contents::Vector{T}) where T<:PDFContent
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
=#

function pdfextract(path::String)
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
            jar = downloadjar()
            pdftxt = readstring(`java -classpath $jar PDFExtractor $file`)
            open("$file.txt", "w") do f
                print(f, pdftxt)
            end
        catch
            println("$file skipped.")
        end
    end
end
