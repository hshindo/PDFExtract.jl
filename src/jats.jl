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
    article = root(readxml("$path.xml"))
    nodename(article) == "article" || return

    texts = readpdf("$path.pdf")
    dict = Dict()
    textids = map(texts) do t
        get!(dict, t.str, length(dict))
    end
    sa = SuffixArray(textids, length(dict))

    spans = [] # (i,j,label)
    firstcontent(xpath) = nodecontent(findfirst(xpath,article))
    c = firstcontent("")
    span = prefixsearch(sa, c)
    push!(spans, (span,"journal"))

    #=
    doc = PDDocument(readpdf("$path.pdf"))
    f(xpath) = nodecontent(findfirst(xpath,article))
    annotate!(doc, f("front/journal-meta/journal-title-group/journal-title"), "journal")
    annotate!(doc, f("front/article-meta/title-group/article-title"), "title")
    annotate!(doc, f("front/article-meta/abstract"), "abstract")
    open(GzipCompressorStream,"$path.pdf.txt.gz","w") do s
        write(s, string(doc))
    end
    =#
end
