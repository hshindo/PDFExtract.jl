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

function Base.findfirst(doc::Document, query::String, start::Int=1)
    r = findnext(query, doc.str, start)
    if r != nothing
        i = doc.char2text[first(r)]
        j = doc.char2text[last(r)]
    end
    r
end
