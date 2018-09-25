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

    texts = readpdf("$path.pdf")
    texts = tokenize(texts)
    doc = PDDocument(texts)
    function f(xpath, node, label)
        nodes = findall(xpath, node)
        s = 1
        for n in nodes
            str = replace(nodecontent(n), " " => "")
            r = annotate!(doc, str, label, s)
            r == nothing || (s = last(r)+1)
        end
    end
    #f("front/journal-meta/journal-title-group/journal-title", "journal")
    f("article-meta/title-group/article-title", front, "title")
    f("article-meta/abstract", front, "abstract")
    f("sec/title", body, "section")

    open(GzipCompressorStream,"$path.pdf.txt.gz","w") do io
        lines = toconll(doc)
        for line in lines
            write(io, line, "\n")
        end
    end
end
