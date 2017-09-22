## Partial Application

**Table of Contents**

<!-- TOC -->

- [Partial Application](#partial-application)
    - [A Partial Call with `call/1`](#a-partial-call-with-call1)
    - [Implementation of "safe" words](#implementation-of-safe-words)
        - [One argument: `not'` and `call/1`](#one-argument-not-and-call1)
        - [Two arguments: `+'` and `call/2`](#two-arguments--and-call2)
        - [Three arguments: `rot'` and `call/3`](#three-arguments-rot-and-call3)
        - [Four arguments: `call/4`](#four-arguments-call4)
    - [Concluding thoughts](#concluding-thoughts)
    - [Unit Tests](#unit-tests)

<!-- /TOC -->

What does [_partial application_](https://en.wikipedia.org/wiki/Partial_application) mean? If you apply a function to less arguments than required (that's why it is called _partial_ application), the result is not an error. Instead, a new function is returned which awaits application to the reamining arguments. If the new function is applied to the remaining arguments the new function returns the result as if the original function were called with all required arguments. By the way, the new function might be subject to partial application as well.

In short: You call a function with fewer arguments than required, which gives you a new function that lets you supply the remaining arguments later on, partially or completely.

Consize doesn't support partial application out of the box. All primitive functions are _unsafe_ in that respect. If you do not provide enough arguments to, say, `+`, you'll notice an error.

~~~
> 2 +
[ 2 ] [ + printer repl ] error
~~~

Subsequently, we provide a variant of `+` named `+'`, which uses partial application.

Assumed that you run Consize within the `src` folder, type the following to load the definitions and execute the tests provided in this document. All lines preceeded by `>>` are executed if you call `lrun` for executing a literate program.

~~~
> \ ../examples/PartialApplication.md lrun
~~~

### A Partial Call with `call/1`

The auxiliary word `agr?` is a predicate and checks whether there is at least one element on the data stack or not.

~~~
>> : arg? ( ? -- t/f ) get-ds empty? not ;
~~~

In concatenative programming quotations are the equivalent of functions in applicative functional languages. The application of a function corresponds to calling a quotation. To limit the `call` of a quotation to _one_ argument only, we define `call/1`. If the argument exists the quotation is called -- business a usual. If the argument is missing on the data stack, `call/1` returns a new quotation (a new function). The point is that the new quotation uses [curring](https://en.wikipedia.org/wiki/Currying) and remains partial using `call/1`. 

~~~
>> : call/1 ( ? [ q ] -- n | q  or  [ q ] )
>>   [ arg? ] dip swap [ call ] [ [ call/1 ] curry ] if ;
~~~

Let's run a simple example. Call `dup` partially with no arguments on the data stack. A new quotation is generated.

~~~
> clear [ dup ] call/1
[ \ [ dup ] call/1 ]
~~~

You might `call` the quotation which changes nothing at all, because there is still an argument missing on the data stack.

~~~
> call
[ \ [ dup ] call/1 ]
~~~

Formally speaking, the quotation is a fix point with respect to `call`.

~~~
> [ call ] Y
[ \ [ dup ] call/1 ]
~~~

If the missing argument is given, the call of the quotation resolves to the expected result.

~~~
> 2 swap call
2 2
~~~

If the argument is given right at the beginning the result is the same, of course.

~~~
> clear 2 [ dup ] call/1
2 2
~~~

### Implementation of "safe" words

By "safe" I mean words which use partial application and do not go crazy if arguments are missing. Three examples are given with increasing numbers of arguments so that you can see the template of constructing definitions using partial calls.

#### One argument: `not'` and `call/1`

Let `not'` (read "not prime") be the safe variant of `not`; `not` negates a boolean value. The definition is easy and resembles the above example with `dup` and `call/1`.

~~~
>> : not' [ not ] call/1 ;
~~~

I guess the interaction is clear.

~~~
> true not'
f
> clear true not'
f
> clear not'
[ \ [ not ] call/1 ]
> true swap call
f
~~~

#### Two arguments: `+'` and `call/2`

Two arguments are a bit more tricky to handle. See the definition of a "safe" variant of addition, `+'` ("plus prime"), below. If the outer `call/1` discovers an argument, the quotation is called which pulls the argument inside `[ + ]` (that's essentially what `curry` does) and the inner `call/1` awaits the second argument.  

~~~
>> : +' [ [ + ] curry call/1 ] call/1 ;
~~~

Let's try this out with no arguments at all.

~~~
> clear +'
[ \ [ \ [ + ] curry call/1 ] call/1 ]
> 2 swap call
[ \ [ \ 2 + ] call/1 ]
> 3 swap call
5
~~~

Works wonderfully. If all arguments are supplied, `+'` works like `+`.

~~~
> clear 2 3 +'
5
~~~

An alternative implementation for `+'` demonstrates how the quotation `[ + ]` can be factored out.

~~~
: +' [ + ] [ curry call/1 ] curry call/1 ;
~~~

The refactoring leads the way to define `call/2` and redefine `+'`.

~~~
>> : call/2 [ curry call/1 ] curry call/1 ;
>> : +' [ + ] call/2 ;
~~~

#### Three arguments: `rot'` and `call/3`

Here is the basic idea of how the definition is constructed: Assumed that two arguments are already given, we can capture both arguments via `curry` and issue a `call/1` for the third and final argument. That is what the code in the inner quotation does. Now let's work outwards. To capture the first and the second argument, we need further `call/1` words. The additional `curry` in the outer quotation is there to place the first argument just in front of `[ rot ]`.

~~~
>> : rot' [ [ [ rot ] curry curry call/1 ] curry call/1 ] call/1 ;
~~~

If we factor out the quotation `[ rot ]`, we know how to define `call/3` and redefine `rot'`.

~~~
: rot' [ rot ] [ [ curry curry call/1 ] curry curry call/1 ] curry call/1 ;
~~~

~~~
>> : call/3 [ [ curry curry call/1 ] curry curry call/1 ] curry call/1 ;
>> : rot' [ rot ] call/3 ;
~~~

#### Four arguments: `call/4`

You might notice the schema. This is how `call/2` and `call/3` are structured.

~~~
: call/2 [ curry call/1 ] curry call/1 ;
: call/3 [ [ curry curry call/1 ] curry curry call/1 ] curry call/1 ;
~~~

It's quite obvious how `call/4` is to be defined:

~~~
>> : call/4 [ [ [ curry curry curry call/1 ] curry curry curry call/1 ] curry curry curry call/1 ] curry call/1 ;
~~~

Run an experiment with `call/4`. We define the sum of four elements from the data stack, `sum/4`.

~~~
>> : sum/4 [ + + + ] call/4 ;
~~~

It works like a charm.

~~~
> clear 1 2 3 4 sum/4
10
> clear 2 3 4 sum/4 1 swap call
10
~~~

### Concluding thoughts

It took me some time to see how easy partial application is with `call/1`. Prior attempts didn't let me factor out "safeguarded" quotation, which hints to a bad design in concatenative programming.

However, the question is how useful partial application in a concatenative environment is. Evaluating code like `clear 1 +' 3 *'` raises a problem (`*'` is meant to be a safe `*`). `1 +'` leads to a quotation representing the partial application (a partial call). Meaning there is no number, yet. Evaluation continues with `3` and `*'`. Multiplication requires two arguments and is doomed, you cannot multiply a number with a quotation.

~~~
> : *' [ * ] call/2 ;

> clear 1 +' 3 *'
[ 3 [ \ [ \ 1 + ] call/1 ] ] [ * printer repl ] error
~~~

Similarly, `clear 1 +' dup'` duplicates the quotation of the partial call, which produces nonsense.

~~~
> : dup' [ dup ] call/1 ;

> clear 1 +' dup'
[ \ [ \ 1 + ] call/1 ] [ \ [ \ 1 + ] call/1 ]
~~~

Partial calls only make sense if evaluation continues as if the data stack were empty afterwards. If evaluation would work that way, the following results are to be expected:

~~~
> clear 1 +' 3 *'
[ \ [ \ 1 + ] call/1 ] [ \ [ \ 3 * ] call/1 ]
> clear 1 +' dup'
[ \ [ \ 1 + ] call/1 ] [ \ [ dup ] call/1 ]
~~~

Such an evaluation strategy might lead to code which is resolved to primitive words only. Interpretation as compilation. I need to further investigate this idea.

### Unit Tests

~~~
>> ( 1 true  ) [ 1 arg? ] unit-test
>> (   false ) [   arg? ] unit-test

>> ( 2 dup ) [ 2 [ dup ] call/1 ] unit-test
>> (   [ dup ] call/1 ) [ [ dup ] call/1        call ] unit-test
>> ( 2 [ dup ] call/1 ) [ [ dup ] call/1 2 swap call ] unit-test

>> (   [ + ] call/2 ) [ [ + ] call/2 call ] unit-test
>> ( 3 [ + ] call/2 ) [ 3 [ + ] call/2 call ] unit-test
>> ( 2 3 [ + ] call/2 ) [ 3 [ + ] call/2 2 swap call ] unit-test
>> ( 2 3 [ + ] call ) [ 2 3 [ + ] call/2 ] unit-test

>> ( [ rot ] call/3 ) [ [ rot ] call/3 call ] unit-test
>> ( 3 [ rot ] call/3 ) [ 3 [ rot ] call/3 call ] unit-test
>> ( 2 3 [ rot ] call/3 ) [ 2 3 [ rot ] call/3 call ] unit-test
>> ( 1 2 3 [ rot ] call ) [ 1 2 3 [ rot ] call/3 ] unit-test
>> ( 1 2 3 [ rot ] call ) [ 3 [ rot ] call/3 2 swap call 1 swap call ] unit-test
>> \ testing println
>> ( [ + + + ] call/4 ) [ [ + + + ] call/4 call ] unit-test
>> ( 4 [ + + + ] call/4 ) [ 4 [ + + + ] call/4 call ] unit-test
>> ( 1 2 3 4 [ + + + ] call ) [ 1 2 3 4 [ + + + ] call/4 ] unit-test
>> ( 1 2 3 4 [ + + + ] call ) [ [ + + + ] call/4 4 swap call 3 swap call 2 swap call 1 swap call ] unit-test
~~~
