export PDChar
export readpdftxt

using CodecZlib
import Base.Unicode

mutable struct PDChar
    page::Int
    str::String
    fcoord::Rectangle
    gcoord::Rectangle
end

istext(c::PDChar) = !isdraw(c)
isdraw(c::PDChar) = c.str[1] == '[' && c.str[end] == ']'

function Base.string(c::PDChar)
    join([t.page, t.str, t.coord...], "\t")
end

function readpdftxt(filepath::String)
    if endswith(filepath,".gz")
        lines = open(s -> readlines(GzipDecompressorStream(s)), filepath)
    else
        lines = open(readlines, filepath)
    end
    chars = PDChar[]
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[1])
        str = Unicode.normalize(items[2], :NFKC)
        if str[1] == '[' && str[end] == ']'
            fcoord = Rectangle()
            gcoord = Rectangle()
        else
            coord = map(x -> parse(Float64,x), split(items[3]," "))
            fcoord = Rectangle(coord...)
            coord = map(x -> parse(Float64,x), split(items[4]," "))
            gcoord = Rectangle(coord...)
        end
        c = PDChar(page, str, fcoord, gcoord)
        push!(chars, c)
    end
    chars
end

function saveimages(inpath::String; options=[])
    jar = downloadjar()
    command = `java -classpath $jar paperai.pdfextract.ImageExtractor $inpath $options`
    run(command)
end

function download_jar()
    version = "0.3.1"
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-$version.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v$version/pdfextract-$version.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
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
