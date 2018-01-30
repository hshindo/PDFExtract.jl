export PDContent, PDEmpty, PDText, PDDraw, PDImage

abstract type PDContent end

struct PDEmpty <: PDContent
end

mutable struct PDText <: PDContent
    page::Int
    c::String
    x::Float64
    y::Float64
    w::Float64
    h::Float64
    tags::Vector
end

Base.string(t::PDText) = join([t.page, "TEXT", t.c, t.x, t.y, t.w, t.h, t.tags...], "\t")


mutable struct PDDraw <: PDContent
    page::Int
    op::String
    props::Vector{Float64}
    tags::Vector
end

Base.string(d::PDDraw) = join([d.page, "DRAW", d.op, d.props..., d.tags...], "\t")


mutable struct PDImage <: PDContent
    page::Int
    x::Float64
    y::Float64
    w::Float64
    h::Float64
    tags::Vector
end

Base.string(i::PDImage) = join([i.page, "IMAGE", i.x, i.y, i.w, i.h, i.tags...], "\t")

function toxml(contents::Vector{T}) where T<:PDContent

end
