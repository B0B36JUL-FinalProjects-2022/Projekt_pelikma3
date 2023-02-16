module Data

    using DataStructures
    
        
    abstract type Token end

    abstract type Parenthesis <: Token end

    struct leftparenth <: Parenthesis
        value::String
        function leftparenth(v::Any)
            return new("(")
        end
        function leftparenth(v::Any, old::Any)
            return new("(")
        end
    end

    struct rightparenth <: Parenthesis
        value::String
        function rightparenth(v::Any)
            return new(")")
        end
        function rightparenth(v::Any, old::Any)
            return new(")")
        end
    end


    struct whitespace <: Token
        function whitespace(v::Any)
            return new()
        end
        function whitespace(v::Any, old::Any)
            return new()
        end
    end

    struct number <: Token
        value::Float64
        function number(v::String)
            return new(parse(Float64, v))
        end
        function number(v::String, old::Any)
            return new(parse(Float64, v))
        end
    end

    struct variable <: Token
        value::String
        function variable(v::String)
            return new(v)
        end
        function variable(v::String, old::Any)
            return new(v)
        end
    end

    abstract type Func <: Token end

    struct sinus <: Func
        value::String
        function sinus(v::String)
            return new("sin")
        end
        function sinus(v::String, old::Any)
            return new("sin")
        end
    end

    struct cosinus <: Func
        value::String
        function cosinus(v::String)
            return new("cos")
        end
        function cosinus(v::String, old::Any)
            return new("cos")
        end
    end

    struct ln <: Func
        value::String
        function ln(v::String)
            return new("ln")
        end
        function ln(v::String, old::Any)
            return new("ln")
        end
    end

    abstract type Operation <: Token end

    struct addition <: Operation
        value::String
        function addition()
            return new("+")
        end
        function addition(v::Any)
            return new("+")
        end
        function addition(v::Any, old::Any)
            return new("+")
        end
    end

    struct subtraction <: Operation
        value::String
        unary::Bool
        function subtraction()
            return new("-", false)
        end
        function subtraction(v::Any)
            return new("-", false)
        end
        function subtraction(v::Any, old::leftparenth)
            return new("-", true)
        end
        function subtraction(v::Any, old::Nothing)
            return new("-", true)
        end
        function subtraction(v::Any, old::Any)
            return new("-", false)
        end

    end

    struct multiplication <: Operation
        value::String
        function multiplication()
            return new("*")
        end
        function multiplication(v::Any)
            return new("*")
        end
        function multiplication(v::Any, old::Any)
            return new("*")
        end
    end

    struct division <: Operation
        value::String
        function division()
            return new("/")
        end
        function division(v::Any)
            return new("/")
        end
        function division(v::Any, old::Any)
            return new("/")
        end
    end

    struct power <: Operation
        value::String
        function power()
            return new("^")
        end
        function power(v::Any)
            return new("^")
        end
        function power(v::Any, old::Any)
            return new("^")
        end
    end

    
    function filterwhitespace(el::whitespace)
        return false
    end

    function filterwhitespace(el::Token)
        return true
    end


    mutable struct TreeNode
        value::Union{Nothing, Token}
        parent::Union{Nothing, TreeNode}
        left::Union{Nothing, TreeNode}
        right::Union{Nothing, TreeNode}

        function TreeNode(value::Token)
            return new(value, nothing, nothing, nothing)
        end

        function TreeNode(value::Token, l::Union{TreeNode, Nothing}, r::TreeNode)
            return new(value, nothing, l, r)
        end

        function TreeNode(value::Token, p::Union{TreeNode, Nothing}, l::Union{TreeNode, Nothing}, r::Union{TreeNode, Nothing})
            return new(value, p, l, r)
        end
    end

    rules = [
        (whitespace, r"^\s+"),
        (number, r"^([0-9]*[.])?([0-9]+)"),
        (addition, r"^\+"),
        (subtraction, r"^\-"),
        (multiplication, r"^\*"),
        (division, r"^\/"),
        (power, r"^\^"),
        (sinus, r"^sin"),
        (cosinus, r"^cos"),
        (ln, r"^ln"),
        (leftparenth, r"^\("),
        (rightparenth, r"^\)"),
        (power, r"^\^")
    ]

    priority(::Func) = 5
    priority(::power) = 4
    priority(::multiplication) = 3
    priority(::division) = 3
    priority(::addition) = 2
    priority(::subtraction) = 2
    priority(::Parenthesis) = 1

    
    function enqueueQ(t::number, q)
        push!(q, TreeNode(t))
    end

    function enqueueQ(t::variable, q)
        push!(q, TreeNode(t))
    end

    function enqueueQ(s::subtraction, q)
        if s.unary
            right = pop!(q)

            t = TreeNode(s, nothing, right)
            right.parent = t
            push!(q, t)
        else
            right = pop!(q)
            left = pop!(q)
    
            t = TreeNode(s, left, right)
            left.parent = t
            right.parent = t
            push!(q, t)
        end
    end

    function enqueueQ(o::Operation, q)
        right = pop!(q)
        left = pop!(q)

        t = TreeNode(o, left, right)
        left.parent = t
        right.parent = t
        push!(q, t)
    end

    function enqueueQ(f::Func, q)
        right = pop!(q)

        t = TreeNode(f, nothing, right)
        right.parent = t
        push!(q, t)
    end

    function emptyStack(s, q)
        while !isempty(s)
            top = first(s)
            if isa(top, leftparenth) 
                pop!(s)
                break 
            end
            enqueueQ(pop!(s), q)
        end
    end

    function processToken(t::number, s, q)
        enqueueQ(t, q)
    end

    function processToken(t::variable, s, q)
        enqueueQ(t, q)
    end

    function processToken(t::Operation, s, q)
        if isempty(s)
            push!(s, t)
        else
            top = first(s)
            while !isempty(s)
                top = first(s)
                if priority(top) > priority(t)
                    enqueueQ(pop!(s), q)
                else
                    break
                end
            end
            push!(s, t)
        end
    end

    function processToken(f::Func, s, q)
        push!(s, f)
    end

    function processToken(t::leftparenth, s, q)
        push!(s, t)
    end

    function processToken(t::rightparenth, s, q)
        
        emptyStack(s, q)

    end


    function processToken(t::Any, s, q)
        nothing
    end



    Base.show(io::IO, t::TreeNode) = show(io, t.value)
    # Base.copy(m::multiplication) = multiplication(m.value)
    Base.copy(t::TreeNode) = TreeNode(t.value, t.parent, t.left, t.right)

end