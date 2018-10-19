mutable struct Document
    texts::Vector{PDText}
    str::String
    char2text::Vector{Int}
end

function Document()
    str = join(map(t -> t.str, texts))
    char2text = Int[]
    for i = 1:length(texts)
        t = texts[i]
        for _ = 1:sizeof(t.str)
            push!(char2text, i)
        end
    end
    Document(texts, str, char2text)
end

function Base.findall(doc::Document, query::String, start::Int=1)
    q = replace(query, " "=>"")
    r1 = findnext(q[1:10], doc.str, start)
    r1 == nothing && return
    r2 = findnext(q[end-9:end], doc.str, start)
    r2 == nothing && return
    
end

function toconll(doc::Document, annos::Vector)
    dict = Dict()
    annos = map(annos) do (i,j,label)
        id = get!(dict, label, length(dict)+1)
        (i, j, label, id)
    end
    labels = map(doc.texts) do t
        ["O" for _ = 1:length(dict)]
    end
    for (i,j,label,id) in annos
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
