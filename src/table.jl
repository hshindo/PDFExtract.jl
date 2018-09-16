export parse_table

function parse_table(texts::Vector{PDText})
    tokens = tokenize(texts)
    for t in tokens
        empty!(t.children)
    end
    rows = parse_rows(tokens)
    columns = parse_columns(tokens)
    cells = Array{Any}(undef, length(rows), length(columns))
    for t in tokens
        i = dict_r[t]
        j = dict_c[t]
        isassigned(cells,i,j) || (cells[i,j] = [])
        push!(cells[i,j], t)
    end

    # xmlstr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    trs = String[]
    for i = 1:length(rows)
        tds = String[]
        [[] for _ = 1:length(columns)]
        for t in rows[i]
            j = coldict[t]
        end

        for j = 1:length(tokens)
            items = String[]
            for c in rows[i]
                push!(items, c.str)
            end
            td = "<td>" * join(items," ") * "</td>"
            push!(tds, td)
        end
        tr = "<tr>" * join(tds) * "</tr>"
        push!(trs, tr)
    end
    join(trs, "\n") |> println
end

function parse_rows(texts::Vector{PDText})
    sorted = sort(texts, by=t->t.fcoord.y)
    rows = [texts[1]]
    for i = 2:length(texts)
        t = sorted[i]
        r = rows[end]
        if t.fcoord.y <= r.fcoord.y+r.fcoord.h
            rows[end] = PDText([r,t])
        else
            push!(rows, t)
        end
    end
    dict = Dict()
    for i = length(rows)
        leaves(rows[i])
    end
    map(leaves, rows)
end

function parse_columns(texts::Vector{PDText})
    sorted = sort(texts, by=t->t.fcoord.x)
    columns = [texts[1]]
    for i = 2:length(texts)
        t = sorted[i]
        c = columns[end]
        if t.fcoord.x <= c.fcoord.x+c.fcoord.w
            columns[end] = PDText([c,t])
        else
            push!(columns, t)
        end
    end
    map(leaves, columns)
end

function toxhtml()

end
