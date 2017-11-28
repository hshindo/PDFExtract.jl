export PDContent, PDText, PDDraw, PDImage

abstract type PDContent end

mutable struct PDText <: PDContent
    page::Int
    c::String
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

Base.string(t::PDText) = join([t.page, "TEXT", t.c, t.x, t.y, t.w, t.h], "\t")

mutable struct PDDraw <: PDContent
    page::Int
    op::String
    props::Vector{Float64}
end

Base.string(d::PDDraw) = join([d.page, "DRAW", d.op, d.props...], "\t")

mutable struct PDImage <: PDContent
    page::Int
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

Base.string(i::PDImage) = join([i.page, "IMAGE", i.x, i.y, i.w, i.h], "\t")
