# Monad

**Note**: _This is work in progress._

Running it: `\ ..\examples\Monad.md lrun`

A lambda expression such as `x -> x + 1` generates an anonymous function, i.e. a function that cannot be referenced by a name. An anonymous function is a value like any other, the difference being that a function represents a computation that can be called for evaluation purposes. The body of the lambda expression (the right hand side of `->`) describes the computation. Typically, the body refers to variables 


The arguments that must be handed over with the call are 

of the lambda expression (the left hand side of `->`) 

the arguments of the lambda expressions declare variables 

If called, the function takes a value, binds it to the variable declared as an argument  and applies the function to the value and the result is returned.

> In concatenative programming, a quotation is the equivalent of an anonymous function.

`[ 1 + ]`

In concatenative programming you do not have named variables. Your variables are anonymous, the attribute _anonymous_ meaning very much the same as in "anonymous function": you cannot reference a variable by name. Instead, values are stored on a stack.

If a quotation (function) is called, values get consumed from the stack, intermediate values might temporarily be stored on the stack until zero, one or more values are left on the stack as a result. 

> A function corresponds to a quotation in concatenative programming.


Nested Lambdas

[ 2 3 4 [ 5 ] call ]

( 1 2 3 ) [ + ] apply'

>> : apply' ( s q -- s ) get-dict func apply ;

Any word is only entiteled to consume as much data as specified; it might produce any number of values on an intermediate data stack but return only as much values as specified -- i.e. any intermediate values on the intermediate data stack which are not to be returned are deleted.

>> : stack ( x -- (x) ) ( ) cons ;
>> : 2stack ( x y -- (y x) ) [ stack ] dip push ;
>> : 3stack ( x y z -- (z y x) ) [ 2stack ] dip push ;
>> : 4stack [ 3stack ] dip push ;
>> : 5stack [ 4stack ] dip push ;

>> : return-Maybe ( v -- mv ) ( \ Just ) cons ;

>> : bind-Maybe ( mv [v -- mv'] )
>>   over \ Nothing equal?
>>     [ drop ]
>>     [ [ top ] dip call ]
>>   if ;

>> : add-m ( mx my -- mz ) 2stack [ [ [ + return-Maybe ] bind-Maybe ] curry bind-Maybe ] apply' top ;

>> ( 2 3 + return-Maybe ) [ 2 return-Maybe 3 return-Maybe add-m ] unit-test
>> ( \ Nothing ) [ \ Nothing 3 return-Maybe add-m ] unit-test
