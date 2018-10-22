export TreeNode
export  setchildren!, topdown, topdown_while, toxml, tosexpr, todict

mutable struct TreeNode
    value
    children::Vector{TreeNode}
    parent
end

function TreeNode(value, children::Vector{TreeNode})
    t = TreeNode(value, children, nothing)
    for i = length(children):-1:1
        c = children[i]
        delete!(c)
        c.parent = t
    end
    t
end
TreeNode(value, children::TreeNode...) = TreeNode(value, [children...])
TreeNode(value) = TreeNode(value, Tree[])

isroot(node::TreeNode) = node.parent == nothing
Base.getindex(node::TreeNode, key::Int) = node.children[key]
function Base.setindex!(node::TreeNode, value::TreeNode, key::Int)
    node.children[key] = value
    value.parent = node
end
Base.isempty(node::TreeNode) = isempty(node.children)
Base.length(node::TreeNode) = length(node.children)
Base.size(node::TreeNode, i::Int) = size(node.children, i)
Base.endof(node::TreeNode) = endof(node.children)

function Base.push!(node::TreeNode, children::TreeNode...)
    push!(node.children, children...)
    for i = length(children):-1:1
        c = children[i]
        delete!(c)
        c.parent = node
    end
end
Base.append!(node::TreeNode, children) = push!(node, children...)
function Base.prepend!(node::TreeNode, children::Vector)
    prepend!(node.children, children)
    for i = length(children):-1:1
        c = children[i]
        delete!(c)
        c.parent = node
    end
end
function Base.insert!(node::TreeNode, i::Int, child::TreeNode)
    insert!(node.children, i, child)
    child.parent = node
end

function Base.deleteat!(node::TreeNode, i::Int)
    node[i].parent = nothing
    deleteat!(node.children, i)
end
function Base.delete!(node::TreeNode)
    node.parent == nothing && return
    i = findfirst(x -> x == node, node.parent.children)
    deleteat!(node.parent, i)
end
function removeat!(node::TreeNode, i::Int)
    children = TreeNode[]
    node[i].parent = nothing
    for k = 1:length(node)
        if k == i
            append!(children, node[k].children)
        else
            push!(children, node[k])
        end
    end
    setchildren!(node, children)
end
function Base.empty!(node::TreeNode)
    foreach(c -> c.parent = nothing, node.children)
    empty!(node.children)
end

function Base.findall(f::Function, node::TreeNode)
    nodes = TreeNode[]
    function traverse(node::TreeNode)
        f(node) && push!(nodes,node)
        for c in node.children
            traverse(c)
        end
    end
    traverse(node)
    nodes
end

function replace!(oldt::TreeNode, newt::TreeNode)
    p = oldt.parent
    i = findfirst(x -> x == oldt, p.children)
    deleteat!(p, i)
    insert!(p, i, newt)
end

function setchildren!(node::TreeNode, children::Vector{TreeNode})
    foreach(c -> c.parent = nothing, node.children)
    foreach(c -> c.parent = node, children)
    node.children = children
end
setchildren!(node::TreeNode, children::TreeNode...) = setchildren!(node, [children...])

function topdown(f, node::TreeNode)
    f(node)
    for c in node.children
        topdown(f, c)
    end
end

function topdown_while(f::Function, node::TreeNode)
    cond = f(node)
    @assert isa(cond,Bool)
    cond || return
    for c in node.children
        topdown_while(f, c)
    end
end

function bottomup(f::Function, node::TreeNode)
    for c in node.children
        bottomup(f, c)
    end
    f(node)
end

function tosexpr(node::TreeNode)
    strs = String["(", node.value]
    for c in node.children
        push!(strs, tosexpr(c))
    end
    push!(strs, ")")
    join(strs)
end

function toxml(node::TreeNode)
    function escape(str::String)
        str = replace(str, "&", "&amp;")
        str = replace(str, ">", "&gt;")
        str = replace(str, "<", "&lt;")
        str = replace(str, "'", "&apos;")
        str = replace(str, "\"", "&quot;")
        str
    end

    @assert !isempty(node)
    strs = String[]
    node.parent == nothing && push!(strs,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>")

    push!(strs, "<$(node.value)>")
    for c in node.children
        if isempty(c)
            push!(strs, escape(c.value))
        else
            !isempty(strs) && strs[end][end] == '>' && push!(strs,"\n")
            push!(strs, toxml(c))
        end
    end
    closetag = split(node.value, " ")[1]
    !isempty(strs) && !isempty(strs[end]) && strs[end][end] == '>' && push!(strs,"\n")
    push!(strs, "</$closetag>")
    join(strs)
end

function todict(node::TreeNode)
    n = count(isempty, node.children)
    @assert n == 0 || n == length(node)
    if n == 0
        Dict(node.value => map(todict, node.children))
    else
        node.value
    end
end

function Base.string(node::TreeNode, delim="")
    strs = String[]
    topdown(node) do node
        isempty(node) && push!(strs,node.value)
    end
    join(strs, delim)
end

function Base.parse(::Type{TreeNode}, sexpr::String)
    sexpr = Vector{Char}(sexpr)
    function f(i::Int)
        chars = Char[]
        children = TreeNode[]
        while i <= length(sexpr)
            c = sexpr[i]
            if c == '('
                child, i = f(i+1)
                push!(children, child)
            elseif c == ')'
                node = TreeNode(join(chars), children)
                return node, i+1
            else
                c != ' ' && c != '\n' && push!(chars,sexpr[i])
                i += 1
            end
        end
        throw("Invalid S-expression.")
    end
    i = findfirst(c -> c == '(', sexpr)
    i == 0 && throw("Invalid S-expression.")
    node, _ = f(i+1)
    node
end

#=
struct TopdownIterator
    tree::Tree
end
topdown = TopdownIterator
Base.start(iter::TopdownIterator) = Tree[iter.tree]
Base.done(iter::TopdownIterator, state::Vector{Tree}) = isempty(state)
function Base.next(iter::TopdownIterator, state::Vector{Tree})
    tree = pop!(state)
    for i = length(tree):-1:1
        push!(state, tree[i])
    end
    (tree, state)
end
=#
