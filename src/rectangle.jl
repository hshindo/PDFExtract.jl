struct Rectangle
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

function Rectangle(rects::Vector{Rectangle})
    minx, miny = rects[1].x, rects[1].y
    maxx, maxy = rects[1].x+rects[1].w, rects[1].y+rects[1].h
    for r in rects
        r.x < minx && (minx = r.x)
        r.y < miny && (miny = r.y)
        r.x+r.w > maxx && (maxx = r.x+r.w)
        r.y+r.h > maxy && (maxy = r.y+r.h)
    end
    Rectangle(minx, miny, maxx-minx, maxy-miny)
end

function Base.parse(::Type{Rectangle}, s::String)
    items = Vector{String}(split(s," "))
    @assert length(items) == 4
    xywh = map(x -> parse(Float64,x), items)
    Rectangle(xywh...)
end

Base.string(r::Rectangle) = join([r.x,r.y,r.w,r.h], " ")
