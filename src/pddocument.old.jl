export PDDocument

mutable struct PDDocument
    texts::Vector{PDText}
    str::String
    char2text::Vector{Int}
    annotations::Vector
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

function annotate!(doc::PDDocument, str::String, label::String, start::Int=1)
    r = findnext(str, doc.str, start)
    if r != nothing
        i = doc.char2text[first(r)]
        j = doc.char2text[last(r)]
        push!(doc.annotations, (i,j,label))
    end
    r
end

function toconll(doc::PDDocument)
    dict = Dict()
    annotations = map(doc.annotations) do (i,j,label)
        id = get!(dict, label, length(dict)+1)
        (i, j, label, id)
    end
    labels = map(doc.texts) do t
        ["O" for _ = 1:length(dict)]
    end
    for (i,j,label,id) in annotations
        if i == j
            labels[i][id] = "S-$label"
        else
            labels[i][id] = "B-$label"
            for k = i+1:j-1
                labels[k][id] = "I-$label"
            end
            labels[j][id] = "E-$label"
        end
    end
    lines = map(zip(doc.texts,labels)) do (t,l)
        strs = [t.str, string(t.page), string(t.fcoord), string(t.gcoord), l...]
        join(strs, "\t")
    end
    collect(lines)
end
