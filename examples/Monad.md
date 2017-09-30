# Monad

A lot has been written about monads in functional programming. It is a concept of an almost mythological cult.

Here, I approach monads from a very technical point of view. No math (that means, no category), no philosophy, just the plain concept. Technically, monads are not that complicated.

A monad is three things: a type constructor `m` and two methods called `bind` and `return`. And that's it.

Simple, isn't it? Before you read on: What is a type constructor? This is just a way of saying that the notion of a monad is a generic concept. The letter `m` is not a specific monad but a placeholder for a specific monad. You might have heard about monads such as the `Maybe` monad, the `List` monad, the `IO` monad and so on. These monads are concrete monads of the generic concept of a monad `m`.

Because of _m_ being a placeholder, I called `bind` and `return` methods. As a matter of fact, `bind` and `return` are functions. Calling them methods should remind you that each specific monad has its own implementations of `bind` and `return`. The implementation of `bind` and `return` for the `Maybe` monad is completely different from the way how `bind` and `return` function for the `List` monad.







A monad type is written as _M a_ meaning: The monad _M_ encapsultates a type _a_. The Monad is a container that contains a value of type _a_. A monad comes with two methods called `bind` and `return`. In Haskell, `bind` is notated as `>>=`, which is used in infix notation (like `+` is used in between two numbers, the arguments to `+`). When I talk about "methods" I mean two functions which are specific for a certain monad. The implementation of `bind` and `return` for a monad called `Maybe` is completely different from the implementation of `bind` and `return` for another monad, say the `State` or `List` monad.

Method `return` expects a value of type _a_ and returns a monad `return` is a method of encapsulting that value. In Haskell, the type signature of that method is written as _a → Ma_. In short: Get a value of type _a_ in and get a monad with that value out, the type of that monad being _Ma_. In other words, `return` is a constructor method, it creates a monadic value. 

In Consize, type signature are notated in a different way. We would say that method `return` (called a _word_ in concatenative programming) expects a value of type _a_ on the data stack, takes it and leaves a new value, a monadic value of type _Ma_ on the data stack.

~~~
return ( a -- Ma )
~~~ 

The other method of a monad, `bind`, takes a monadic value of type _Ma_ and a function. The function takes a value of type _a_ and returns a new monadic value of type _Mb_. The return value of `bind` is a monadic value of type _Mb_. The type signature of `bind` reads as _Ma → (a → Mb) → Mb_.


 The notation _M a_ is taken from Haskell. In Haskell, _a_ is a type variable. One and the same monad 

    

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

### `add-m'` and `do`



~~~
2stack
do [ bind-Maybe ]
  curry |
  + return-Maybe
;
top
~~~

: SPREAD ( [ quot1 ... quotn ] -- ... ) % def inspired by Factor
  ( ) [ swap dup empty?
          [ drop ]
          [ [ dip ] rot concat cons ]
        if ]
  reduce ;

: spread ( itm1 ... itmn [ quot1 ... quotn ] -- ... ) SPREAD call ;

Source of the following code: https://en.wikibooks.org/wiki/Haskell/do_notation

~~~
do { x1 <- action1
   ; x2 <- action2
   ; mk_action3 x1 x2 }
~~~

~~~
action1 >>= (\ x1 -> action2 >>= (\ x2 -> mk_action3 x1 x2 ))
~~~

~~~
( [ action1 ]
  [ action2 ]
  [ action3 ... ] )
[ bind ] do
~~~

action1 [ action2 [ action3 ... ] bind ] bind 

~~~
>> : add-m' ( mx my -- mz ) 2stack
>>   [ [ [ + return-Maybe ] bind-Maybe ] curry bind-Maybe ] apply' top ;
~~~

( [ ]
  [ [ ] curry ]
  [ + return-Maybe ]
)
[ bind-Maybe ] do


`bind` means: Take a value and if you do not call the function, abort the execution context of the monad.

So find means to notate bind in sequential order with the option to skip the rest of the computation.

## `if`-Monade

Nach dem Schema: Wenn Wert nicht legitim, dann verwerfe den Anufruf der Funktion, ansonsten rufe sie auf. Das erfordert aber schon eine andere Entscheidungsqualität, sonst nicht umsetzbar.

: id dup drop ;
: return-When id ;
: bind-When over true equal? 

## `join` and `fmap`

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