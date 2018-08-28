export search!

function search!(query::String, pdffile::String)
    path = ""
    chars = readpdftxt()
    for char in chars

    end
end

function lcs(X::String, Y::String)
    D = zeros(Int, length(X)+1, length(Y)+1)
    for i = 1:length(X)
        x = X[i]
        for j = 1:length(Y)
            y = Y[j]
            if i == 0 || j == 0
                L[i,j] = 0
            else if (X[i-1] == Y[j-1])
                L[i,j] = L[i-1,j-1] + 1
            else
                L[i,j] = max(L[i-1,j], L[i,j-1])
            end
        end
    end

    # row 0 and column 0 are initialized to 0 already
    for (i, x) in enumerate(a), (j, y) in enumerate(b)
        if x == y
            lengths[i+1, j+1] = lengths[i, j] + 1
        else
            lengths[i+1, j+1] = max(lengths[i+1, j], lengths[i, j+1])
        end
    end

    result = ""
    x, y = length(a) + 1, length(b) + 1
    while x > 1 && y > 1
        if lengths[x, y] == lengths[x-1, y]
            x -= 1
        elseif lengths[x, y] == lengths[x, y-1]
            y -= 1
        else
            @assert a[x-1] == b[y-1]
            result = string(a[x-1], result)
            x -= 1
            y -= 1
        end
    end
end
