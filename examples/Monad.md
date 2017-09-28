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

~~~
>> : apply' ( s q -- s ) get-dict func apply ;
~~~

Any word is only entiteled to consume as much data as specified; it might produce any number of values on an intermediate data stack but return only as much values as specified -- i.e. any intermediate values on the intermediate data stack which are not to be returned are deleted.

~~~
>> : stack ( x -- (x) ) ( ) cons ;
>> : 2stack ( x y -- (y x) ) [ stack ] dip push ;
>> : 3stack ( x y z -- (z y x) ) [ 2stack ] dip push ;
>> : 4stack [ 3stack ] dip push ;
>> : 5stack [ 4stack ] dip push ;
~~~

~~~
>> : return-Maybe ( v -- mv ) ( \ Just ) cons ;
~~~

~~~
>> : bind-Maybe ( mv [v -- mv'] )
>>   over \ Nothing equal?
>>     [ drop ]
>>     [ [ top ] dip call ]
>>   if ;
~~~

~~~
>> : add-m ( mx my -- mz ) 2stack [ [ [ + return-Maybe ] bind-Maybe ] curry bind-Maybe ] apply' top ;
~~~

~~~
>> ( [ 2 Just ] ) [ 2 return-Maybe ] unit-test
>> ( 2 return-Maybe ) [ 2 return-Maybe [ return-Maybe ] bind-Maybe ] unit-test

>> ( 2 3 + return-Maybe ) [ 2 return-Maybe 3 return-Maybe add-m ] unit-test
>> ( \ Nothing ) [ \ Nothing 3 return-Maybe add-m ] unit-test
>> ( \ Nothing ) [ 2 return-Maybe \ Nothing add-m ] unit-test
>> ( \ Nothing ) [ \ Nothing \ Nothing add-m ] unit-test
~~~

~~~
>> : liftM2 ( mx my [q] -- mz )
>>   [ 2stack ] dip
>>   [ return-Maybe ] concat [ bind-Maybe ] curry [ curry bind-Maybe ] curry apply' top ;

>> ( 5 return-Maybe ) [ 2 return-Maybe 3 return-Maybe [ + ] liftM2 ] unit-test
>> ( 6 return-Maybe ) [ 2 return-Maybe 3 return-Maybe [ * ] liftM2 ] unit-test
>> ( \ Nothing ) [ 2 return-Maybe \ Nothing [ * ] liftM2 ] unit-test
>> ( \ Nothing ) [ \ Nothing 2 return-Maybe [ * ] liftM2 ] unit-test
>> ( \ Nothing ) [ \ Nothing \ Nothing [ * ] liftM2 ] unit-test
~~~

So we can redefine `add-m` as

~~~
>> : add-m ( mx my -- mz ) [ + ] liftM2 ;
~~~

The test cases still pass.

~~~
>> ( 2 3 + return-Maybe ) [ 2 return-Maybe 3 return-Maybe add-m ] unit-test
>> ( \ Nothing ) [ \ Nothing 3 return-Maybe add-m ] unit-test
>> ( \ Nothing ) [ 2 return-Maybe \ Nothing add-m ] unit-test
>> ( \ Nothing ) [ \ Nothing \ Nothing add-m ] unit-test
~~~

`join n = n >>= id`, type `M (M t) → M t`

~~~
>> : id ( x -- x ) dup drop ; % ensures having a stack effect
>> : join-Maybe ( m(mv) -> mv' ) [ id ] bind-Maybe ; % join flattens a monad

>> ( 3 return-Maybe ) [ 3 return-Maybe return-Maybe join-Maybe ] unit-test
~~~

`fmap f m = m >>= (return . f)`, type `(t → u) → M t → M u`

~~~
>> : fmap-Maybe ( mx [x -- y] -- my ) [ return-Maybe ] concat bind-Maybe ;

>> ( 6 return-Maybe ) [ 3 return-Maybe [ 2 * ] fmap-Maybe ] unit-test
~~~

## List Monad

Reference: https://www.schoolofhaskell.com/school/starting-with-haskell/basics-of-haskell/13-the-list-monad

https://en.wikibooks.org/wiki/Haskell/Understanding_monads/List

Bin mir bei `bind-List` nicht sicher, wie es arbeiten soll.

~~~
>> : return-List [ ] cons ;
>> : fmap-List over empty?
>>     [ drop ]
>>     [ swap uncons rot dup [ fmap-List ] curry bi* cons ]
>>   if ;
>> : fmap-List over empty?
>>     [ drop ]
>>     [ swap uncons rot dup [ fmap-List ] curry bi* cons ]
>>   if ;
>> : join-List dup empty?
>>   [ uncons join-List concat ] unless ;
>> : bind-List fmap-List join-List ;

>> ( ( 3 ) ) [ 3 return-List ] unit-test
>> ( ( 3 ) ) [ 3 return-List return-List join-List ] unit-test
>> ( ( 1 4 9 ) ) [ ( 1 2 3 ) [ dup * ] fmap-List ] unit-test
~~~