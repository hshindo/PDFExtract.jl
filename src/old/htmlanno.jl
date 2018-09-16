using HttpCommon

function readpdf2(path::String)
    jar = "pdfextract-0.2.3.jar"
    pdfstr = readstring(`java -classpath $jar PDFExtractor $path`)
    tokens = String[]
    lines = split(pdfstr, "\n")
    push!(lines, "")
    for line in lines
        if isempty(line)
            push!(tokens, " ")
        else
            items = Vector{String}(split(line,'\t'))
            id = parse(Int, items[1])
            page = parse(Int, items[2])
            items[3] == "TEXT" || continue
            c = items[4]
            length(c) == 1 || (c = "*")
            push!(tokens, c)
        end
    end

    # create sentences
    sents = String[]
    words = String[]
    for t in tokens
        t == " " && isempty(words) && continue
        push!(words, t)
        if t == "."
            isempty(words) && continue
            push!(sents, join(words))
            empty!(words)
        end
    end
    sents
end

function write_xhtml(filename::String, strs::Vector{String})
    strs = map(escapeHTML, strs)
    body = join(map(s -> "<p>$s</p>\n", strs))
    xhtml = """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head></head>
    <body>
    $body
    </body>
    </html>
    """
    open(filename, "w") do f
        println(f, xhtml)
    end
end

function main(pdffile::String, dictfile::String)
    sents = readpdf(pdffile)
    dict = open(readlines, dictfile)
    # dict = map(lowercase, dict)

    offset = 0
    count = 1
    for sent in sents
        # sent = lowercase(sent)
        for word in dict
            isempty(word) && continue
            i = searchindex(sent, word)
            i == 0 && continue
            i = offset + 1
            j = i + length(word)
            anno = """
            [$count]
            type = "span"
            position = [$i, $j]
            label = "auto:solvent"
            text = "$word"
            """
            count += 1
        end
        offset += length(sent) + 1
    end


    offset = 0
    word = "cyclohexane"
    count = 1
    for sent in sents
        i = offset + 1
        j = i + 1
        data = """
        [$count]
        type = "span"
        position = [$i, $j]
        label = "auto:solvent"
        text = "cyclohexane"
        """
        println(f, data)
        #println(f, "")
        #i = searchindex(sent, word)
        #if i > 0
            #i += offset
            #j = i + length(word)
            #println("$i, $j")
        #end
        offset += length(sent) + 1
        count += 1
    end
end

filename = "Macromolecules_13_3_653-656_1980.pdf"
main(filename)
