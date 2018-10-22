mutable struct Document
    texts::Vector{PDText}
    str::String
    char2text::Vector{Int}
end

function Document(filepath::String)
    if endswith(filepath, ".txt")
        lines = open(readlines, filepath)
    elseif endswith(filepath, ".pdf")
        gzfilepath = "$filepath.0-3-1.txt.gz"
        if !isfile(gzfilepath)
            jar = download_jar("0.3.1")
            run(`java -classpath $jar paperai.pdfextract.PDFExtractor $filepath`)
        end
        lines = open(s -> readlines(GzipDecompressorStream(s)), gzfilepath)
    else
        throw("File error.")
    end

    texts = PDText[]
    for line in lines
        isempty(line) && continue
        items = split(line, '\t')
        page = parse(Int, items[1])
        str = Unicode.normalize(items[2], :NFKC)
        str[1] == '[' && str[end] == ']' && continue

        coord = map(x -> parse(Float64,x), split(items[3]," "))
        fcoord = Rectangle(coord...)
        coord = map(x -> parse(Float64,x), split(items[4]," "))
        gcoord = Rectangle(coord...)
        t = PDText(str, PDText[], page, fcoord, gcoord)
        push!(texts, t)
    end
    Document(texts)
end

function Document(texts::Vector{PDText})
    str = join(map(t -> t.str, texts))
    char2text = Int[]
    for i = 1:length(texts)
        t = texts[i]
        for _ = 1:sizeof(t.str)
            push!(char2text, i)
        end
    end
    Document(texts, str, char2text)
end

function toconll(doc::Document, annos::Vector)
    dict = Dict()
    annos = map(annos) do (i,j,label)
        id = get!(dict, label, length(dict)+1)
        (i, j, label, id)
    end
    labels = map(doc.texts) do t
        ["O" for _ = 1:length(dict)]
    end
    for (i,j,label,id) in annos
        if i == j
            labels[i][id] = "S-$label"
        else
            labels[i][id] = "B-$label"
            for k = i+1:j-1
                labels[k][id] = "I-$label"
            end
            labels[j][id] = "E-$label"
        end
    end
    lines = map(zip(doc.texts,labels)) do (t,l)
        strs = [t.str, string(t.page), string(t.fcoord), string(t.gcoord), l...]
        join(strs, "\t")
    end
    collect(lines)
end
