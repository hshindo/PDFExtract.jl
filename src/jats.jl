export jats2pdf

using EzXML

function jats2pdf(jatspath::String, pdfpath::String)
    article = root(readxml(jatspath))
    nodename(article) == "article" || return

    doc = PDDocument(readpdf(pdfpath))
    f(xpath) = nodecontent(findfirst(xpath,article))
    annotate!(doc, f("front/journal-meta/journal-title-group/journal-title"), "journal")
    annotate!(doc, f("front/article-meta/title-group/article-title"), "title")
    annotate!(doc, f("front/article-meta/abstract"), "article")
    open("a.out","w") do f
        println(f, string(doc))
    end
end

using Base.Filesystem
function mvjats(path::String)
    for file in readdir(path)
        endswith(file,".pdf") || continue
        pdffile = file
        xmlfile = file[1:end-4] * ".xml"
        isfile(joinpath(path,xmlfile)) || continue

        dirpath = joinpath(path, file[1:end-4])
        isdir(dirpath) || mkdir(dirpath)
        mv(joinpath(path,pdffile), joinpath(dirpath,pdffile))
        sleep(0.1)
        mv(joinpath(path,xmlfile), joinpath(dirpath,xmlfile))
        sleep(0.1)
    end
end
