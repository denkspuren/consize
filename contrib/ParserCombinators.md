
# Parser Combinators

This module implements parser combinators for consize, that are built on top of the default prelude.
Using this module you're able to create and compose primitive parsers.
Note, that words prefixed by -- are meant to be internal/private.

```consize
>> 
>> %%% Parser Combinators for consize
>>
>> %%% This library is very much inspired by [Scala's Parser Combinators](https://github.com/scala/scala-parser-combinators/) library.
>> 
```

<!-- TOC depthFrom:2 -->

- [Conventions](#conventions)
- [Auxiliary definitions](#auxiliary-definitions)
- [Parse Results](#parse-results)
    - [Encoding](#encoding)
    - [Words](#words)
- [Parsers](#parsers)
    - [Encoding](#encoding-1)
    - [Constant parsers, Using parsers](#constant-parsers-using-parsers)
    - [Parsers, that parse single elements](#parsers-that-parse-single-elements)
    - [Parser Combinators: Parsers that depend on other parser's input](#parser-combinators-parsers-that-depend-on-other-parsers-input)
    - [Parser Combinators, that transform parse-results](#parser-combinators-that-transform-parse-results)
    - [Parser Combinators, for sequential parser composition](#parser-combinators-for-sequential-parser-composition)
    - [Parser Combinators, for alternative parser composition](#parser-combinators-for-alternative-parser-composition)
    - [Parser Combinators, for optional parsing](#parser-combinators-for-optional-parsing)
    - [Parser Combinators, for repeated parsing](#parser-combinators-for-repeated-parsing)
    - [Parser Combinators, for lazy composition](#parser-combinators-for-lazy-composition)

<!-- /TOC -->

## Conventions

Words that are prefixed by `--` are meant to be private and used by this module only.

## Auxiliary definitions

This module requires a few auxiliary definitions.

```consize
>> : --stack ( x -- [ x ] ) ( ) cons ;
>> : --glue ( wrd1 wrd2 -- wrd1wrd2 ) [ unword ] bi@ concat word ;
>> : --getn ( key map -- val/nil ) nil get ;
>> 
>> 
```
The word `--stack` creates a singleton list. `--glue` is for concating two words and `--getn` is short for "get or else nil", which uses nil as the default value for looking up values in maps.

## Parse Results

```consize
>> % ================================ parse results =================================
>> 
>> 
```

Parse-results capture the notion of successful and non-successful parsing attempts.

### Encoding

They are modeled using maps, that have a certain structure. It is presented below.

```consize
{
  \ status  success|error|failure
  \ input   $input

  % one of the following fields
  \ message $message
  \ value   $value
}
```

- `status`: The value of the field `status` is one of the words `success`, `error` or `failure`. It is used to differientiate the outcome of the parse-attempt.
- `input`: The field `input` contains a list with the remaining input, that was not consumed by the parser.
- `message` or `value`: Depending on the value of field `status`, a parse-result either has the field `message` or `value`. Non-successful (failed or erroneous) parse-results have an error message, whereas successful parse-results contain the value, that was returned by the parser.

The differentiation that is made between erroneous and failed parse-results is a result of backtracking. See [`parser-or`](#parser-combinators-for-alternative-parser-composition).

### Words

There are three auxiliary words, that help constructing the maps with the described structure.

```consize
>> : --parse-result-common ( reminput status -- parse-result' ) \ status { } assoc \ input swap assoc ;
```
A word that implements common behavior for all constructors.

```consize
>> : parse-result-success ( val rem -- parse-result ) \ success --parse-result-common \ value swap assoc ;
```
`parse-result-success` will construct a successful parse-result given the value 'val' and the remaining input 'rem'.

```consize
>> : parse-result-failure ( msg rem -- parse-result ) \ failure --parse-result-common \ message swap assoc ;
```
`parse-result-failure` will construct a failed (non-successful) parse-result given the message 'msg' and the remaining input 'rem'.

```consize
>> : parse-result-error ( msg rem -- parse-result ) \ error --parse-result-common \ message swap assoc ;
>> 
```
`parse-result-error` will construct an erroneous (non-successful) parse-result given the message 'msg' and the remaining input 'rem'.

```consize
>> : --parse-result-success-value-input ( succ-res -- value input ) dup \ value swap --getn swap \ input swap --getn ;
>> 
>> 
```
`--parse-result-success-value-input` extracts the `value`-field and the `input`-field from a successful parse-result.

## Parsers

```consize
>> % =================================== parsers ====================================
>> 
>> 
```

### Encoding

A parser conceptionally is a function, that takes a list as its input and returns a parse-result.
Currently a parser in this library is encoded as a quotation, that implements described behavior.

Parsers created using this library are value-parsers.
That is, that they can't just be used to parse strings, but also to accept and recognize patterns on arbitrary lists of values.

### Constant parsers, Using parsers

```consize
>> : parser-quotation ( quot -- parser ) ;
>> 
>> 
```
The simplest possible parser (`parser-quotation`) is constructed from a quotation that implements the described behavior (accepting a list of values and returning a parse-result).
Always use this constructor word to create a parser from a quotation, since the parsers' representation might change.

```consize
>> : parser-run ( parser input -- parse-result ) swap call ;
>> 
>> 
```
The word `parser-run` runs the parser on the given input, returning a parse-result.

```consize
>> : --parser-const-result ( val mk-parse-result -- parser ) --stack \ swap push swap push parser-quotation ;
```
Using `parser-quotation` the parser-combinator `--parser-const-result` can be built, that helps to define constant parsers.
Constant parsers are parsers, that don't consume any input and have a constant behavior.

```consize
>> : parser-success ( val -- parser ) \ parse-result-success --parser-const-result ;
```
The word `parser-success` returns a constant parser, that will always succeed returning the value `val` as the parse-result's `value`.

```consize
>> : parser-failure ( msg -- parser ) \ parse-result-failure --parser-const-result ;
```
The word `parser-failure` returns a constant parser, that will always fail returning the message `msg` as the parse-result's `message`.

```consize
>> : parser-error ( msg -- parser ) \ parse-result-error --parser-const-result ;
>> 
>> 
```
The word `parser-error` returns a constant parser, that will always return a erroneous parse-result with the `message` `msg`.

### Parsers, that parse single elements

```consize
>> : --x-expected-but-y ( x y -- w )
>>   swap repr
>>   ( <space> \ expected, <space> \ but <space> \ got <space> ) word
>>   --glue swap repr --glue ;
>> : --x-expected-but-empty ( x -- w )
>>   repr ( <space> \ expected, <space> \ but <space> \ input <space> \ is <space> \ empty ) word --glue ;
>> 
```

```consize
>> : parser-item ( val -- parser )
>>   [ swap dup empty?
>>     [ [ --x-expected-but-empty ] dip parse-result-failure ]
>>     [ dup top rot dup rot equal?
>>       [ swap pop parse-result-success ]
>>       [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ]
>>       if
>>     ]
>>     if
>>   ] curry parser-quotation ;
>> 
```
The word `parser-item` returns a parser, that exactly accepts 'val' as the first element of the input.
If the parser, returned by this word is run against an input that starts with `val` a successful parse-result is returned, consisting of the `value` `val` and the rest of the input. If the input doesn't start with `val` (or is empty), a failed parse-result is returned. Word `--x-expected-but-y` (and `--x-expected-but-empty`) are used to create the appropriate error-messages.

```consize
>> : --predicate-mismatch ( elem quot -- w )
>>  swap repr
>>  ( <space> \ is <space> \ expected <space> \ to <space> \ match <space> \ predicate <space> ) word
>>  --glue swap repr --glue
>>  ( \ , <space> \ but <space> \ it <space> \ doesn't ) word --glue ;
>> : --predicate-mismatch-empty ( quot -- w )
>>  repr
>>  ( \ the <space> \ first <space> \ element <space> \ of <space>
>>    \ the <space> \ input <space> \ is <space> \ expected <space>
>>    \ to <space> \ match <space> \ predicate <space>
>>  ) word
>>  swap --glue
>>  ( \ , <space> \ but <space> \ the <space> \ input <space> \ is  <space> \ empty )
>>  word --glue ;
>> 
```

```consize
>> : parser-predicate ( pred -- parser )
>>   [ swap dup empty?
>>     [ [ --predicate-mismatch-empty ] dip parse-result-failure ]
>>     [ swap dup rot dup top rot call
>>       [ swap drop unpush swap parse-result-success ]
>>       [ dup top rot --predicate-mismatch swap parse-result-failure ]
>>       if
>>     ]
>>   if
>>   ] curry parser-quotation ;
>> 
>> 
```
The word `parser-predicate` returns a parser, that matches the predicate against the first element of the input, returning a successful parse-result and consuming the element, if the predicate matches and a failed parse-result if it doesn't (or the input is empty). `--predicate-mismatch` (or `--predicate-mismatch-empty`) is used to generate an error message in the non-successful case.

### Parser Combinators: Parsers that depend on other parser's input

```consize
>> : parser-flatmap ( parser quot -- parser' )
>>   [ swap rot parser-run dup \ status swap --getn
>>     \ success equal?
>>     [ swap drop ]
>>     [ --parse-result-success-value-input rot rot --stack swap get-dict func 
>>       apply unstack swap parser-run
>>     ]
>>     if-not
>>   ] 2curry parser-quotation ;
>> 
>> 
```
Using `parser-flatmap` one can construct a parser, that depends on the value parsed by another one.
`parser-flatmap` returns a parser, that first uses the underlying parser `parser`. On success, the `value`-field of the parse-result is passed to `quot`, which has to yield a parser.
This newly created parser will be run on the remaining input returned by `parser`.

### Parser Combinators, that transform parse-results

```consize
>> : parser-map ( parser quot -- parser' )
>>   [ swap rot parser-run swap get-dict func swap dup \ status swap --getn
>>     \ success equal?
>>     [ swap drop ]
>>     [ dup \ value swap --getn --stack rot apply unstack \ value rot assoc ] if-not
>>   ] 2curry parser-quotation ;
>> 
```
The word `parser-map` returns a parser, that runs the underlying parser `parser`. On success, `quot` is used to transform the `value`-field of the parse-result.

```consize
>> : parser-tag ( parser tag -- parser' ) swap [ { } assoc ] rot push \ \ push parser-map ;
>> 
```
`parser-tag` constructs a parser, that uses the underlying parser `parser` und puts its resulting `value` in the case of a successful parsing attempt into a map. `tag` is used as the key.

```consize
>> : parser-onsuccess ( parser quot -- parser' ) \ drop push parser-map ;
>> 
>> 
```
`parser-onsuccess` is very similar to `parser-map`. Instead of transforming the parse-results `value`-field, `parser-onsuccess` will discard the value and use the value prodived by `quot`. Note that `quot` can be an arbitrary computation, but must yield a single value.

### Parser Combinators, for sequential parser composition

```consize
>> : parser-and ( a b -- parser )
>>   [ -rot swap parser-run dup \ status swap --getn \ success equal?
>>     [ swap drop ]
>>     [ --parse-result-success-value-input rot swap parser-run dup \ status swap --getn \ success equal?
>>       [ swap drop ]
>>       [ --parse-result-success-value-input -rot --stack swap push swap parse-result-success ]
>>       if-not
>>     ]
>>     if-not
>>   ] 2curry parser-quotation ;
>> 
```
The word `parser-and` composes the parsers `a` and `b`.
The composed parser, first tries to parse the input using `a` and then tries to parse the remaining input using `b`.
If both parsers succeed, a successful parse-result is returned, having a list of exactly two elements as its `value`: the values returned by `a` and `b`.

```consize
>> : parser-append-map ( a b quot -- parser' )
>>   -rot parser-and swap \ unstack push parser-map ;
>> 
```
`parser-append-map` is a combination of `parser-and` and `parser-map` for convenience.
`quot` has to be a quotation, that accepts the outputs from `a` and `b` and returns a value.

```consize
>> : parser-append-left ( a b -- parser ) [ drop ] parser-append-map ;
>> 
```
`parser-append-left` returns a parser, that parses the input by sequentially appling `a` and then `b` (using the `parser-append-map` combinator) and finally discarding the value parsed by `b` only returning `a`'s value.

```consize
>> : parser-append-right ( a b -- parser ) [ swap drop ] parser-append-map ;
>> 
```
`parser-append-right` returns a parser, that parses the input by sequentially appling `a` and then `b` (using the `parser-append-map` combinator) and finally discarding the value parsed by `a` only returning `b`'s value.

```consize
>> : parser-between ( parser before after -- parser' )
>>   swapd [ parser-append-right ] dip parser-append-left ;
>> 
```
`parser-between` is a combination of `parser-append-left` and `parser-append-right`.
This word creates a parser, that sequentially tries to parse `before`, `parser` and `after`, discarding the parse-results from `before` and `after` and returning `parser`'s result.

```consize
>> : parser-append-merge ( a b -- parser ) [ merge ] parser-append-map ;
>> 
>> 
```
The word `parser-append-merge` requires two tagged-parsers `a` and `b` and returns a parser that parses the input by sequentially appling `a` and then `b` (using the `parser-append-map` combinator) and merging the resulting maps.

### Parser Combinators, for alternative parser composition

```consize
>> : parser-or ( a b -- parser )
>>   [ -rot [ dup ] dip swap parser-run
>>     dup \ status swap --getn dup \ success equal? swap \ error equal? or
>>     [ [ drop drop ] dip ]
>>     [ drop parser-run ]
>>     if
>>   ] 2curry parser-quotation ;
>> 
```
`parser-or` returns a parser, that first tries to parse the input using `a`.
Then it behaves differently, depending on `a`'s parse-result:

- On success `a`'s parse-result is returned.
- On error `a`'s parse-result is returned, propagating the error.
- On failure `b` is executed on the original input to construct the parse-result.

Note that this word implements backtracking of failed parsers.

```consize
>> : --empty-choice ( -- msg ) ( \ empty <space> \ choice ) word ;
>> 
```

```consize
>> : parser-choice ( list-of-parsers -- parser )
>>   dup empty?
>>   [ drop --empty-choice parser-error ]
>>   [ unpush [ parser-or ] reduce ]
>>   if ;
>> 
>> 
```
`parser-choice` returns a parser, that is a disjunction of all parsers given in the sequence `list-of-parsers`.
If the sequence is empty, a parser is returned that always errors using the error-message provided by `--empty-choice`.

### Parser Combinators, for optional parsing

```consize
>> : parser-opt ( parser -- parser' ) [ --stack ] parser-map ( ) parser-success parser-or ;
>> 
>> 
```
`parser-opt` returns a parser, that tries to parse the input using `parser`.
And then, depending on `parser`s result behaves as follows:

- On success, a singleton-list containing the value from `parser`s parse-result is returned.
- On failure, an empty list is returned.
- On error, the error is propagated.

### Parser Combinators, for repeated parsing

```consize
>> : --parser-rep1-with-first-rec ( parser in0 acc -- parse-result )
>>   -rot 2dup parser-run
>>   dup \ status swap --getn dup \ success equal?
>>   [ drop [ drop ] dip
>>     dup \ value swap --getn
>>     swap \ input swap --getn
>>     swap rot4 swap push
>>     --parser-rep1-with-first-rec
>>   ]
>>   [ \ error equal?
>>     [ [ drop drop drop ] dip ]
>>     [ drop [ drop reverse ] dip parse-result-success ]
>>     if
>>   ]
>>   if ;
>> 
```

```consize
>> : parser-rep1-with-first ( first rest -- parser )
>>   [ -rot swap parser-run dup \ status swap --getn \ success equal?
>>     [ dup \ input swap --getn swap \ value swap --getn --stack --parser-rep1-with-first-rec ]
>>     [ swap drop ]
>>     if
>>   ] 2curry parser-quotation ;
>> 
```
`parser-rep1-with-first` returns a parser, that will parse the input using `first`.
On success it tries to repeatedly parse the remaining input using `rest` until a failure happens.
(This is done in the auxiliary word `--parser-rep1-with-first-rec`).
The values of the successful parse-results are accumulated in a list.
This word is similar to `parser-rep1`, but it lets you specify the parser, which is used for the first element.

```consize
>> : parser-rep1 ( parser -- parser' ) dup parser-rep1-with-first ;
>> 
```
The word `parser-rep1` returns a parser, that will repeatedly (but at least once) be used to parse the input using `parser`, collecting the values of successful parse-results in a list.
The resulting list will have at least a single element.

```consize
>> : parser-rep ( parser -- parser' ) parser-rep1 ( ) parser-success parser-or ;
>> 
```
The word `parser-rep1` returns a parser, that will repeatedly be used to parse the input using `parser`, collecting the values of successful parse-results in a list.
This parser might produce an empty list, if nothing could be parsed.

```consize
>> : parser-rep1sep ( parser sep -- parser' )
>>   swap dup [ swap ] dip parser-append-right parser-rep
>>   [ swap push ] parser-append-map ;
>> 
```
`parser-rep1sep` returns a parser, that will repeatedly (but at least once) be used to parse the input using `parser`, collecting the values of successful parse-results in a list.
Between each run of `parser` `sep` is used to parse a seperator.
The values of the separator-parser are not collected.

```consize
>> : parser-repsep ( parser sep -- parser' ) parser-rep1sep ( ) parser-success parser-or ;
>> 
```
`parser-repsep` returns a parser, that will repeatedly be used to parse the input using `parser`, collecting the values of successful parse-results in a list.
Between each parse of `parser` `sep` is used to parse seperator elements.
The values of the separator-parser are not collected.
This parser might produce an empty list, if nothing could be parsed.

```consize
>> : parser-chainl1-with-first ( first rest quotparser -- parser' )
>>   swap parser-and parser-rep parser-and
>>   [ unstack swap
>>     [ unstack swap call ] reduce
>>   ] parser-map ;
>> 
```
`parser-chainl1-with-input` constructs a parser, that (similar like `parser-rep1-with-first`) works like the word `parser-chainl1`, but it lets you specify the parser used for the first element.

```consize
>> : parser-chainl1 ( parser quotparser -- parser' ) dupd parser-chainl1-with-first ;
>>
>> 
```
`parser-chainl1` creates a parser that, roughly, generalises the `parser-rep1sep` generator so that `quotparser`, which parses the separator, produces a left-associative function that combines the elements it separates.
Note, that the documentation of this word is taken from [Scala's Parser Combinators](https://github.com/scala/scala-parser-combinators/) library.

%% Parser Combinators, for lazy composition

```consize
>> : parser-lazy ( quot -- parser ) [ call swap parser-run ] curry parser-quotation ;
```
The word `parser-lazy` creates a parser, that when run, evaluates the quotation `quot` and runs the produced parser on the input.
Using this word, it is possible to lazify another parser, which is necessary for recursively defined parsers.

