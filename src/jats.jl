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
    chars = map(TreeNode, pdtexts)
    words = segment_words(chars)
    lines = segment_lines(words)
    root = TreeNode("article", lines)

    str = join(map(c -> c.value.str, chars))
    str2char = TreeNode[]
    for c in chars
        for _ = 1:sizeof(c.value.str)
            push!(str2char, c)
        end
    end
    sm = StringMatch(str)

    node = findfirst("article-meta/title-group/article-title", front)
    node = findfirst("article-meta/abstract", front)
    query = replace(nodecontent(node), " "=>"")
    approxsearch(sm, query)

    #r = approxsearch(query)
    #nodes = char2str[r]
    #insert!("article-title", nodes)

    return

    for i = 1:length(words)-1
        push!(words[i], TreeNode(" "))
    end
    foreach(remove!, words)
    #foreach(remove!, lines)
    writexml("out.xml", root)

    # "front/journal-meta/journal-title-group/journal-title", "journal"
    #find("article-meta/title-group/article-title", front, "title")
    #find("article-meta/abstract", front, "abstract")
    #find("sec/title", body, "section")
end

function conllout()
    open(GzipCompressorStream,"$path.pdf.txt.gz","w") do io
        lines = toconll(doc)
        for line in lines
            write(io, line, "\n")
        end
    end
end
