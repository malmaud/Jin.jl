using Test
using Jin

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

@test f()==6
@test f(x=10)==11
@test g(5)==5

config_filename = joinpath(@__DIR__, "test_config.jin")
Jin.load_config(config_filename)
println(Jin.jind)

@test f()==16
@test f(x=10)==11
@test g(5)==-5

Jin.reset()
@test f()==6
@test g(5)==5
