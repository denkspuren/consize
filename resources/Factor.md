# Factor

## Parsing [_Parsing words_]

Der Parser liest ein Token nach dem anderen. Ist das Token eine Zahl oder ein Wort, wird die Zahl bzw. das Wort einem auf dem Stack befindlichen Sammel-Vektor `accum` hinzugefügt. Einzig Parsing-Wörter werden sofort ausgeführt. Parsing-Wörter sind mit `SYNTAX:` definiert und müssen den Stapeleffekt `( accum -- accum )` haben.

* Frage: Was genau ist der _input stream_?

Im sogenannten Manifest `manifest` ist der aktuelle Zustand der Wortsuche hinterlegt. Es kommt einzig zur Parsezeit zum Einsatz.

```
USING: hash-sets vectors ;
IN: vocabs.parser
TUPLE: manifest
    current-vocab
    { search-vocab-names hash-set initial: HS{ } }
    { search-vocabs vector initial: V{ } }
    { qualified-vocabs vector initial: V{ } }
    { auto-used vector initial: V{ } } ;
```

> Words for working with the current manifest:
> * use-vocab ( vocab -- )
> * unuse-vocab ( vocab -- )
> * add-qualified ( vocab prefix -- )
> * add-words-from ( vocab words -- )
> * add-words-excluding ( vocab words -- )
>
> Words used to implement IN::
> * current-vocab ( -- vocab )
> * set-current-vocab ( name -- )
>
> Words used to implement Private words:
> * begin-private ( -- )
> * end-private ( -- )

Private Wörter sind per Konvention Wörter, die von niemandem sonst genutzt werden sollten, obwohl das prinzipiell möglich ist.

## _Parse-time word lookup_

> When the parser reads a word name, it resolves the word at parse-time, looking up the word instance in the right vocabulary and adding it to the parse tree.

## Vokabular-Lader (_Vocabulary loader_)

Mit `USE:` bzw. `USING:` werden Vokabulare gesucht und geladen. Es wird in den folgenden Wurzelverzeichnissen `vocab-roots` gesucht:

* `core` -- das Systemvokabular des Bootimages
* `basis` -- nützliche Bibliotheken und Werkzeuge
* `extra` -- ergänzende, beigesteuerte Bibliotheken
* `work` -- Vokabulare, die nicht Teil von Factor selbst sind; hier geht der Code eines "normalen" Entwicklers ein

Mit `IN:` wird ein neues Vokabular definiert.

## _Stack machine model_

> Quotations are evaluated sequentially from beginning to end. When the end is reached, the quotation returns to its caller. As each object in the quotation is evaluated in turn, an action is taken based on its type:
>
> * a word - the word's definition quotation is called. See Words
> * a wrapper - the wrapped object is pushed on the data stack. Wrappers are used to push word objects directly on the stack when they would otherwise execute. See the \ parsing word.
> * All other types of objects are pushed on the data stack.

## Continuation

```
IN: continuations
TUPLE: continuation data call retain name catch ;
```

Der Daten- und der Retain-Stack sind Arrays. 

## _Objects_

> An object is any datum which may be identified. All values are objects in Factor. Each object carries type information, and types are checked at runtime; Factor is dynamically typed.

> Tuples are composed entirely of slots, and instances of Built-in classes consist of slots together with intrinsic data. (--> _Low-level slot operations_)

### Built-in classes

Siehe auch den aktuellen Wert von `builtins`

 > * alien
 > * array
 > * bignum
 > * byte-array
 > * callstack
 > * dll
 > * f
 > * fixnum
 > * float
 > * quotation
 > * string
 > * tuple
 > * word ( -- * )
 > * wrapper
