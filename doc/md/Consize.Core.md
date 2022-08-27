# Die VM von Consize: Der Kernel {#Sec:ConsizeVM}

In diesem Kapitel geht es um den Kern von Consize, um die [Virtuelle
Maschine](http://de.wikipedia.org/wiki/Virtuelle_Maschine) (VM), die aus
dem eigentlichen Interpreter und einer Laufzeitumgebung besteht.

Die Consize-VM besteht aus einem Mapping mit rund 50 atomaren Wörtern.
Da die Schlüsselwerte des Mappings allesamt Wörter sind, nennen wir das
Mapping "Wörterbuch" (*dictionary*). Jedes dieser Wörter ist mit einer
Funktion assoziiert. Einzig in vier Ausnahmefällen sind die Funktionen
in Stapeln eingepackt.

Grundsätzlich nimmt jede Funktion einen Stapel als Input entgegen und
liefert einen Stapel als Ergebnis zurück. Darum bezeichnet man
konkatenative Sprachen auch gerne als "stapelverarbeitende Sprachen".
Streng genommen muss eine konkatenative Sprache nicht unbedingt aus
stapelverarbeitenden Funktionen aufgebaut sein.

Der eigentliche [Interpreter](http://de.wikipedia.org/wiki/Interpreter)
wird durch die mit dem Wort `stepcc` abgebildete Funktion realisiert.
Das Wort ist der Dreh- und Angelpunkt der Virtuellen Maschine und ist
zentral für das Verständnis des Interpreters. Dazu kommen noch die vier
erwähnten Sonderfälle, die in Stapeln verpackten Funktionen zu den
Wörtern `call/cc`, `continue`, `get-dict`, `set-dict`. Diese vier
Funktionen ergänzen die Fähigkeit zur
[Metaprogrammierung](http://de.wikipedia.org/wiki/Metaprogrammierung).

Die übrigen Wörter der VM samt ihrer Funktionen bilden die
[Laufzeitumgebung](http://de.wikipedia.org/wiki/Laufzeitumgebung) ab,
die nötig ist für den Umgang mit den fünf von Consize unterstützten
Datentypen, für Ein- und Ausgabeoperationen, für arithmetische
Operationen und für das Lesen und Zerlegen eines Consize-Programms. Wenn
man wollte, könnte die Consize-VM mit deutlich weniger atomaren Wörtern
und Funktionen auskommen. Darunter würde allerdings die Anschaulichkeit
leiden, teils auch die Effizienz in der Ausführung. Die hier
vorgestellte VM versucht eine goldene Mitte zu finden. Einerseits ist es
sehr komfortabel, Stapel und Mappings als Datenstrukturen fertig zur
Verfügung zu haben. Andererseits fehlt damit der Einblick, wie solche
Datenstrukturen intern aufgebaut sind und funktionieren.

Eines ist in dem Zusammenhang wichtig zu erwähnen: Alle Datentypen in
Consize sind immutabel (unveränderlich).
Kap. [\[Sec:GleichheitIdentitaet\]](#Sec:GleichheitIdentitaet){reference-type="ref"
reference="Sec:GleichheitIdentitaet"} geht darauf näher ein.

Die Spezifikation der Consize-VM gibt pro Wort in der Regel ein Beispiel
zur Verwendung des Wortes an. Die Beispiele setzen die geladene Prelude
voraus, mit der Consize in aller Regel aufgerufen wird.

## Kurzdokumentation mittels Stapeleffekten

Die mit den Wörtern der Virtuellen Maschine assoziierten Funktionen
verarbeiten Stapel. Jede Funktion erwartet einen Stapel als Argument und
liefert einen Stapel als Ergebnis zurück. Die Funktionen unterscheiden
sich darin, wie viele Elemente sie auf dem Eingangsstapel mindestens
erwarten und von welchem Typ die Elemente sein müssen. Vom Ergebnis her
interessiert, was sich im Vergleich zum Eingangsstapel auf dem
Ausgangsstapel verändert hat.

Mit Hilfe des Stapeleffektes (*stack effect*) beschreibt man genau
dieses Verhältnis von Erwartungen an den Eingangsstapel und den
Auswirkungen auf den Ausgangsstapel. Der Stapeleffekt wird in runden
Klammern notiert. Links vom Doppelstrich "`--`" steht, was auf dem
Eingangsstapel erwartet wird, rechts vom Doppelstrich steht, was der
Ausgangsstapel liefert, sofern die Erwartungen an den Eingangsstapel
erfüllt sind. Die Angaben für die Stapel sind von rechts nach links zu
lesen, sprich, rechts ist das jeweilige obere Ende des Eingangs- bzw.
Ausgangsstapels.

Ein Beispiel: Für das atomare Wort `swap` gibt `( x y -- y x )` den
Stapeleffekt an. Damit ist gemeint: Auf dem Eingangsstapel müssen sich
mindestens zwei Elemente befinden, wobei wir das oberste Element mit `y`
und das darauf folgende mit `x` bezeichnen. Auf dem Ausgangsstapel
bleiben all die nicht weiter benamten Elemente erhalten. Sie werden
ergänzt um das mit `y` und -- ganz zuoberst auf dem Stapel -- um das mit
`x` bezeichnete Element aus dem Eingangsstapel. Kurzum: `swap` tauscht
die obersten beiden Elemente auf dem Stapel.

Es ist gar nicht so selten, dass sich auf dem Stapel ein oder mehrere
Stapel befinden. Wollen wir uns bei der Angabe des Stapeleffekt auf den
Inhalt eines Stapels beziehen, so notieren wir den Stapel in bekannter
Notation mit eckigen Klammern und arbeiten ebenso mit Bezeichnern auf
den Stapelpositionen. Vergessen Sie nicht, dass bei eckigen Klammern das
obere Stapelende *immer* links ist. Um die übrigen Elemente eines
Stapels zu fassen, arbeiten wir mit dem `&`-Zeichen als Rest-Erkenner.
Das heißt: `[ x y ]` meint einen Stapel mit genau zwei Elementen, dessen
obersten Wert wir mit `x` und den folgenden Wert mit `y` bezeichnen.
`[ x & r ]` bezieht sich auf einen Stapel der mindestens ein Element
hat. Den obersten Wert bezeichnen wir mit `x`, alle restlichen Elemente
des Stapels bezeichnen wir mit `r`. `[ x y & r ]` erwartet einen Stapel
mit mindestens zwei Elementen. `[ & r ]` spezifiziert einen Stapel mit
beliebig vielen Elementen, die allesamt durch `r` erfasst sind. Wir
machen von solchen Beschreibungen zu Stapeleffekten z.B. in
Kap. [1.4](#sec:core.stacks){reference-type="ref"
reference="sec:core.stacks"} und
Kap. [1.12](#sec:core.meta){reference-type="ref"
reference="sec:core.meta"} Gebrauch.

Obwohl die Notation für Stapeleffekte ansonsten informell ist, folgt sie
gewissen Vereinbarungen. Meist sind die Namen nach einem der möglichen
Datentypen benannt.

-   Wenn die Implementierung als Stapel nicht entscheidend ist, reden
    wir auch vom Stapel mit seinen Elementen als "Folge" oder "Sequenz"
    (*sequence*); bei der Notation der Stapeleffekte wird dann oft das
    Kürzel `seq` verwendet.

-   Repräsentiert ein Stapel ein Programm, dann sprechen wir von einer
    "Quotierung" (*quotation*), abgekürzt in den Stapeleffekten als
    `quot`.

-   Ein Mapping kürzen wir mit `map` ab, den Spezialfall eines
    Wörterbuchs (*dictionary*) mit `dict`.

-   Handelt es sich um ein beliebiges Element (*item*), dann kürzen wir
    es in den Stapeleffekten als `itm` ab oder geben ihm einen
    generischen Namen wie z.B. `x`, `y` oder `z`.

Nicht immer passen diese Konventionen, manchmal erweisen sich andere
Namen als hilfreicher, die Funktion eines Wortes zu erfassen.

## Stack Shuffler: `dup`, `swap`, `drop`, `rot`

Das Tauschen, Verschieben, Duplizieren und Entfernen von Elementen auf
dem Eingangsstapel wird als *stack shuffling* bezeichnet. Ganze vier
Wörter dienen dazu, jedes gewünschte Arrangement der obersten drei
Elemente auf dem Datastack herzustellen.

`dup ( x – x x )`

:   dupliziert das oberste Element auf dem Stapel.

```{=html}
<!-- -->
```
    > clear x y z dup
    x y z z

`swap ( x y – y x )`

:   vertauscht die obersten Elemente auf dem Stapel.

```{=html}
<!-- -->
```
    > clear x y z swap
    x z y

`drop ( x – )`

:   entfernt das oberste Element auf dem Stapel.

```{=html}
<!-- -->
```
    > clear x y z drop
    x y

`rot ( x y z – y z x )`

:   rotiert die obersten drei Elemente auf dem Stapel, wobei das
    drittoberste Element nach ganz oben gebracht wird.

```{=html}
<!-- -->
```
    > clear x y z rot
    y z x

Die Stack Shuffler zum Rearrangieren, Duplizieren und Entfernen von
Elementen des Eingangsstapels sind unverzichtbar, da Consize nicht das
Konzept der
[Variable](http://de.wikipedia.org/wiki/Variable_(Programmierung))
kennt. Kombinatoren sind ein anderer, eleganter Weg, wie man ohne
Variablen auszukommen vermag, siehe
Kap. [\[Sec:Kombinatoren\]](#Sec:Kombinatoren){reference-type="ref"
reference="Sec:Kombinatoren"}.

## Typ und Vergleich: `type`, `equal?`, `identical?`

Consize kennt insgesamt fünf immutable Datentypen. Ein Datentyp
repräsentiert eine Menge von Datenwerten. So steht der Datentyp `wrd`
für die Menge aller Wörter, `fct` für die Menge aller Funktionen, `stk`
für die Menge aller Stapel und `map` für die Menge aller Mappings. Eine
Sonderstellung nimmt der Typ `nil` ein. Er repräsentiert einen einzigen
Wert, der "Nichts" heißt (englisch *nil*) und dann eingesetzt wird, wenn
statt eines Fehlers das Resultat einer Operation als erfolglos
ausgewiesen werden soll im Sinne von "es ist 'nichts' dabei
herumgekommen".

`type ( itm – wrd )`

:   ermittelt den Datentypen des obersten Elements auf dem Stack. Der
    Typ ist entweder das Wort `wrd`, `stk`, `map`, `fct` oder `nil`.

```{=html}
<!-- -->
```
    > clear hi type
    wrd
    > [ 1 2 3 ] type
    wrd stk

Sie haben ein intuitives Verständnis davon, was Gleichheit (*equality*)
von Werten bedeutet. Dass die Stapel `[ 1 x 2 ]` und `[ 1 x 2 ]` gleich
sind, leuchtet Ihnen unmittelbar ein. Wir werden in
Kap. [\[Sec:GleichheitIdentitaet\]](#Sec:GleichheitIdentitaet){reference-type="ref"
reference="Sec:GleichheitIdentitaet"} genauer definieren, was mit
Gleichheit gemeint ist. In dem
Kap. [\[Sec:GleichheitIdentitaet\]](#Sec:GleichheitIdentitaet){reference-type="ref"
reference="Sec:GleichheitIdentitaet"} wird auch das Konzept der
Identität (*identity*) ausführlich zur Sprache kommen.

`equal? ( itm1 itm2 – t/f )`

:   testet die Gleichheit der obersten beiden Stapelwerte; liefert
    entweder `t` (für *true*, wahr) oder `f` (für *false*, falsch)
    zurück.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 ] [ 1 2 3 ] equal?
    t

Das Wort `identical?` ist einzig aus didaktischen Gründen in Consize
vorhanden, siehe
Kap. [\[Sec:GleichheitIdentitaet\]](#Sec:GleichheitIdentitaet){reference-type="ref"
reference="Sec:GleichheitIdentitaet"}. Es hat in einer funktionalen
Sprache keine Verwendung und ist in einer Consize-Implementierung nicht
erforderlich.

`identical? ( itm1 itm2 – t/f )`

:   testet die obersten zwei Stapelwerte auf Identität. Legt `t` oder
    `f` auf dem Ergebnisstapel ab.

Wörter, die als Ergebnis auf dem Rückgabestapel entweder ein `t` (für
*true*) oder `f` (für *false*) zurücklassen, sind meist als Prädikate
(ein Begriff aus der
[Prädikatenlogik](http://de.wikipedia.org/wiki/Pr%C3%A4dikatenlogik)) zu
verstehen und schließen ihren Namen gerne mit einem Fragezeichen ab. In
vielen Fällen ist diese Konvention hilfreich und dient als
Gedächtnisstütze: Endet ein Wort mit einem Fragezeichen, ist das
Resultat auf dem Stapel entweder `t` oder `f`.

## Stapel: `emptystack`, `push`, `top`, `pop`, `reverse`, `concat` {#sec:core.stacks}

Der Stapel ist *die* allgegenwärtige Datenstruktur in Consize. Nicht nur
bilden die Funktionen aller primitiven Wörter einen Eingangsstapel auf
einen Ausgangsstapel ab. Man kann auch Stapel mit den Konstruktoren
`emptystack` und `push` erzeugen und auf dem Ausgangsstapel ablegen. Die
Zerlegung eines Stapels auf dem Eingangsstapel ist mit den Destruktoren
`top` und `pop` möglich.

Wenn ein Stapel eine Folge von Daten enthält, dann sprechen wir auch
immer wieder von einer Sequenz (*sequence*). Repräsentiert der Inhalt
eines Stapels ein Programm, dann sprechen wir von einer "Quotierung"
(*quotation*).

`emptystack ( – [ ] )`

:   legt auf dem Ergebnisstapel einen leeren Stapel ab.

```{=html}
<!-- -->
```
    > clear emptystack
    [ ]

`push ( stk itm – [ itm & stk ] )`

:   erzeugt einen neuen Stapel, der das Ergebnis des Vorgangs ist, das
    Element `itm` auf dem Stapel `stk` abzulegen.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 ] 4 push
    [ 4 1 2 3 ]

`top ( [ itm & stk ] – itm )`

:   legt das oberste Element `itm` vom Stapel `stk` auf dem
    Ergebnisstapel ab. Bei einem leeren Stapel oder `nil` liefert `top`
    als Ergebnis `nil`.

```{=html}
<!-- -->
```
    > clear [ 4 1 2 3 ] top
    4
    > [ ] top
    4 nil
    > nil top
    4 nil nil

`pop ( [ itm & stk ] – stk )`

:   legt den um das oberste Element reduzierten Stapel auf dem
    Ergebnisstapel ab.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 ] pop
    [ 2 3 ]
    > [ ] pop
    [ 2 3 ] [ ]
    > nil pop
    [ 2 3 ] [ ] [ ]

Der Wert für "Nichts" (*nil*), der von `top` erzeugt und auch von `pop`
akzeptiert wird, hat eine Sonderfunktion. Er weist das Resultat von
`[ ] top` als erfolglos aus; es macht keinen Sinn, von einem leeren
Stapel den obersten Wert zu verlangen. Mit *nil* als Wert dennoch bei
`top` und `pop` weiter arbeiten zu können, ermöglicht die effiziente
Zerlegung von Stapeln, ohne stets überprüfen zu müssen, ob der Stapel
inzwischen leer ist. Abseits dieses Einsatzzwecks sollten Sie auf *nil*
als Datenwert verzichten.

`reverse ( stk – stk’ )`

:   kehrt die Reihenfolge der Element in einem Stapel um.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 4 5 ] reverse
    [ 5 4 3 2 1 ]

`concat ( stk1 stk2 – stk3 )`

:   verbindet die Elemente der beiden Stapel `stk1` und `stk2` zu einem
    neuen Stapel `stk3`. Die Reihenfolge der Elemente wird gemäß der
    Lesart von links nach rechts beibehalten. Ein leerer Stapel
    konkateniert lediglich seinen "leeren" Inhalt.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 ] [ 4 5 ] concat
    [ 1 2 3 4 5 ]
    > [ ] concat
    [ 1 2 3 4 5 ]

Hinweis: Die Wörter `reverse` und `concat` sind ebenfalls Konstruktoren
und bietet die Consize-VM aus Gründen der Performanz an. Sie können als
optional betrachtet werden. Man könnte diese Wörter auch in der Prelude
definieren.

## Mappings: `mapping`, `unmap`, `assoc`, `dissoc`, `get`, `keys`, `merge`

Mappings dienen dazu, Schlüssel- mit Zielwerten zu assoziieren, weshalb
diese Datenstruktur auch [assoziatives
Datenfeld](http://de.wikipedia.org/wiki/Assoziatives_Datenfeld) genannt
wird. Wenn die Schlüsselwerte ausschließlich Wörter sind, dann nennen
wir ein Mapping in Consize auch "Wörterbuch" (*dictionary*). Mappings
sind ein vielseitig verwendbarer Datentyp.

`mapping ( stk – map )`

:   wandelt einen Stapel in ein Mapping um. Die Elemente auf dem Stapel
    werden paarweise als Schlüssel- und Zielwert interpretiert. Der
    Stapel muss eine gerade Anzahl an Elementen haben. Ein leerer Stapel
    liefert ein leeres Mapping.

```{=html}
<!-- -->
```
    > clear [ mon 1 tue 2 wed 3 thu 4 fri 5 ] mapping
    { thu 4 tue 2 mon 1 wed 3 fri 5 }
    > clear [ ] mapping
    { }

`unmap ( map – stk )`

:   wandelt ein Mapping in einen Stapel, wobei die Assoziationen eine
    Folge von Schlüssel- und Zielwerten bilden. Die Reihenfolge der
    Schlüssel- und Zielwertpaare ist unbestimmt. Ein leeres Mapping
    führt zu einem leeren Stapel.

```{=html}
<!-- -->
```
    > clear { mon 1 tue 2 wed 3 thu 4 fri 5 } unmap
    [ thu 4 tue 2 mon 1 wed 3 fri 5 ]
    > clear { } unmap
    [ ]

`assoc ( val key map – map’ )`

:   fügt dem Mapping `map` die Assoziation aus Schlüsselwert `key` und
    Zielwert `val` hinzu und liefert das neue Mapping `map'` zurück.
    Existiert ein Schlüsselwert in `map` bereits, wird der Zielwert
    "überschrieben".

```{=html}
<!-- -->
```
    > clear 3 :radius { :type circle } assoc
    { :radius 3 :type circle }

`dissoc ( key map – map’ )`

:   legt ein Mapping `map'` auf dem Ergebnisstapel ab, das alle
    Assoziationen des Mappings `map` übernimmt bis auf die Assoziation,
    die über den Schlüsselwert `key` identifiziert ist. Existiert `key`
    in `map` nicht, bleibt das Mapping unverändert.

```{=html}
<!-- -->
```
    > clear c { a b c d } dissoc
    { a b }
    > clear c { a b } dissoc
    { a b }

`get ( key map default – val/default )`

:   liefert den mit dem Schlüsselwert `key` im Mapping `map`
    assoziierten Zielwert `val` zurück. Existiert die Assoziation nicht,
    liefert `get` stattdessen den `default`-Wert zurück.

```{=html}
<!-- -->
```
    > clear thu { mon 1 tue 2 wed 3 thu 4 fri 5 } _|_ get
    4
    > clear sat { mon 1 tue 2 wed 3 thu 4 fri 5 } _|_ get
    _|_

`keys ( map – seq )`

:   gibt alle Schlüsselwerte eines Mappings `map` als Sequenz `seq`
    (Stapel) zurück. Die Reihenfolge der Schlüsselwerte in `seq` kann
    beliebig sein.

```{=html}
<!-- -->
```
    > clear { mon 1 tue 2 wed 3 thu 4 fri 5 } keys
    [ thu tue mon wed fri ]

`merge ( map1 map2 – map3 )`

:   fasst die zwei Mappings `map1` und `map2` zu einem neuen Mapping
    `map3` zusammen. Bei gleichen Schlüsselwerten in `map1` und `map2`
    werden die Assoziationen aus `map2` in `map3` übernommen.

```{=html}
<!-- -->
```
    > clear { a b c d } { c x y z } merge
    { a b c x y z }

Hinweis: Nicht alle Wörter zu Mappings sind unabdingbar notwendig. Die
Wörter `unmap`, `dissoc` und `merge` bietet die Consize-VM aus Gründen
der Performanz an. Sie können als optional betrachtet werden, da sie mit
den übrigen Wörtern der Consize-VM nachgebildet werden können.

## Wörter: `unword`, `word`, `char`

Ein Wort ist in Consize ein eigener Datentyp, der eine Folge von
beliebigen Einzelzeichen (*characters*) repräsentiert. Normalerweise
verstehen wir in Consize unter einem Wort eine etwas striktere
Auslegung: Ein Wort besteht aus mindestens einem oder mehr *sichtbaren*
Einzelzeichen. Diese strikte Interpretation liegt der Arbeitsweise von
`tokenize` zugrunde (Kap. [1.9](#Sec:Parsing){reference-type="ref"
reference="Sec:Parsing"}). Tatsächlich kann ein Wort auch Leerzeichen
und andere Steuerzeichen enthalten oder sogar leer sein. Das ist
nützlich z.B. für die Erzeugung von Ausgaben auf der Konsole mittels
`print` (Kap. [1.7](#sec:VM.Konsole){reference-type="ref"
reference="sec:VM.Konsole"}).

`unword ( wrd – seq )`

:   zerlegt ein Wort in seine Einzelzeichen in Form einer Folge von
    Wörtern. Jedes Wort in der Folge entspricht einem Einzelzeichen.

```{=html}
<!-- -->
```
    > clear \ push unword
    [ p u s h ]

`word ( seq – wrd )`

:   erwartet eine Folge von ausschließlich Wörtern und fügt diese Wörter
    zu einem neuen Gesamtwort zusammen. Die Folge muss mindestens ein
    Wort enthalten.

```{=html}
<!-- -->
```
    > clear [ it's me ! ] word
    it'sme!

`char ( wrd – wrd’ )`

:   legt auf dem Ergebnisstapel ein Wort `wrd'` ab, das lediglich aus
    einem Einzelzeichen (*character*) besteht. Das Einzelzeichen wird
    durch das Wort `wrd` kodiert. Die Kodierung erfolgt als
    [Unicode](http://de.wikipedia.org/wiki/Unicode) mit dem Präfix
    "`\u`" und vier folgenden Stellen im
    [Hexadezimalsystem](http://de.wikipedia.org/wiki/Hexadezimalsystem)
    (z.B. `\u0040` für das Wort `@`) oder im
    [Oktalsystem](http://de.wikipedia.org/wiki/Oktalsystem) mit dem
    Präfix "`\o`" (z.B. `\o100` ebenfalls für `@`). Zusätzlich stehen
    als Kodierung für `wrd` die Wörter

    -   `\space` (Leerzeichen, *space*),

    -   `\newline` (Zeilenvorschub, *line feed*),

    -   `\formfeed` (Seitenvorschub *form feed*),

    -   `\return` (Wagenrücklauf, *carriage return*),

    -   `\backspace` (Rückschritt, *backspace*) und

    -   `\tab` (horizontaler Tabulator, *tab*)

    zur Verfügung, denen die entsprechenden Zeichen
    bzw. [Steuerzeichen](http://de.wikipedia.org/wiki/Steuerzeichen) als
    Wörter für `wrd'` entsprechen. Beachten Sie, dass `\space` etc. mit
    `char` "unsichtbare" Wörter erzeugen, die z.B. bei der Ausgabe über
    die Konsole dennoch Auswirkungen als
    [Leerraum](http://de.wikipedia.org/wiki/Leerraum) haben. Der
    vorrangige Nutzen von `char` besteht in der Erzeugung von
    Sonderzeichen über die Unicode-Kodierung.

```{=html}
<!-- -->
```
    > clear \u0040 char
    @

## Konsole: `print`, `flush`, `read-``line` {#sec:VM.Konsole}

Zur Ein- und Ausgabe über die Konsole stellt Consize drei Wörter bereit.
In der Regel erscheinen Ausgaben nicht direkt auf dem Bildschirm,
sondern wandern zunächst in einen Zwischenspeicher, einen
[Puffer](http://de.wikipedia.org/wiki/Puffer_(Informatik)).

`print ( wrd – )`

:   gibt das Wort auf der Konsole aus. Da die Ausgabe über einen
    [Puffer](http://de.wikipedia.org/wiki/Puffer_(Informatik)) erfolgt,
    kann die Ausgabe möglicherweise nicht direkt, sondern zu einem
    späteren Zeitpunkt erfolgen. Die sofortige Ausgabe erzwingt `flush`.

```{=html}
<!-- -->
```
    > clear \ Hello print \newline char print
    Hello

`flush ( – )`

:   leert den Ausgabepuffer und bringt alles, was noch im Ausgabepuffer
    ist, zur Ausgabe in der Konsole. Das Wort "*flush*" heißt soviel wie
    "ausspülen".

```{=html}
<!-- -->
```
    > clear \ Hi print \newline char print flush
    Hi

`read-line ( – wrd )`

:   liest eine Zeile über die Konsole ein. Sobald die Eingabe mit der
    [Eingabetaste](http://de.wikipedia.org/wiki/Eingabetaste)
    abgeschlossen ist, legt `read-line` die Eingabezeile als Wort auf
    dem Ergebnisstapel ab.

Geben Sie in dem nachstehenden Beispiel nach `read-line` über die
Tastatur "Hello you" ein und schließen Sie die Eingabe mit der
Eingabetaste ab.

    > clear read-line
    Hello you
    Hello you

Die Ausgabe lässt den Eindruck aufkommen, als handele es sich um zwei
Wörter auf dem Ergebnisstapel. Tatsächlich ist `Hello you` ein einziges
Wort, das ein Leerzeichen beinhaltet! Das wird offensichtlich, wenn Sie
ein `dup` eingeben.

    > dup
    Hello you Hello you

## Dateien und mehr: `slurp`, `spit`, `spit-on`

Consize unterstützt nur sehr rudimentär die Arbeit mit dem
[Dateisystem](http://de.wikipedia.org/wiki/Dateisystem): das Lesen von
Dateien mit `slurp` und das Schreiben von Daten in Dateien mit `spit`
und `spit-on`. Consize ist absichtlich nicht mit weiteren Fähigkeiten
zum Löschen von Dateien und zum Navigieren durch das Dateisystem
ausgestattet.

`slurp ( source – wrd )`

:   interpretiert das Wort `source` als Datenquelle, liest die Daten von
    dort ein und legt die Daten als Wort `wrd` auf dem Ergebnisstapel
    ab. Nur Datenquellen mit Textdaten können sinnvoll verarbeitet
    werden. Bei einfachen Wortnamen für `source` liest Consize die Daten
    von einer namensgleichen Datei ein, die sich im Aufrufverzeichnis
    von Consize befindet. Die Konventionen für Dateipfade folgen
    [java.io](http://docs.oracle.com/javase/7/docs/api/java/io/File.html).
    Es können auch Daten aus dem World Wide Web gelesen werden, siehe
    Beispiel.

Das folgende Beispiel zeigt, dass Sie auch Daten über das [Hypertext
Transfer Protokoll](http://de.wikipedia.org/wiki/Http) (HTTP) lesen
können, sofern Sie online sind. Das gelieferte Ergebnis ist der Inhalt
eines einzigen Wortes. Auch hier gilt wie bei `read-line`: Das Wort
`wrd` kann Leerzeichen, Sonder- und Steuerzeichen enthalten. Die
beispielhafte Ausgabe ist natürlich abhängig vom aktuellen Inhalt der
Webseite. Der besseren Lesbarkeit wegen habe ich Zeilenumbrüche
hinzugefügt.

    > clear http://m.twitter.com slurp
    <html><body>You are being
    <a href="https://mobile.twitter.com/signup">redirected</a>.
    </body></html>

`spit ( data-wrd file-wrd – )`

:   schreibt das Wort `data-wrd` in eine Datei unter dem Namen
    `file-wrd` in das Dateisystem. Für `file-wrd` gelten die
    Konventionen wie unter `slurp` erwähnt. Existiert die Datei nicht,
    wird sie neu angelegt. Existiert die Datei bereits, wird ihr
    bisheriger Inhalt überschrieben.

Nach Eingabe des Beispiels sollten Sie im Startverzeichnis von Consize
eine Datei namens `dummy.txt` finden. Öffnen Sie die Datei mit einem
Editor, um sich den Inhalt anzuschauen.

    > clear \ Hello \ dummy.txt spit

`spit-on ( data-wrd file-wrd – )`

:   hängt das Wort `data-wrd` an den Inhalt der Datei unter dem Namen
    `file-wrd` an. Für `file-wrd` gelten die Konventionen wie unter
    `slurp` erwähnt.

Wenn Sie das Beispiel zu `spit` ausgeführt haben, hängt Ihnen das
folgende Beispiel ein `You` an. In der Datei steht anschließend
`HelloYou`.

    > clear \ You \ dummy.txt spit-on

## Parsing: `uncomment`, `tokenize`, `undocument` {#Sec:Parsing}

Die Wörter `uncomment`, `undocument` und `tokenize` bearbeiten den durch
ein Wort repräsentierten Inhalt seiner Einzelzeichen. Die Wörter sind
insbesondere dafür gedacht, über `read-line` oder `slurp` eingelesene
Consize-Programme einer Vorverarbeitung zu unterziehen.

`uncomment ( wrd – wrd’ )`

:   entfernt aus einem Wort alle Kommentare. Ein Kommentar beginnt mit
    dem `%`-Zeichen und geht bis zum Ende einer Zeile. Das Zeilenende
    wird durch einen
    [Zeilenumbruch](http://de.wikipedia.org/wiki/Zeilenumbruch)
    markiert. Je nach Betriebssystem markieren die
    [Steuerzeichen](http://de.wikipedia.org/wiki/Steuerzeichen)
    "[Wagenrücklauf](http://de.wikipedia.org/wiki/Wagenr%C3%BCcklauf)"
    (*carriage return*, CR) und/oder
    "[Zeilenvorschub](http://de.wikipedia.org/wiki/Zeilenvorschub)"
    (*line feed*, LF) den Zeilenumbruch.

Da `read-line` im folgenden Beispiel keinen Marker für das Zeilenende
setzt, müssen wir ein `\newline char` zu dem eingelesenen Wort
hinzufügen, damit `uncomment` den Kommentar entfernen kann.

    > read-line
    This line % has a comment
    This line % has a comment
    > [ ] \newline char push swap push word uncomment
    This line

`tokenize ( wrd – seq )`

:   zerlegt das Wort an vorhandenen Leerraum-Stellen in eine Folge von
    Wörtern. Als [Leerraum](http://de.wikipedia.org/wiki/Leerraum)
    (*whitespace character* gilt eine nicht leere Folge bzw. Kombination
    der folgenden Zeichen: Leerzeichen, horizontaler Tabulator,
    vertikaler Tabulator, Zeilenvorschub, Seitenvorschub und
    Wagenrücklauf. Diese Definition eines Leerraums folgt dem
    [POSIX](http://de.wikipedia.org/wiki/POSIX)-Standard für [reguläre
    Ausdrücke](http://de.wikipedia.org/wiki/Regul%C3%A4rer_Ausdruck).

```{=html}
<!-- -->
```
    > read-line tokenize
    This line % has a comment
    [ This line % has a comment ]

`undocument ( wrd – wrd’ )`

:   extrahiert aus einem Wort lediglich die "Zeilen", die mit einem
    "`>> `" bzw. "`%> `" (jeweils mit einem Leerzeichen) beginnen,
    verwirft dabei jedoch diese Anfänge. Die extrahierten Anteile werden
    per Wagenrücklauf und Zeilenvorschub miteinander verknüpft und als
    neues Wort `wrd'` zurück gegeben.

Mit `uncomment` unterstützt Consize eine schwache Form des [*Literate
Programming*](http://de.wikipedia.org/wiki/Literate_programming), wie
sie auch die funktionale Programmiersprache
[Haskell](http://de.wikipedia.org/wiki/Haskell_(Programmiersprache))
anbietet. Das Literate Programming zielt darauf ab, nicht den Code zu
dokumentieren, sondern die Dokumentation mit Code anzureichern. Die Idee
des Literate Programming stammt von [Donald
E. Knuth](http://de.wikipedia.org/wiki/Donald_Ervin_Knuth), dem Schöpfer
von [TeX](http://de.wikipedia.org/wiki/TeX).

So haben Sie zwei Möglichkeiten: Sie schreiben entweder Programmcode und
reichern ihn mit Kommentaren an, die durch ein Prozentzeichen
ausgewiesen sind; dann entfernt `uncomment` die Kommentare aus dem
Consize-Code. Oder Sie schreiben eine Dokumentation und reichern diese
mit Programmcode an, der Code ist durch "`>> `" bzw. "`%>> `"
auszuweisen; dann entfernt `undocument` die Dokumentation und lässt den
Consize-Code übrig, den man in einem weiteren Schritt von Kommentaren
per `uncomment` befreien kann.

Hinweise: Alle Parsing-Wörter sind nicht strikt erforderlich. Sie können
allesamt durch Programme aus den übrigen Wörtern der Consize-VM
nachgebildet werden und sind deshalb als optional zu betrachten. Aus
Gründen der Performanz sind sie jedoch als fester Bestandteil der
Consize-VM empfohlen.

## Funktionen: `apply`, `func`, `compose`

Die Bedeutung atomarer Wörter ist über die mit ihnen assoziierten
Funktionen definiert. Diese Funktionen sind fest vorgegeben und heißen
auch *primitive Funktionen*. Mit `apply` wird eine Funktion auf einen
Stapel angewendet, und mit `func` können eigene Funktionen definiert
werden. Das Wort `compose` erlaubt die Komposition zweier Funktionen zu
einer neuen Funktion.

`apply ( stk fct – stk’ )`

:   wendet die Funktion `fct` auf den Stapel `stk` an. Das Ergebnis der
    [Funktionsanwendung](http://en.wikipedia.org/wiki/Apply) ist `stk'`.

Im Beispiel wird die mit `rot` im Wörterbuch assoziierte primitive
Funktion auf den Stapel `[ 1 2 3 ]` angewendet.

    > clear [ 1 2 3 ] \ rot get-dict nil get
    [ 1 2 3 ] <fct>
    > apply
    [ 3 1 2 ]

`func ( quot dict – fct )`

:   erzeugt eine Funktion und initialisiert sie mit einer Quotierung
    `quot` als Programm und einem im Kontext der Funktion gültigen
    Wörterbuch `dict`. Die Semantik der Anwendung dieser Funktion auf
    einen Stapel (z.B. per `apply`) ist wie folgt definiert: Der Stapel
    sei der initiale Datastack, die Quotierung `quot` der initiale
    Callstack und `dict` das initiale Wörterbuch. `stepcc` wird solange
    wiederholt mit dem sich verändernden Triple aus Callstack, Datastack
    und Wörterbuch aufgerufen, bis der Callstack leer ist. Als Ergebnis
    der Anwendung der per `func` erzeugten Funktion wird lediglich der
    Datastack als "normaler" Stapel (wie in `apply`) zurück gegeben.

```{=html}
<!-- -->
```
    > clear [ 1 2 3 ] [ rot ] get-dict func
    [ 1 2 3 ] <fct>
    > apply
    [ 3 1 2 ]
    > clear [ 1 2 3 ] [ rot swap ] get-dict func apply
    [ 1 3 2 ]

Wenn ein Fehler bei der Anwendung einer mit `func` definierten Funktion
auftritt, dann wird das Wort `error` auf dem Callstack abgelegt. Die
Bedeutung von `error` ist frei definierbar und nicht vorgegeben.

`compose ( fct1 fct2 – fct3 )`

:   liefert die Funktion `fct3` als Ergebnis der
    [Komposition](http://de.wikipedia.org/wiki/Komposition_(Mathematik))
    von `fct1` und `fct2` zurück.

Die Bedeutung der per `compose` erzeugten Funktion ist indirekt
definiert: Die Anwendung der Funktion `fct3` auf einen Stapel `stk`
liefert das gleiche Resultat wie die Anwendung von `fct1` auf `stk` mit
folgender Anwendung von `fct2` auf dieses Ergebnis. Anders ausgedrückt:
Die Programme `compose apply` und `[ apply ] bi@` sind ergebnisgleich.
Der Apply-Kombinator `bi@` ist in der Prelude definiert, siehe
Kap. [\[Sec:applyCombinators\]](#Sec:applyCombinators){reference-type="ref"
reference="Sec:applyCombinators"}.

    > clear [ 1 2 3 ] \ rot get-dict nil get \ swap get-dict nil get
    [ 1 2 3 ] <fct> <fct>
    > compose
    [ 1 2 3 ] <fct>
    > apply
    [ 1 3 2 ]

## Der Interpreter: `stepcc`

Die Definition des Interpreters kommt mit drei Konzepten aus: der
Konkatenation, der Funktionsanwendung und dem Nachschlagen eines Wortes
im Wörterbuch. Die zentrale Stellung der Konkatenation ist der Grund für
die Charakterisierung von Consize als konkatenative Sprache. Eher
nebensächlich ist, ob es bei der Konkatenation um Stapel, Arrays,
Vektoren, Ströme, generell um Folgen irgendwelcher Art geht. Da Consize
stapelbasiert ist, kann die Konkatenation in manchen Fällen durch ein
`push` eines Elements auf den Stapel ersetzt werden. Aber das ist eher
ein Detail der Implementierung, weniger ein konzeptuelles.

::: description
[]{#description.stepcc label="description.stepcc"}

erwartet auf dem Eingangsstapel zwei Stapel `cs` und `ds`, die wir
Callstack und Datastack nennen, und ein Wörterbuch `dict`. Der Callstack
`cs` muss mindestens ein Element enthalten! Das Wort `stepcc` definiert
einen Rechenschritt in Consize als Veränderungen bezüglich des
Callstacks, des Datastacks und des Wörterbuchs. Zum leichteren
Verständnis vereinbaren wir folgende
[Substitutionen](http://de.wikipedia.org/wiki/Substitution_(Logik))
(Ersetzungen):[^1]

-   `cs` $=$ `[ itm ] rcs concat`. Der nicht-leere Callstack kann
    verstanden werden als Konkatenation einer Sequenz mit einem Element
    `itm` und den "restlichen" Elementen `rcs`; `itm` repräsentiert das
    oberste Element auf dem Callstack.

-   `res` $=$ `itm dict nil get`. Der mit dem obersten Element des
    Callstacks assoziierte Wert im Wörterbuch sei durch `res` erfaßt;
    ist kein Eintrag zu `itm` im Wörterbuch zu finden, so ist `res` $=$
    `nil`.

Die Veränderungen auf dem Ergebnisstapel seien ebenfalls in Form von
Substitutionen für `cs'`, `ds'` und `dict'` notiert. Sofern in den
folgenden Fallunterscheidungen nichts anderes angegeben ist, gilt
grundsätzlich `cs'` $=$ `rcs`, `ds'` $=$ `ds`, `dict'` $=$ `dict`.

1.  Ist `itm` ein Wort, dann schlage das Wort im Wörterbuch nach und
    betrachte das Resultat `res`.

    1.  Ist `res` ein Stapel (Quotierung/Programm): `cs'` $=$
        `res rcs concat`

    2.  Ist `res` eine Funktion: `ds'` $=$ `ds res apply`

    3.  weder/noch: `ds'` $=$ `[ itm ] ds concat`, `cs'` $=$
        `[ read-word ] rcs concat`

2.  Ist `itm` ein Mapping: `ds'` $=$ `[ itm ] ds concat`, `cs'` $=$
    `[ read-mapping ] rcs concat`

3.  Ist `itm` eine Funktion, []{#stepcc:fct label="stepcc:fct"} so wird
    die Funktion angewendet auf den Eingangsstapel mit dem kleinen
    Unterschied, dass `rcs` statt `cs` verwendet wird. Der
    Ergebnisstapel ist das Resultat von:
    `[ rcs ds dict ] r concat itm apply` Mit `r` seien die "restlichen"
    Elemente des Eingangsstapels ohne die führenden drei Elemente des
    Stapeleffekts (`cs`, `ds` und `dict`) erfasst.

4.  Ist `itm` entweder ein Stapel oder `nil`: `ds'` $=$
    `[ itm ] ds concat`
:::

In dieser formalen Darstellung stellt sich die Spezifikation des
Verhaltens von `stepcc` ein wenig komplizierter dar, als sie es wirklich
ist. Freisprachlich formuliert arbeitet `stepcc` wie folgt:

Befindet sich auf dem Callstack ein Wort und findet sich zu diesem Wort
im Wörterbuch eine Quotierung, dann ersetzt der Inhalt der Quotierung
das Wort auf dem Callstack. Die Ersetzung geschieht durch Konkatenation
der Quotierung mit dem Rest des Callstacks.

    > clear { \ -rot [ rot rot ] } [ z y x ] [ -rot swap ] stepcc
    { -rot [ rot rot ] } [ z y x ] [ rot rot swap ]

Findet sich im Wörterbuch stattdessen eine Funktion, dann wird die
Funktion auf den Datastack angewendet. Mit `get-dict` und `get` schlagen
wir die zu `rot` hinterlegte Funktion im Wörterbuch nach.

    > clear \ rot get-dict nil get \ rot { } assoc
    { rot <fct> }
    > [ z y x ] [ rot rot swap ] stepcc
    { rot <fct> } [ x z y ] [ rot swap ]

Findet sich zu dem Wort im Wörterbuch kein Eintrag oder ist es im
Wörterbuch weder mit einer Quotierung noch mit einer Funktion
assoziiert, dann gilt das Wort als unbekannt. Das Wort wird auf dem
Datastack abgelegt und auf dem Callstack durch `read-word` ersetzt.

    > clear { } [ z y x ] [ rot swap ] stepcc
    { } [ rot z y x ] [ read-word swap ]

Auf diese Weise kann mittels `read-word` ein Verhalten für unbekannte
Wörter vom Anwender selbst definiert werden. Anders ausgedrückt:
`read-word` ist ein Meta-Wort zur Definition des Umgangs mit unbekannten
Wörtern.

Ähnlich ist der Umgang mit Mappings. Ist das oberste Element auf dem
Callstack kein Wort, sondern ein Mapping, dann wird das Mapping auf dem
Datastack abgelegt und auf dem Callstack durch `read-mapping` ersetzt.
Das Wort `read-mapping` ist ein Meta-Wort, mit dem man das Verhalten im
Umgang mit Mappings frei definieren kann.

    > clear { } [ z y x ] [ { a b } swap ] stepcc
    { } [ { a b } z y x ] [ read-mapping swap ]

Ist das oberste Element auf dem Callstack weder ein Wort noch ein
Mapping, sondern eine Funktion, dann wende die Funktion auf den gesamten
Eingangsstapel an, mit dem `stepcc` aufgerufen wurde. Das Beispiel ist
zwar wenig sinnhaft, zeigt aber dennoch, wie `rot` nicht auf den durch
`[ 1 2 3 ]` repräsentierten Datastack der Continuation arbeitet, sondern
auf dem Eingangsstapel.

    > clear { } [ 1 2 3 ] [ ] \ rot get-dict nil get push
    { } [ 1 2 3 ] [ <fct> ]
    > stepcc
    [ 1 2 3 ] [ ] { }

Ist das oberste Elemente auf dem Callstack weder ein Wort noch ein
Mapping noch eine Funktion, dann muss es sich um einen Stapel oder `nil`
handeln; mehr als diese fünf Datentypen gibt es nicht. Ein Stapel bzw.
`nil` wandert vom Callstack auf den Datastack.

    > clear { } [ z y x ] [ [ 1 2 3 ] nil ] stepcc
    { } [ [ 1 2 3 ] z y x ] [ swap ]
    > clear { } [ z y x ] [ ] nil push stepcc
    { } [ nil z y x ] [ ]

Die Wörter `read-word` und `read-mapping` definieren ein einfaches
Metaprotokoll. Mit ihnen kann das Verhalten bei einem unbekannten Wort
oder bei einem Mapping auf dem Callstack frei definiert werden. Ohne
eine Definition für `read-word` wird bei Interpretation eines
unbekannten Wortes eine Endlosschleife losgetreten: Wenn `read-word`
unbekannt ist, wird per `read-word` nach der Bedeutung von `read-word`
gefahndet.

## Metaprogrammierung mit `call/cc`, `continue`, `get-dict`, `set-dict`, `"5C` {#sec:core.meta}

In dem durch `stepcc` definierten Interpreter sind auch ohne
Fall [\[stepcc:fct\]](#stepcc:fct){reference-type="ref"
reference="stepcc:fct"} (Funktion auf Callstack) die entscheidenden
Mechanismen angelegt, um ein turingmächtiges Rechensystem zu
realisieren. Fall [\[stepcc:fct\]](#stepcc:fct){reference-type="ref"
reference="stepcc:fct"} erweitert den Interpreter um die Möglichkeit der
[Metaprogrammierung](http://de.wikipedia.org/wiki/Metaprogrammierung),
einer Funktion wird der gesamte Zustand des Interpreters zur freien
Manipulation übergeben. Damit ist all das möglich, was in anderen
Programmiersprachen als
[Reflexion](http://de.wikipedia.org/wiki/Reflexion_(Programmierung))
(*reflection*) oder Introspektion (*introspection*) bezeichnet wird.

Das Wort `call/cc` (*call with current continuation*) dient als Einstieg
zur Manipulation von Call- und Datastack. Call- und Datastack werden in
Kombination auch als
"[Continuation](http://de.wikipedia.org/wiki/Continuation)" bezeichnet.
Mit `continue` wird der Meta-Modus beendet und die meist über `call/cc`
unterbrochene und manipulierte Continuation fortgesetzt (darum
*continue*). Mit `set-dict` kann der aktuelle Programmkontext, das
Wörterbuch gesetzt und mit `get-dict` gelesen werden.

Die Stapeleffekte zu den Wörtern sind, wie gehabt, die Effekte der
Funktionen auf Eingangs- und Ausgangsstapel. Dennoch gibt es einen
wichtigen Unterschied: Die Wörter sind im Wörterbuch nicht direkt mit
den Funktionen assoziiert, die Funktionen sind in einem Stapel
eingepackt. Das hat eine entscheidende Konsequenz bei der Interpretation
des Wortes durch `stepcc`: Der Stapel wird im ersten Schritt mit dem
Callstack konkateniert; damit befindet sich die Funktion als oberstes
Element auf dem Callstack. Im zweiten Schritt greift dann der
[\[stepcc:fct\]](#stepcc:fct){reference-type="ref"
reference="stepcc:fct"}. Fall in `stepcc`, und die Funktion wird
angewendet auf den aktuellen, gesamten Zustand aus Callstack, Datastack
und Wörterbuch des Interpreters.

`call/cc ( [ quot & ds ] cs – [ cs ds ] quot )`

:   erwartet zwei Stapel, die Continuation aus Callstack `cs` und
    Datastack `ds`, wobei sich auf dem Datastack als oberstes Element
    eine Quotierung `quot` befindet. Die Quotierung `quot` übernimmt als
    "neuer" Callstack das Ruder der Programmausführung, die Continuation
    aus `cs` und `ds` bildet den Inhalt des "neuen" Datastacks. Das
    durch `quot` repräsentierte Programm kann nun die auf dem Datastack
    abgelegte Continuation beliebig manipulieren.

```{=html}
<!-- -->
```

`continue ( [ cs ds & r ] quot – ds cs )`

:   ist das Gegenstück zu `call/cc`. Das Wort erwartet zwei Stapel, die
    Continuation aus der Quotierung `quot` (die durch `call/cc` in den
    Rang des ausführenden, aktuellen Callstacks erhoben wurde) und dem
    Datastack auf dem sich die übernehmende Continuation befindet
    `[ cs ds & r ]`. Weitere Elemente auf dem Datastack werden
    ignoriert, d.h. `r` spielt keine Rolle. Mit `cs` und `ds` wird die
    "neue" Continuation gesetzt.

Als Beispiel für `call/cc` und `continue` diene die Implementierung des
*backslash*-Wortes "`\`". Der Backslash ist Teil der Consize-VM.

`"5C`` ( ds [  wrd & cs ] – [ wrd & ds ] cs )`

:   legt das dem Wort `\` folgende Element auf dem Callstack direkt auf
    dem Datastack ab. Das Wort `\` wird auch als "Quote" oder "Escape"
    bezeichnet. Es verhindert die Interpretation von Daten auf dem
    Callstack. Das Wort ist definiert über das folgende Programm:

        : \ ( ds [ \ wrd & cs ] -- [ wrd & ds ] cs )   
          [ dup top rot swap push swap pop continue ] call/cc ;

Im Beispiel wird das dem Quote folgende `swap` auf dem Datastack
abgelegt, während das zweite, unquotierte `swap` seinen "normalen"
Dienst verrichtet.

    > clear 1 2 \ swap swap
    1 swap 2

Die Interpretation des Wortes `\` triggert die Ablage der aktuellen
Continuation auf dem Datastack. Die Quotierung zu `call/cc` sorgt dann
für den Transfer des Wortes vom Call- auf den Datastack. Sie können das
leicht nachvollziehen, wenn Sie `\` durch ein `break` im Beispiel
ersetzen.

    > clear 1 2 break swap swap
    [ 2 1 ] [ swap swap printer repl ]

Nun sehen Sie die Inhalte der im Moment von `break` gültigen
Continuation und können händisch die Manipulation durchführen. Per
`continue` wird anschließend die Programmausführung an die veränderte
Continuation übergeben.

    > dup top rot swap push swap pop
    [ swap 2 1 ] [ swap printer repl ]
    > continue
    1 swap 2

`get-dict ( dict ds cs – dict [ dict & ds ] cs )`

:   erwartet die Continuation aus `cs` und `ds` samt Wörterbuch `dict`
    und legt ein Duplikat des Wörterbuchs als oberstes Element auf dem
    Datastack ab.

Wenn Sie `get-dict` an der Konsole eingeben, dauert die Aufbereitung der
Ausgabe eine Weile. Haben Sie ein wenig Geduld. Zwar ist die Ausgabe
umfangreicher Wörterbücher oder Mappings wenig sinnvoll, aber Sie
bekommen einen Einblick, was so alles im Wörterbuch steht.

    > clear get-dict
    % output deliberately omitted

`set-dict ( dict [ dict’ & ds ] cs – dict’ ds cs )`

:   erwartet die Continuation aus `cs` und `ds` samt Wörterbuch `dict`,
    wobei sich auf dem Datastack als oberstes Element ein Wörterbuch
    `dict'` befindet. Das Wörterbuch `dict'` ersetzt das Wörterbuch
    `dict`.

Im Beispiel fügen wir dem Wörterbuch das Wort `square` mit einer
Quotierung hinzu.

    > clear [ dup * ] \ square get-dict assoc set-dict

    > 4 square
    16

## Arithmetik: `+`, `-`, `*`, `div`, `mod`, `<`, `>`, `integer?`

Consize bietet ein paar Wörter an, die Wörter als Zahlen interpretieren
und damit das Rechnen mit Zahlen
([Arithmetik](http://de.wikipedia.org/wiki/Arithmetik)) sowie einfache
Zahlenvergleiche (größer, kleiner) ermöglichen. Nachfolgend sind die
Angaben `x`, `y` und `z` in den Stapeleffekten Wörter, die [ganze
Zahlen](http://de.wikipedia.org/wiki/Ganze_Zahlen) repräsentieren.
Allerdings sind Ganzzahlen nicht als eigenständiger Datentyp in Consize
vertreten, Zahlen sind Wörter.

`+ ( x y – z )`

:   liefert mit `z` die Summe `x`$+$`y` zurück; `+` realisiert die
    [Addition](http://de.wikipedia.org/wiki/Addition).

```{=html}
<!-- -->
```
    > 2 3 +
    5

`- ( x y – z )`

:   liefert mit `z` die Differenz `x`$-$`y` zurück; `-` realisiert die
    [Subtraktion](http://de.wikipedia.org/wiki/Subtraktion).

```{=html}
<!-- -->
```
    > 2 3 -
    -1

`* ( x y – z )`

:   liefert mit `z` das Produkt `x`$\cdot$`y` zurück; `*` realisiert die
    [Multiplikation](http://de.wikipedia.org/wiki/Multiplikation).

```{=html}
<!-- -->
```
    > 2 3 *
    6

`div ( x y – z )`

:   liefert mit `z` den ganzzahligen Wert des Quotienten `x`$:$`y`
    zurück; `div` realisiert die ganzzahlige
    [Division](http://de.wikipedia.org/wiki/Division_(Mathematik)). Der
    Divisor `y` muss von `0` verschieden sein.

```{=html}
<!-- -->
```
    > 7 3 div
    2

`mod ( x y – z )`

:   liefert mit `z` den Rest der Division `x`$:$`y` zurück; `mod`
    realisiert den Divisionsrest,
    "[Modulo](http://de.wikipedia.org/wiki/Modulo#Modulo)" genannt. Die
    Zahl `y` muss von `0` verschieden sein.

```{=html}
<!-- -->
```
    > 7 3 mod
    1

Die Vergleichsoperatoren `<`, `>` etc. nutzen die
[Ordnungsrelation](http://de.wikipedia.org/wiki/Ordnungsrelation) unter
den Zahlen, die man sich z.B. anhand eines
[Zahlenstrahls](http://de.wikipedia.org/wiki/Zahlengerade)
veranschaulichen kann.

`< ( x y – t/f )`

:   liefert als Ergebnis des Vergleichs `x`$<$`y` entweder `t` (für
    wahr, *true*) oder `f` (für falsch, *false*) zurück.

```{=html}
<!-- -->
```
    > 7 3 <
    f

`> ( x y – t/f )`

:   liefert als Ergebnis des Vergleichs `x`$>$`y` entweder `t` oder `f`
    zurück.

```{=html}
<!-- -->
```
    > 7 3 >
    t

`integer? ( x – t/f )`

:   testet, ob das Wort `x` eine Ganzzahl (*integer*) repräsentiert, und
    liefert als Ergebnis entweder `t` oder `f` zurück.

```{=html}
<!-- -->
```
    > -7 integer?
    t
    > x integer?
    f

Hinweis: Alle Wörter zur Arithmetik sind optional und können durch
Consize-Programme in der Prelude vollständig ersetzt werden. Sie sind
lediglich aus Performanzgründen in der Consize-VM enthalten. Die
Referenzimplementierung von Consize rechnet mit Ganzzahlen beliebiger
Größe. Notwendig ist jedoch lediglich die Unterstützung von Ganzzahlen
mit mindestens 16 Bit Genauigkeit
([Integer](http://de.wikipedia.org/wiki/Integer_(Datentyp))), d.h. mit
einem Wertebereich von $-32.768$ bis $+32.767$.

## Zum Start: `load`, `call`, `run` {#sec:core.start}

Mit dem Aufruf von Consize ist über die Kommandozeile als Argument ein
Consize-Programm als Zeichenkette zu übergeben. Angenommen, diese
Zeichenkette werde durch das Wort `<args>` repräsentiert, so entspricht
die Semantik des Programmstarts der Wortfolge

    [ ] <args> uncomment tokenize get-dict func apply

Mit der Beendigung von Consize wird der aktuelle Datastack auf dem
Bildschirm ausgegeben. Die Ausgabe und die Notation ist abhängig von der
gewählten Implementierungssprache von Consize.

Zum Programmstart stehen alle bisher erwähnten Wörter der Consize-VM im
Wörterbuch bereit inklusive der folgenden Wörter, die es erleichtern,
ein Programm wie z.B. die Prelude aufzurufen und zu starten.

`load ( source – [ & itms ] )`

:   liest ein Consize-Programm aus der gegebenen Quelle, typischerweise
    aus einer Datei, entfernt Kommentare und zerlegt den Input in Wörter
    und gibt eine Sequenz aus Wörtern zurück. `load` ist in der
    Consize-VM wie folgt definiert:

        : load ( source -- [ & itms ] ) slurp uncomment tokenize ;

```{=html}
<!-- -->
```

`call ( [ quot & ds ] cs – ds quot cs concat )`

:   nimmt eine Quotierung vom Datastack und konkateniert sie mit dem
    Callstack.

        : call ( [ quot & ds ] cs -- ds quot cs concat )
          [ swap dup pop swap top rot concat continue ] call/cc ;

Der Aufruf einer über das Wörterbuch assoziierten Quotierung, einer
sogenannten "benamten" Quotierung, ist über den Mechanismus von `stepcc`
geregelt. Der Aufruf einer nicht-benamten, anonymen Quotierung ist mit
`call` möglich.

`run ( source – ... )`

:   liest ein Consize-Programm aus der gegebenen Quelle und führt das
    Programm aus.

        : run ( source -- ... ) load call ;

Beim Start von Consize sind die Meta-Wörter `read-word`, `read-mapping`
und `error` nicht definiert! Damit fehlt Consize das Wissen, wie es mit
unbekannten Wörtern, Mappings und Fehlersituationen umgehen soll. Die
Bedeutung dieser Wörter ist von der Programmiererin bzw. dem
Programmierer festzulegen.

## Referenzimplementierung {#Sec:Referenzimplementierung}

Für Consize liegt eine Referenzimplementierung in der funktionalen
Sprache [Clojure](http://clojure.org/) vor, die die Consize-VM komplett
umsetzt. Das Clojure-Programm ist weniger als 150 Programmzeilen lang!
Es läuft unter der [Java Virtual
Machine](http://de.wikipedia.org/wiki/Java_Virtual_Machine) (JVM). Die
Clojure-Implementierung ist im Zweifel der freisprachlichen
Spezifikation vorzuziehen -- allerdings ist dafür ein Verständnis der
Sprache Clojure erforderlich.

Alternative Implementierungen der Consize-VM müssen das Verhalten der
Referenzimplementierung nachbilden, wenn sie sich als "Consize-VM"
bezeichnen wollen; ausgenommen ist das Wort `identity?`.

Optionale Wörter der Consize-VM müssen, sofern sie nicht Teil einer
Consize-Implementierung sind, in einer angepassten Prelude
bereitgestellt werden.

[^1]: Bitte verwechseln Sie das Gleichheitszeichen auf keinen Fall mit
    einer Zuweisung.
