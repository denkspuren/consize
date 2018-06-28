
# Algebraic Data Types

```consize
>> 
>> %%% Algebraic Data Types for consize
>>
>> 
```

This module introduces algebraic data types (ADTs) in consize, defines syntax for their definitions and implements pattern matching for adt-values.
It depends on the default prelude and the `Parser Combinators` library.

- [Conventions](#conventions)
- [Auxiliary definitions](#auxiliary-definitions)
- [Algebraic Data Types](#algebraic-data-types)
    - [Idea](#idea)
    - [Encoding](#encoding)
    - [Syntax Extension](#syntax-extension)
        - [Parser for the syntax extension](#parser-for-the-syntax-extension)
        - [Introducing words](#introducing-words)
        - [Extending the syntax](#extending-the-syntax)
    - [Pattern Matching for ADTs](#pattern-matching-for-adts)
        - [Patterns available for matching](#patterns-available-for-matching)
        - [Unapplying adt values](#unapplying-adt-values)
        - [Machinery for Pattern matches](#machinery-for-pattern-matches)

## Conventions

Words that are prefixed by `--` are meant to be private and used by this module only.

## Auxiliary definitions

```consize
>> % ============================ auxiliary definitions =============================
>> 
```

This chapter will introduce some auxiliary definitions, used by this module.

```consize
>> : --flatten ( seqofseqs -- seq ) ( ) [ concat ] reduce ;
```
The word `--flatten` flattens a sequence of sequences by concatenating the nested ones.

```consize
>> : --2swap ( a b c d -- c d a b ) [ -rot ] dip -rot ;
```
The word `--2swap` swaps two 2-tuples (pairs) of values.

```consize
>> : --override ( seq v -- seq' ) [ swap drop ] curry map ;
```
`--override` returns a new sequence `seq'`, where each value in the sequence `seq` is replaced by `v`.

```consize
>> : --replicate ( n v -- seq ) swap 1 swap [a,b] swap --override ;
```
`--replicate` constructs a sequence `seq`, by repeating the value `v` `n` times.

```consize
>> : --contains ( seq v -- t/f ) [ equal? ] curry filter empty? not ;
```
The word `--contains` checks if the sequence `seq` contains the value `v`.

```consize
>> : --contains-all ( haystack needles -- t/f ) swap [ swap --contains ] curry all? ;
>>
>> 
```
The word `--contains-all` checks if `needles` is a subset of `haystack`.

```consize
>> : --pred-and ( x y -- pred' )
>>   [ [ over ] dip --2swap call
>>     [ call ] [ 2drop false ] if
>>   ] 2curry ;
>> 
```
The word `--pred-and` produced a predicate `pred'` that is the combination of the two predicates `a` and `b`.

## Algebraic Data Types

In this chapter the [Encoding](#encoding), the [Syntax Extension](#syntax-extension) and the [Pattern Matching for ADTs](#pattern-matching-for-adts) will be presented.

Algebraic data types provide a neat way to structure data in terms of sums of products.
For more detailed information see the [Wikipedia for ADTs](https://en.wikipedia.org/wiki/Algebraic_data_type).

Since consize is dynamically typed, our ADTs will be typeless.
Neither they will introduce types nor they will typecheck their arguments.
The main focus in this document will be the constructors and the pattern matching.

### Idea

The idea is to extend the syntax of consize such that the definition of an algebraic data type introduces words, that allow to easily construct and deconstruct values as well membership checks.
The following snippet would then introduce the constructors `Some` and `None`, that expect a single and no argument respectively.
For convinience the words `Some?`, `None?` and `Option?` will be introduced as well. They enable manual checking whether a value is an adt-value and belongs to the type `Option` (`Option?`), or whether the value was constructed by the `None`-constructor (`None?`)  or `Some`-constructor (`Some?`).

```consize
data Option = Some value | None ;
```

### Encoding

Since it is possible to destruct values via pattern matching, they have to carry certain metadata about their origin.
To be exact, the metadata comprises the type of the value and which constructor created it.

ADT-values are modeled using maps, which have the structure presented below.
```consize
{
  \ adt-type   <typename>
  \ adt-ctor   <ctorname>
  \ adt-values <valuenames>
  \ adt-data   <data>
}
```
- <typename>: The name of the type.
- <ctorname>: The name of the constructor, which constructed the value.
- <valuenames>: The names of the values, which the constructor <ctorname> requires. Note that in this sequence, the names are in the same order they were defined.
- <data>: A map, which maps a valuename to a value.

### Syntax Extension

In this section we will discuss how the syntax of consize was extended.
Therefore we will first present the [Parser for the syntax extension](#parser-for-the-syntax-extension), then show what words are generated using the definitions returned by the parser ([Introducing words](#introducing-words)) and then how [Extending the syntax](#extending-the-syntax) works.

#### Parser for the syntax extension

```consize
>> % ======================= parser for the syntax extensions =======================
>> 
>> 
```

```consize
>> : --adt-invald-name ( w -- t/f ) ( \ | \ ; ) swap --contains ;
>> 
>> : --parser-adt-name ( -- parser )
>>   [ dup type \ wrd equal? swap --adt-invald-name not and ] parser-predicate ;
>> 
```
The word `--parser-adt-name` creates a parser, that accepts all words, except `|` and `;`.

```consize
>> : --parser-adt-ctor ( -- parser )
>>   --parser-adt-name            \ ctor-name parser-tag
>>   --parser-adt-name parser-rep \ ctor-values parser-tag
>>   parser-append-merge ;
>> 
```
Using the parser created by `--parser-adt-name`, we can create a parser, that accepts a single constructor of an adt-definition.
A single constructor has the form `<name> { <name> }`, where `<name>` is defined by `--parser-adt-name`.
The word returning such a parser is `--parser-adt-ctor`.
If the parser accepts it returns a map with the keys `ctor-name` and `ctor-values` associated with the corresponding values.

```consize
>> : --parser-adtdef ( -- parser )
>>   --parser-adt-name \ adt-type parser-tag
>>   \ = parser-item --parser-adt-ctor \ | parser-item parser-rep1sep
>>   parser-append-right parser-opt [ --flatten ] parser-map \ adt-ctors parser-tag
>>   parser-append-merge  
>>   \ ; parser-item parser-append-left ;
>> 
>> 
```
The word `--parser-adtdef` returns a parser, that parses an adt-definition, without the leading `data`-keyword.
The parser returned by this word defines the grammar `<name> [ '=' <ctor> { '|' <ctor> } ] ';'`, where `<name>` is defined by `--parser-adt-name` and <ctor> is defined by `--parser-adt-ctor`.
On success the parser returns a value, describing a definition of an adt:
```consize
{
  \ adt-type  <wrd>
  \ adt-ctors <ctor>
}

% where <ctor> has the form

{
  \ ctor-name   <wrd>
  \ ctor-values <stk>
}
```

#### Introducing words

Based on the adt-definition returned by the parser `--parser-adtdef`, we now want to generatively define words.
As described in [Idea](#idea) three different kinds of words will be generated:

1. Type membership checks of the form <typename>? (see [Type Membership Checks](#type-membership-checks))
2. Checks that test, if a value was created by a specific constructor, of the form <ctorname>? (see [Constructor Membership Checks](#constructor-membership-checks))
3. The constructors of the form <ctorname> (see [Constructor Definitions](#constructor-definitions))

```consize
>> % ============================== introducing words ===============================
>> 
>> 
```

```consize
>> : --suffix-qmark ( w -- w? )
>>   unword ( \ ? ) concat word ;
>> 
```
The word `--suffix-qmark` will append a `?` to the wprd `w`.

```consize
>> : --is-adt-instance? ( value -- t/f )
>>   dup type \ map equal?
>>   [ drop false ]
>>   [ keys ( \ adt-type \ adt-ctor \ adt-values \ adt-data ) --contains-all ]
>>   if-not ;
>> 
```
The word `--is-adt-instance?` checks if `value` is a map and has the structure of an adt-value (as described in [Encoding](#encoding)).

##### Type Membership Checks

```consize
>> : --membership-word-adt ( field-value def field-def )
>>   dupd swap nil get dup --suffix-qmark -rot4 swap drop
>>   [ rot dup --is-adt-instance?
>>     [ swapd nil get equal? ]
>>     [ 3drop false ]
>>     if
>>   ] 2curry ;
>> 
```
The word `--membership-word-adt` is a generalized definition for dealing with type and constructor memberships.
It extracts the desired name and creates membership predicates for checking the memberships.

```consize
>> : --define-adt-tpe? ( adt-def -- )
>>   \ adt-type swap over
>>   --membership-word-adt def ;
>> 
```
Using `--membership-word-adt` `--define-adt-tpe?` defines a word named `<typename>?`, that tests type membership.
This word has to be called for each adt-definition.

##### Constructor Membership Checks

```consize
>> : --define-adt-ctor? ( adt-def ctor-def -- )
>>   [ drop ] dip
>>   \ adt-ctor swap \ ctor-name
>>   --membership-word-adt def ;
>> 
```
Using `--membership-word-adt` `--define-adt-ctor?` defines a word named `<ctorname>?`, that tests constructor membership.
This word has to be called for each constructor definition and adt-definition.

##### Constructor Definitions

When called a constructor-word has to consume k elements from the datastack, where k is the count of arguments the constructor accepts.
From those values a map has to be built, that maps each argument-name to its corresponding value.
This map represents the payload information, which every adt-value will have (see [Encoding](#encoding)).

The word `--constructor-collect-values` implements the described behavior, accumulating a map.

```consize
>> : --constructor-collect-values-rec ( ... acc values -- quot )
>>   dup empty?
>>   [ drop ]
>>   [ unpush swap [ swap assoc ] dip --constructor-collect-values-rec ]
>>   if ;
>> 
>> : --constructor-collect-values ( values -- quot )
>>   reverse { } swap --constructor-collect-values-rec ;
>> 
```
The word `--constructor-collect-values` will consume size(`values`) values from the datastack, mapping corresponding keys to the values.

At this point we have a way to package the adt-data, given the map of argument names.

```consize
>> : --make-adt-ctor-programm ( adt-def ctor-def -- quot )
>>   % prebuild partial map, that represents the values
>>   dup emptystack cons cons cons
>>   ( \ adt-type \ ctor-name \ ctor-values )
>>   zip [ unstack swap nil get ] map unstack -rot
>>   \ adt-ctor { } assoc \ adt-type swap assoc
>>   [ dup ] dip
>>   \ adt-values swap assoc
>>   % build the programm
>>   [ \ adt-data swap assoc ] curry
>>   swap \ --constructor-collect-values emptystack cons curry
>>   swap concat ;
>> 
```
Using the word `--make-adt-ctor-programm` a quotation, that constructs the adt-value, is generated for each constructor.

```consize
>> : --define-adt-ctor ( adt-def ctor-def -- )
>>   dup \ ctor-name swap nil get -rot
>>   --make-adt-ctor-programm def ;
>>
```
The word `--define-adt-ctor` extracts the name of the constructor, creates the quotation, that implements the constructor using `--make-adt-ctor-programm` and defines it.

#### Invoking words, that generate words

Now all pieces can be put together.
The words `--define-adt-tpe?`, `--define-adt-ctor?` and `--define-adt-ctor` are called, generatively defining the words for working with adt-values.

```consize
>> : --define-adt-words ( adt-def -- )
>>   dup --define-adt-tpe?
>>   dup \ adt-ctors swap nil get dup -rot
>>   swap --override swap
>>   2dup [ --define-adt-ctor? ] 2each
>>   2dup [ --define-adt-ctor ] 2each
>>   2drop ;
>>
>> 
```
Using the previously defined words `--define-adt-tpe?`, `--define-adt-ctor?` and `--define-adt-ctor` we can introduce the word `--define-adt-words`, that extracts and delegates the neccessary information to the words mentioned above.

#### Extending the syntax

```consize
>> % ============================= extending the syntax =============================
>> 
>> 
```

Consize provides a word called `call/cc`, which lets you manipulate the data- and callstack, allowing to change the semantic of the future code programmatically.
Using `call/cc` and the parser presented earlier (see [Parser for the syntax extension](#parser-for-the-syntax-extension)), the syntax of consize can be easily extended.

```consize
>> : --error-parsing-adt-definition ( -- w )
>>   ( \ error <space> \ parsing <space> \ adt-definition ) word ;
>> 
>> : --consume-adt-definition ( cs -- cs' )
>>   dup --parser-adtdef swap parser-run dup \ status swap nil get \ success equal?
>>   [ 2drop --error-parsing-adt-definition error ]
>>   [ swap drop dup \ input swap nil get swap \ value swap nil get --define-adt-words ]
>>   if-not ;
>> 
>> : data ( ) [ --consume-adt-definition continue ] call/cc ;
>> 
>> 
```
The word `data` intercepts the program using `call/cc` and calls the word `--consume-adt-definition`, that will run the parser for adt-definitions on the callstack, extracting the definition.
That is why the parser was defined to only parse the adt-definition without the leading `data`-keyword.
If the parser was successful, `--define-adt-words` is called with the definition of the algebraic data type and the remaining callstack is returned.
If the parser couldn't parse a valid adt-definition, the word will fail, calling word `error`.

### Pattern Matching for ADTs

```consize
>> % =============================== pattern matching ===============================
>> 
>> 
```

#### Unapplying adt values

First we define words that will help us unapplying values from adt-values.
We will define three flavors of unapply: `unapply-map`, `unapply-seq` and `unapply`.

```consize
>> : unapply-map ( adt-value -- map )
>>   dup --is-adt-instance?
>>   [ drop error ]
>>   [ \ adt-data swap nil get ]
>>   if-not ;
>> 
```
For any adt-value the word `unapply-map` will return the underlying map, which represents the arguments of the value.

```consize
>> : unapply-seq ( adt-value -- seq )
>>   dup --is-adt-instance?
>>   [ drop error ]
>>   [ dup \ adt-values swap nil get
>>     swap unapply-map
>>     [ nil get ] curry map
>>   ]
>>   if-not ;
>> 
```
For any adt-value the word `unapply-seq` will return the values associated with the adt-value in the order they are named in the definition of the corresponding constructor.

```consize
>> : unapply ( adt-value -- ..values ) unapply-seq unstack ;
>> 
```
The word `unapply`, will similar to `unapply-seq` extract values of any adt-value, but it will push them to the datastack instead of returning them in a sequence.
After executing this word the last argument will be on the top of the datastack.

#### Patterns available for matching

```consize
>> : adtmatch-error ( ... -- ... ) [ \ adtmatch-error printer repl ] call/cc ;
>>
```
`adtmatch-error` is called, if the pattern match was unexhaustive, that is, no pattern was given that matched the value.

We allow three different kinds of patterns to be used in the pattern match for adt-values.
The three pattern kinds and parsers, that detect those are presented below.

```consize
>> : --adtmatch-list-pattern ( -- parser )
>>   [ type \ stk equal? ] parser-predicate parser-guard ;
>> 
```
The word `--adtmatch-list-pattern` returns a parser, that accepts every list.

1. Type and constructor pattern

This pattern has the form <Type / Constructor>.
It matches if the value is of the given `Type` and created using the constructor `Constructor`.

```consize
>> : --adtmatch-typector-pattern ( -- parser )
>>   --parser-adt-name dup \ / parser-item swap parser-append-right
>>   [ [ --suffix-qmark lookup ] bi@ --pred-and ] parser-append-map
>>   --adtmatch-list-pattern parser-append-left ;
>> 
```
The word `--adtmatch-typector-pattern` returns a parser, which returns a predicate that performs the check, if the value is of the given `Type` and created using the constructor `Constructor`.

2. Constructor pattern

This pattern has the form <Constructor>.
It matches if the value was created using the constructor `Constructor`.

```consize
>> : --adtmatch-ctor-pattern ( -- parser )
>>   --parser-adt-name [ --suffix-qmark lookup ] parser-map
>>   --adtmatch-list-pattern parser-append-left ;
>> 
```
The word `--adtmatch-ctor-pattern` returns a parser, which returns a predicate that performs the check, if the value was created using the constructor `Constructor`.

3. :else pattern

This pattern has the form `:else`.
It matches any value.

```consize
>> : --adtmatch-else-pattern ( -- parser )
>>   \ :else parser-item [ [ drop true ] ] parser-onsuccess
>>   --adtmatch-list-pattern parser-append-left ;
>> 
```
The word `--adtmatch-else-pattern` returns a parser, which returns a predicate that accepts all values.

```consize
>> : --adtmatch-pattern ( -- parser )
>>   --adtmatch-typector-pattern --adtmatch-else-pattern --adtmatch-ctor-pattern
>>   parser-or parser-or ;
>> 
```
The word `--adtmatch-pattern` returns a parser, which combines the parsers `--adtmatch-typector-pattern`, `--adtmatch-ctor-pattern`and `--adtmatch-else-pattern`.

```consize
>> : --adtmatch-pattern-match ( metapattern patterns -- metapattern patterns' pat )
>>   2dup parser-run dup \ status swap nil get \ success equal?
>>   [ [ drop ] dip dup \ input swap nil get swap \ value swap nil get ]
>>   [ drop nil ]
>>   if ;
>>  
```
The word `--adtmatch-pattern-match` runs the parser `metapattern` on the sequence `patterns` which contains patterns and quotations (alternating).

#### Machinery for Pattern matches

The following words describe the machinery used for pattern matches.

```consize
>> : --adtmatch-rec ( value metapattern [ pat1 quot1 pat2 quot2 ... patn quotn ] -- ... )
>>   dup empty?
>>   [ 2drop adtmatch-error ]
>>   [ --adtmatch-pattern-match dup nil equal?
>>     [ 3drop adtmatch-error ]
>>     [ dup [ drop true ] equal? -rot
>>       [ [ [ over ] dip swap ] dip swap ] dip call
>>       [ swap drop pop --adtmatch-rec ]
>>       [ top rot drop swap [ [ unapply ] dip ] unless call ]
>>       if-not
>>     ]
>>     if
>>   ]
>>   if ;
>> 
>> : adtmatch ( adt-value [ pat1 quot1 pat2 quot2 ... patn quotn ] -- ... )
>>   --adtmatch-pattern swap --adtmatch-rec ;
>>
>> 
```

