export write_conll

function write_conll(dir::String)
    lines = String[]
    for file in readdir(dir)
        endswith(file, ".pdfanno") || continue
        pdffile = file[1:end-4]
        println(pdffile)
        pdffile = "$dir/$pdffile"
        try
            l = format_conll(pdffile)
            append!(lines, l)
        catch
        end
        push!(lines, "")
    end
    open("$dir.conll", "w") do io
        for line in lines
            println(io, line)
        end
    end
end

function format_conll(pdffile::String)
    chars = readpdf(pdffile)

    pdfanno = readpdfanno(pdffile * "anno")
    spans = pdfanno.spans
    label_s = "abstract_start"
    label_e = "abstract_end"
    i = findfirst(s -> s.label == label_s, spans)
    ind_s = start(spans[i].range)
    i = findfirst(s -> s.label == label_e, spans)
    ind_e = start(spans[i].range)

    texts = filter(c -> c._type == "TEXT", chars[ind_s:ind_e])
    tokens = tokenize_space(texts)
    char2tokenid = Dict()
    for i = 1:length(tokens)
        for c in tokens[i].chars
            char2tokenid[c] = i
        end
    end

    labels = ["O" for i=1:length(tokens)]
    for span in spans
        (span.label == label_s || span.label == label_e) && continue
        s = start(span.range)
        l = last(span.range)
        label = span.label
        startswith(label,"Material_") && (label = "Material")
        bid = char2tokenid[chars[s]]
        eid = char2tokenid[chars[l]]
        if bid == eid
            labels[bid] = "S-$label"
        else
            labels[bid] = "B-$label"
            labels[eid] = "E-$label"
            for i = bid+1:eid-1
                labels[i] = "I-$label"
            end
        end
    end

    lines = String[]
    buffer = []
    b = false
    for i = 1:length(tokens)
        t = tokens[i]
        l = labels[i]
        l == "O" || (b = true)
        push!(buffer, (t,l))
        if t.str[end] == '.' || i == length(tokens)
            if b
                for (_t,_l) in buffer
                    str = _t.str
                    str[end] == '.' && length(str) > 1 && (str = str[1:end-1])
                    push!(lines, "$str\t$_l")
                end
                push!(lines, "")
            end
            b = false
            empty!(buffer)
        end
    end
    lines
end
