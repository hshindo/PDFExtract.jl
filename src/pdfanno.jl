abstract type PDFAnno end

mutable struct SpanAnno <: PDFAnno
    id::String
    page::Int
    position::Vector{Rectangle}
    label::String
    text::String
end

function todict(span::SpanAnno)
    Dict(
        "type" => "span",
        "page" => span.page,
        "position" => map(p -> String[p.x,p.y,p.w,p.h], span.position),
        "label" => span.label,
        "text" => span.text
    )
end

mutable struct RelationAnno <: PDFAnno
    id::String
    dir::String
    ids::Vector{String}
    label::String
end

function todict(rel::RelationAnno)
    Dict(
        "dir" => rel.dir,
        "ids" => rel.ids,
        "label" => rel.label
    )
end

function todict(annos::Vector{T}) where T<:PDFAnno
    dict = Dict()
    for a in annos
        dict[a.id] = todict(a)
    end
    dict
end
