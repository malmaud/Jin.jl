using Test
using Jin

@Jin.register plus_one(x)=x+1
@Jin.register plus_two(x)=x+2

@Jin.configurable function f(;x=5)
    return x+1
end

@Jin.configurable function g(value;name="default")
    if name=="default"
        return value
    elseif name=="from_config"
        return -value
    else
        throw("Unrecognized name")
    end
end

@Jin.configurable function outer_fn(x;kernel=x->x)
    return -kernel(x)
end

@test f()==6
@test f(x=10)==11
@test g(5)==5
@test outer_fn(3)== -3
@test outer_fn(3, kernel=plus_one) == -4
@test outer_fn(3, kernel=plus_two) == -5


config_filename = joinpath(@__DIR__, "test_config.jin")
Jin.load_config(config_filename)
println(Jin.jind)

@test f()==16
@test f(x=10)==11
@test g(5)==-5
@test outer_fn(3) == -5

Jin.reset()
@test f()==6
@test g(5)==5
