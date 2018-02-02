export PDFAnno, SpanAnno, RelationAnno
export todict

abstract type PDFAnno end

mutable struct SpanAnno <: PDFAnno
    page::Int
    position::Vector{Rectangle}
    label::String
    text::String
end

mutable struct RelationAnno <: PDFAnno
    dir::String
    spans::Vector{SpanAnno}
    label::String
end

function todict(annos::Vector{T}) where T<:PDFAnno
    iddict = ObjectIdDict()
    foreach(annos) do a
        get!(iddict, a, length(iddict)+1)
    end

    dict = Dict()
    for a in annos
        id = string(iddict[a])
        if isa(a, SpanAnno)
            dict[id] = Dict(
                "type" => "span",
                "page" => a.page,
                "position" => map(p -> [string(p.x),string(p.y),string(p.w),string(p.h)], a.position),
                "label" => a.label,
                "text" => a.text
            )
        elseif isa(a, RelationAnno)
            dict[id] = Dict(
                "dir" => a.dir,
                "ids" => map(s -> string(iddict[s]), a.spans),
                "label" => a.label
            )
        end
    end
    dict
end
