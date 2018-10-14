export PDTable

mutable struct PDTable
    data::Matrix{Vector{PDText}}
    caption::String
end

Base.size(t::PDTable, i::Int) = size(t.data, i)
Base.getindex(t::PDTable, i::Int, j::Int) = t.data[i,j]

function PDTable(texts::Vector{PDText}, caption)
    tokens = tokenize(texts)
    rows = parse_rows(tokens)
    columns = parse_columns(tokens)
    dict_col = Dict()
    for i = 1:length(columns)
        for c in columns[i]
            dict_col[c] = i
        end
    end

    data = [PDText[] for i=1:length(rows), j=1:length(columns)]
    for i = 1:length(rows)
        for t in rows[i]
            j = dict_col[t]
            push!(data[i,j], t)
        end
    end
    PDTable(data, caption)
end

function Base.string(table::PDTable)
    function escape(s::String)
        s = replace(s, "&"=>"&amp;")
        s = replace(s, "\""=>"&quot;")
        s = replace(s, "'"=>"&#39;")
        s = replace(s, "<"=>"&lt;")
        s = replace(s, ">"=>"&gt;")
        s
    end
    trs = map(1:size(table,1)) do i
        tds = map(1:size(table,2)) do j
            texts = table[i,j]
            if isempty(texts)
                "<td/>"
            else
                s = join(map(t -> t.str, texts), " ")
                "<td>$(escape(s))</td>"
            end
        end
        tr = join(tds)
        "<tr>$tr</tr>"
    end
    caption = "<caption>$(escape(table.caption))</caption>"
    join(["<table>",caption,trs...,"</table>"], "\n")
end

function toxml()
    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
end

function toxhtml(tables::Vector{PDTable})
    s = join(map(string,tables), "\n<br/>")
    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
     "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
    <style type="text/css">
    table{
        border-collapse:collapse;
        margin:0 auto;
    }
    td,th{
        border-top:1px solid #666;
        padding:10px;
    }
    tr:last-child td,
    tr:last-child th{
        border-bottom:1px solid #666;
    }
    </style>
    </head>
    <body>
    $s
    </body>
    </html>
    """
end

function parse_rows(texts::Vector{PDText})
    sorted = sort(texts, by=t->t.fcoord.y)
    rows = [[sorted[1]]]
    rect = sorted[1].fcoord
    for i = 2:length(sorted)
        t = sorted[i]
        if t.fcoord.y <= rect.y + rect.h
            push!(rows[end], t)
            rect = merge(rect, t.fcoord)
        else
            push!(rows, [t])
            rect = t.fcoord
        end
    end
    for r in rows
        sort!(r, by=t->t.fcoord.x)
    end
    # remove header and footer
    for i = 1:length(rows)
        rect = merge(map(r -> r.fcoord, rows[i]))
    end
    rows
end

function parse_columns(texts::Vector{PDText})
    sorted = sort(texts, by=t->t.fcoord.x)
    columns = [[sorted[1]]]
    rect = sorted[1].fcoord
    for i = 2:length(sorted)
        t = sorted[i]
        if t.fcoord.x <= rect.x + rect.w
            push!(columns[end], t)
            rect = merge(rect, t.fcoord)
        else
            push!(columns, [t])
            rect = t.fcoord
        end
    end
    for c in columns
        sort!(c, by=t->t.fcoord.y)
    end
    columns
end
