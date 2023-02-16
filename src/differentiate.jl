include("derivatives.jl")


module differentiate

    using DataStructures
    d = Main.Data
    der = Main.Derivative


    function lex(text, args)
        _rules = d.rules

        for el in args
            push!(_rules, (d.variable, Regex("^"*el)))
        end


        last_text = Nothing
        toks = []
        tokens = d.Token[]
        
        oldToken = nothing
        while length(text) > 0 && last_text != text
            ruled = false
            for (type, regex) in _rules
                m = match(regex, text)
                if !isnothing(m)
                    matched = m.match
                    
                    newToken = type(String(m.match), oldToken)
                    oldToken = newToken
                    push!(tokens, newToken);

                    push!(toks, matched)
                    len = length(matched)
                    
                    last_text = text
                    text = text[len+1:end]

                    ruled = true
                    break
                end
            end
            if !ruled
                last_text = text
                nothing
            end
        end

        @assert length(text)==0 "Error while lexing"

        tokens = tokens[d.filterwhitespace.(tokens)]
        return tokens
    end


    function shunting_yard(tokens::Array{d.Token})
        s = Stack{d.Token}()
        q = Stack{d.TreeNode}()

        for el in tokens
            d.processToken(el, s, q)
        end


        while !isempty(s)
            #TODO - co kdyz neni Operation, mozna pouzit emptyStack() misto tohoto while

            d.enqueueQ(pop!(s), q)
        end

        return first(q)
    end

    function define_function(input, args...)
        println(typeof(args))

        tokenStream = lex(input, args)
        root = shunting_yard(tokenStream)

        fce = d.FuncStructure(root, args)
        return fce
        # rootDer = der.differ(root, "x")
        # println(der._evaluate(rootDer, "s", 1.0))
    end

    function differentiate_(f::d.FuncStructure, var::String)
        rootDer = der.differ(f.root, var)
        fce = d.FuncStructure(rootDer, f.list)
        return fce
    end


    f = define_function("(ln(x*y))^2", "x", "y")
    println(f.list)
    println(f.root)



    f_der_x = differentiate_(f, "x")
    println(f_der_x.root)


    e = der.evaluate(f_der_x, 2.0, 2.0)
    println(e)


end # module
