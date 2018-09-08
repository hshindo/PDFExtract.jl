export readtexdir

function ssss(path::String)
    for dir in readdir(path)
        texpath, pdfpath = readtexdir(joinpath(path,dir))

    end
end

function readtexdir(dir::String)
    files = readdir(dir)
    texids = findall(f -> endswith(f,".tex"), files)
    length(texids) == 1 || return
    pdfids = findall(f -> endswith(f,".pdf"), files)
    length(pdfids) == 1 || return

    texpath = joinpath(dir, files[texids[1]])
    pdfpath = joinpath(dir, files[pdfids[1]])
    texstr = readtex(texpath)
    pdtexts = readpdf(pdfpath)
    idx2texts = PDText[]
    for t in pdtexts
        push!(t.tags, "O")
        for _ = 1:sizeof(t.str)
            push!(idx2texts, t)
        end
    end
    pdstr = join(map(t -> t.str, pdtexts))

    for m in eachmatch(r"\\section\**\{(.+)\}", texstr)
        query = replace(string(m[1]), " "=>"")
        r = findfirst(query, pdstr)
        idx2texts[first(r)].tags[1] = "B-section"
        idx2texts[last(r)].tags[1] = "E-section"
    end
    write("a.tex.out", pdtexts)
end

function readtex(path::String)
    str = String(open(read,path))
    str
end
