export PDDocument

mutable struct PDDocument
    texts::Vector{PDText}
    str::String
    char2text::Vector{Int}
    spans::Vector
end

function PDDocument(texts::Vector{PDText})
    str = join(map(t -> t.str, texts))
    char2text = Int[]
    for i = 1:length(texts)
        t = texts[i]
        for _ = 1:sizeof(t.str)
            push!(char2text, i)
        end
    end
    PDDocument(texts, str, char2text, [])
end

function annotate!(doc::PDDocument, str::String, label::String)
    str = replace(str, " "=>"")
    k = 1
    while true
        r = findnext(str, doc.str, k)
        r == nothing && break
        i = doc.char2text[first(r)]
        j = doc.char2text[last(r)]
        k = last(r) + 1
        push!(doc.spans, (i,j,label))
    end
end

function Base.string(doc::PDDocument)
    dict = Dict()
    spans = map(doc.spans) do (i,j,l)
        id = get!(dict, l, length(dict)+1)
        (i, j, l, id)
    end
    labels = map(doc.texts) do t
        ["O" for _ = 1:length(dict)]
    end
    for (i,j,l,id) in spans
        if i == j
            labels[i][id] = "S-$l"
        else
            labels[i][id] = "B-$l"
            labels[j][id] = "E-$l"
        end
    end
    lines = map(zip(doc.texts,labels)) do (t,l)
        strs = [t.str, string(t.page), string(t.fcoord), string(t.gcoord)]
        append!(strs, l)
        join(strs, "\t")
    end
    join(lines, "\n")
end
