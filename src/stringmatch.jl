mutable struct StringMatch
    n::Int
    feats::Dict
end

function (sm::StringMatch)(query::String)
    rs1 = prefixsearch(sm.sa1, query)
    isempty(rs1) && return
    rs2 = prefixsearch(sm.sa2, reverse(query))
    isempty(rs2) && return
end

function similarity(s1::String, s2::String)
    dict = Dict{String,Int}()
    i = 1
    while i <= sizeof(s1)
        s = join(s1[i:nextind(s1,i,2)])
        i = nextind(s1, i)
    end
    for s in s1
        haskey(dict,s) ? (dict[s] += 1) : (dict[s] = 1)
    end
    for s in s2
        haskey(dict,s) ? (dict[s] -= 1) : (dict[s] = -1)
    end
    c = count(c -> c == 0, collect(values(dict)))
    p = c / length(s1)
    r = c / length(s2)
    2p*r / (p+r)
end

function similarity(s1::Vector{String}, s2::Vector{String})
    dict = Dict{String,Int}()
    for s in s1
        haskey(dict,s) ? (dict[s] += 1) : (dict[s] = 1)
    end
    for s in s2
        haskey(dict,s) ? (dict[s] -= 1) : (dict[s] = -1)
    end
    c = count(c -> c == 0, collect(values(dict)))
    p = c / length(s1)
    r = c / length(s2)
    2p*r / (p+r)
end
