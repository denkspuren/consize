# Thinking about `let`

This code emulates some kind of a `let` word to bind a value (a quotation) to a word and use that word thereafter. It is inspired by Ocaml's `let v = a in ...` -- but be aware, this variant of a `let` has different semantics compared to Ocaml's.

To execute this code, type the following in Consize given that you fired up Consize in `/src`. Type `lrun` (not `run`) because this is a literate program.

```
\ ../research/let.md lrun
```

## Emulating `let`

A `let` expects a quotation `[ @Q ]` and a variable `Var`. The quotation is the context within which the variable is resolved to the value bound to the variable; let's assume that the quotation consumes `a..` values from the stack and leaves `b..` values on the stack. Word `let` returns a quotation. If called, the quotations takes a value from the stack and binds it to the variable. Besides, the called quotation has the stack effect of the quotation `[ @Q ]` being given. (Word `def-` is just a helper word.)


```
>> : def- ( w -- ) get-dict dissoc set-dict ;
```

```
>> : let ( [ @Q(a.. -- b..) ] Var -- [(a.. Val -- b..)] )
>>   [ [ ] cons [ call ] concat ] dip
>>     [ [ swap [ ] curry def  ] curry ]
>>     [ [                def- ] curry ]
>>   bi
>>   swapd concat concat ;
```

In the example, we use `let` in order to build a behaviorally equivalent version of `dup`. If `let` were primitive, there would be no need to define `dup`, `swap` etc. as primitives. (Be careful not to use and overwrite `X` or `Y`, because both words are defined in the prelude. `Y` is the anonymous recursion combinator, which relies on the `X` combinator.)

```
> [ X' X' ] \ X' let
[ \ X' swap [ ] curry def [ X' X' ] call \ X' def- ]
> 3 swap
3 [ \ X' swap [ ] curry def [ X' X' ] call \ X' def- ]
> call
3 3
```

## Getting rid of stack shufflers

With `let` we can easily define stack shufflers. There is no need for stack shufflers to be primitives anymore if `let` is given.

```
>> \ DUP [ X' X' ] \ X' let def
>> \ SWAP [ [ Y' X' ] \ X' let call ] \ Y' let def
>> \ ROT [ [ [ Y' X' Z' ] \ Z' let call ] \ Y' let call ] \ X' let def
>> \ DROP [ ] \ X' let def
```

The test confirm proper functioning.

```
>> [ x x ] [ x DUP ] unit-test
>> [ y x ] [ x y SWAP ] unit-test
>> [ y z x ] [ x y z ROT ] unit-test
>> [ ] [ x DROP ] unit-test
```

## Defining words with `let`

If `let` were primitive, we might enjoy getting rid of a dictionary. The dictionary is implicit by the bindings established with `let`. 

Here is a simple demonstration of that idea. We treat `DUP` and `SWAP` as variables and use them within the context of a quotation, here `2 DUP call` and `2 3 SWAP call`. As expected, the first expression leaves `2 2` on the stack, the second leaves `3 2` on the stack. Try it out by copying the programs to the Consize REPL.

```
[ X' X' ] \ X' let [ 2 DUP call ] \ DUP let call

[ [ Y' X' ] \ X' let call ] \ Y' let [ 2 3 SWAP call ] \ SWAP let call
```

## Discussion

Maybe, this kind of `let` is more properly called `lambda`.

## Unrelated: Partial application

For some reason, playing around with `let` let we think about partial application. That each word processes just one argument and is called with a _partial call_ (`pcall`) when there is a something left on the callstack.

```
>> : pcall get-ds pop empty? [ call ] unless ;
>> : SWAP/1 [ swap ] curry ;
>> : SWAP/2 SWAP/1 pcall ;
```

<!--
: DIP ( v q -- v ) swap [ ] curry concat call ;
-->

