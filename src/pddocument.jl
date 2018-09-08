export PDDocument

mutable struct PDDocument
    texts::Vector{PDText}
    str::String
    spandict::Dict
end

function PDDocument(texts::Vector{PDText})
    str = join(map(t -> t.str, texts))
    PDDocument(texts, str, Dict())
end

function annotate!(doc::PDDocument, str::String, tag::String)
    str = replace(str, " "=>"")
    i = 1
    dict = doc.spandict
    while true
        r = findnext(str, doc.str, i)
        r == nothing && break
        i = last(r) + 1
        haskey(dict,tag) || (dict[tag] = [])
        push!(dict[tag], r)
    end
end

function Base.string(doc::PDDocument)
    lines = map(doc.texts) do t
        [i == 1 ? string(t,delim="\t") : "O" for i=1:length(doc.spandict)+1]
    end
    char2index = Int[]
    for i = 1:length(doc.texts)
        t = doc.texts[i]
        for _ = 1:sizeof(t.str)
            push!(char2index, i)
        end
    end
    i = 1
    for (k,v) in doc.spandict
        i = char2index[first(v)]
        j = 1
        lines[i]
        i += 1
    end
end
