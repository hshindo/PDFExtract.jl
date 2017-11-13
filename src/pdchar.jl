mutable struct PDChar <: PDContent
    page::Int
    c::String
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end
