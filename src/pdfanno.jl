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
    dir::String
    spans::Vector{PDSpan}
    label::String
end

function readpdfanno(filename::String)
    dict = TOML.parsefile(filename)
    for (k,v) in dict
    end
end
