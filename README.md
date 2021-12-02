# Jin
![CI passing](https://github.com/malmaud/Jin.jl/actions/workflows/ci.yml/badge.svg)

A Julia version of the Python [Gin configuration library](https://github.com/google/gin-config).

# Usage
This package offers a way to configure your Julia code by specifying the default value of your function's keyword arguments in a configuration file.

For example, if you are training a neural network, you might have a function like

```julia
function train(data; learning_rate=.01, epochs=10)
    @show learning_rate
   ...
end

function load_data(; dataset="mnist")
    @show dataset
    ...
end

results = train(load_my_data())
```

You'll see output like 

```
dataset = "mnist"
learning_rate = .01
``` 

when you run this script.

With Jin, we'll able to set the learning rate in a configuration file with no additional plumbing. Change the above example to

```julia
using Jin

@Jin.configurable function train(data; learning_rate=.01)
    @show learning_rate
   ...
end

@Jin.configurable function load_data(; dataset="mnist")
    @show dataset
    ...
end

Jin.load_config("my_config.jin")

results = train(load_my_data())
```

Create a file `my_config.jin` with the following contents:

```
# Configuration to train on imagenet with a low learning rate
load_data.dataset = "imagenet"
train.learning_rate = .005
```

Now when you run your Julia program, you'll see 

```
dataset = "imagenet"
learning_rate = .005
``` 

, indicating that the configuration file has changed the value of the learning rate and dataset.



# Why Jin?
With just a single call to `load_config`, your configuration is loaded and applied to all configurable objects. No need to manually parse a configuration file and plumb keyword arguments all over your code.

# References
Values in the config don't have to be literals - they can be references to other Julia objects (including other functions) defined in your Julia program.

For example, you can use the config to change the activation function of a neural network:

```julia
using Jin
using Flux

@Jin.register relu(x) = max(0, x)
@Jin.register sigmoid(x) = 1/(1+exp(-x))
@Jin.register identity(x) = x

function linear_layer(x, w, b; activation=identity)
  return x*w + b
end

Jin.load_config("my_config.jin")
...
y = linear_layer(x, w, b)
```

And in the config,

```
linear_layer.activation = @sigmoid
```

This config has changed the activation function of the linear layer to be the sigmoid function with no change to your code. There is no clumsy need to define an enum for all possible activation functions, load that enum from a config or command-line argument, and have a bunch of `if` statements to translate that enum into a function call. Less boilerplate!

Note the `@` in front of the function name in the config - this tells Jin that it should look for a registered function named `sigmoid`.

# Documentation
In general, the syntax "a.b=c" in a configuration file changes the default value of the keyword argument `b` in the function `a` to `c`. A configuration file can have multiple lines. Blank lines and lines starting with a comment `#` are ignored. Only functions decorated with `Jin.configurable` can be configured.

As expected in Julia, you can always explicitly set the value of a keyword argument at a call site to override the value in the configuration. For example, with the definition

```julia
@Jin.configurable f(;x=0) = x
load_config("my_config.jin")
```

calling `f(x=5)` will return 5 no matter what `f.x` is set to in the configuration file.


**TODO**: More robust documentation.

# Future work
Currently this package only supports a subset of the functionality of Gin. In the future, we'll add support for

* scopes
* more robust support for references
* logging

# Installation
In a Julia REPL,

```julia
import Pkg
Pkg.add("Jin")
```
