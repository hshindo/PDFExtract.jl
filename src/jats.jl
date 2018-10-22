export jats2pdf

using EzXML

function jats2pdfs(path::String)
    for dir in readdir(path)
        println(dir)
        filepath = joinpath(path, dir, dir)
        jats2pdf(filepath)
    end
end

function jats2pdf(path::String)
    xml = readxml("$path.xml")
    front = findfirst("article/front", xml)
    body = findfirst("article/body", xml)
    pdtexts = readpdf("$path.pdf")
    words = towords(pdtexts)
    lines = tolines(pdtexts)
    scripts = map(addscripts, lines)

    annos = []
    function find(xpath, node, label)
        nodes = findall(xpath, node)
        for n in nodes
            r = find(doc, nodecontent(n))
            push!(annos, (r,label))
        end

        nodes = findall(xpath, node)
        s = 1
        for n in nodes
            str = replace(nodecontent(n), " " => "")
            r = annotate!(doc, str, label, s)
            r == nothing || (s = last(r)+1)
        end
    end
    #f("front/journal-meta/journal-title-group/journal-title", "journal")
    #find("article-meta/title-group/article-title", front, "title")
    #find("article-meta/abstract", front, "abstract")
    #find("sec/title", body, "section")

    open(GzipCompressorStream,"$path.pdf.txt.gz","w") do io
        lines = toconll(doc)
        for line in lines
            write(io, line, "\n")
        end
    end
end
