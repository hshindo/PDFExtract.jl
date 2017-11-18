export PDContent, PDChar, PDDraw, PDImage

abstract type PDContent end

mutable struct PDText <: PDContent
    page::Int
    c::String
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

mutable struct PDDraw <: PDContent
    page::Int
    op::String
    props::Vector{Float64}
end

mutable struct PDImage <: PDContent
    page::Int
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end
