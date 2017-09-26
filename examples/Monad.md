# Monad

**Note**: _This is work in progress._

A lambda expression such as `x -> x + 1` generates an anonymous function, i.e. a function that cannot be referenced by a name. An anonymous function is a value like any other, the difference being that a function represents a computation that can be called for evaluation purposes. The body of the lambda expression (the right hand side of `->`) describes the computation. The arguments of the lambda expression (the left hand side of `->`) 

the arguments of the lambda expressions declare variables 

If called, the function takes a value, binds it to the variable declared as an argument  and applies the function to the value and the result is returned.

> In concatenative programming, a quotation is the equivalent of an anonymous function.

`[ 1 + ]`

In concatenative programming you do not have named variables. Your variables are anonymous, the attribute _anonymous_ meaning very much the same as in "anonymous function": you cannot reference a variable by name. Instead, values are stored on a stack.

If a quotation (function) is called, values get consumed from the stack, intermediate values might temporarily be stored on the stack until zero, one or more values are left on the stack as a result. 

> A function corresponds to a quotation in concatenative programming.