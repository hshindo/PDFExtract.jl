export SuffixArray

struct SuffixArray
    data::Vector
    index::Vector{Int}
end

function SuffixArray(data::String)
    index = sais(data)
end

function Base.findall(sa::SuffixArray, query::String)
    chars = Vector{Char}(query)
    i = 1
    j = length(sa)
    while i <= j
        k = (i+j) ÷ 2
        ii = sa.index[k]
        while sa.data[ii+m] == chars[m]
            m == length(chars) && return ii
            m += 1
        end

    end
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
