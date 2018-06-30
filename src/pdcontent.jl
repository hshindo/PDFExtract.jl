export PDContent
export readpdf

mutable struct PDContent
    page::Int
    op::String
    value::String
    coord::Vector{Float64}
    labels::Vector
end

function Base.string(c::PDContent)
    join([t.page, t.op, t.value, t.coord...], "\t")
end

function readpdf(filename::String)
    @assert endswith(filename, ".pdf")
    jar = download_jar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $filename`)
    contents = PDContent[]
    lines = split(pdfstr, "\n")
    for line in lines
        if isempty(line)
            page = contents[end].page
            c = PDContent(page, "TEXT", " ", Float64[])
        else
            items = split(line, '\t')
            id = parse(Int, items[1])
            page = parse(Int, items[2])
            op = items[3]
            value = items[4]
            if length(items) >= 5
                coord = map(x -> parse(Float64,x), items[5:end])
            else
                coord = Float64[]
            end
            c = PDContent(page, op, value, coord)
        end
        push!(contents, c)
    end
    contents
end

function writepdftxt(filename::String, contents::Vector{PDContent})
    open(filename, "w") do io
        for c in contents
            println(io, string(c))
        end
    end
end

function saveimages(inpath::String; options=[])
    jar = downloadjar()
    command = `java -classpath $jar ImageExtractor $inpath $options`
    run(command)
end

function download_jar()
    version = "0.2.5"
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-$version.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v$version/pdfextract-$version.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end
