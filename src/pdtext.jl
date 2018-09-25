export PDText
export readpdf, tokenize

using CodecZlib
import Base.Unicode

mutable struct PDText
    str::String
    children::Vector{PDText}
    page::Int
    fcoord::Rectangle
    gcoord::Rectangle
end

function PDText(children::Vector{PDText})
    @assert all(c -> c.page == children[1].page, children)
    str = join(map(c -> c.str, children))
    fcoord = merge(map(c -> c.fcoord, children))
    gcoord = merge(map(c -> c.gcoord, children))
    PDText(str, children, children[1].page, fcoord, gcoord)
end

function leaves(text::PDText)
    l = PDText[]
    function f(t::PDText)
        if isempty(t.children)
            push!(l,t)
        else
            foreach(f, t.children)
        end
    end
    f(text)
    l
end

function readpdf(filepath::String)
    if endswith(filepath, ".txt")
        lines = open(readlines, filepath)
    elseif endswith(filepath, ".pdf")
        gzfilepath = "$filepath.0-3-1.txt.gz"
        if !isfile(gzfilepath)
            jar = download_jar("0.3.1")
            run(`java -classpath $jar paperai.pdfextract.PDFExtractor $filepath`)
        end
        lines = open(s -> readlines(GzipDecompressorStream(s)), gzfilepath)
    else
        throw("File error.")
    end

    texts = PDText[]
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[1])
        str = Unicode.normalize(items[2], :NFKC)
        str[1] == '[' && str[end] == ']' && continue

        coord = map(x -> parse(Float64,x), split(items[3]," "))
        fcoord = Rectangle(coord...)
        coord = map(x -> parse(Float64,x), split(items[4]," "))
        gcoord = Rectangle(coord...)
        t = PDText(str, PDText[], page, fcoord, gcoord)
        push!(texts, t)
    end
    texts
end

function tokenize(texts::Vector{PDText})
    tokens = PDText[]
    buffer = [texts[1]]
    average = texts[1].fcoord.w
    for i = 2:length(texts)
        prev, curr = texts[i-1], texts[i]
        expected = prev.fcoord.x + prev.fcoord.w + 0.1*average
        if prev.page != curr.page || prev.fcoord.x > curr.fcoord.x || expected < curr.fcoord.x
            push!(tokens, PDText(buffer))
            buffer = [curr]
            average = curr.fcoord.w
        else
            push!(buffer, curr)
            average = (average + curr.fcoord.w) / 2
        end
    end
    isempty(buffer) || push!(tokens,PDText(buffer))
    tokens
end

function tokenize_line(texts::Vector{PDText})
end

export average_size
function average_size(texts::Vector{PDText})
    w = 0.0
    h = 0.0
    for t in texts
        w += t.fcoord.w
        h += t.fcoord.h
    end
    w /= length(texts)
    h /= length(texts)
end
