include("data.jl")



module Derivative
    d = Main.Data

    function differ(root::d.TreeNode, var::String)
        if isa(root.value, d.power)
            nothing
        elseif isa(root.value, d.ln)
            rd = differ(root.right, var)

            rootToken = d.multiplication()
            rootNode = d.TreeNode(rootToken)

            leftToken = d.division()
            leftNode = d.TreeNode(leftToken)

            rootNode.left = leftNode
            leftNode.parent = rootNode

            leftleftToken = d.number("1")
            leftleftNode = d.TreeNode(leftleftToken)

            leftNode.left = leftleftNode
            leftleftNode.parent = leftNode

            leftNode.right = root.right
            root.right.parent = leftNode

            rootNode.right = rd
            rd.parent = rootNode

            return rootNode

        elseif isa(root.value, d.sinus)
            rd = differ(root.right, var)

            rootToken = d.multiplication()
            rootNode = d.TreeNode(rootToken)

            leftToken = d.cosinus("cos")
            leftNode = d.TreeNode(leftToken)

            rootNode.left = leftNode
            leftNode.parent = rootNode

            rootNode.right = rd
            rd.parent = rootNode

            leftNode.right = root.right
            root.right.parent = leftNode

            return rootNode

        elseif isa(root.value, d.multiplication)
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

        elseif isa(root.value, d.division)
            ld = differ(root.left, var)
            rd = differ(root.right, var)

            rootToken = d.division()
            rootNode = d.TreeNode(rootToken)

            leftToken = d.subtraction()
            leftNode = d.TreeNode(leftToken)

            rightToken = d.power()
            rightNode = d.TreeNode(rightToken)

            rootNode.left = leftNode
            leftNode.parent = rootNode
            rootNode.right = rightNode
            rightNode.parent = rootNode

            leftleftToken = d.multiplication()
            leftleftNode = d.TreeNode(leftleftToken)
            leftrightToken = d.multiplication()
            leftrightNode = d.TreeNode(leftrightToken)

            leftNode.left = leftleftNode
            leftleftNode.parent = leftNode
            leftNode.right = leftrightNode
            leftrightNode.parent = leftNode

            leftleftNode.left = ld
            ld.parent = leftleftNode
            leftleftNode.right = root.right
            root.right.parent = leftleftNode

            leftrightNode.left = root.left
            root.left.parent = leftrightNode
            leftrightNode.right = rd
            rd.parent = leftrightNode

            # rightNode.left = root.right
            #crucial division
            rightNode.left = d.TreeNode(root.right.value, rightNode, root.right.left, root.right.right)

            rightrightToken = d.number("2")
            rightrightNode = d.TreeNode(rightrightToken)
            rightNode.right = rightrightNode
            rightrightNode.parent = rightNode

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