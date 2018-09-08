export readjats

import EzXML

function readjats(filepath::String)
    article = root(readxml(filepath))
    nodename(article) == "article" || throw("No article.")

    journal = findfirst(article, "front/journal-meta/journal-title-group/journal-title") |> nodecontent
    title = findfirst(article, "front/article-meta/title-group/article-title") |> nodecontent
    search!(title, pdf)
end

function aaa()
    nodename(xml_article) == "article" || throw("No article.")
    countelements(xml_article) < 3 && throw("#xml elements < 3")

    article = Tree("article")
    xml_front = findfirst(xml_article, "front")
    push!(article, parse_front(xml_front))

    body = findfirst(xml_article, "body")
    push!(article, parse_body(body))

    back = find(xml_article, "back")
    if !isempty(back)
        push!(article, parse_back(back[1]))
    end

    push!(article, Tree("floats-group"))
    append!(article[end], findfloats(article))
    floats = find(xml_article, "floats-group")
    if !isempty(floats)
        append!(article[end], parse_body(floats[1]).children)
    end
    isempty(article[end]) && deleteat!(article,length(article)) # no floats

    maths = findall(article, "math")
    for i = 1:length(maths)
        math = maths[i]
        mathml = root(parsexml(toxml(math)))
        normalize_mathml!(mathml)
        replace!(math, convert(Tree,mathml))
    end

    # tokenize_word!(article)
    postprocess!(article)
    nonrecursive!(article)
    article
end

function align(pdftxt::String, xmlfile::String)
    pdchars = readpdftxt(pdftxt)
    #pdchars = filter(istext, pdchars)
    #iddict = Dict{String,Int}()
    #pdids = map(x -> get!(iddict,x.c,length(iddict)+1), pdchars)

    xml = readjats(xmlfile)
    xmltree = xmltree[findfirst(c -> c.name == "body", xmltree.children)]
    tokenize!(xmltree)
    xmlchars = findall(isempty, xmltree)
    xmlids = map(c -> get!(iddict,string(c.name),length(iddict)+1), xmlchars)
    pairs = lcsmatch(pdids, xmlids)
end
