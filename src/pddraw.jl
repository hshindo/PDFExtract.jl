mutable struct PDDraw <: PDContent
    page::Int
    op::String
    coords::Vector{Float64}
end
