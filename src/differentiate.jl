include("data.jl")

using .Data


module differentiate

    using DataStructures
    d = Main.Data


    function lex(text, args...)
        _rules = d.rules

        for el in args
            push!(_rules, (d.variable, Regex("^"*el)))
        end

        println(_rules)


        last_text = Nothing
        toks = []
        tokens = d.Token[]

        while length(text) > 0 && last_text != text
            ruled = false
            for (type, regex) in _rules
                m = match(regex, text)
                if !isnothing(m)
                    matched = m.match
                    

                    push!(tokens, type(String(m.match)));

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


        # println(length(q))
        # root = first(q)
        # println(root)
        # println(root.left)
        # println(root.right)

        return first(q)
    end


    tokenStream = lex("sin(3*5+1)^2+y", "x", "y")
    # println(tokenStream)


    root = shunting_yard(tokenStream)

    println(root)
    println(root.right)



end # module
