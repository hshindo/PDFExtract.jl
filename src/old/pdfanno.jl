using TOML
export PDSpan, PDRelation
export readpdfanno

mutable struct PDSpan
    page::Int
    range::Range
    label::String
    text::String
end

mutable struct PDRelation
    head::String
    tail::String
    label::String
end

mutable struct PDFAnno
    spans::Vector{PDSpan}
end

function readpdfanno(filename::String)
    dict = TOML.parsefile(filename)
    if haskey(dict, "spans")
        spans = map(dict["spans"]) do d
            r = d["textrange"]
            PDSpan(d["page"], r[1]:r[2], d["label"], d["text"])
        end
    else
        spans = PDSpan[]
    end
    PDFAnno(spans)
end
