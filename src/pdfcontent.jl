export PDFContent, PDFText, PDFDraw, PDFImage

abstract type PDFContent end

mutable struct PDFText <: PDFContent
    page::Int
    c::String
    font::Rectangle
    glyph::Rectangle
    fontname::String
    tags::Vector
end

function Base.string(t::PDFText)
    join([t.page, "TEXT", t.c, t.font, t.glyph, t.fontname, t.tags...], "\t")
end

mutable struct PDFDraw <: PDFContent
    page::Int
    op::String
    props::Vector{Float64}
    tags::Vector
end

Base.string(d::PDFDraw) = join([d.page, "DRAW", d.op, d.props..., d.tags...], "\t")


mutable struct PDFImage <: PDFContent
    page::Int
    rect::Rectangle
    tags::Vector
end

Base.string(i::PDFImage) = join([i.page, "IMAGE", i.rect, i.tags...], "\t")
