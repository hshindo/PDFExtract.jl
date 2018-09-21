export SuffixArray

struct SuffixArray
    data::Vector
    index::Vector{Int}
end

function SuffixArray(data::Vector, k::Int)
    index = sais(data, k)
    @inbounds for i = 1:length(index)
        index[i] += 1
    end
    SuffixArray(data, index)
end
SuffixArray(data::Vector{UInt8}) = SuffixArray(data, 65536)

function prefixsearch(sa::SuffixArray, query::Vector{T}) where T
    l = 1
    r = length(sa.index)
    while l <= r
        m = (r+l) ÷ 2
        p = sa.index[m]
        lcp = getlcp(sa, p, query)
        lcp == length(query) && return p:p+lcp
        lcp + sa.index[m] == length(sa.data) && return p:p+lcp
        if sa.data[p+lcp] < query[lcp+1]
            l = m + 1
        else
            r = m - 1
        end
        l <= r || return p:p+lcp
    end
end

function getlcp(sa::SuffixArray, pos::Int, query::Vector{T}) where T
    i = 1
    while sa.data[pos+i-1] == query[i]
        i == length(query) && return i
        pos+i-1 == length(sa.data) && return i
        i += 1
    end
    i-1
end

"""
    lcparray

Kasai's algorithm for linear-time construction of LCP array from Suffix Array
"""
function lcparray(sa::Vector{Int}, data::Vector{T}) where T<:Integer
    n = length(sa)
    lcps = similar(sa)
    rank = similar(sa)
    for i = 1:n
        rank[sa[i]] = i
    end

    lcp = 0
    for i = 1:n
        rank[i] > 1 || continue
        j = sa[rank[i]-1]
        while i+lcp <= n && j+lcp <= n && data[i+lcp] == data[j+lcp]
            lcp += 1
        end
        lcps[rank[i]] = lcp
        lcp > 0 && (lcp -= 1)
    end
    lcps[1] = 0
    lcps
end
