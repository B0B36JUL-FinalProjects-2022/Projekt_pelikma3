include("data.jl")



module Derivative
    d = Main.Data

    function differ(root::d.TreeNode, var::String)
        if isa(root.value, d.multiplication)
            println("je to mult")
            ld = differ(root.left, var)
            rd = differ(root.right, var)

            rootToken = d.addition()
            rootNode = d.TreeNode(rootToken)

            leftToken = d.multiplication()
            leftNode = d.TreeNode(leftToken)

            rightToken = d.multiplication()
            rightNode = d.TreeNode(rightToken)

            rootNode.left = leftNode
            leftNode.parent = rootNode

            rootNode.right = rightNode
            rightNode.parent = rootNode


            leftNode.left = ld
            ld.parent = leftNode
            leftNode.right = root.right #TODO deep copy, asi to pujde i bez deep
            root.right.parent = leftNode

            rightNode.left = root.left
            root.left.parent = rightNode
            rightNode.right = rd
            rd.parent = rightNode

            return rootNode

        elseif isa(root.value, d.addition)
            println("je to add")
            ld = differ(root.left, var)
            rd = differ(root.right, var)

            rootToken = d.addition()
            rootNode = d.TreeNode(rootToken)

            rootNode.left = ld
            ld.parent = rootNode

            rootNode.right = rd
            rd.parent = rootNode

            return rootNode

        elseif isa(root.value, d.number)
            n = d.number("0")
            t = d.TreeNode(n)
            return t
        elseif isa(root.value, d.variable) && root.value.value == var
            n = d.number("1")
            t = d.TreeNode(n)
            return t
        elseif isa(root.value, d.variable)
            n = d.number("0")
            t = d.TreeNode(n)
            return t
        end
    end

end