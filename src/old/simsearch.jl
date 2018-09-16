using EzXML

function aasearch(filename::String)
    pdf = readpdf("$filename.pdf")
    xml = readxml("$filename.xml")
    tree
    leaves = filter(isleaf, tree)
    for leaf in leaves
        leaf.data
    end
end

function simsearch(doc::Vector{PDContent}, query::String)

end

function featvec()
end

export dictmatch
function dictmatch!(pdf::Vector{PDContent}, dictfile::String)
    patterns = Regex[]
    for line in open(readlines, dictfile)
        isempty(line) && continue
        if startswith(line,"/") && endswith(line,"/")
            push!(patterns, Regex(line[2:end-1]))
        else

        end
    end

    text = join(map(c -> c.value, pdf))
    for p in patterns
        for m in eachmatch(p, text)
            println(m.offset)
        end
    end
    pdf
end
