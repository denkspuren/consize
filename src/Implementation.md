_incomplete, to be continued_

## The Implementation of Consize

This explanation helps you getting a rough understanding of how Consize is implemented in Clojure. Any knowledge of Clojure is benefitial but not a must. Have this text next to the source code and you will immediately understand what is explained here.

Consize is a functional programming language. That is why functions are key in the implementation of Consize, as you will see in a minute. Another aspect of the functional programming paradigm is that data structures are immutable. You cannot change values at all. That might sound strange to you if you are coming from an imperative language, but it is a powerful feature.

It is especially simple to implement Consize by using a functional language. You get functions and immutable data for free. That is why Consize is implemented in Clojure. Clojure is a functional language in the tradition of Lisp, with Lisp being the oldest functional language around. With a language such as Clojure you just need to focus on the speficis of the concatenative execution paradigm. And, as you can see, it is not that much code that builds the fundament of Consize. 

### The Virtual Machine

The Virtual Machine (VM) that 


The CVM consists of a number of functions which can be referenced by name. 

The Consize Virtual Machine is a dictionary that maps names (a string of characters) to functions. The basic structure of the dictionary looks like follows:

    (def VM
      "<name>" (fn [<arguments>] <body>),
      "<name>" (fn [<arguments>] <body>),
      ...
    )

In four cases there is a slight deviation from this schema. The functions associated with `call/cc`, `continue`, `get-dict` and `set-dict` are surrounded by a list expression. Take `call/cc` for instance; the details of the function's implementation are not shown.

      "call/cc" (list (fn [...] ...)),

The reason is that these functions are special functions. The interpreter calls this functions in a slightly different way than all the other functions. The interpreter is implemented by the function that is associated with `stepcc`. But we are getting ahead of our explanations.

### Functions

Every function processes any number of arguments, some of them might be mandatory, the rest is optional. For example, the function associated with name `swap` expects at least two arguments `x` and `y`. The following `&`-sign says: all remaining arguments are captured by `r`. 

    (fn [y x & r] (conj r y x))

It is an error to call this function with less than two arguments.

Another example is the function under name `stepcc`. This function expects at least three arguments. Remaining arguments are captured by `r`. In this case it is an error to call this function with less than three arguments.

    (fn [cs ds dict & r] ...)

You might also find functions in the source code, which do not expect any manatory arguments.

#### Preconditions

The body of some functions begins with some code embedded in curly braces `{:pre ... }`. This is a precondition. A precodition checks for some conditions which must hold true before the actual code in the body of a function is called. Take the function associated with `push` as an example.

    (fn [x s & r] {:pre [(seq? s)]} ...)

The preconditions says: The second argument referred to as `s` must be a sequence. In the terminology of Consize, `s` is required to be a stack. It is a fault to call this function with `s` not being a sequence or stack in terms of Consize.

Preconditions establish a sort of safety net. They prevent you from misusing a function. While this is somewhat to your comfort as a Consize programmer, the extra check requires some time and poses a runtime penalty. XXX Switch off??? If you want to have the thrill of running Consize without the safety net of preconditions, you can turn them off.

### Return Values

You will notice that the body of each function follows a code template. The outer expression of almost all function implementations looks like this:

    (conj r ...)

The rest of the function logic is nested inside this schema. This expression constructs the result returned by the function. It always returns all optional arguments and puts any other return values upfront.

There are just rare expetions from the schema of `(conj r ...)`. 




Most function bodies do not span over one or two lines of code in the source file. 




