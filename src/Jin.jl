module Jin
using MacroTools

jind = Dict()
jind_original = Dict()
references = Dict()

function reset()
    empty!(jind)
    merge!(jind, jind_original)
end

function process_expr(ex)
    ex=deepcopy(ex)
    assign_blocks=[]
    kwargs = splitdef(ex)[:kwargs]
    f_name = splitdef(ex)[:name]
    f_nameq = Meta.quot(f_name)
    for kwarg in kwargs
        name, value = kwarg.args
        nameq = Meta.quot(name)
        qualified_name = :(($f_nameq, $nameq))
        assign_block = quote
            Jin.jind[$qualified_name] = $value
            Jin.jind_original[$qualified_name] = $value
        end
        push!(assign_blocks, assign_block)
        kwarg.args[2] = :(Jin.jind[$qualified_name])
    end
    assign_blocks, ex
end

macro register(f_ex)
    name = splitdef(f_ex)[:name]
    quote
        $(esc(f_ex))
        Jin.references[$(Meta.quot(name))] = $(esc(name))
    end
end

macro configurable(f_ex)
    assign_blocks, f_ex_new = process_expr(f_ex)
    name = splitdef(f_ex)[:name]
    quote
        $(assign_blocks...)
        $(esc(f_ex_new))
        Jin.references[$(Meta.quot(name))] = $(esc(name))
    end
end

function parse_value(value)
    value = strip(value)
    if isempty(value)
        throw("value can't be empty")
    end
    # This is a reference
    if value[1] == '@'
        ref_name = value[2:end] |> Symbol
        if !haskey(references, ref_name)
            throw("No reference to $ref_name found")
        end
        return references[ref_name]
    else
        return Meta.parse(value)
    end
end

function parse_file(text)
    lines = split(text, "\n")
    config_dict = Dict()
    for line in lines
        line = strip(line)
        if isempty(line) || startswith(line, "#")
            continue
        end
        line_parts = split(line, "=")
        if length(line_parts) != 2
            throw("Invalid line: $line")
        end
        variable, value = line_parts
        parsed_value = parse_value(value)
        variable_parts = split(variable, ".")
        if length(variable_parts) != 2
            throw("Invalid variable: $variable")
        end
        function_name, var_name = variable_parts
        config_dict[(Symbol(function_name |> strip), Symbol(var_name |> strip))]= parsed_value
    end
    return config_dict
end

function load_config(filename)
    contents = open(filename) |> read |> String
    dict = parse_file(contents)
    merge!(jind, dict)
end

end # module
