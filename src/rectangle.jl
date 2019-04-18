struct Rectangle
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

Rectangle() = Rectangle(0.0, 0.0, 0.0, 0.0)

function Base.parse(::Type{Rectangle}, s::String)
    items = Vector{String}(split(s," "))
    @assert length(items) == 4
    xywh = map(x -> parse(Float64,x), items)
    Rectangle(xywh...)
end

Base.string(r::Rectangle) = join([r.x,r.y,r.w,r.h], " ")

function contains(r1::Rectangle, r2::Rectangle)
    r1.x <= r2.x && r1.x+r1.w >= r2.x+r2.w && r1.y <= r2.y && r1.y+r1.h >= r2.y+r2.h
end

function overlaps(r1::Rectangle, r2::Rectangle)
    r1.x < r2.x+r2.w && r2.x < r1.x+r1.w && r1.y < r2.y+r2.h && r2.y < r1.y+r1.h
end

function merge(rects::Vector{Rectangle})
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
merge(rects::Rectangle...) = merge([rects...])
