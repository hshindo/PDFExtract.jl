export PDChar, PDToken
export readpdf, tokenize_space

using CodecZlib

mutable struct PDChar
    page::Int
    str::String
    coord::Vector{Float64}
end

istext(c::PDChar) = !isdraw(c)
isdraw(c::PDChar) = c.str[1] == '[' && c.str[end] == ']'

function Base.string(c::PDChar)
    join([t.page, t.str, t.coord...], "\t")
end

mutable struct PDToken
    chars::Vector{PDChar}
    str::String
end

function PDToken(chars::Vector{PDChar})
    str = join(map(c -> c.str, chars))
    PDToken(chars, str)
end

function readpdf_v024(filename::String)
    @assert endswith(filename, ".pdf")
    jar = download_jar()
    pdfstr = readstring(`java -classpath $jar PDFExtractor $filename`)
    chars = PDChar[]
    lines = split(pdfstr, "\n")
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[2])
        _type = items[3]
        str = normalize_string(items[4], :NFKC)
        if length(items) > 4
            coord = map(x -> parse(Float64,x), split(items[5]," "))
        else
            coord = Float64[]
        end
        c = PDChar(page, _type, str, coord)
        push!(chars, c)
    end
    chars
end

function readpdf(filename::String)
    @assert endswith(filename, ".pdf")
    jar = download_jar()
    pdfstr = readstring(`java -classpath $jar paperai.pdfextract.PDFExtractor $filename -glyph`)
    chars = PDChar[]
    lines = split(pdfstr, "\n")
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[1])
        str = normalize_string(items[2], :NFKC)
        coord = map(x -> parse(Float64,x), split(items[3]," "))
        c = PDChar(page, str, coord)
        push!(chars, c)
    end
    chars
end

function readpdftxt(filepath::String)
    chars = PDChar[]
    if endswith(filepath,".gz")
        lines = open(s -> readlines(GzipDecompressorStream(s)), path)
    else
        lines = open(readlines, filepath)
    end
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[1])
        str = normalize_string(items[2], :NFKC)
        coord = map(x -> parse(Float64,x), split(items[3]," "))
        c = PDChar(page, str, coord)
        push!(chars, c)
    end
    chars
end

function tokenize_space(chars::Vector{PDChar})
    tokens = PDToken[]
    buffer = [chars[1]]
    average = chars[1].coord[3]
    for i = 2:length(chars)
        prev, curr = chars[i-1], chars[i]
        expected = prev.coord[1] + prev.coord[3] + 0.3average
        if prev.page != curr.page || prev.coord[1] > curr.coord[1] || expected < curr.coord[1]
            push!(tokens, PDToken(buffer))
            buffer = [curr]
            average = curr.coord[3]
        else
            push!(buffer, curr)
            average = (average + curr.coord[3]) / 2
        end
    end
    isempty(buffer) || push!(tokens,PDToken(buffer))
    tokens
end

function writepdftxt(filename::String, tokens::Vector{PDToken})
    open(filename, "w") do io
        for t in tokens
            println(io, string(t))
        end
    end
end

function saveimages(inpath::String; options=[])
    jar = downloadjar()
    command = `java -classpath $jar paperai.pdfextract.ImageExtractor $inpath $options`
    run(command)
end

function download_jar()
    version = "0.3.0"
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-$version.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v$version/pdfextract-$version.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end
