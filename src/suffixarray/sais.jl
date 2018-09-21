#=
 * sais
 * Copyright (c) 2010 Yuta Mori. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
=#

function sais(data::Vector, k::Int)
    sa = Array{Int}(undef,length(data))
    sais!(data, sa, 0, length(data), k)
    sa
end
function sais!(text::Vector{T}, sa::Vector{Int}, fs::Int, n::Int, k::Int) where T<:Integer
    pidx = 0
    flags = 0
    if k <= 256
        C = zeros(Int, k)
        if k <= fs
            B = offset_to_array(sa, n+fs-k+1)
            flags = 1
        else
            B = zeros(Int, k)
            flags = 3
        end
    elseif k <= fs
        C = offset_to_array(sa, n+fs-k+1)
        if k <= fs-k
            B = offset_to_array(sa, n+fs-2k+1)
            flags = 0
        elseif k <= 1024
            B = zeros(Int, k)
            flags = 2
        else
            B = C
            flags = 8
        end
    else
        C = B = zeros(Int, k)
        flags = 4 | 8
    end

    # stage 1: reduce the problem by at least 1/2
    # sort all the LMS-substrings
    setcounts!(text, C, n, k)
    getbuckets(C, B, k, true)
    for i = 1:n
        sa[i] = 0
    end
    b = -1
    i = j = n
    m = 0
    c0 = c1 = text[n]
    i -= 1
    while 1 <= i && ((c0 = text[i]) >= c1)
        c1 = c0
        i -= 1
    end
    while 1 <= i
        c1 = c0
        i -= 1
        while 1 <= i && ((c0 = text[i]) <= c1)
            c1 = c0
            i -= 1
        end
        if 1 <= i
            0 <= b && (sa[b+1] = j)
            b = (B[c1+1] -= 1)
            j = i-1
            m += 1
            c1 = c0
            i -= 1
            while 1 <= i && ((c0 = text[i]) >= c1)
                c1 = c0
                i -= 1
            end
        end
    end
    if 1 < m
        LMSsort(text, sa, C, B, n, k)
        name = LMSpostproc(text, sa, n, m)
    elseif m == 1
        sa[b+1] = j + 1
        name = 1
    else
        name = 0
    end

    # stage 2
    if name < m
        newfs = n + fs - 2m
        if flags & (1 | 4 | 8) == 0
            if (k + name) <= newfs
                newfs -= k
            else
                flags |= 8
            end
        end
        j = 2m + newfs
        for i = (m + (n >> 1)):-1:(m+1)
            if sa[i] != 0
                sa[j] = sa[i] - 1
                j -= 1
            end
        end
        RA = offset_to_array(sa, m+newfs+1)
        sais!(RA, sa, newfs, m, name)

        i = n
        j = 2m
        c0 = c1 = text[n]
        while 1 <= (i -= 1) && ((c0 = text[i]) >= c1)
            c1 = c0
        end
        while 1 <= i
            c1 = c0
            while 1 <= (i -= 1) && ((c0 = text[i]) <= c1)
                c1 = c0
            end
            if 1 <= i
                sa[j] = i
                j -= 1
                c1 = c0
                while 1 <= (i -= 1) && ((c0 = text[i]) >= c1)
                    c1 = c0
                end
            end
        end
        for i = 1:m
            sa[i] = sa[m+sa[i]+1]
        end
        if flags & 4 != 0
            C = B = zeros(Int, k)
        end
        if flags & 2 != 0
            B = zeros(Int, k)
        end
    end

    # stage 3
    flags & 8 != 0 && setcounts!(text, C, n, k)
    if 1 < m
        getbuckets(C, B, k, true)
        i = m - 1
        j = n
        p = sa[m]
        c1 = text[p+1]
        while true
            c0 = c1
            q = B[c0+1]
            while q < j
                j -= 1
                sa[j+1] = 0
            end
            while true
                j -= 1
                sa[j+1] = p
                i -= 1
                i < 0 && break
                p = sa[i+1]
                c1 = text[p+1]
                c1 != c0 && break
            end
            i < 0 && break
        end
        while 0 < j
            j -= 1
            sa[j+1] = 0
        end
    end
    #if (isbwt == false) { induceSA(T, SA, C, B, n, k); }
    #else { pidx = computeBWT(T, SA, C, B, n, k); }
    induceSA(text, sa, C, B, n, k)
end

function setcounts!(text::Vector{T}, C::Vector{Int}, n::Int, k::Int) where T
    for i = 1:k
        C[i] = 0
    end
    for i = 1:n
        C[text[i]+1] += 1
    end
end

function getbuckets(C::Vector{Int}, B::Vector{Int}, k::Int, isend::Bool)
    sum = 0
    if isend
        for i = 1:k
            sum += C[i]
            B[i] = sum
        end
    else
        for i = 1:k
            sum += C[i]
            B[i] = sum - C[i]
        end
    end
end

offset_to_array(x::Vector, i::Int) = unsafe_wrap(Array, pointer(x,i), length(x)-i+1)

function LMSsort(text::Vector{T}, sa, C, B, n::Int, k::Int) where T<:Integer
    C == B && setcounts!(text, C, n, k)
    getbuckets(C, B, k, false)
    j = n - 1
    c1 = text[j+1]
    b = B[c1+1]
    j -= 1
    sa[b+1] = text[j+1] < c1 ? ~j : j
    b += 1
    for i = 1:n
        if 0 < (j = sa[i])
            if (c0 = text[j+1]) != c1
                B[c1+1] = b
                c1 = c0
                b = B[c1+1]
            end
            j -= 1
            sa[b+1] = text[j+1] < c1 ? ~j : j
            b += 1
            sa[i] = 0
        elseif j < 0
            sa[i] = ~j
        end
    end
    C == B && setcounts!(text, C, n, k)
    getbuckets(C, B, k, true)
    c1 = 0
    b = B[c1+1]
    for i = n:-1:1
        if 0 < (j = sa[i])
            c0 = text[j+1]
            if c0 != c1
                B[c1+1] = b
                c1 = c0
                b = B[c1+1]
            end
            j -= 1
            b -= 1
            sa[b+1] = text[j+1] > c1 ? ~(j+1) : j
            sa[i] = 0
        end
    end
end

function LMSpostproc(text::Vector{T}, sa::Vector{Int}, n::Int, m::Int) where T
    i = 1
    while (p = sa[i]) < 0
        sa[i] = ~p
        i += 1
    end
    if i-1 < m
        j = i
        i += 1
        while true
            if (p = sa[i]) < 0
                sa[j] = ~p
                j += 1
                sa[i] = 0
                j-1 == m && break
            end
            i += 1
        end
    end

    i = j = n
    c0 = c1 = text[n]
    while 1 <= (i -= 1) && ((c0 = text[i]) >= c1)
        c1 = c0
    end
    while 1 <= i
        c1 = c0
        while 1 <= (i -= 1) && ((c0 = text[i]) <= c1)
            c1 = c0
        end
        if 1 <= i
            sa[m + (i >> 1) + 1] = j - i
            j = i + 1
            c1 = c0
            while 1 <= (i -= 1) && ((c0 = text[i]) >= c1)
                c1 = c0
            end
        end
    end
    name = 0
    q = n
    qlen = 0
    for i = 1:m
        p = sa[i]
        plen = sa[m + (p >> 1) + 1]
        diff = true
        if plen == qlen && (q + plen < n)
            j = 0
            while j < plen && text[p+j+1] == text[q+j+1]
                j += 1
            end
            j == plen && (diff = false)
        end
        if diff != false
            name += 1
            q = p
            qlen = plen
        end
        sa[m + (p >> 1) + 1] = name
    end
    return name
end

function induceSA(text::Vector{T}, sa::Vector{Int}, C::Vector{Int}, B::Vector{Int}, n::Int, k::Int) where T
    C == B && setcounts!(text, C, n, k)
    getbuckets(C, B, k, false)
    j = n - 1
    c1 = text[j+1]
    b = B[c1+1]
    sa[b+1] = 0 < j && text[j] < c1 ? ~j : j
    b += 1
    for i = 1:n
        j = sa[i]
        sa[i] = ~j
        if 0 < j
            j -= 1
            if (c0 = text[j+1]) != c1
                B[c1+1] = b
                c1 = c0
                b = B[c1+1]
            end
            sa[b+1] = 0 < j && text[j] < c1 ? ~j : j
            b += 1
        end
    end
    C == B && setcounts!(text, C, n, k)
    getbuckets(C, B, k, true)
    c1 = 0
    b = B[c1+1]
    for i = n:-1:1
        if 0 < (j = sa[i])
            j -= 1
            if (c0 = text[j+1]) != c1
                B[c1+1] = b
                c1 = c0
                b = B[c1+1]
            end
            b -= 1
            sa[b+1] = j == 0 || text[j] > c1 ? ~j : j
        else
            sa[i] = ~j
        end
    end
end
