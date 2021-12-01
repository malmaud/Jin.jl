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

# Reference
In general, the syntax "a.b=c" in a configuration file changes the default value of the keyword argument `b` in the function `a` to `c`. A configuration file can have multiple lines. Blank lines and lines starting with a comment `#` are ignored. Only functions decorated with `Jin.configurable` can be configured.

As expected in Julia, you can always explicitly set the value of a keyword argument at a call site to override the value in the configuration. For example, with the definition

```julia
@Jin.configurable f(;x=0) = x
load_config("my_config.jin")
```

calling `f(x=5)` will return 5 no matter what `f.x` is set to in the configuration file.


**TODO**: More robust documentation.

# Future work
Currently this package only supports the most basic usage of Gin - setting the default value of a function argument to a literal. In the future, we'll add support for additioanl features in Gin, such as allowing values to be references to other values in your Julia program or configuration.

# Installation
In a Julia REPL,

```julia
import Pkg
Pkg.add("Jin")
```
