mutable struct TreeNode
    value
    children::Vector{TreeNode}
    parent
end

function TreeNode(value, children::Vector{TreeNode})
    t = TreeNode(value, TreeNode[], nothing)
    push!(t, children...)
    t
end
TreeNode(value, children::TreeNode...) = TreeNode(value, [children...])
TreeNode(value) = TreeNode(value, TreeNode[])

isroot(node::TreeNode) = node.parent == nothing
Base.getindex(node::TreeNode, key::Int) = node.children[key]
function Base.setindex!(node::TreeNode, value::TreeNode, key::Int)
    delete!(value)
    delete!(node[key])
    insert!(node, key, value)
end
Base.isempty(node::TreeNode) = isempty(node.children)
Base.length(node::TreeNode) = length(node.children)

function Base.push!(node::TreeNode, children::TreeNode...)
    #foreach(delete!, children)
    for c in children
        @assert isroot(c)
        push!(node.children, c)
        c.parent = node
    end
end

function Base.insert!(node::TreeNode, i::Int, child::TreeNode)
    delete!(child)
    insert!(node.children, i, child)
    child.parent = node
end

function Base.delete!(node::TreeNode)
    isroot(node) && return
    i = findfirst(c -> c == node, node.parent.children)
    deleteat!(node.parent.children, i)
    node.parent = nothing
end
function Base.deleteat!(node::TreeNode, i::Int)
    node[i].parent = nothing
    deleteat!(node.children, i)
end
function Base.empty!(node::TreeNode)
    foreach(c -> c.parent = nothing, node.children)
    empty!(node.children)
end

function parentindex(node::TreeNode)
    findfirst(c -> c == node, node.parent.children)
end

function remove!(node::TreeNode)
    p = node.parent
    parentindex = findfirst(c -> c == node, node.parent.children)
    children = p.children[1:parentindex-1]
    append!(children, node.children)
    for i = parentindex+1:length(p)
        push!(children, p[i])
    end
    node.parent = nothing
    empty!(node)
    empty!(p)
    push!(p, children...)
end

function topdown(f, node::TreeNode)
    f(node)
    for c in node.children
        topdown(f, c)
    end
end

function leaves(node::TreeNode)
    leaves = TreeNode[]
    function f(n::TreeNode)
        isempty(n.children) ? push!(leaves,n) : foreach(f,n.children)
    end
    f(node)
    leaves
end

function writexml(filename::String, root::TreeNode)
    strs = ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "\n"]
    function _toxml(node::TreeNode)
        opentag = string(node.value)
        push!(strs, "<$opentag>")
        all(!isempty,node.children) && push!(strs,"\n")
        for c in node.children
            if isempty(c)
                s = string(c.value)
                s = replace(s, "&"=>"&amp;")
                s = replace(s, ">"=>"&gt;")
                s = replace(s, "<"=>"&lt;")
                s = replace(s, "'"=>"&apos;")
                s = replace(s, "\""=>"&quot;")
                push!(strs, s)
            else
                _toxml(c)
            end
        end
        closetag = split(opentag, " ")[1]
        push!(strs, "</$closetag>")
        all(!isempty,node.children) && push!(strs,"\n")
    end
    _toxml(root)
    open(filename,"w") do io
        println(io, join(strs))
    end
end

function Base.string(node::TreeNode, delim="")
    strs = String[]
    topdown(node) do node
        isempty(node) && push!(strs,string(node.value))
    end
    join(strs, delim)
end
