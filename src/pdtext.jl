export PDText
export readpdf, tokenize

using CodecZlib
import Base.Unicode

mutable struct PDText
    str::String
    page::Int
    fcoord::Rectangle
    gcoord::Rectangle
end

function PDText(texts::Vector{PDText})
    @assert !isempty(texts)
    @assert all(t -> t.page == texts[1].page, texts)
    str = join(map(t -> t.str, texts))
    fcoord = merge(map(t -> t.fcoord, texts))
    gcoord = merge(map(t -> t.gcoord, texts))
    PDText(str, texts[1].page, fcoord, gcoord)
end

Base.string(t::PDText) = t.str

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
        t = PDText(str, page, fcoord, gcoord)
        push!(texts, t)
    end
    texts
end

function segment_words(chars::Vector{TreeNode})
    words = TreeNode[]
    buffer = [chars[1]]
    average = chars[1].value.fcoord.w
    for i = 2:length(chars)
        prev, curr = chars[i-1].value, chars[i].value
        expected = prev.fcoord.x + prev.fcoord.w + 0.3*average
        if prev.page != curr.page || prev.fcoord.x > curr.fcoord.x || expected < curr.fcoord.x
            w = PDText(map(x -> x.value, buffer))
            push!(words, TreeNode(w,buffer))
            buffer = [chars[i]]
            average = curr.fcoord.w
        else
            push!(buffer, chars[i])
            average = (average + curr.fcoord.w) / 2
        end
    end
    if !isempty(buffer)
        w = PDText(map(x -> x.value, buffer))
        push!(words, TreeNode(w,buffer))
    end
    words
end

function segment_lines(words::Vector{TreeNode})
    lines = TreeNode[]
    buffer = [words[1]]
    for i = 2:length(words)
        word = words[i]
        prev = buffer[end].value
        curr = word.value
        if prev.page != curr.page || (prev.gcoord.y-prev.gcoord.h) > curr.gcoord.y || (curr.gcoord.y-curr.gcoord.h) > prev.gcoord.y
            push!(lines, TreeNode("line",buffer))
            buffer = [word]
        else
            push!(buffer, word)
        end
    end
    isempty(buffer) || push!(lines,TreeNode("line",buffer))
    lines
end

function addscripts!(line::TreeNode)
    chars = leaves(line)
    prev = chars[1].value
    for i = 2:length(chars)
        c = chars[i]
        curr = c.value
        if curr.fcoord.y < prev.fcoord.y - 1
            i = parentindex(c)
            p = c.parent
            deleteat!(p, i)
            insert!(p, i, TreeNode("sup",c))
        elseif curr.fcoord.y > prev.fcoord.y + 1
            i = parentindex(c)
            p = c.parent
            deleteat!(p, i)
            insert!(p, i, TreeNode("sub",c))
        else
            prev = curr
        end
    end
end

#=
function segment_words(texts::Vector{PDText})
    words = Vector{PDText}[]
    buffer = [texts[1]]
    average = texts[1].fcoord.w
    for i = 2:length(texts)
        prev, curr = texts[i-1], texts[i]
        expected = prev.fcoord.x + prev.fcoord.w + 0.3*average
        if prev.page != curr.page || prev.fcoord.x > curr.fcoord.x || expected < curr.fcoord.x
            push!(words, buffer)
            buffer = [curr]
            average = curr.fcoord.w
        else
            push!(buffer, curr)
            average = (average + curr.fcoord.w) / 2
        end
    end
    isempty(buffer) || push!(words,buffer)
    words
end

function segment_lines(texts::Vector{PDText})
    lines = Vector{PDText}[]
    buffer = [texts[1]]
    for i = 2:length(texts)
        t = texts[i]
        prev, curr = texts[i-1], texts[i]
        if prev.page != curr.page || prev.fcoord.x >= curr.fcoord.x
            push!(lines, buffer)
            buffer = [curr]
        else
            push!(buffer, curr)
        end
    end
    isempty(buffer) || push!(lines,buffer)
    lines
end
=#
