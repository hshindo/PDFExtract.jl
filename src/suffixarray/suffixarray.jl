export SuffixArray
export prefixsearch

struct SuffixArray{T}
    data::Vector{T}
    indexes::Vector{Int}
end

function SuffixArray(str::String)
    data = Vector{UInt8}(str)
    indexes = sais(data)
    SuffixArray(data, indexes)
end

Base.length(sa::SuffixArray) = length(sa.data)

function prefixsearch(sa::SuffixArray{T}, query::Vector{UInt8}) where T
    left = 1
    right = length(sa)
    maxlcp, maxi = 0, 0
    while left <= right
        mid = (left+right) ÷ 2
        lcp = getlcp(sa, mid, query)
        if lcp > maxlcp
            maxlcp = lcp
            maxi = mid
        end
        lcp == length(query) && break

        i = sa.indexes[mid]
        if i+lcp-1 == length(sa) || sa.data[i+lcp] < query[1+lcp]
            left = mid + 1
        else
            right = mid - 1
        end
    end
    maxlcp == 0 && return UnitRange{Int}[]

    res = [sa.indexes[maxi]]
    i = maxi - 1
    while getlcp(sa,i,query) == maxlcp
        push!(res, sa.indexes[i])
        i -= 1
    end
    i = maxi + 1
    while getlcp(sa,i,query) == maxlcp
        push!(res, sa.indexes[i])
        i += 1
    end
    sort!(res)
    map(i -> i:i+maxlcp-1, res)
end
prefixsearch(sa::SuffixArray, query::String) = prefixsearch(sa, Vector{UInt8}(query))

function getlcp(sa::SuffixArray, i::Int, query::Vector)
    i > length(sa) && return 0
    index = sa.indexes[i]
    lcp = 0
    while sa.data[index+lcp] == query[1+lcp]
        lcp += 1
        lcp == length(query) && break
        index+lcp-1 == length(sa) && break
    end
    lcp
end

mutable struct StringMatcher
    fwd::SuffixArray
    bwd::SuffixArray
end

function (m::StringMatcher)(query::Vector{Int})
    r1 = prefixsearch(m.fwd, query)
    r2 = prefixsearch(m.bwd, query)
    isempty(r1) || isempty(r2) || return
    length(r1[1]) < 3 || length(r2[1]) < 3 || return
    r1[1]
    r2[1]
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
