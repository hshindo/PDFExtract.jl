export pdf2xml
using JSON

mutable struct DeepFigure
end

function read_deepfigure(path::String)
end

function extract(texts::Vector{PDText}, page::Int, frect::Rectangle, crect::Rectangle)
    range = 0:0
    offset = 1
    while true
        i = findnext(texts,offset) do t
            t.page == page && contains(frect,t.fcoord) && !contains(crect,t.fcoord)
        end
        i == nothing && break
        j = findnext(texts, i) do t
            t.page == page && (!contains(frect,t.fcoord) || contains(crect,t.fcoord))
        end
        j -= 1
        length(i:j) > length(range) && (range = i:j)
        offset = j + 1
    end
    texts[range]
end

function pdf2xml(pdfpath::String)
    texts = readpdf(pdfpath)

    jsonpath = pdfpath[1:end-4] * "deepfigures-results.json"
    dict = JSON.parsefile(jsonpath)
    tables = filter(x -> x["figure_type"] == "Table", dict["figures"])
    pdtables = PDTable[]
    for t in tables
        page = t["page"] + 1
        caption = t["caption_text"]
        c = 1.38888888889
        b = t["figure_boundary"]
        x1, x2, y1, y2 = b["x1"], b["x2"], b["y1"], b["y2"]
        frect = Rectangle(x1/c, y1/c, (x2-x1)/c, (y2-y1)/c)

        b = t["caption_boundary"]
        x1, x2, y1, y2 = b["x1"], b["x2"], b["y1"], b["y2"]
        crect = Rectangle(x1/c, y1/c, (x2-x1)/c, (y2-y1)/c)

        tabletexts = extract(texts, page, frect, crect)
        table = PDTable(tabletexts, caption)
        push!(pdtables, table)
    end
    xhtml = toxhtml(pdtables)
    open("$pdfpath.xhtml","w") do io
        println(io, xhtml)
    end

    #table = PDTable(texts)
    #xhtml = toxhtml(table)

    #r = Rectangle
    #i1 = findfirst(t -> contains(r.fcoord,t.fcoord), texts)
    #i2 = findfirst(t)
    #tablerange = texts[i1:i2]
end
