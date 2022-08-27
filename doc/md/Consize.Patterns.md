# Patterns and Rewriting Rules

When you write a program in Consize, you are essentially defining just a
set of new words. A new word is defined in terms of a sequence of other
words. That's it.

While this sounds simple, reading and understanding a program is not. If
you go through a program word by word, your brain finds itself easily
overloaded by some few stack shuffling operations. Our brains are not
perfectly suited for keeping track of what is left where on the
datastack.

Take the definition of `each` as an example.

    : each ( seq quot -- ... )
      swap dup empty?
        [ 2drop ]
        [ unpush -rot over [ call ] 2dip each ]
      if ;

The definition is not really complex, but even the stack effect
description does not turn out to be helpful. A sequence and a quotation
is expected on the datastack, but what exactly is going on here? What is
the result on the datastack? If you are somewhat trained, you will see
that `each` just drops both the sequence and the quotation if the
sequence is empty. But if the sequence is not empty, the behavior of
`each` is not self-explanatory.

Our brains are much better at recognizing patterns instead of shuffling
data on a stack. In this chapter, we introduce a very simple notation
for patterns and learn how to use pattern-based rewriting rules to
describe the transformational effects a word has on the datastack as
well as on the callstack.

## Pattern Matching and Instantiation

Let us define pattern matching and pattern instantiation with the help
of two imaginary words, `match` and `instantiate`. Both words are not
defined in the Prelude, but they could have been. Their existence is not
of importance, we use them here to explain what pattern matching and
instantiation is and what it means.

The word `match ( stk pat -- matches/f )` expects two stacks on the
datastack with `pat` being the pattern the stack `stk` is matched
against. The result is a mapping of `matches` or `f`. Let's have a look
at an example, assuming that the word `match` would actually be
available at the console.

    > clear [ 1 2 3 4 ] [ #H 2 @T ] match
    { #H 1 @T [ 3 4 ] }

The word `match` compares both stacks item by item from left to right
(i.e. from top to bottom), nesting included. If the pattern item is a
word with a hash symbol (`#`) as its first character, the pattern item
is said to match the corresponding data item on the stack. If the
pattern item is a word with an at sign (`@`) as its first character, the
pattern item matches the rest of the stack. Otherwise, if the pattern
item is neither a `#`- nor an `@`-matcher, the pattern item must match
the data item exactly. The resulting mapping is an assembly of matchers
and matched values. If something goes wrong, `f` (for *false*) is left
on the datastack instead.

In the above example the pattern `[ #H 2 @T ]` only matches successfully
(not returning `f`) if the supplied stack contains *at least* two items
with the second item being a `2`. A `#`-matcher requires the data item
to exist. Here, `#H` matches the very first item, namely `1`, and `@T`
matches the rest of the stack which is `[ 3 4 ]`. By convention, the
symbols of a word denoting a matcher are written in upper case.

Without matchers, `match` would simply compare for equality and return
an empty mapping in case of success or `f` for failure. If there are no
matchers in the pattern, the resulting mapping is empty.

    > clear [ ] [ ] match
    { }
    > clear [ 1 2 3 4 ] [ 1 2 3 4 ] match
    { }
    > clear [ 1 2 3 4 ] [ 1 2 3 1 ] match
    f
    > clear [ 1 2 3 4 ] [ 1 2 3 ] match
    f

Pattern `[ @T ]` matches any stack successfully, even if the matched
stack is empty.

    > clear [ 1 2 3 4 ] [ @T ] match
    { @T [ 1 2 3 4 ] }
    > clear [ ] [ @T ] match
    { @T [ ] }

The following examples should help you validate your understanding of
the concept of matching a pattern against a stack. Note that `#H`
demands that there is a data item to match against.

    > clear [ ] [ #H ] match
    f
    > clear [ ] [ #H @T ] match
    f
    > clear [ 1 ] [ #F ] match
    { #F 1 }
    > clear [ 1 ] [ #F #S ] match
    f
    > clear [ 1 ] [ #F @R ] match
    { #F 1 @R [ ] }

Usually, `#H` means "head", `@T` "tail", and `#F`, `#S`, `@R` typically
stand for "first", "second" and "rest", respectively.

::: exercise
[]{#ex:match label="ex:match"} What is the result of the following
`match`es?

    > clear [ 1 [ 2 3 ] 4 ] [ #X #Y #Z ] match
    > clear [ 1 [ 2 3 ] 4 ] [ #X @Y ] match
    > clear [ 1 [ 2 3 ] 4 ] [ #X #Y #Z #U ] match
    > clear [ 1 2 3 ] [ #X #Y #X ] match
    > clear [ 1 2 1 ] [ #X #Y #X ] match
:::

Patterns with nested stacks enable the extraction of parts of nested
stacks.

    > clear [ [ 1 { 2 3 } 4 5 ] 6 7 ] [ [ #F #S @R ] @T ] match
    { #F 1 #S { 2 3 } @R [ 4 5 ] @T [ 6 7 ] }
    > clear [ [ 1 { 2 3 } 4 5 ] 6 7 ] [ #1 @2 ] match
    { #1 [ 1 { 2 3 } 4 5 ] @2 [ 6 7 ] }

The opposite of pattern matching is *pattern instantiation*. Taking a
mapping and a stack pattern, word `instantiate` replaces `#`- and
`@`-matchers in the pattern with their corresponding values and returns
the resulting stack. More specifically, a `#`-matcher is replaced by the
associated value, a `@`-matcher is replaced by the sequences of values
of the associated stack.

    > clear { #H 1 @T [ 2 3 ] } [ #H @T ] instantiate
    [ 1 2 3 ]

In the example, `#H` gets replaced by `1` and `@T` by the sequence of
associated elements, `2` and `3`.

::: exercise
[]{#Ex:instantiate label="Ex:instantiate"} What is the result of the
following instantiations?

    > clear { #X 1 #Y 2 } [ #X 1 #Y 2 ] instantiate
    > clear { @T [ 2 3 ] #H 4 } [ #H #H @T ] instantiate
:::

## Rewriting Rules

A rewriting rule consists of two patterns: one pattern describes pattern
matching, the other pattern instantiation. Let us call the matching
pattern `m-pat` and the instantiation pattern `i-pat`. Rewriting a stack
according to a rewriting rule means: first match the stack against
`pat-m` and then use the result to instantiate `i-pat`, see the
definition of word `rewrite`. If matching or instantiation fails, the
result is `f`.

    : rewrite ( stk m-pat i-pat -- stk'/f )
      [ match ] dip over [ instantiate ] [ drop ] if ;

For example, the notion of swapping the two topmost items on a stack can
be expressed by the following rewriting rule: `[ #F #S @R ]`, the
matching pattern, deconstructs a given stack into a first and second
item and remaining items; the instantiation pattern `[ #S #F @R ]`
constructs a stack with two items and some remaining items. Observe that
in the instantiation pattern `#F` and `#S` are interchanged. A rewriting
rule composed of these two patterns does exactly the job of swapping the
two topmost elements on a given stack. If the stack does not have enough
items rewriting fails.

    > clear [ x y z u v ] [ #F #S @R ] [ #S #F @R ] rewrite
    [ y x z u v ]
    > clear [ x ] [ #F #S @R ] [ #S #F @R ] rewrite
    f

Remember that a continuation captures the state of a computation in
Consize and consists of two stacks, the datastack and the callstack.[^1]
For example, the continuation of the program `1 2 3 swap` just right
before interpreting word `swap` reads as

    [ [ swap ] [ 3 2 1 ] ]

The outer stack serves as a container for the continuation and contains
the callstack (being topmost) and the datastack underneath with `3`
being the topmost item on the datastack.

The following rule describes rewriting the continuation if and only if
`swap` is the topmost element on the callstack. The rewriting rule fails
if there are not at least two elements on the datastack of the
continuation.

    [ [ swap @RCS ] [ #Y #X @RDS ] ] [ [ @RCS ] [ #X #Y @RDS ] ]

The notation of the rewriting rule is a bit awkward and not very
readable. We will agree on interchanging the datastack and the callstack
and write them head-to-head with a separating bar (`|`) in between;
consequently, the elements of the datastack appear in reverse order. In
addition, we include an arrow (`=>`) between the matching and the
instantiating pattern. The outer squared brackets are being removed.

    @RDS #X #Y | swap @RCS => @RDS #Y #X | @RCS

Since we assume `@RDS` (rest of datastack) and `@RCS` (rest of
callstack) to be present by default, we eliminate their mentioning and
indicate so by using a different arrow (`->`). If nothing else effects
the callstack, the bar symbol can be omitted on the right hand side of
the rule.[^2]

    #X #Y | swap -> #Y #X

This style of a rewriting rule for a continuation looks pretty cool and
is easy to grasp. Some more examples for some well-known words are:

    #X | dup -> #X #X
    #X | drop -> 
    #X #Y #Z | rot -> #Y #Z #X
    [ @S ] #X | push -> [ #X @S ]

A rewriting rule is much more precise than a stack effect description
is. We can use rewriting rules in addition to or as a substitute for
stack effect descriptions to get a clear understanding of the stack
manipulations a words does. Stack rewriting patterns are much more
expressive for human readers.

::: exercise
[]{#ex:over.etc label="ex:over.etc"} Write down the rewriting rules for
`over`, `2drop`, `empty?` and `-rot`.
:::

Rewriting rules have another nice feature. We can use them to track the
state of a computation when we try to understand a word by resolving and
analyzing its definition in a stepwise word-by-word approach. The
approach is easy to learn and to perform.

## Describing and Analyzing Words with Rewriting Rules

Sometimes, the behavior of a word depends on the values or on the
structure of some data on the datastack. Different data patterns require
different matching patterns and possibly different instantiating
patterns. In such cases more than one rewriting rule is needed to
properly describe a word's behavior.

Take for example word `top`. Word `top` returns the topmost item of a
stack; this is the standard behavior, so to speak. If the stack is
empty, `nil` is left of the datastack. And `top` applied on `nil` also
returns `nil`. These three alternative behaviors require three rewriting
rules.

    [ #H @T ] | top -> #H
          [ ] | top -> nil
          nil | top -> nil

In the same way the following rewriting rules mirror the behavior of
word `pop`. The order of rules is important if the pattern matching
parts are not exclusive to each other.

    [ #H @T ] | pop -> @T
          [ ] | pop -> [ ]

Using all of the above rewriting rules, one can systematically conclude
the rewriting rule(s) of e.g. a word such as `unpush`.

    : unpush ( stk -- stk' itm ) dup pop swap top ;

Even if we would not know the stack effect of `unpush`, a step-by-step
analysis of the defining words unveils everything we need to know: The
rewriting rule for `dup` tells us that there must be an item on the
datastack and that the item is duplicated. The rewriting rules for the
following `pop` refine this knowledge: the duplicated item must be a
stack, either empty or at least with one item, which determines the
result of `pop`. The rewriting rule for `swap` interchanges the two
topmost items on the datastack, and the rewriting rule for `top` gives
us the two possible results. Thus we conclude the rewriting rules for
`unpush` to be

          [ ] | unpush ->    [ ] nil
    [ #H @T ] | unpush -> [ @T ] #H 

Although our analysis is informal and *ad hoc*, this example
demonstrates how valuable rewriting rules are in understanding the
"stack mechanics" of a word. The rewriting rules translate the behavior
of `unpush` to a simple mapping of input patterns to output patterns.
The rules with their matchers support a very visual style of
illustrating the way a word transforms some input to some output. In
contrast, the definition of `unpush` is significantly less
self-explaining; the stack effect description serves as a reminder on
what the word does on the datastack, but the stack effect description is
less informative than the rewriting rules are.

The expressivity of rewriting rules includes recursion: at least one
rule represents the base case and at least one more rule represents the
case of repetition. Take the rewriting rules for reversing the elements
of a stack. If the stack is empty, there is nothing to do. Otherwise,
the first element of the stack is attached to the end of the reversed
stack; here is where recursion comes in.

          [ ] | reverse -> [ ]
    [ #H @T ] | reverse -> [ @T ] | reverse [ #H ] concat

Often, there is more than one way to express a certain behavior. If the
pattern extracts the very last element of a stack (an option we rarely
make use of), the element must be pushed to the top of the reversed
stack.

          [ ] | reverse -> [ ]
    [ @H #T ] | reverse -> [ @H ] | reverse \ #T push

Another alternative is defined as follows; we will make use of this very
definition of `reverse` later on.

          [ ] | reverse -> [ ]
    [ @H #T ] | reverse -> [ #T ] [ @H ] | reverse concat

::: exercise
[]{#ex:size label="ex:size"} Try to conclude the rewriting rules for
`size` taking the following definition:

    : size ( stk -- n ) dup empty? [ drop 0 ] [ pop size 1 + ] if ;
:::

In an instantiation pattern the combined use of two or more `@`-matchers
might be useful, see e.g. `concat` below. In a matching pattern two or
more `@`-matchers cause ambiguities. Pattern matching must be
unambiguous.

    [ @S1 ] [ @S2 ] | concat -> [ @S1 @S2 ]

::: exercise
[]{#ex:concat label="ex:concat"} You have to use pattern `[ #H @T ]` in
an alternative set of rewrite rules for `concat`.
:::

## Examples

### `call/cc`, `continue` and `call`

Since a rewriting rule refers to a continuation, the rules for `call/cc`
and `continue` are easy to conclude. Notice that the double arrow `=>`
indicates that the patterns for matching and instantiation must address
each stack in its entirety.

    @RDS [ @Q ] | call/cc @RCS => [ @RDS ] [ @RCS ] | @Q
    @RDS [ @DS ] [ @CS ] | continue @RCS => @DS | @CS

::: exercise
[]{#ex:clearA label="ex:clearA"} Guess what the rewriting rule for
`clear` looks like.
:::

In Consize, `call` is defined by a manipulation of the current
continuation. The topmost element on the datastack must be a quotation
(a stack), which is concatenated with the callstack.

    : call
      [ swap unpush rot concat continue ] call/cc ;

Let us conclude the rewriting rule for `call` by systematically applying
the rewriting rules we already have. A prolonged arrow indicates
intermediate steps in the chain of reasoning.

    @RDS [ @Q ] | call @RCS ==>
    @RDS [ @Q ] | [ swap unpush rot concat continue ] call/cc @RCS ==>
    @RDS [ @Q ] [ swap unpush rot concat continue ] | call/cc @RCS ==>
    [ [ @Q ] @RDS ] [ @RCS ] | swap unpush rot concat continue
    [ @RCS ] [ [ @Q ] @RDS ] | unpush rot concat continue ==>
    [ @RCS ] [ @RDS ] [ @Q ] | rot concat continue ==>
    [ @RDS ] [ @Q ] [ @RCS ] | concat continue ==>
    [ @RDS ] [ @Q @RCS ] | continue ==>
    @RDS | @Q @RCS

We can thus conclude that the rewriting rule for `call` is:

    [ @Q ] | call -> | @Q

The above analysis is straight forward and explicates what you would
mentally do in order to understand the consequences of stack shuffling
and stack manipulations. Rewriting rules formalize this mental process
and make it more systematic rather than intuitive.

::: exercise
[]{#ex:clearB label="ex:clearB"} Provide a sound analysis of the
rewriting rule for `clear`. Look up the definition for `clear` up and
base your analysis on the definition.
:::

::: exercise
[]{#ex:backslash label="ex:backslash"} The backslash word can be defined
as follows (as it actually is by the implementation of Consize):

    : \ [ dup top rot swap push swap pop continue ] call/cc ;

Provide a step-by-step analysis of the rewriting rule of `\`.
:::

The exercise shows that any backslashed item will be moved on top of the
datastack; so does any backslashed stack, which is -- of course -- just
an item.

    \ [ @S ] -> [ @S ] |

Since any stack will be moved to the datastack by default

    [ @S ] -> [ @S ] |

we can conclude that it does not matter whether a stack is backslashed
or not. (Note the bar symbol in the following rewriting rule!)

    \ [ @S ] -> | [ @S ]

::: exercise
[]{#ex:rewritingVM label="ex:rewritingVM"} Did you realize that
rewriting rules allow us to formulate most of the internals of the
Consize VM? Which words resist being represented as rewriting rules?
:::

### `dip` and `2dip`

The meaning of most combinators is hard to remember, and stack effects
are only a poor aid to memory. Rewriting rules come to the rescue. We
exemplify this on `dip` and `2dip`.

    : dip ( x quot -- x ) [ ] rot push \ \ push concat call ;

Resolving the definition of `dip` via rewriting rules leads to:

    #X [ @Q ] | dip -->
    #X [ @Q ] | [ ] rot push \ \ push concat call -->
    #X [ @Q ] [ ] | rot push \ \ push concat call -->
    [ @Q ] [ ] #X | push \ \ push concat call -->
    [ @Q ] [ #X ] | \ \ push concat call -->
    [ @Q ] [ #X ] \ | push concat call -->
    [ @Q ] [ \ #X ] | concat call -->
    [ @Q \ #X ] | call -->
    | @Q \ #X 

Word `dip` works almost like `call` with the item in front of the
quotation removed from the scope of the call and attached after the
call. One dead-simple rule of one line suffices to comprehend the
semantics of `dip`.

    #X [ @Q ] | dip -> | @Q \ #X

The definition of `2dip` relies on `dip`. Once you get an understanding
of the workings of `dip`, it is not so hard to find out how `2dip`
works.

    : 2dip ( x y quot -- x y ) swap [ dip ] dip ;

The resolution of the definition of `2dip` shows that two items in front
of the quotation are being "saved" before and "restored" after the call.

    #X #Y [ @Q ] | 2dip -->
    #X #Y [ @Q ] | swap [ dip ] dip -->
    #X [ @Q ] #Y | [ dip ] dip -->
    #X [ @Q ] #Y [ dip ] | dip -->
    #X [ @Q ] | dip \ #Y -->
    | @Q \ #X \ #Y

During the application of rewriting rules, one risks to mix up with the
names of pattern matchers in other rewriting rules -- but that is all
there is to take care of. To summarize, the rewriting rules for `2dip`
is:

    #X #Y [ @Q ] | 2dip -> | @Q \ #X \ #Y

::: exercise
[]{#ex:keep.bi label="ex:keep.bi"} Derive the rewriting rules for `keep`
and `bi`.
:::

### `t` and `f`, `choose` and `if`

The rules defining the meaning of `t` (*true*) and `f` (*false*) are
also strikingly simple. So are the helper words `true` and `false`.

    : t ( this that -- this ) drop ;
    : f ( this that -- that ) swap drop ;
    : true  ( -- t ) \ t ;
    : false ( -- f ) \ f ;

Without further ado we can conclude that:

    #T #F | t -> #T
    #T #F | f -> #F
    true -> t
    false -> f

As you might have realized by now, a set of rewriting rules may
substitute the dictionary as a storage for the meaning of any kind of
word, be it atomic or composite. That is why word `lookup` does not make
much sense in the context of rewriting rules: rewriting rules cannot be
looked up. Mimicking the existence of a dictionary by a set of rules for
`lookup` such as

    t | lookup -> [ drop ]
    f | lookup -> [ swap drop ]

points to the absurdity of maintaining a simulated dictionary in
addition to rewriting rules. That's not practical at all.

However, the sequence of `lookup` and `call` is unproblematic and can be
meaningfully expressed by a single rewriting rule. Moving an item from
top of the datastack to the top of the callstack lets us stay inside the
system of rewriting rules without referencing the notion of a global
dictionary.

    #W | lookup call -> | #W

Now, the definition of `choose` becomes tractable to an analysis with
rewriting rules.

    : choose ( f/* this that -- that/this )
      swap rot false equal? lookup call ;

We first investigate having `f` as the third item on the datastack.

    f #T #F | choose -->
    f #T #F | swap rot false equal? lookup call -->
    f #F #T | rot false equal? lookup call -->
    #F #T f | false equal? lookup call -->
    #F #T f | \ f equal? lookup call -->
    #F #T f f | equal? lookup call -->
    #F #T t | lookup call -->
    #F #T | t -->
    #F

The investigation of not having `f` but any other item -- matched by
`#ELSE` -- on the third position of the datastack looks very similar.

::: exercise
[]{#ex:choose.ELSE label="ex:choose.ELSE"} Do the analysis of `choose`
for `#ELSE`.
:::

Finally, the two rules for `choose` are:

        f #T #F | choose -> #F
    #ELSE #T #F | choose -> #T

Given `choose` and `call`, we can deduce the rewriting rule for `if`.

    : if ( f/* then else -- ... ) choose call ;

The application and resolution of the rewriting rules is a no-brainer;
we can save us the two-step analysis and write down the results
immediately.

        f [ @T ] [ @F ] | if -> | @F
    #ELSE [ @T ] [ @F ] | if -> | @T

In case of `f` word `if` `choose`s the "second" quotation and `call`s
it; in case of anything `#ELSE`, the "first" quotation is `choose`n and
`call`ed.

Whenever there is an `if` in the definition of a word, the `if` can
usually be transformed into two rewriting rules. One rule covers the
case for *falsity*, the other all remaining cases.

::: exercise
[]{#ex:if* label="ex:if*"} Deduce the rewriting rules for `if*`.
:::

### `each` and `map`

Let us come back to the introductory example of word `each`. We have
everything in place to analyze how `each` translates to rewriting rules.

    : each ( seq quot -- ... )
      swap dup empty?
        [ 2drop ]
        [ unpush -rot over [ call ] 2dip each ]
      if ;

If the supplied sequence is empty, `each` is done and simply drops both
the quotation and the sequence. To save space, the second quotation to
`if` is noted as `[ ... ]`.

    [ ] [ @Q ] | each -->
    [ ] [ @Q ] | swap dup empty? [ 2drop ] [ ... ] if -->
    [ @Q ] [ ] | dup empty? [ 2drop ] [ ... ] if -->
    [ @Q ] [ ] [ ] | empty? [ 2drop ] [ ... ] if -->
    [ @Q ] [ ] t | [ 2drop ] [ ... ] if -->
    [ @Q ] [ ] | 2drop -->
    |

If the supplied sequence is not empty, we work with `[ #H @T ]` as the
matching pattern, which enforces the stack not to be empty. In the
following analysis we skip testing for emptiness and jump right into the
`if`-case for *false*. Remember that for any backslashed stack on the
callstack the backslash can be removed, see
exercise [\[ex:backslash\]](#ex:backslash){reference-type="ref"
reference="ex:backslash"}.

    [ #H @T ] [ @Q ] | each -->
    [ @Q ] [ #H @T ] | unpush -rot over [ call ] 2dip each -->
    [ @Q ] [ @T ] #H | -rot over [ call ] 2dip each -->
    #H [ @Q ] [ @T ] | over [ call ] 2dip each -->
    #H [ @Q ] [ @T ] [ @Q ] | [ call ] 2dip each -->
    #H [ @Q ] | call \ [ @T ] \ [ @Q ] each -->
    #H | @Q [ @T ] [ @Q ] each

What `each` does is maybe hard to analyze but easy to describe with
patterns: `each` takes one element after another from a given sequence
of elements and calls the given quotation on each of the elements.

          [ ] [ @Q ] | each -> |
    [ #H @T ] [ @Q ] | each -> #H | @Q [ @T ] [ @Q ] each

We will finish our examples with `map`. Word `map` is defined in terms
of `each`.

    : map ( seq quot -- seq' )
      [ push ] concat [ ] -rot each reverse ;

The rewriting rule up to `each` is easy to derive in your head, which is
enough to understand the semantics of `map`: Word `map` applies the
quotation `[ @Q push ]` on `each` element of sequence `[ @S ]`; the
extra `push` ensures that the result of calling `[ @Q ]` on each element
is moved on a result collecting stack, which is initially empty. Since
pushing elements on the result stack does reverse the order of the
results, `reverse` restores the order.

    [ @S ] [ @Q ] | map -> [ ] [ @S ] [ @Q push ] | each reverse

Note that the correct functioning of `map` requires that the called
quotation `[ @Q ]` consumes exactly one element from the datastack and
leaves exactly one element on the datastack. If this assumption is not
fulfilled, the semantics and the execution of `map` gets corrupted.

It is possible to formalize this constraint using the following
notation, saying: The expression on the left hand side (LHS) is
equivalent (`==`) to the expression on the right hand side (RHS). The
expression on the RHS matches (and must match, that is the constraint)
the result of resolving the expression on the LHS.

    #X | @Q == #Y

Things get interesting and advanced, if we apply the rewriting rules for
`each` and `reverse` so that our explanation of the behavior of `map`
does depend neither on `each` nor on `reverse`.

If `[ @S ]` matches an empty stack, the terminating behavior of `map` is
three derivation steps away.

    [ ] [ @Q ] | map -->
    [ ] [ ] [ @Q push ] | each reverse -->
    [ ] | reverse -->
    [ ]

If `[ @S ]` matches a non-empty stack, we use `[ #H @T ]` instead.

    [ #H @T ] [ @Q ] | map -->
    [ ] [ #H @T ] [ @Q push ] | each reverse -->
    [ ] #H | @Q push [ @T ] [ @Q push ] each reverse -->
    (to be continued)

For `[ ] #H | @Q push` we know it to be a stack with a single element,
say `[ #R ]`, because of the above mentioned constraint. Therefore, we
could -- just to make things clearer -- also write for the last rule:

    [ #R ] | [ @T ] [ @Q push ] each reverse -->

We also know that `[ @T ] [ @Q push ] each` will continue to push
elements on top of `[ #R ]`. In other words, `[ #R ]` is the *last*
element of a growing stack that is to be `reverse`d after all. It takes
some thinking to see that the rules for `reverse` open up a nice
"trick".

          [ ] | reverse -> [ ]
    [ @H #T ] | reverse -> [ #T ] [ @H ] | reverse concat

If `[ @T ] [ @Q push ] each` can be managed to be a stack on its own, so
that it can represent `[ @H ]` in the second rewriting rule of
`reverse`, we have the means to resolve `reverse` once. The introduction
of an empty stack does the trick.

    [ #R ] | [ @T ] [ @Q push ] each reverse -->
    [ #R ] | [ ] [ @T ] [ @Q push ] each reverse concat -->
    (to be continued)

Recognize that a part of the rewriting expression looks familiar: it is
a map expression!

    [ #R ] | [ ] [ @T ] [ @Q push ] each reverse concat -->
    [ #R ] | [ @T ] [ @Q ] map concat

To summarize the rules for `map`: Word `map` applies quotation `[ @Q ]`
to each element of a given stack and assembles the results in a stack.

          [ ] [ @Q ] | map -> [ ]
    [ #H @T ] [ @Q ] | map -> [ ] #H | @Q push [ @T ] [ @Q ] map concat

We might use a feature of Consize, namely parentheses, that resembles
much better the notion of `[ #R ]` than the above expression does.

          [ ] [ @Q ] | map -> [ ]
    [ #H @T ] [ @Q ] | map -> | ( \ #H @Q ) [ @T ] [ @Q ] map concat

The analysis for `map` is challenging. But that is due to the formal
nature of rewriting rules. The approach not only feels mathematical, it
actually is mathematical. Computing is formal and requires analytical
skills, sharp thinking and sometimes an creative insight on how to
proceed in the chain of reasoning. It can be quite hard to perform a
solid analysis. Occasionally, it is easier to "guess" the rewriting rule
instead of deriving it from a word's definition.

::: exercise
[]{#ex:reduce label="ex:reduce"} What are the rewriting rules for
`reduce`? Please resolve `each` as well and formulate the constraint
that applies to `reduce`.
:::

::: exercise
[]{#ex:reduce.examples label="ex:reduce.examples"} Word `reduce` is a
very powerful and expressive word, so it is important to get acquainted
with it. Define the following words using `reduce`; no conditionals like
`if` are required! Hint: This exercise is not about rewriting rules but
word definitions.

-   `sum ( stk -- n )` takes a stack of numbers and returns the sum of
    the numbers.

-   `my-size ( stk -- n )` takes a stack and returns the number of
    elements of the stack. Note: `size` is already defined in Consize;
    the challenge is to find an alternative implementation using
    `reduce`.

-   `my-reverse ( stk -- stk' )` takes a stack of items and returns a
    stack with the items in reversed order. Note: `reduce` is an atomic
    words in Consize for performance reasons. Find an implementation
    using `reduce`.

In addition, write some unit tests to verify correct behavior of your
definitions. Do not forget to consider processing an empty stack.
:::

::: exercise
[]{#ex:concat.reduce label="ex:concat.reduce"} Challenge: Define word
`my-concat` (which is behaviorally equivalent to `concat`) using *only*
stacks and the words `swap`, `push` and `reduce`. Write some unit tests
to verify correct behavior of your definition.
:::

::: exercise
[]{#ex:filter label="ex:filter"} What are the rewriting rules for
`filter`?
:::

## Closing Remarks

Rewriting rules help you quite much in understanding concatenative
programs. You might ask, why we do not define words with rewriting
rules, which looks and feels simpler. Why is a word in Consize always
defined in terms of other words besides atomic ones?

As a matter of fact, many programming languages, mostly functional and
logic programming languages, offer some kind of [pattern
matching](http://en.wikipedia.org/wiki/Pattern_matching) for a good
reason: functions or relations become much more readable and
understandable.

However, in a language like Consize, rewriting rules for word
definitions do more harm than good. It would mess up the design
philosophy of a concatenative language. In a concatenative language,
quotations (representing programs) are built up from smaller quotations
by concatenation. The smallest fragment of a program is a quotation
which consists of a single word or data item. Semantically, quotations
correspond to functions and concatenation to function composition.

The notion of named and unnamed abstractions builds upon the idea of
concatenation and function composition, respectively, which implies a
strictly layered program design and scales seamlessly from atomic words
up to the architectural level; it features refactoring and favors the
use and detection of design patterns in a way which is unparalleled in
the world of programming languages. Rewriting rules do not share these
properties and do not blend in a concatenative language.

Take the rewriting rules for `map` and `each` as an example. Looking at
the rules, both words seem to be completely unrelated. Considering the
word definitions in Consize, the relationship between `map` and `each`
is so obvious that you cannot ignore it; it tells you much more about
inner dependencies of words than rewriting rules ever could do. In
Consize, you design even tiny programs very much like you would do on an
architectural level. Rewriting rules, in contrast, focus on input/output
relationships rather than on compositional aspects.

To conclude: Concatenative languages are great for their compositional
style of programming and somewhat bad at disclosing input/output
relationships in terms of stack effects. Rewriting rules excel at
revealing stack effects (even on the level of continuations) but do not
enforce a compositional style of programming.

We could combine the best of both worlds and use rewriting rules as a
formal and superior notation for stack effect descriptions. That means
that you are writing word definitions twice: on the one hand as a word
made of a sequence of other words and items; on the other hand as a set
of rewriting rules to lay out stack effects. Such an approach supports a
very consistent and sound regimen on software engineering. Some machine
assisted help could support the programmer in deducing the rewriting
rules or the word definition.

Some historic remarks: In their bachelor thesis, two of my students,
Florian Eitel and Aaron Müller, implemented an interpreter for rewriting
rules in Ruby. Their work was awarded by the Thomas Gessmann foundation.
Another student of mine, Tim Reichert, was so much inspired by the
pattern system outlined in this chapter that he continued to develop it
further and extend it even to meta patterns. His impressive work is
documented in [his PhD thesis](http://nrl.northumbria.ac.uk/4385/).[^3]

## Solutions

You cannot really know but you might have guessed correctly that in the
last two cases `#X` demands the very same value to appear anywhere `#X`
asks for a match.

    > clear [ 1 [ 2 3 ] 4 ] [ #X #Y #Z ] match
    { #X 1 #Y [ 2 3 ] #Z 4 }
    > clear [ 1 [ 2 3 ] 4 ] [ #X @Y ] match
    { #X 1 @Y [ [ 2 3 ] 4 ] }
    > clear [ 1 [ 2 3 ] 4 ] [ #X #Y #Z #U ] match
    f
    > clear [ 1 2 3 ] [ #X #Y #X ] match
    f
    > clear [ 1 2 1 ] [ #X #Y #X ] match
    { #X 1 #Y 2 }

The solutions are

    > clear { #X 1 #Y 2 } [ #X 1 #Y 2 ] instantiate
    [ 1 1 2 2 ]
    > clear { @T [ 2 3 ] #H 4 } [ #H #H @T ] instantiate
    [ 4 4 2 3 ]

The rewriting rules almost match the stack effect descriptions.

    #X #Y | over -> #X #Y #X
    #X #Y | 2drop -> |
      [ ] | empty? -> t
    #ELSE | empty? -> f
    #X #Y #Z | -rot -> #Z #X #Y

The solution is

          [ ] | size ->        | 0
    [ #H @T ] | size -> [ @T ] | size 1 +

The first solution is almost a no-brainer: move the very first item of
the topmost stack to the end of the second stack.

    [ @S ] [ ] | concat -> [ @S ]
    [ @S ] [ #H @T ] | concat -> [ @S #H ] [ @T ] concat

The second solution shows how elements from the leftmost stack get
pushed to the rightmost stack pertaining the order of elements.

    [ ] [ @S ] | concat -> [ @S ]
    [ #H @T ] [ @S ] | concat -> [ @T ] [ @S ] | concat \ #H push

You need a continuation pattern to express what `clear` does. It empties
the datastack.

    @RDS | clear @RCS => | @RCS

The definition of word `clear` relies on word `set-ds`.

    : set-ds ( stk -- ) [ swap top swap continue ] call/cc ;
    : clear ( -- ) [ ] set-ds ;

    @RDS | clear @RCS ==>
    @RDS | [ ] set-ds @RCS ==>
    @RDS [ ] | set-ds @RCS ==>
    @RDS [ ] | [ swap top swap continue ] call/cc @RCS ==>
    @RDS [ ] [ swap top swap continue ] | call/cc @RCS ==>
    [ [ ] @RDS ] [ @RCS ] | swap top swap continue ==>
    [ @RCS ] [ [ ] @RDS ] | top swap continue ==>
    [ @RCS ] [ ] | swap continue ==>
    [ ] [ @RCS ] | continue ==>
    | @RCS

In the analysis, sometimes two words are rewritten at once.

    @RDS | \ #I @RCS ==>
    @RDS | [ dup top rot swap push swap pop continue ] call/cc #I @RCS ==>
    @RDS [ dup top rot swap push swap pop continue ] | call/cc #I @RCS ==>
    [ @RDS ] [ #I @RCS ] | dup top rot swap push swap pop continue ==>
    [ @RDS ] [ #I @RCS ] #I | rot swap push swap pop continue ==>
    [ #I @RCS ] #I [ @RDS ] | swap push swap pop continue ==>
    [ #I @RCS ] [ #I @RDS ] | swap pop continue ==>
    [ #I @RDS ] [ @RCS ] | continue ==>
    @RDS #I | @RCS

The rewriting rules refer to stack transformations only. We have not
introduced adequate means to rewrite mappings or to rewrite words, I/O
activities etc. The scope of rewrite rules is limited and involves only
stack shufflers, stack words and continuations.

The solutions according to the following definitions are:

    : keep  ( x quot -- x ) [ dup ] dip dip ;
    : bi ( x p q -- ) [ keep ] dip call ;

    #X [ @Q ] | keep -->
    #X [ @Q ] | [ dup ] dip dip -->
    #X [ @Q ] [ dup ] | dip dip -->
    #X | dup \ [ @Q ] dip -->
    #X #X | \ [ @Q ] dip -->
    #X #X [ @Q ] | dip -->
    #X | @Q \ #X

    #X [ @P ] [ @Q ] | bi -->
    #X [ @P ] [ @Q ] | [ keep ] dip call -->
    #X [ @P ] [ @Q ] [ keep ] | dip call -->
    #X [ @P ] | keep \ [ @Q ] call -->
    #X | @P \ #X [ @Q ] call -->
    #X | @P \ #X @Q

No solution provided. I think you can do the analysis yourself, don't
you?!

The assumption is that you can derive the rewriting rules for `pick` and
`2nip` yourself and use them in the process of concluding the rewriting
rules for `if*`.

    : if* ( f/* [ @T ] [ @F ] )
      pick [ drop call ] [ 2nip call ] if ;

    f [ @T ] [ @F ] | if* -->
    f [ @T ] [ @F ] | pick [ drop call ] [ 2nip call ] if -->
    f [ @T ] [ @F ] f [ drop call ] [ 2nip call ] | if -->
    f [ @T ] [ @F ] | 2nip call -->
    [ @F ] | call -->
    | @F

    #ELSE [ @T ] [ @F ] | if* -->
    #ELSE [ @T ] [ @F ] | pick [ drop call ] [ 2nip call ] if -->
    #ELSE [ @T ] [ @F ] #ELSE [ drop call ] [ 2nip call ] | if -->
    #ELSE [ @T ] [ @F ] | drop call -->
    #ELSE [ @T ] | call -->
    #ELSE | @T

In contrast to `if`, word `if*` keeps the value for "truth".

The definition of `reduce` is suprinsingly close to `each`.

    : reduce ( seq identity quot -- res ) [ swap ] dip each ;

    [ @S ] #I [ @Q ] | reduce -->
    [ @S ] #I [ @Q ] | [ swap ] dip each -->
    [ @S ] #I [ @Q ] [ swap ] | dip each -->
    #I [ @S ] [ @Q ] | each

What is the purpose of item `#I`? Why does it matter? The resolution of
`each` helps getting the point.

          [ ] [ @Q ] | each -> |
    [ #H @T ] [ @Q ] | each -> #H | @Q [ @T ] [ @Q ] each

          [ ] #I [ @Q ] | reduce --> |
    [ #H @T ] #I [ @Q ] | reduce --> #I #H | @Q [ @T ] [ @Q ] each

Word `reduce` is only meaningful if `@Q` processes two items on the
datastack, namely `#I` and `#H`, and leaves exactly one item on the
datastack. This constraint can be expressed by

    #X #Y | @Q == #Z

Item `#I` serves as a sort of accumulator; `reduce` gets called with an
initial value for the accumulator and continues to be updated with each
turn of `each`.

The solutions are:

    : sum ( stk -- n ) 0 [ + ] reduce ;
    : my-size ( stk -- n ) 0 [ drop 1 + ] reduce ;
    : my-reverse ( stk -- stk' ) [ ] [ push ] reduce ;

Here is a proposal for a minimal set of unit tests: the base case (empty
stack) and some other scenario is tested.

    [ 0 ] [ [ ] sum ] unit-test
    [ 10 ] [ [ 1 2 3 4 ] sum ] unit-test
    [ 0 ] [ [ ] my-size ] unit-test
    [ 4 ] [ [ x x x x ] my-size ] unit-test
    [ [ ] ] [ [ ] my-reverse ] unit-test
    [ [ 3 2 1 ] ] [ [ 1 2 3 ] my-reverse ] unit-test

The key point is using `reduce` in the definition of `my-concat`.

    : my-concat ( stk1 stk2 -- stk3 )
      swap reverse [ push ] reduce reverse ;

Now, resolve word `reduce` (see `my-reduce` in
exercise [\[ex:reduce.examples\]](#ex:reduce.examples){reference-type="ref"
reference="ex:reduce.examples"}) and you are done.

    : my-concat ( stk1 stk2 -- stk3 )
      swap [ ] [ push ] reduce [ push ] reduce [ ] [ push ] reduce ;

The following four types of unit tests are a must!

    [ [ 1 2 3 4 5 6 7 ] ] [ [ 1 2 3 ] [ 4 5 6 7 ] my-concat ] unit-test
    [ [ 1 2 3 ] ] [ [ 1 2 3 ] [ ] my-concat ] unit-test
    [ [ 4 5 6 7 ] ] [ [ ] [ 4 5 6 7 ] my-concat ] unit-test
    [ [ ] ] [ [ ] [ ] my-concat ] unit-test

The definition of `filter` adds some code to `quot` and then runs `each`
and `reverse`.

    : filter ( seq quot -- seq' )
      [ dup ] swap concat
      [ [ push ] [ drop ] if ] concat
      [ ] -rot each reverse ;

From the analysis experience you have you might see that

    [ ] [ @Q ] | filter --> [ ]

It is not much meaningful to go too much into depth with the standard
case.

    [ #H @T ] [ @Q ] | filter -->
    [ ] [ #H @T ] [ dup @Q [ push ] [ drop ] if ] | each reverse

This rule looks very much like a resolved `map`; in fact, it works like
a `map` for all elements in the given sequence for which
`#H | @Q true and == t`. The elements which do not satisfy the predicate
are dropped and not included in the resulting sequence.

[^1]: A full continuation includes the dictionary as well.

[^2]: If there is no bar symbol on the left hand side (LHS) or right
    hand side (RHS) of a rewriting rule, assume the bar symbol to be on
    the outmost left on the LHS and on the outmost right on the RHS.
    That means, the LHS represents the callstack if the bar is missing,
    and the RHS represents the datastack if the bar is missing.

[^3]: Reichert, Tim (2011): *A Pattern-based Foundation for
    Language-Driven Software Engineering*, Doctoral thesis, Northumbria
    University, Newcastle (UK)
