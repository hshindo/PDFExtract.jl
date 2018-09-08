export PDToken
export tokenize_space

mutable struct PDToken
    data
    children::Vector{PDToken}
    page::Int
    fcoord::Rectangle
    gcoord::Rectangle
end

function PDToken(chars::Vector{PDChar})
    str = join(map(c -> c.str, chars))
    fcoord = merge(map(c -> c.fcoord, chars))
    gcoord = merge(map(c -> c.gcoord, chars))
    PDToken(chars, str, fcoord, gcoord)
end

function tokenize_space(chars::Vector{PDChar})
    tokens = PDToken[]
    buffer = [chars[1]]
    average = chars[1].fcoord.w
    for i = 2:length(chars)
        prev, curr = chars[i-1], chars[i]
        expected = prev.fcoord.x + prev.fcoord.w + 0.3*average
        if prev.page != curr.page || prev.fcoord.x > curr.fcoord.x || expected < curr.fcoord.x
            push!(tokens, PDToken(buffer))
            buffer = [curr]
            average = curr.fcoord.w
        else
            push!(buffer, curr)
            average = (average + curr.fcoord.w) / 2
        end
    end
    isempty(buffer) || push!(tokens,PDToken(buffer))
    tokens
end

function writepdftxt(filename::String, tokens::Vector{PDToken})
    open(filename, "w") do io
        for t in tokens
            println(io, string(t))
        end
    end
end

export maketable
function maketable(chars::Vector{PDChar})
    tokens = tokenize_space(chars)
    maketable(tokens)
end

function maketable(tokens::Vector{PDToken})
    sorted = sort(tokens, by=t->t.gcoord.x)
    groups = [tokens[1]]
    for i = 2:length(tokens)
        t = sorted[i]
        prev = groups[end]
        if t.gcoord.x <= prev.gcoord.x+prev.gcoord.w
            push!(prev, t)
        else
            push!(groups, t)
        end
    end
end
