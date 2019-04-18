mutable struct StringMatch
    sa1::SuffixArray
    sa2::SuffixArray
end

function StringMatch(data::String)
    sa1 = SuffixArray(data)
    sa2 = SuffixArray(reverse(data))
    StringMatch(sa1, sa2)
end

function approxsearch(sm::StringMatch, query::String)
    rs1 = prefixsearch(sm.sa1, query)
    isempty(rs1) && return
    rs2 = prefixsearch(sm.sa2, reverse(query))
    isempty(rs2) && return
    rs2 = map(rs2) do r
        n = length(sm.sa2)
        (n-last(r)+1):(n-first(r)+1)
    end
    println(rs1)
    println(rs2)
end

function cossimilarity(s1::String, s2::String, n::Int)
    dict1 = Dict()
    i = 1
    s = s1
    while i <= sizeof(s)
        j = nextind(s, i, n-1)
        j <= sizeof(s) || break
        ngram = s[i:j]
        haskey(dict1,ngram) ? (dict1[ngram] += 1) : (dict1[ngram] = 1)
        i = nextind(s, i)
    end
    a1 = sqrt(sum(c -> c*c, values(dict1)))

    dict2 = Dict()
    i = 1
    s = s2
    while i <= sizeof(s)
        j = nextind(s, i, n-1)
        j <= sizeof(s) || break
        ngram = s[i:j]
        haskey(dict2,ngram) ? (dict2[ngram] += 1) : (dict2[ngram] = 1)
        i = nextind(s, i)
    end
    a2 = sqrt(sum(c -> c*c, values(dict2)))

    dot = 0
    for (k,v) in dict1
        if haskey(dict2, k)
            dot += v * dict2[k]
        end
    end
    dot / (a1*a2)
end
