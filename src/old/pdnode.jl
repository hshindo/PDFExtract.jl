export PDNode

mutable struct PDNode
    data
    children::Vector{PDNode}
    parent
end

PDNode(data) = PDNode(data, PDNode[], nothing)
function PDNode(data, children::Vector{PDNode})
    node = PDNode(data, children, nothing)
    push!(node, children...)
    node
end

isroot(node::PDNode) = node.parent == nothing
Base.isempty(node::PDNode) = isempty(node.children)
Base.length(node::PDNode) = length(node.children)
Base.size(node::PDNode, i::Int) = size(node.children, i)
#Base.endof(node::PDNode) = endof(node.children)

function Base.setindex!(node::PDNode, child::PDNode, i::Int)
    node.children[i] = child
    child.parent = node
end

function Base.push!(node::PDNode, children::PDNode...)
    push!(node.children, children...)
    for i = length(children):-1:1
        c = children[i]
        delete!(c)
        c.parent = node
    end
end

function Base.insert!(node::PDNode, i::Int, child::PDNode)
    insert!(node.children, i, child)
    child.parent = node
end

function Base.delete!(node::PDNode)
    node.parent == nothing && return
    i = findfirst(x -> x == node, node.parent.children)
    deleteat!(node.parent, i)
end

function topdown(f, node::PDNode)
    f(node)
    for c in node.children
        topdown(f, c)
    end
end

function bottomup(f, node::PDNode)
    for c in node.children
        bottomup(f, c)
    end
    f(node)
end

function toconll(root::PDNode)
    dict = Dict()
    i = 1
    bottomup(root) do node
        if isempty(node)
            dict[node] = i:i
            i += 1
        else
            r1 = dict[node[1]]
            r2 = dict[node[end]]
            dict[node] = first(r1):last(r2)
        end
    end
end
