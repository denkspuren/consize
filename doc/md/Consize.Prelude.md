# Die Prelude {#Sec:Prelude}

Consize ist eine sehr primitive Sprache, die allein mit rund 50 atomaren
Wörter auskommt. Damit kann man zwar programmieren -- aber das
Programmieren mit Consize einzig mit den Wörtern der VM ist zu
umständlich und macht wenig Spaß. Viel schlimmer noch: Consize ist
anfänglich nicht einmal in der Lage, mit Ihnen zu interagieren. Wenn Sie
Consize starten, möchte Consize eine Datei namens `prelude.txt`
verarbeiten, die sogenannte Prelude. Fehlt die Datei oder steht dort
Unsinn drin, macht Consize entweder gar nichts -- oder eben eine Menge
Unsinn. So oder so, wir können mit Consize im Urzustand kaum sinnvoll
arbeiten.

Der Clou an Consize ist: Die Sprache lässt sich erweitern. Machen wir
uns die Sprache komfortabel. Wir werden etliche neue Wörter einführen,
die hilfreiche Abstraktionen bieten, wir werden die Syntax erweitern und
Consize interaktiv machen. Die dazu nötigen Programme stehen in der
Prelude.

In diesem Kapitel sind alle Programmzeilen der Prelude durch ein
vorangestelltes "`>> `" (inkl. Leerzeichen) ausgezeichnet. Diese
Markierung soll Ihnen helfen, in dem gesamten Text dieses Kapitels mit
all seinen Erläuterungen und Beispielen die entscheidenden
Programmzeilen zu identifizieren. Übrigens helfen die Markierungen auch
Consize, um den Quelltext aus der Dokumentation zu filtern.

Auch wenn der Einstieg in die Prelude gleich ein unvermittelter Einstieg
in die Programmierung mit Consize ist: Sie werden sehen, Consize ist
nicht wirklich schwer zu verstehen. In Consize zerlegt man Programme
systematisch in kleine Miniprogramme, die zu schreiben vergleichbar ist
mit der Herausforderung von Rätselaufgaben. Und Sie haben einen immensen
Vorteil bei der Arbeit mit Consize: Ihnen stehen die
Consize-Erweiterungen direkt zur Verfügung. Sie arbeiten mit einer
geladenen Prelude, um die Prelude zu verstehen. Das ist einfacher und
umkomplizierter als sich das anhört. Sie können ein paar Hilfsmittel,
wie z.B. den Debugger nutzen, um sich die Arbeitsweise von Consize zu
veranschaulichen.

## Vorbereitungen: Was sein muss und was nützlich ist

### Consize-Lizenz

Die Prelude beginnt mit einer
[Präambel](http://de.wikipedia.org/wiki/Pr%C3%A4ambel). Die Prelude ist
[Open-Source-Software](http://de.wikipedia.org/wiki/Open_source) (OSS).
Consize soll als Bildungsgut allen Interessierten frei zur Verfügung
stehen.

    >> %%% A Prelude for Consize in Consize
    >> %%% Copyright (c) 2017, Dominikus Herzberg, https://www.thm.de
    >> %%% New BSD License: http://opensource.org/licenses/BSD-3-Clause

### Booting zur Verarbeitung der Prelude {#Sec:LoadBootimage}

In Consize schreibt man Programme, indem man Wörter zum globalen
Wörterbuch hinzufügt und das Wort mit einer Quotierung -- einem
Mini-Programm, wenn man so möchte -- assoziiert. Das ist ein sehr
einfacher, aber auch sehr leistungsfähiger Abstraktionsmechanismus. So
abstrahiert das Wort `-rot` die Quotierung `[ rot rot ]`. Man spricht
auch von einer benamten Abstraktion: `-rot` ist der "Name" für die
Abstraktion `[ rot rot ]`.

    > \ -rot get-dict nil get
    [ rot rot ]

Mit dieser Abstraktionstechnik werden große und umfangreiche Programme
überhaupt erst realisierbar. Wir Menschen müssen mehr oder minder große
Programmeinheiten unter für uns sinngebenden Namen fassen können.
Ansonsten stoßen unsere intellektuellen Fähigkeiten beim Programmieren
rasch an ihre Grenzen.

Fortan wollen wir die Definition neuer Einträge im Wörterbuch wie folgt
notieren: Ein Doppelpunkt `:` leitet die Definition ein. Nach dem
Doppelpunkt folgt das Wort, dann optional der Stapeleffekt und
anschließend die das Wort definierende Wortfolge. Ein Semikolon schließt
die Definition ab.

In Anlehnung an die in
Kap. [\[Sec:UrGrammatik\]](#Sec:UrGrammatik){reference-type="ref"
reference="Sec:UrGrammatik"} formulierte Grammatik hält die folgende
Regel den Aufbau einer Wort-Definition fest.

::: grammar
\<definition\> = ':' \<separator\> \<word\> \[ \<separator\>
\<stackeffect\> \] \<separator\> \<program\> \<separator\> ';'
:::

Die Angabe von Stapeleffekten kennen Sie bereits aus
Kap. [\[Sec:ConsizeVM\]](#Sec:ConsizeVM){reference-type="ref"
reference="Sec:ConsizeVM"}. Alle Wörter der Consize-VM sind dort mit
ihren Stapeleffekten angegeben worden. Details zur Umsetzung von finden
sich in Kap. [1.7.2](#Sec:DefWords){reference-type="ref"
reference="Sec:DefWords"}, S. .

Die Syntax zur Definition neuer Wörter kann nicht direkt verwendet
werden, da die Consize-VM sie nicht kennt. Es bedarf eines kleinen
Consize-Programms, das diese komfortable Art der Definition neuer Wörter
zur Verfügung stellt. Dieses Consize-Programm ist als sogenanntes
"Bootimage" in der Datei `bootimage.txt` abgelegt und muss zuvor geladen
werden. Der Ladevorgang fährt die Consize-VM in einen
programmiertauglichen Zustand hoch, was man als
"[Booten](http://de.wikipedia.org/wiki/Booten)" bezeichnen kann.

    >> \ bootimage.txt run

In Kap. [1.9.3](#Sec:Bootstrapping){reference-type="ref"
reference="Sec:Bootstrapping"} ist beschrieben, was in dem Bootimage
steht und wie es erzeugt wird.

### Definition von `read-word` und `read-mapping`

Der durch `stepcc` beschriebene Ausführungsmechanismus der Consize-VM
ist in engen Grenzen konfigurierbar. Das Verhalten der beiden Wörter
`read-word` und `read-mapping` kann vom Anwender bzw. von der Anwenderin
frei definiert werden.

Die Prelude assoziiert beide Wörter mit "leeren" Programmen. Das
bedeutet: Unbekannte Wörter werden genauso wie Mappings auf dem
Datastack belassen.

    >> : read-word    ( wrd -- wrd ) ;
    >> : read-mapping ( map -- map ) ;

Durch Anpassung dieser Wörter sind beispielsweise Kodierungskonventionen
für Wörter und Mappings einführbar, die eine Sonderbehandlung erfahren
oder eine Vorverarbeitung erfordern sollen. Zu beachten ist, dass eine
alternative Definition dieser Meta-Wörter das Risiko birgt,
existierenden Code in größerem Umfang zu brechen. Man muss sehr sorgsam
mit diesen Wörtern umgehen.

### Mehr davon: Stack Shuffler

In praktisch allen höheren Programmiersprachen können Variablen in Form
von Zuweisungen (bei imperativen Sprachen) oder Substitutionen (bei
deklarativen/funktionalen Sprachen) verwendet werden. Variablen erfüllen
dabei hauptsächlich zwei Aufgaben: sie helfen Werte zwischenzuspeichern
und sie neu zu arrangieren für den Aufruf von Funktionen, Prozeduren
oder Methoden. Darüber hinaus bieten Variablennamen semantische Brücken
für den Programmierer bzw. die Programmiererin an, sich den Inhalt oder
den Zweck eines Wertes zu merken.

Da es in Consize keine Variablen gibt, muss das Zwischenspeichern von
Werten über die Erzeugung von Duplikaten auf dem Datastack möglich sein
(deshalb gibt es `dup` in der Consize-VM) und das Rearrangieren von
Werten über Stack-Shuffling gelöst werden. Es ist daher sehr hilfreich,
weitere Wörter als Abstraktionen zu den Stack-Shufflern der Consize-VM
zur Verfügung zu haben.

Da Variablennamen als semantische Brücken beim Programmieren fehlen,
gibt es nur eine Möglichkeit, um Consize-Programme übersichtlich zu
halten: Man muss die Definition von neuen Wörtern kurz halten und
gegebenenfalls weitere Wörter einführen, um über geeignete Abstraktionen
die Programme lesbar zu halten. Das ist auch der Grund, warum sich
Wortdefinitionen oft nur über ein, zwei oder drei Zeilen erstrecken und
praktisch nie über ein Dutzend Codezeilen hinausgehen. Und es
unterstreicht auch die Bedeutung der Angabe von Stapeleffekten.
Stapeleffekte beschreiben oft hinreichend genau, was ein Wort tut, so
dass man sich das *Wie* der Manipulation der Werte auf dem
Eingangsstapel nicht merken muss. Stapeleffekte erfüllen die Funktion
einer Schnittstellenbeschreibung (*interface description*).

    >> : 2drop ( x y -- ) drop drop ;
    >> : 3drop ( x y z -- ) drop drop drop ;
    >> : 2dup ( x y -- x y x y ) over over ;
    >> : 3dup ( x y z -- x y z x y z ) pick pick pick ;
    >> : dupd ( x y -- x x y ) swap dup rot ;    % dup deep
    >> : swapd ( x y z -- y x z ) swap rot rot ; % swap deep
    >> : -rot ( x y z -- z x y ) rot rot ;
    >> : rot4 ( x y z u -- y z u x ) [ rot ] dip swap ;
    >> : -rot4 ( x y z u -- u x y z ) swap [ -rot ] dip ;
    >> : pick ( x y z -- x y z x ) rot dup [ -rot ] dip ;
    >> : over ( x y -- x y x ) swap dup -rot ;
    >> : 2over ( x y z -- x y z x y ) pick pick ;
    >> : nip ( x y -- y ) swap drop ;
    >> : 2nip ( x y z -- z ) nip nip ;

Es deutet sich bei den Definitionen einiger Stack-Shuffler wie
z.B. `rot4` und `-rot4` an, dass es eine Alternative zum Stack-Shuffling
gibt, die die Abwesenheit von Variablen elegant kompensiert:
Kombinatoren, siehe Kap. [1.3](#Sec:Kombinatoren){reference-type="ref"
reference="Sec:Kombinatoren"}.

Zum Beispiel kann `rot4` auch wie folgt definiert werden; das
Stack-Shuffling ist im Kopf kaum mehr nachvollziehbar -- die Kommentare
mögen bei den gedanklichen Schritten helfen.

    : rot4 ( x y z u -- y z u x )
      [ ] swap push swap push % x y [ z u ]
      rot swap                % y x [ z u ]
      dup top swap pop top    % y x z u
      rot ;                   % y z u x

Da die Stack-Shuffler der Consize-VM nicht über die ersten drei Elemente
auf dem Datastack hinaus reichen, muss hier zu dem Trick gegriffen
werden, Elemente vom Datastack in einen Stapel zu "packen", um auf das
vierte Element von oben, hier `x`, zugreifen zu können.

Mit Hilfe des `dip`-Kombinators wird der Code radikal kürzer und
gleichzeitig auch leicht nachvollziehbar. Es werden zunächst die unteren
drei Werte, `x` `y` `z`, auf dem Datastack per `rot` rotiert, dann die
obersten zwei Werte mit `swap` getauscht.

Interessant ist auch, dass bei dem Einsatz von Kombinatoren die
Reversibilität des Verhaltens von `-rot4` zu `rot4` klar zutage tritt:
`-rot4` tauscht erst die beiden obersten Elemente und rotiert dann die
untersten drei. Die alternative Definition von `-rot4` mittels

    : -rot4 ( x y z u -- u x y z ) rot4 rot4 rot4 ;

macht nicht nur deutlich schwerer nachvollziehbar, was die mehrfache
Anwendung eines `rot4` bewirkt, sondern sie hat auch die dreifachen
Laufzeitkosten eines `rot4`.

Mehr zu `dip` und den anderen Kombinatoren steht in
Kap. [1.3](#Sec:Kombinatoren){reference-type="ref"
reference="Sec:Kombinatoren"}.

### Freunde und Helferlein {#Sec:Friends}

Bei der Arbeit mit Consize werden Sie feststellen, dass Sie einige
Wortkombinationen sehr häufig benötigen. Es macht Sinn, eigene Wörter
dafür einzuführen, um den Consize-Code lesbarer zu machen.

Die folgenden Wörter sind hilfreiche Begleiter bei der Arbeit mit
Stapeln.

    >> : swapu ( itm stk -- stk' ) cons ; % deprecated
    >> : cons ( itm stk -- [ itm & stk ] ) swap push ;
    >> : uncons ( [ itm & stk ] -- itm stk ) dup top swap pop ;
    >> : unpush ( [ itm & stk ] -- stk itm ) dup pop swap top ;
    >> : empty? ( stk -- t/f ) ( ) equal? ;
    >> : size ( seq -- n ) dup empty? [ drop 0 ] [ pop size 1 + ] if ;
    >> : time ( quot -- ... msecs )
    >>   current-time-millis swap dip current-time-millis swap - ;

Die Anzahl der Elemente in einer Sequenz liefert `size` zurück.

    > clear [ ] size [ x y z ] size
    0 3

Der Wert `nil` zum Datentyp "nil" ist in Consize nur indirekt über ein
`top` eines leeren Stapels definiert. Um den Wert ohne Umwege zugreifbar
zu haben, gibt es das Wort `nil`.

Das Wort `lookup` schlägt den mit einem Wort assoziierten Wert im
Wörterbuch nach, `delete` entfernt das Wort auf seinen Zielwert aus dem
Wörterbuch. Das Wort `values` gibt -- im Gegensatz zu `keys` -- alle mit
den Schlüsseln assoziierten Zielwerte als Sequenz zurück.

    >> : nil ( -- nil ) ( ) top ;
    >> : lookup ( word -- item ) get-dict nil get ;
    >> : delete ( itm -- ) get-dict dissoc set-dict ;
    >> : values ( dict -- seq ) dup keys swap [ nil get ] cons map ;

### Kombinatoren: `call`, `fcall`

Ein "Kombinator" ist ein Wort, das einen Stapel zur Ausführung bringt,
d.h. das den Stapel als Programm interpretiert. Einen solchen Stapel
nennen wir "Quotierung". Der Stapel dient nur als Mittel zum Zweck, um
die Ausführung des darin enthaltenen Programms zurückzustellen. Der
Kombinator aktiviert die Quotierung.

Wenn Consize ein Programm abarbeitet, ist es zu einem guten Teil mit der
Auflösung benamter Abstraktionen beschäftigt: Das oberste Wort auf dem
Callstack wird durch den Inhalt der mit ihm assoziierten Quotierung
ersetzt. Technisch ausgedrückt: Das Wort wird vom Callstack entfernt und
die assoziierte Quotierung mit dem Callstack konkateniert.

Für den Aufruf anonymer Abstraktionen, d.h. Quotierungen, die nicht im
Wörterbuch mit einem Wort verknüpft sind, gilt im Grunde der gleiche
Ablauf -- realisiert durch den Kombinator `call`. Das Wort erwartet eine
Quotierung auf dem Eingangsstapel, die es mit dem Callstack
konkateniert. Implementiert werden kann dieses Verhalten mit Zugriff auf
die aktuelle Continuation. Der Stapeleffekt soll die Umsetzung per
`call/cc` abbilden.

    >> : call ( [ quot & ds ] cs -- ds quot cs concat )
    >>   [ swap unpush rot concat continue ] call/cc ;

Das mit `call/cc` initiierte Programm tauscht Data- und Callstack der
aktuellen Continuation (`swap`), holt das oberste Element (die
Quotierung) vom Datastack (`unpush`), bringt den Callstack wieder nach
oben (`rot`) und konkateniert Quotierung und Callstack miteinander
(`concat`). Anschließend übernimmt die so veränderte Continuation wieder
die Ausführung (`continue`).[^1]

Im Beispiel wird das per Quotierung zurückgestellte Programm, die
Addition, erst durch den Aufruf von `call` ausgeführt.

    > clear 4 2 3 [ + ]
    4 2 3 [ + ]
    > call
    4 5

Die Technik, mit `call/cc` und `continue` ein Programm zu unterbrechen,
es zu modifizieren und dann fortzusetzen, nennt man
"[Metaprogrammierung](http://de.wikipedia.org/wiki/Metaprogrammierung)".
Das mit `call/cc` mitgegebene Programm modifiziert das aktuell in der
Ausführung begriffene Programm. Diese zur Laufzeit des Programms
stattfindende Änderung nennt man deshalb auch
"Laufzeit-Metaprogrammierung".

Mit Hilfe des `call`-Kombinators können direkt oder indirekt alle
anderen Kombinatoren abgeleitet werden. Einzig `fcall` (für \"\`*call
via a function*\") ist eine Ausnahme, aber nur deshalb, weil es eine
andere Implementierungsstrategie über Funktionen verfolgt. Es erzeugt im
Gegensatz zu `call` über `func` einen eigenen Ausführungskontext,
bekommt einen leeren Stapel als Eingangsstapel, wendet die Funktion
darauf an (`apply`) und liefert das Ausführungsergebnis als Stapel
zurück und zwar mit dem "umgekehrten" Ergebnisstapel (`reverse`).

    >> : fcall ( quot -- seq ) get-dict func ( ) swap apply reverse ;  

    > clear [ 4 2 3 + ] fcall
    [ 4 5 ]

Das Wort `fcall` nimmt den Callstack der Implementierungssprache von
Consize in Anspruch, `call` nutzt den Callstack der aktuellen
Continuation.

Die Namen der Kombinatoren in den folgenden Kapiteln orientieren sich in
vielen Fällen an der konkatenativen Sprache Factor. Bisweilen sind auch
die Definition der Kombinatoren von Factor übernommen.

## Entscheidungskombinatoren

Ein grundlegendes Feature einer turingvollständigen Programmiersprache
ist es, Entscheidungen treffen zu können: wähle -- abhängig von einem
Entscheidungswert -- entweder dieses oder jenes. Im einfachstenfall ist
der Entscheidungswert zweiwertig, binär. Zu Ehren des Logikers [George
Boole](http://de.wikipedia.org/wiki/George_Boole) heißen diese beiden
Werte "boolesche Werte" und werden mit "wahr" (*true*) und "falsch"
(*false*) bezeichnet. In Consize repräsentieren die Werte `t` und `f`
diese beiden Optionen; in einem Programm schreibt es sich lesbarer mit
`true` und `false`.

### Boolesche Werte und die binäre Wahl mit `choose`

Die Consize-VM bietet von sich aus kein Wort an, das Entscheidungen
realisiert; in vielen Programmiersprachen dient dazu das *if*. Trotzdem
-- und das ist das Spannende daran -- ist ein Wort für Entscheidungen
nachrüstbar. Der
[Lambda-Kalkül](http://en.wikipedia.org/wiki/Lambda_calculus) macht es
übrigens genauso.

Das Wort `choose ( t/f this that -- this/that )` bildet die Grundlage
für die binäre Auswahl. `choose` erwartet auf dem Datastack einen
booleschen Wert und zwei Wahlwerte, die wir im Stapeleffekt mit `this`
und `that` bezeichnen. Abhängig vom booleschen Wert lässt `choose`
entweder `this` oder `that` auf dem Datastack zurück.

Die Bedeutung von `t` und `f` erschließt sich nur im Kontext des Wortes
`choose` -- und so bilden die mit den booleschen Werten assoziierten
Programme exakt das beschriebene Verhalten nach: `t` entfernt `that` vom
Datastack, um `this` zu erhalten, `f` macht es genau anders herum. Ohne
den Kontext von `choose` sind die booleschen Werte `t` und `f`
bedeutungslos.

    : t ( this that -- this ) drop ;
    : f ( this that -- that ) swap drop ;

Die Wörter `true` und `false` dienen lediglich dem Lese- und
Schreibkomfort beim Programmieren; es ist rasch vergessen, das
Escape-Wort einem `t` bzw. `f` voranzustellen, denn schließlich sollen
die Programme für `t` und `f` nicht sofort ausgeführt werden.

    >> : true  ( -- t ) \ t ;
    >> : false ( -- f ) \ f ;

Das Wort `choose` muss per `rot` den booleschen Wert lediglich oben auf
den Datastack bringen, die Bedeutung (sprich: Semantik) von `t` bzw. `f`
mit `lookup` nachschlagen, und die ermittelte Quotierung mit `call`
aufrufen. Das Wort `choose` macht nicht viel mehr als das mit `t` bzw.
`f` assoziierte Verhalten zu aktivieren.

    : choose ( t/f this that -- this/that ) rot lookup call ;

Mit dieser Definition könnte man es bewenden lassen, doch es gibt einen
guten Grund, die Auslegung boolescher Werte ein wenig zu erweitern.

Falls sich bei `choose` weder ein `t` noch ein `f` an dritter Stelle,
sondern ein beliebiger anderer Wert auf dem Datastack befindet, dann hat
der Programmierer bzw. die Programmiererin den im Stapeleffekt
dokumentierten "Vertrag" zum Gebrauch des Wortes `choose` gebrochen. Die
Folgen aus einem fälschlichen Gebrauch des Wortes hat der Programmierer
bzw. die Programmiererin zu verantworten. Es spielt keine Rolle, ob der
Fehlgebrauch unabsichtlich erfolgt oder nicht. Dieses Prinzip ist so
wichtig, dass es nicht nur "im richtigen Leben" sondern auch in der
Softwaretechnik zur Anwendung kommt: Wer einen Vertrag verletzt, darf
die andere Partei (in dem Fall Consize) nicht für den entstehenden
Schaden verantwortlich machen. Man muss beim Programmieren durchaus
Vorsicht walten lassen.

Man könnte eine Vertragsverletzung durch eine Fehlermeldung abfangen, um
auf das Problem aufmerksam zu machen und gegebenenfalls darauf zu
reagieren. Allerdings verändert ein solches Vorgehen das Wort `choose`
von einer binären zu einer ternären Wahl: wähle `this` im Fall von `t`,
`that` im Fall von `f` und mache etwas gänzlich anderes, wenn ein
anderes Datum an dritter Position im Datastack steht. Das passt nicht zu
unseren anfänglichen Intentionen, mit `choose` lediglich eine binäre
Auswahl treffen zu wollen.

Programmiersprachen mit [dynamischer
Typisierung](http://de.wikipedia.org/wiki/Dynamische_Typisierung) --
Consize gehört dazu -- unterstützen zwar ein strikt binäres Verhalten,
vermeiden aber Fehlermeldungen in der Regel durch eine simple Regelung:
Jeder Wert, der sich von `f` unterscheidet, wird so interpretiert als
sei er ein logisches *true*. Wenn der dritte Wert auf dem Datastack
nicht `f` ist, dann wählt `choose` `this`, ansonsten `that` aus. Die
Definition von `choose` verändert sich entsprechend geringfügig. Der
Stern `*` im Stapeleffekt steht für einen beliebigen Wert außer `f`.

    : choose ( f/* this that -- that/this )
      swap rot false equal? lookup call ;

Sprachen mit [statischer
Typisierung](http://de.wikipedia.org/wiki/Statische_Typisierung)
schließen den Fehlerfall eines nicht booleschen Wertes durch eine
Typüberprüfung vor Programmausführung aus. Wäre Consize eine statisch
typisierte Sprache, könnte die Verwendung eines booleschen Wertes sicher
gestellt werden, und es würde die eingangs angegebene Definition von
`choose` ausreichen.

Wenn die booleschen Werte nur im Kontext von `choose` sinnvoll
interpretiert werden können, stellt sich die Frage, ob die Bedeutung von
`t` und `f` überhaupt außerhalb von `choose` bekannt sein muss. Anders
gefragt: Kommen wir ohne Einträge für `t` und `f` im Wörterbuch aus? In
der Tat lässt sich ein "lokales" Wörterbuch im Rumpf der Definition von
`choose` verwenden. Und den Vergleich per `equal?` bekommen wir bei
einer Wörterbuchabfrage per `get` gleichermaßen "geschenkt".

    >> SYMBOL: t
    >> SYMBOL: f
    >> 
    >> : choose ( f/* this that -- that/this )
    >>   rot { \ f [ swap drop ] } [ drop ] get call ;

Das Verhalten von `choose` demonstriert folgende Beispieleingabe an der
Konsole.

    > clear false this that
    f this that
    > choose
    that
    > clear [ 1 2 3 ] this that choose
    this

Die logischen Operationen der [Booleschen
Algebra](http://de.wikipedia.org/wiki/Boolesche_Algebra) `and`
(Konjunktion), `or` (Disjunktion), `xor` (ausschließende Disjunktion)
und `not` (Negation) sind dieser erweiterten Interpretation logischer
Werte ("alles was nicht `f` ist, ist logisch `t`") angepasst.

    >> : and ( f/* f/* -- t/f ) over choose ; % Factor
    >> : or  ( f/* f/* -- t/f ) dupd choose ; % Factor
    >> : xor ( f/* f/* -- t/f ) [ f swap choose ] when* ; % Factor
    >> : not ( f/* -- t/f ) false true choose ;

Ein kurzes Beispiel zeigt den Gebrauch von `and`.

    > clear true true and
    t
    > false true and
    t f

### Binäre Entscheidungen: `if`, `when`, `unless` & Co.

Das Wort `choose` realisiert zwar eine binäre Wahl, doch werden damit
noch keine unterschiedlichen Verhaltenskonsequenzen umgesetzt. Das ist
erst dann der Fall, wenn `this` und `that` Quotierungen sind, die nach
einem `choose` per `call` aufgerufen werden. Dafür gibt es das Wort
`if`; die Quotierungen werden im Stapeleffekt mit `then` und `else`
bezeichnet. Dass die Auswirkungen auf den Datastack von den beiden
Quotierungen abhängen und nicht vorhersehbar sind, deuten die Punkte auf
der rechten Seite des Stapeleffekts an.

    >> : if ( f/* then else -- ... ) choose call ;
    >> : if-not ( f/* then else -- ... ) swap if ;
    >> : when ( f/* then -- ... ) [ ] if ;
    >> : unless ( f/* else -- ... ) [ ] if-not ;

Die Wörter `if-not`, `when` und `unless` sind hilfreiche Abstraktionen,
die alle Variationen des `if`-Themas abdecken: `if-not` vertauscht die
Rolle der beiden Quotierungen `then` und `else` (dem gedanklich eine
Negation des booleschen Wertes entspricht), `when` führt die Quotierung
nur aus, wenn der vorangehende Wert als logisch *true* gilt, `unless`,
wenn er *false* ist.

    > clear 5 dup 3 < [ 1 + ] [ 1 - ] if
    4
    > clear 5 dup 3 < [ 1 + ] [ 1 - ] if-not
    6
    > clear 5 true [ 1 + ] when
    6
    > clear 5 false [ 1 - ] unless
    4

Jeder Wert außer `f` gilt im Kontext eines `if`, `if-not`, `when` oder
`unless` als logisch *true*, selbst wenn der Bedingungswert nicht gleich
`t` ist. Da macht es bisweilen Sinn, den logisch wahren Bedingungswert
auf dem Stapel durch ein implizites `dup` zu erhalten, um mit ihm weiter
rechnen zu können. Genau dafür gibt es die "Stern-Varianten" `if*`,
`when*` und `unless*`. Ist der Bedingungswert `f`, so unterbleibt die
Duplizierung und `if*`, `when*` bzw. `unless*` arbeiten wie ihre
"sternlosen" Vorbilder `if`, `when` und `unless`.

    >> : if* ( f/* then else -- ... )
    >>   pick [ drop call ] [ 2nip call ] if ; % Factor
    >> : when* ( f/* then -- ... ) over [ call ] [ 2drop ] if ; % Factor
    >> : unless* ( f/* else -- ... ) over [ drop ] [ nip call ] if ; % Factor

    > clear 6 [ 1 + ] [ 0 ] if*
    7
    > clear false [ 1 + ] [ 0 ] if*
    0
    > 6 [ 1 + ] when*
    7
    > clear 5 6 [ 1 - ] unless*
    5 6
    > clear 5 false [ 1 - ] unless*
    4

### $n$-äre Entscheidungen: `case` und `cond`

Die mit dem Wort `case` umgesetzte $n$-äre Entscheidung verallgemeinert
das Konzept der binären `if`-Entscheidung. Eine Handlungsalternative
hängt bei `case` nicht ab von zwei Alternativen (`f` oder nicht `f`),
sondern von einem Wert aus einer Menge von Werten. Die
Grundfunktionalität von `case` ist bereits durch Mappings gegeben; nach
einem `get` muss im Grunde nur noch ein `call` folgen. Mit dem
Auswahlwert `:else` besteht die Option, eine Reaktion zu initiieren,
wenn kein sonstiger Auswahlwert in `case` zutrifft.

Das Wort `SYMBOL:` setzt mit dem nachfolgenden Wort, hier `:else`, eine
Definition auf, die das Wort mit sich selbst als Datenwert definiert
(hier `: :else \ :else ;`).

    >> SYMBOL: :else 
    >> : case ( val { val' quot ... } -- ... )
    >>   :else over [ ] get get call ;

Es ist zu beachten, dass die Zielwerte in einem "`case`-Mapping" stets
Quotierungen sind.

    > clear 3 \ red
    3 red
    > { \ red [ 1 + ] \ blue [ 1 - ] :else [ ] } case
    4
    > blue { \ red [ 1 + ] \ blue [ 1 - ] :else [ ] } case
    3
    > black { \ red [ 1 + ] \ blue [ 1 - ] :else [ ] } case
    3

Die Verschachtlung von `if`-Wörtern in den `else`-Quotierungen eines
`if`-Worts erzeugt rasch unleserlichen Code. Als Alternative bietet sich
das syntaktisch übersichtlichere `cond` an, das die `test`- und
`then`-Quotierungen verschachtlungsfrei zu notieren erlaubt. Einer
`test`-Quotierung folgt eine `then`-Quotierung; im `else`-Fall folgt die
nächste `test`-Quotierung usw.; die Terminologie orientiert sich an der
Beschreibung des Stapeleffekts für `if`. Eine optionale
`else`-Quotierung dient für den Fall, wenn alle `test`-Quotierungen
fehlschlagen.

    >> : cond ( [ test1 then1 test2 then3 ... else ] -- ... )
    >>   dup empty?                 % anything left to test?
    >>     [ drop ]                 % no: quit
    >>     [ uncons dup empty?      % only one quotation left?
    >>       [ drop call ]          % yes: call 'else'
    >>       [ uncons               % otherwise:
    >>         [ ] \ cond push cons % prepare 'cond' recursion
    >>         [ call ] 2dip if ]   % call 'testN' and apply 'if'
    >>     if ]
    >>   if ;

Per Konvention wird die Folge von Quotierungen vor einem `cond` in
runden Klammern notiert, nicht zuletzt, um eine visuell leichtere
Abgrenzung zu haben. Beachten Sie, dass in den `test`-Quotierungen in
aller Regel ein `dup` nötig ist, nicht zuletzt, um den Test-Wert für
nachfolgende Bedingungen zu erhalten.

    > clear

    > 7 ( [ dup 0 > ] [ 1 + ] [ dup 0 < ] [ 1 - ] [ ] ) cond
    8
    > -7 ( [ dup 0 > ] [ 1 + ] [ dup 0 < ] [ 1 - ] [ ] ) cond
    8 -8
    > 0 ( [ dup 0 > ] [ 1 + ] [ dup 0 < ] [ 1 - ] [ ] ) cond
    8 -8 0

Ein `case` lässt sich immer über ein `cond` nachbilden, allerdings hat
ein `case` durch das Mapping ein besseres Laufzeitverhalten, während die
Laufzeit von `cond` mit jeder Verschachtlung linear anwächst. Umgekehrt
kann nicht jedes `cond` in ein äquivalentes `case` umgewandelt werden.

## Aufruf-Kombinatoren {#Sec:Kombinatoren}

Dieses Kapitel beschäftigt sich mit Kombinatoren, die Varianten von
`call` sind und unter dem Oberbegriff der "Aufruf-Kombinatoren"
(`call`-Kombinatoren) laufen. Die Abtauch-Kombinatoren
(`dip`-Kombinatoren) lassen die oberen Stapelwerte vor dem `call` der
Quotierung abtauchen, die Erhaltungskombinatoren (`keep`-Kombinatoren)
restaurieren die oberen Werte nach dem `call` wieder. Wieder andere
Kombinatoren rufen zwei oder mehr Quotierungen nach verschiedenen
Mustern auf (Cleave-, Spread- und Apply-Kombinatoren).

Generell reduzieren diese Kombinatoren die Notwendigkeit des
Stack-Shufflings und bringen deshalb lesbarere Programme mit sich.

### "Abtauch"-Kombinatoren: `dip` {#Sec:dip}

Die `dip`-Kombinatoren rufen wie ein `call` eine Quotierung auf dem
Datastack auf. Im Gegensatz zu einem reinen `call` gehen die unmittelbar
"vor" der Quotierung stehenden Daten für die Dauer des Aufrufs
gleichermaßen auf Tauchstation; das englische Wort *dip* ist hier im
Sinne von "abtauchen" zu verstehen. Nach dem Aufruf erscheinen die
"abgetauchten" Daten wieder auf dem Datastack. Das Wort `dip` verbirgt
ein Element vor der aufzurufenden Quotierung, das Wort `2dip` verbirgt
zwei Elemente, `3dip` drei und `4dip` vier.

    >> : dip ( x quot -- x ) [ ] rot push \ \ push concat call ;
    >> : 2dip ( x y quot -- x y ) swap [ dip ] dip ;
    >> : 3dip ( x y z quot -- x y z ) swap [ 2dip ] dip ;
    >> : 4dip ( w x y z quot -- w x y z ) swap [ 3dip ] dip ;

    > clear [ ] 4 5 [ push ] dip
    [ 4 ] 5
    > clear [ ] 4 5 [ drop ] 2dip
    4 5

Die Definition $n$-facher `dip`-Kombinatoren folgt einem einfachen
Schema: Das einleitende `swap` und das beendende `dip` bleiben immer
gleich; lediglich die Quotierung greift auf die vorhergehende
`dip`-Definition zurück. In der Rückverfolgung des Bildungsgesetzes kann
man auch fragen: Wie müsste demnach die Definition von `dip` lauten? In
der Quotierung wäre ein `0dip` zu verwenden. Ein `dip`, das `0` Werte
auf dem Datastack "abtauchen" lässt, ist identisch mit `call`.

    : dip ( x quot -- x ) swap [ call ] dip ;

Diese Definition nimmt auf sich selbst Bezug und liefert auch in ihrer
Auflösung von `dip` im Definitionsrumpf durch die Definition von `dip`
keine weitere Erkenntnisse. Einen Hinweis, wie `dip` implementiert
werden kann, liefert sie dennoch: Es ist der Versuch, das im
Stapeleffekt mit `x` bezeichnete Element nicht mehr vor der Quotierung,
sondern es per `swap` hinter die Quotierung zu bekommen, so dass der
`call` der Quotierung `quot` das Element `x` nicht mehr erfasst.

Man kann dieses Verhalten zum Beispiel durch die Manipulation der
aktuellen Continuation nach einem `swap` erreichen; der Stapeleffekt
deutet an, was hier gemacht wird.

    : dip ( itm quot -- quot | call \ itm )
      swap [ swap unpush rot cons \ \ push \ call push continue ]
      call/cc

Grundsätzlich sollte man den Einsatz von Continuations vermeiden wann
immer möglich; das hat formale Gründe, auf die in
Kap. [1.7.3](#Sec:DefSymbols){reference-type="ref"
reference="Sec:DefSymbols"} näher eingegangen wird. Alternativ kann man
den vor der Quotierung stehenden Wert ans Ende der Quotierung anhängen
und mit einem Escape-Wort sicherstellen, dass der Wert nicht als zu
interpretierendes Wort behandelt wird. Genau das tut die in der Prelude
verwendete Definition, siehe oben. Alternative Definitionen sind:

    : dip ( x quot -- x ) swap [ ] cons \ \ push concat call ;

    : dip ( x quot -- x ) reverse \ \ push cons reverse call ;

Die alternativen Definitionen sind ebenso lesbar und einleuchtend wie
die in der Prelude verwendete. Eine Messung der Laufzeiten könnte als
Kriterium herangezogen werden, um die schnellste Lösung zu wählen. Da
`dip` durchaus laufzeitkritisch ist -- es spielt bei den nachfolgenden
Kombinatoren eine entscheidende Rolle --, hat z.B. die konkatenative
Sprache Factor `dip` im Kern seiner VM aufgenommen. Angenommen, `dip`
sei als primitives Wort gegeben, dann sind `call` und `rot` definierbar
als:

    : call ( quot -- ... ) dup dip drop ;
    : rot ( x y z -- y z x ) [ swap ] dip swap ;

Es hängt sehr davon ab, welche Wörter als primitiv angesehen und in
einer VM implementiert werden, und welche Wörter dann in Folge
"abgeleitete" Wörter sind.

### Erhaltungskombinatoren: `keep`

Die `keep`-Kombinatoren rufen die Quotierung auf dem Datastack wie ein
`call` auf, sie bewahren (*keep*) jedoch nach dem Aufruf eine Reihe von
Daten, die sich "vor" der Quotierung und vor dem Aufruf auf dem
Datastack befanden. Das Wort `keep` erhält ein Datum, `2keep` zwei
Datenwerte und `3keep` drei Datenwerte.

    >> : keep  ( x quot -- x ) [ dup ] dip dip ;
    >> : 2keep ( x y quot -- x y ) [ 2dup ] dip 2dip ;
    >> : 3keep ( x y z quot -- x y z ) [ 3dup ] dip 3dip ;

Die Ausdrucksmittel für die Beschreibung der Stapeleffekte reichen nicht
aus, um die Unterschiede zu den `dip`-Kombinatoren hervorzuheben. Die
tatsächlichen Auswirkungen auf den Datastack hängen von dem Aufruf der
Quotierung ab.

    > clear 2 3 [ + ] 2keep
    5 2 3

Beachten Sie, dass die `keep`-Kombinatoren wie die `dip`-Kombinatoren
einem regulären Aufbau folgen -- diesmal ohne jegliche Brüche.

Interessant sind in Consize die wechselseitigen Bezüge, die Wörter
zueinander haben. Das offenbart innere Strukturen, die andere
Programmiersprachen weniger deutlich erkennen lassen. Zum Beispiel
könnten `dup`, `2dup` und `3dup` auch über Erhaltungskombinatoren
definiert sein.

    : dup ( x -- x x ) [ ] keep ;
    : 2dup ( x y -- x y x y ) [ ] 2keep ;
    : 3dup ( x y z -- x y z x y z ) [ ] 3keep ;

Andererseits ist `keep` mit `dup` definiert worden, `2keep` mit `2dup`
etc. Es ist alles eine Frage, aus welchen Wörtern die Consize-VM
besteht. Daraus sind die nicht atomaren Wörter abzuleiten.

Eine alternative Implementierung für die Erhaltungskombinatoren ist:

    : keep  ( x quot -- x ) over [ call ] dip ; % see Factor
    : 2keep ( x y quot -- x y ) 2over [ call ] 2dip ;
    : 3keep ( x y z quot -- x y z ) 3over [ call ] 3dip ;

Beachten Sie, dass `3over` in der Prelude nicht definiert ist.

### Cleave-Kombinatoren: `bi`, `tri`, `cleave`

Das Wort *cleave* heißt hier soviel wie "bewahren", "festhalten",
"teilen".

Die `bi`- und `tri`-Kombinatoren wenden zwei bzw. drei Quotierungen
nacheinander auf den Datastack an und restaurieren ein, zwei oder drei
Werte auf dem Datastack vor dem Aufruf der nächsten Quotierung. Im
Stapeleffekt sind die Quotierungen mit `p`, `q` und `r` bezeichnet, die
restaurierten Werte mit `x`, `y` und `z`.

    >> : bi ( x p q -- ) [ keep ] dip call ;
    >> : 2bi ( x y p q -- ) [ 2keep ] dip call ;
    >> : 3bi ( x y z p q -- ) [ 3keep ] dip call ;

    >> : tri ( x p q r -- ) [ [ keep ] dip keep ] dip call ;
    >> : 2tri ( x y p q r -- ) [ [ 2keep ] dip 2keep ] dip call ;
    >> : 3tri ( x y z p q r -- ) [ [ 3keep ] dip 3keep ] dip call ;

Ein paar wenige Beispiele mögen die Arbeitsweise von `bi`- bzw.
`tri`-Kombinatoren veranschaulichen.

    > clear 2 [ 1 + ] [ dup * ] bi
    3 4
    > [ + ] [ * ] 2bi
    7 12
    > clear 2 [ 1 + ] [ dup * ] [ 1 - ] tri
    3 4 1

Der `cleave`-Kombinator verallgemeinert die `bi`- bzw.
`tri`-Kombinatoren. Der `cleave`-Kombinator nimmt beliebige viele
Quotierungen als Sequenz entgegen und wendet die Quotierungen
nacheinander auf einen (`cleave`), auf zwei (`2cleave`) bzw. drei
(`3cleave`) Werte auf dem Datastack an; vor jedem Aufruf werden die
Werte restauriert. Das Wort `each` ist in
Kap. [1.4](#Sec:SequenceCombinators){reference-type="ref"
reference="Sec:SequenceCombinators"} definiert.

    >> : cleave ( x [ p q ... ] -- ) [ keep ] each drop ;
    >> : 2cleave ( x y [ p q ... ] -- ) [ 2keep ] each 2drop ;
    >> : 3cleave ( x y z [ p q ... ] -- ) [ 3keep ] each 3drop ;

Das folgende Beispiel ist identisch mit dem vorstehenden `tri`-Beispiel.

    > clear 2 ( [ 1 + ] [ dup * ] [ 1 - ] ) cleave
    3 4 1

### Spread-Kombinatoren: `bi*`, `tri*`, `spread`

Der `bi*`-Kombinator erwartet zwei Quotierungen (`p` und `q`), der
`tri*`-Kombinator drei Quotierungen (`p`, `q` und `r`). Die Quotierungen
verarbeiten im Fall von `bi*` und `tri*` jeweils nur einen Wert, bei
`2bi*` und `2tri*` jeweils zwei Werte. Die Quotierungen werden auf die
Verarbeitung der Stapelwerte verteilt -- *spread* bedeutet soviel wie
"verteilen", "spreizen".

Im Fall von `bi*` arbeitet `p` auf `x` und `q` auf `y`. Und im Fall von
`2bi*` verarbeitet `p` die Werte `w` und `x` und `q` die Werte `y` und
`z`.

    >> : bi* ( x y p q -- ) [ dip ] dip call ;
    >> : 2bi* ( w x y z p q -- ) [ 2dip ] dip call ;

    > clear 2 3 [ 1 + ] [ dup * ] bi*
    3 9
    > clear 1 2 3 4 [ + ] [ * ] 2bi*
    3 12

Die Kombinatoren `tri*` und `2tri*` arbeiten entsprechend.

    >> : tri* ( x y z p q r -- ) [ 2dip ] 2dip bi* ;
    >> : 2tri* ( u v w x y z p q r -- ) [ 4dip ] 2dip 2bi* ;

    > clear 4 3 2 [ 1 + ] [ dup * ] [ 1 - ] tri*
    5 9 1
    > clear 6 5 4 3 2 1 [ + ] [ * ] [ - ] 2tri*
    11 12 1

Die Verallgemeinerung der Spread-Kombinatoren `bi*`- und `tri*` bietet
das Wort `spread`; es erwartet $n$ Elemente und entsprechend $n$
Quotierungen in einem Stapel. Die $n$-te Quotierung wird auf das $n$-te
Element angewendet.

Die Umsetzung des Wortes `spread` geschieht via `SPREAD`, das den
notwendigen Code verschachtelter `dip`-Aufrufe für das gewünschte
"Spreading" erzeugt. Das Wort `reduce` ist ein Sequenzkombinator, siehe
Kap. [1.4](#Sec:SequenceCombinators){reference-type="ref"
reference="Sec:SequenceCombinators"}.

    >> : SPREAD ( [ quot1 ... quotn ] -- ... ) % def inspired by Factor
    >>   ( ) [ swap dup empty?
    >>           [ drop ]
    >>           [ [ dip ] rot concat cons ]
    >>         if ]
    >>   reduce ;

Greifen wir das obige Beispiel für `tri*` auf. `SPREAD` erzeugt den
benötigten Code, d.h. `SPREAD` ist ein Code-Generator. Ein
anschließendes `call` bringt den generierten Code zur Ausführung. Das
Ergebnis ist mit dem `tri*`-Beispiel identisch.

    > clear 4 3 2 ( [ 1 + ] [ dup * ] [ 1 - ] ) SPREAD
    4 3 2 [ [ [ 1 + ] dip dup * ] dip 1 - ]
    > call
    5 9 1

Damit erklärt sich auch die Umsetzung von `spread`:

    >> : spread ( itm1 ... itmn [ quot1 ... quotn ] -- ... ) SPREAD call ;

### Apply-Kombinatoren: `bi@`, `tri@`, `both?`, `either?` {#Sec:applyCombinators}

Die Apply-Kombinatoren sind "Anwendungskombinatoren" (*apply* heißt
"anwenden"), die wie Spread-Kombinatoren arbeiten, im Gegensatz dazu
jedoch nur eine Quotierung erwartet, die entsprechend `dup`liziert wird.
Die Definitionen sind selbsterklärend.

    >> : bi@ ( x y quot -- ) dup bi* ;
    >> : 2bi@ ( w x y z quot -- ) dup 2bi* ;
    >> : tri@ ( x y z quot -- ) dup dup tri* ;
    >> : 2tri@ ( u v w x y z quot -- ) dup dup 2tri* ;

    > clear 3 4 [ dup * ] bi@
    9 16
    > clear 6 5 4 3 2 1 [ * ] 2tri@
    30 12 2

Zwei Beispiele für die Anwendung des `bi@`-Kombinators sind `both?` und
`either?`.

    >> : both? ( x y pred -- t/f ) bi@ and ;
    >> : either? ( x y pred -- t/f ) bi@ or ;

    > clear 2 -3 [ 0 > ] both?
    f
    > 2 -3 [ 0 > ] either?
    f t

## Sequenzkombinatoren {#Sec:SequenceCombinators}

Sequenzkombinatoren wenden eine Quotierung auf jedes Element einer
Sequenz an. Damit stehen Abstraktionen zur Verfügung, die dasselbe
erreichen, wofür in anderen Programmiersprachen Schleifenkonstrukte wie
"`for`" und sogenannte Iteratoren zur Verfügung stehen. In einer
funktionalen Sprache wie Consize geht man die Elemente einer Sequenz
nicht per Index, sondern einfach der Reihe nach durch.

### Elemente bearbeiten: `each`, `map` und `reduce`

Der `each`-Kombinator ist der elementarste der Sequenzkombinatoren, er
legt die Ergebnisse der Anwendung der Quotierung auf die einzelnen
Elemente schlicht auf dem Datastack ab. Der rekursive Aufruf ist in
*tail position*, d.h. er ist das letzte Worte am Ende (*tail*) der
Quotierung, die für die Rekursion verantwortlich ist. Man spricht auch
von *tail recursion*, im Deutschen als "Endrekursion" bezeichnet. Sie
zeichnet sich dadurch aus, dass die Rekursion nicht zum Anwachsen des
Callstacks führt -- das Merkmal von Schleifenkonstrukten in imperativen
Programmiersprachen.

    >> : each ( seq quot -- ... )
    >>   swap dup empty?
    >>     [ 2drop ]
    >>     [ unpush -rot over [ call ] 2dip each ]
    >>   if ;

    > clear ( 1 2 3 4 ) [ dup * ] each
    1 4 9 16

Ein einfaches Beispiel für die Verwendung von `each` ist das Entpacken
eines Stapel, hier definiert in Form des Wortes `unstack`.

    >> : unstack ( stk -- ... ) ( ) each ;

    > clear [ x [ y ] z ] unstack
    x [ y ] z

Die Varianten `2each` und `3each` erwarten zwei bzw. drei Stapel,
greifen dort jeweils das oberste Element ab und rufen damit die
Quotierung auf.

    >> : 2each ( stk1 stk2 quot -- ... )
    >>   \ unstack push [ zip ] dip each ;
    >> : 3each ( stk1 stk2 stk3 quot -- ... )
    >>   \ unstack push [ 3zip ] dip each ;

Jeweils ein Beispiel illustriere den Gebrauch der Wörter.

    > clear ( 1 2 3 ) ( 4 5 6 ) [ + ] 2each
    5 7 9
    > clear ( 1 2 ) ( 3 4 ) ( 5 6 ) [ + * ] 3each
    8 20

Das Wort `map` fasst im Gegensatz zu `each` die Ergebnisse in einer
Sequenz zusammen.

    >> : map ( seq quot -- seq' )
    >>   [ push ] concat ( ) -rot each reverse ;

Die Definition von `map` erweitert das durch die Quotierung dargestellte
Programm um ein `push`, das die einzelnen Ergebnis auf einen per `( )`
und `-rot` bereit gestellten Stapel ablegt. Am Schluss stellt `reverse`
die korrekte Reihenfolge her.

    > clear ( 1 2 3 4 ) [ dup * ] map
    [ 1 4 9 16 ]

Das Wort `reduce` aggregiert die Werte einer Sequenz zu einem Einzelwert
bezüglicher einer Operation, die durch eine Quotierung repräsentiert
wird. Die Annahme ist zum einen, dass die Quotierung eine zweiwertige
Operation ist, d.h. dass sie zwei Werte auf dem Datastack erwartet. Zum
anderen ist `identity` das neutrale Element dieser Operation.

    >> : reduce ( seq identity quot -- res ) swapd each ;

Ein paar Beispiele: Das neutrale Element der Addition ist `0`, das der
Multiplikation `1` und das der Konkatenation `( )`.

    > clear ( 1 4 9 16 ) 0 [ + ] reduce
    30
    > clear ( ) 0 [ + ] reduce
    0
    > clear ( 2 3 4 ) 1 [ * ] reduce
    24
    > clear ( [ 1 ] [ 2 ] [ 3 4 ] ) ( ) [ concat ] reduce
    [ 1 2 3 4 ]

Die Beispiele motivieren drei nützlichen Abstraktionen: `sum` zur
Summenbildung, `prod` zur Produktbildung und `cat` zur Verschmelzung
mehrerer Sequenzen.

    >> : sum ( [ x ... z ] -- sum ) 0 [ + ] reduce ;
    >> : prod ( [ x ... z ] -- prod ) 1 [ * ] reduce ;
    >> : cat ( [ seq1 ... seq2 ] -- seq ) ( ) [ concat ] reduce ;

Eine alternative, endrekursive (*tail recursive*) Definition für `size`
(siehe Kap. [1.1.5](#Sec:Friends){reference-type="ref"
reference="Sec:Friends"}) ist:

    : size ( seq -- n ) 0 [ drop 1 + ] reduce ;

Die Wörter `map` und `reduce` sind ein besonderes Paar, da sie ein
gewichtiges Prinzip verkörpern, das als Idee z.B. die Konzeption der
Sprache [MapReduce](http://de.wikipedia.org/wiki/MapReduce) geprägt hat:
Mit `map` kann eine Operation in Form einer Quotierung im Grunde
parallel auf den einzelnen Daten einer Sequenz arbeiten, mit `reduce`
werden die Einzelergebnisse zusammengetragen und ausgewertet. Nach
diesem Prinzip verarbeitet Google mit MapReduce die riesigen
Datenmengen, die bei der Erfassung von Webseiten und anderen
Datenquellen anfallen. Die Berechnung verteilt Google auf Rechencluster
von mehreren tausend Rechnern.

Auch wenn sich Programme sehr kompakt mit `map` und `reduce` darstellen
lassen, nicht immer sind diese Wörter die ideale Wahl. Die Definitionen
von `any?` und `all?` haben einen entscheidenden Nachteil: Sie laufen
Gefahr zuviel des Guten zu tun. Bei `any?` ist der Abbruch sinnvoll,
sobald die Anwendung des Prädikats auf ein Element erfolgreich ist --
Folgewerte müssen per `map` nicht mehr untersucht werden. Ebenso kann
`all?` abbrechen, sobald ein Prädikatstest fehl schlägt.

    >> : any? ( seq pred -- t/f ) map f [ or ] reduce ;
    >> : all? ( seq pred -- t/f ) map t [ and ] reduce ;

    > clear ( 1 3 -4 5 0 7 2 ) [ 0 <= ] any?
    t
    > clear ( 1 3 -4 5 0 7 2 ) [ 0 >= ] all?
    f

Natürlich kann man `any?` und `all?` entsprechend anders rekursiv
programmieren. Doch die konzeptuelle Kürze mit `map` und `reduce`
besticht! Es gibt funktionale Sprachen, wie z.B.
[Haskell](http://de.wikipedia.org/wiki/Haskell_(Programmiersprache)),
die auf eine andere Strategie zur
[Auswertung](http://de.wikipedia.org/wiki/Auswertung_(Informatik)) von
Programmausdrücken zurückgreifen. Mit einer verzögerten Auswertung
([*lazy evaluation*](http://en.wikipedia.org/wiki/Lazy_evaluation))
werden überflüssige Rechenschritte vermieden, die konzeptuelle Kürze
aber beibehalten.[^2]

Zur Arbeit mit zwei oder drei Sequenzen stehen die folgenden Varianten
von `map` und `reduce` bereit:

    >> : 2map ( seq1 seq2 quot -- seq ) [ zip ] dip \ unstack push map ;
    >> : 3map ( seq1 seq2 seq3 quot -- seq ) [ 3zip ] dip \ unstack push map ;
    >> : 2reduce ( seq1 seq2 identity quot -- res )
    >>   [ zip ] 2dip \ unstack push reduce ;
    >> : 3reduce ( seq1 seq2 seq3 identity quot -- res )
    >>   [ 3zip ] 2dip \ unstack push reduce ;

### Sequenzverschnitte: `zip`

Oft ist der Wunsch, die Elemente von zwei oder mehr Stapeln zusammen
bearbeiten möchte. Eine Lösung dazu bietet `zip`, das im
Reißverschlußverfahren die jeweils obersten Elemente zweier Stapel
zusammenfasst und aus den Paaren einen neuen Stapel erstellt.

    >> : zip ( stk1 stk2 -- stk )
    >>   2dup [ empty? ] bi@ or
    >>     [ 2drop ( ) ]
    >>     [ unpush ( ) cons  rot
    >>       unpush rot cons -rot swap zip cons ]
    >>    if ;

Am einfachsten ist `zip` am Beispiel zu verstehen.

    > clear ( 1 2 3 ) ( 4 5 6 ) zip
    [ [ 1 4 ] [ 2 5 ] [ 3 6 ] ]

Sind die beiden Stapel nicht gleich in der Anzahl ihrer Elemente, endet
der Reißverschluß mit dem letzten Element des kürzeren Stapels.

    > clear ( 1 2 3 4 ) ( 5 6 ) zip
    [ [ 1 5 ] [ 2 6 ] ]

Die Wörter `3zip` und `4zip` bringen die Elemente von drei bzw. vier
Stapeln zusammen.

    >> : 3zip ( stk1 stk2 stk3 -- stk ) zip zip [ unstack cons ] map ;
    >> : 4zip ( stk1 stk2 stk3 stk4 -- stk ) 3zip zip [ unstack cons ] map ;

    > clear ( 1 2 ) ( 3 4 ) ( 5 6 ) 3zip
    [ [ 1 3 5 ] [ 2 4 6 ] ]
    > clear ( 1 2 ) ( 3 4 ) ( 5 6 ) ( 7 8 ) 4zip
    [ [ 1 3 5 7 ] [ 2 4 6 8 ] ]

### Aussortieren: `filter`, `remove`

Das Wort `filter` nutzt die Quotierung als Prädikat, um nur die Elemente
aus der Sequenz herauszufiltern, die den Prädikatstest bestehen. Eine
Quotierung heißt Prädikat, wenn sie als Ergebnis ihrer Ausführung
entweder ein *true* oder *false* in Form von `t` bzw. `f` auf dem
Datastack ablegt.

    >> : filter ( seq pred -- seq' ) % pred is a quotation
    >>   ( ) -rot [ keep and [ push ] when* ] cons each reverse ;

    > clear ( 1 3 -4 5 0 7 2 ) [ 0 > ] filter
    [ 1 3 5 7 2 ]

Das Wort `remove` macht das Gegenteil von `filter`: Es fasst die von
`filter` verworfenen Elemente zusammen. Die Definition macht genau das,
indem es das Prädikatsergebnis mit `not` negiert.

    >> : remove ( seq quot -- seq' ) [ not ] concat filter ;

    > clear ( 1 3 -4 5 0 7 2 ) [ 0 > ] remove
    [ -4 0 ]

## Wiederholungskombinatoren

In einer funktionalen Sprache gibt es einzig die Rekursion als Mittel,
um die Idee der Wiederholungen eines Vorgangs auszudrücken. Sequenz- wie
auch Wiederholungskombinatoren abstrahieren gängige Muster der
Wiederholung für verschiedene Zwecke und machen den Programmcode
leichter lesbar.

### Abbruch via Prädikat: `loop`, `do`, `while`, `until`

Die Wörter `while` und `until` abstrahieren ein gängiges
Rekursionsschema: Wiederhole den Aufruf der Quotierung solange, wie das
Prädikat ein *true* (`while`) bzw. ein *false* (`until`) zurück liefert.
Beide Abstraktionen lassen sich auf das Wort `loop` zurückführen.

    >> : loop ( pred -- ... ) [ call ] keep [ loop ] curry when ;  
    >> : do ( pred quot -- pred quot ) dup 2dip ;
    >> : while ( pred quot -- ... ) swap do concat [ loop ] curry when ;
    >> : until ( pred quot -- ... ) [ [ not ] concat ] dip while ;

Die Beispiele zeigen den Gebrauch der Wiederholungskombinatoren am
Beispiel der Berechnung der Fakultät von `4`.

    > clear 1 4 [ [ * ] keep 1 - dup 0 > ] loop drop
    24
    > clear 4 1 [ over 0 > ] [ over * [ 1 - ] dip ] while nip
    24
    > clear 4 1 [ over 0 == ] [ over * [ 1 - ] dip ] until nip
    24

Mit `do while` kann der Aufruf der Quotierung einmal vor der Abarbeitung
durch `while` erzwungen werden.

### Abbruch als Fixpunkt: `X`, `Y`

In der Regel wird die Rekursion dadurch hergestellt, dass ein Wort sich
selbst im Definitionrumpf erwähnt und aufruft. Das ist die benamte
Rekursion. Aber wie ist es um die anonyme, unbenamte Rekursion bestellt?
Wie kann man ohne den Selbstaufruf eines Wortes Rekursion erzeugen?

Den Schlüssel zur Antwort liefert der `X`-Kombinator. Eine Quotierung
dupliziert sich vor ihrem Aufruf, womit eine Programmkopie für einen
Wiederholungsaufruf auf dem Stapel bereit liegt.

    >> : X ( quot -- ... ) dup call ;

Der [Lambda-Kalkül](http://de.wikipedia.org/wiki/Lambda-Kalk%C3%BCl),
die Basis vieler funktionaler Programmiersprachen, setzt die anonyme
Rekursion mit dem Fixpunkt-Kombinator um, auch Y-Kombinator bezeichnet.
Der Fixpunkt-Kombinator wiederholt die Anwendung einer Funktion auf
einen Funktionswert solange, bis Eingangs- und Ausgangswert identisch
sind -- der
[Fixpunkt](http://de.wikipedia.org/wiki/Fixpunkt_(Mathematik)) ist
erreicht.

In Consize drückt sich der Y-Kombinator wie folgt aus; der X-Kombinator
sorgt dafür, dass die Rekursion anonym bleibt.

    >> : Y ( val quot -- res )
    >>   [ [ [ call ] 2keep -rot dupd equal? ] dip
    >>     swap [ drop nip ] [ swapd X ] if ] X ;

Die Fakultät von `4` lässt sich mit dem Y-Kombinator ohne jegliche
namentliche Wort-Rekursion berechnen.

    > clear

    > 4 1 [ swap dup 0 equal? [ drop 1 ] when [ * ] keep 1 - swap ] Y nip
    24

Man könnte also durchaus Programme in Consize schreiben, selbst wenn das
Wörterbuch fixiert wäre und -- da es dann kein `set-dict` gäbe -- und es
unmöglich wäre, neue Wörter im Wörterbuch mit ihren Quotierungen zu
hinterlegen. Man müsste alle nicht primitiven Wörter selber händisch
auflösen. Das ist mehr als unpraktisch, zeigt aber eines: Ein
Rechenformalismus braucht keine benamten Abstraktionen, auch sind
benamte Abstraktionen keine Notwendigkeit, um Programmieren zu können.
Wenn jemand benamte Abstraktionen braucht, so sind es wir Menschen. Für
uns ist eine Programmiersprache ohne benamte Abstraktionen schlicht
unbrauchbar, unsere intellektuellen Fähigkeiten sind zu begrenzt. Was
andererseits betont, wie wichtig die Wahl eines guten Namens für eine
Abstraktion ist. Da geht es um nichts anderes als die Kommunikation von
Mensch zu Mensch.

## Kompositionskombinatoren: `curry`

Zwei Kombinatoren zur Komposition von Programmen bzw. Funktionen sind
bereits Bestandteil der Consize-VM. Mit `concat` lassen sich zwei
Quotierungen zu einer zusammenfassen. Die Komposition zweier Funktionen
erfolgt mit `compose`.

Eine weitere Wortgruppe, die die Prelude zur Komposition von Programmen
bereitstellt, sind `curry`, `2curry` und `3curry`. Das sogenannte
"[Currying](http://de.wikipedia.org/wiki/Currying)" ist ein Begriff aus
der Welt der funktionalen Programmierung, der Name ist zu Ehren des
Mathematikers [Haskell Brooks
Curry](http://de.wikipedia.org/wiki/Haskell_Brooks_Curry) gewählt
worden. In einer konkatenativen Sprache ist das Currying trivial: die
gwünschte Anzahl an Argumenten wird in die Quotierung "gezogen"; das
verkürzt die noch benötigten Argumente auf dem Stapel, wenn die
Quotierung aufgerufen wird.

    >> : curry ( itm quot -- quot ) cons \ \ push ;
    >> : 2curry ( itm1 itm1 quot -- quot ) curry curry ;
    >> : 3curry ( itm1 itm2 itm3 quot -- quot ) curry curry curry ;

    > 1 [ + ] curry
    [ \ 1 + ]

## Erweiterung der Consize-Grammatik {#Sec:Grammatik+}

Consize hat eine äußerst einfache Grammatik, die jeden Programmtext
erfolgreich in eine Folge von Wörtern zerlegen lässt. Leerräume im
Programmtext grenzen Wörter voneinander ab, siehe auch
Kap. [\[Sec:Parsing\]](#Sec:Parsing){reference-type="ref"
reference="Sec:Parsing"}. Jedes Consize-Programm beginnt als eine Folge
von Wörtern.

Die Großzügigkeit der Grammatik hat eine Schattenseite: Es fehlt die
Möglichkeit, den Code syntaktisch zu strukturieren und Literale für
Stapel und Mappings zu verwenden.

Als Literale bezeichnet man syntaktische Vereinbarungen, die eine
Notation zur direkten Angabe eines Datentypen vorsehen. Zum Beispiel
kodiert die Schreibweise `[ x y ]` einen Stapel, was einem die wenig
leserliche Form der Stapelkonstruktion erspart:

    emptystack \ y push \ x push

Kap. [1.7.1](#Sec:Literale){reference-type="ref"
reference="Sec:Literale"} führt Literale für zusammengesetzte
Datentypen, sprich für Stapel und Mappings ein.

Ein Beispiel für eine syntaktische Struktur ist die Definition neuer
Wörter. Nach dem einleitenden Doppelpunkt folgt das Wort, der optionale
Stapeleffekt und die definierenden Wörter bis zum Semikolon. Damit
befasst sich Kap. [1.7.2](#Sec:DefWords){reference-type="ref"
reference="Sec:DefWords"}.

In Kap. [1.7.3](#Sec:DefSymbols){reference-type="ref"
reference="Sec:DefSymbols"} wird eine weitere, kleine syntatische
Struktur zur Definition von Wörtern eingeführt, die als Symbole
fungieren.

### Literale: `[ ... ]`, `( ... )`, `{ ... }` {#Sec:Literale}

Eine Literal-Notation für zusammengesetzte Datentypen ist leicht in
Consize integriert, wenn die Klammern eigenständige Wörter sind und
nicht mit dem Wort verschmelzen. Die verschmelzende Schreibweise `[x y]`
hat das Problem, die zwei Wörter `[x` und `y]` jeweils darauf hin
untersuchen zu müssen, ob sie mit einem öffnenden Klammerzeichen
beginnen oder einem schließenden Klammerzeichen enden. Dieser Analyse
muss prinzipiell jedes Wort unterzogen werden. Ein unnötiger Aufwand, da
es auch einfacher geht.

Die nicht-verschmelzende Notation `[ x y ]` lässt die Klammern
eigenständige Wörter sein. Jetzt dient das Wort `[` als Auslöser, um die
Suche nach dem schließenden Klammerwort zu starten und aus den Elementen
zwischen den Klammer-Wörtern den Stapel zu konstruieren. Sobald eine
öffnende Klammern die Suche triggert, wird das Klammer-Wort auf dem
Datastack abgelegt und die schließende Klammer in der Continuation
gesucht.

    >> : [ ( -- quot ) \ [ [ scan4] continue ] call/cc ;
    >> : ( ( -- seq  ) \ ( [ scan4] continue ] call/cc ;
    >> : { ( -- map  ) \ { [ scan4] continue ] call/cc ;

Das Wort `scan4]` sucht nach `]`, `}` bzw. `)` in der aktuellen
Continuation und liefert im Fall von eckigen und runden Klammern einen
Stapel und bei geschweiften Klammern ein Mapping zurück. Worin
unterscheiden sich die Notationen im Detail?

Die eckigen Klammern repräsentieren eine Quotierung und übernehmen alle
Wörter zwischen den Klammern so, wie sie sind. Runde Klammern erlauben
die Ausführung von Wörtern zwischen der öffnenden und der schließenden
runden Klammer.

    > clear [ 1 dup 1 + dup 1 + ]
    [ 1 dup 1 + dup 1 + ]
    > clear ( 1 dup 1 + dup 1 + )
    [ 1 2 3 ]

Die geschweiften Klammern erzeugen ein Mapping, die -- wie runde
Klammern -- die Wörter zwischen den Klammern ausführen und dann erst das
Mapping bilden.

    > clear { 1 dup 1 + 3 4 }
    { 1 2 3 4 }

Natürlich werden Verschachtlungen von Klammern vom Wort `scan4]`
berücksichtigt. Ebenso beachtet `scan4]` die Wirkung des Wortes `\` als
Escape-Wort. Erreicht `scan4]` das Ende des Callstacks, ohne dass die
Klammern aufgelöst werden konnten, fehlt irgendwo zu einer öffnenden
Klammer ihr schließendes Pendant, was eine Fehlermeldung nach sich
zieht.

    >> : scan4] ( ds cs -- ds' cs' )
    >>   unpush dup
    >>   { \ ]   [ drop ( ) rot scan4[ ]
    >>     \ }   over
    >>     \ )   over
    >>     \ [   [ rot cons swap scan4] scan4] ] 
    >>     \ {   over
    >>     \ (   over
    >>     \ \   [ drop unpush rot cons \ \ push swap scan4] ]
    >>     :else [ rot cons swap scan4] ]
    >>     nil   [ \ syntax-error [ unbalanced brackets ] _|_ ]
    >>   } case ;

Das Wort `over` realisiert innerhalb der geschweiften Klammern zum
`case`-Wort einen kleinen [Hack](http://de.wikipedia.org/wiki/Hack).
Code-Dopplungen werden per `over` einfach in die nächste Zeile
übertragen.

Ist eine schließende Klammer gefunden, wird von hinten her das Feld
"aufgeräumt": Die Elemente werden durch `scan4[` vom Ende her per `push`
solange in einen Stapel befördert, bis die öffnende Klammer gefunden
ist. Die öffnende Klammer bestimmt, was mit den aufgesammelten Elementen
passiert: Werden die Elemente unverändert gelassen (Quotierung mit `[`),
werden sie innerhalb der Klammern in einem eigenen Kontext mit `fcall`
aufgerufen (so der Fall bei `(` und `{`), wird aus dem Ergebnis ein
Mapping gemacht (was bei `{` der Fall ist)?

    >> : scan4[ ( cs' stk ds' -- ds'' cs'' )
    >>   unpush dup
    >>   { \ [   [ drop swap               push swap ]
    >>     \ {   [ drop swap fcall mapping push swap ]
    >>     \ (   [ drop swap fcall         push swap ]
    >>     \ \   [ drop unpush rot cons \ \ push swap scan4[ ] 
    >>     :else [ rot cons swap scan4[ ]
    >>     nil   [ \ syntax-error [ unbalanced brackets ] _|_ ]
    >>   } case ;

Consize verlangt immer eine ausgewogene Anzahl an öffnenden und
schließenden Klammern, nicht jedoch, dass die schließende Klammer zur
öffnenden passt. Auch wenn das höchst verwirrend zu lesen ist (und daher
niemals so geschrieben werden sollte), das folgende Beispiel liefert ein
Mapping, obwohl die schließende Klammer nicht passt.

    > clear { 1 dup 2 3 )
    { 1 1 2 3 }

Sollen die Elemente für ein Mapping nicht ausgeführt werden, so ist mit
einer Quotierung und `mapping` zu arbeiten:

    > clear { 1 dup 2 3 }
    { 1 1 2 3 }
    > clear [ 1 dup 2 3 ] mapping
    { 1 dup 2 3 }

Mit `parse-quot` werden die innerhalb einer Quotierung verwendeten
Literal-Notationen in die entsprechenden Datentypen umgewandelt.

    >> : parse-quot ( quot -- quot' )
    >>   \ [ push reverse \ ] push reverse call ;

Die Folge der Wörter `[`, `1`, `2`, `3` und `]` sieht zwar aus wie die
Notation eines Stapels, es sind aber tatsächlich nur fünf Wörter, wie
sich durch `top` im Beispiel zeigt.

    > clear ( \ [ 1 2 3 \ ] )
    [ [ 1 2 3 ] ]
    > top
    [

Nach der Anwendung von `parse-quot` ist die Wortfolge in einen Stapel
verwandelt worden. Die Intention der Notation als Literal muss per
`parse-quot` ausdrücklich eingefordert werden.

    > clear ( \ [ 1 2 3 \ ] )
    [ [ 1 2 3 ] ]
    > parse-quot
    [ [ 1 2 3 ] ]
    > top
    [ 1 2 3 ]

### Wörter definieren: von `:` bis `;` definieren {#Sec:DefWords}

Ohne eine spezielle Syntax zur Definition neuer Wörter bedarf es
mindestens des Wortes `def`, um ein neues Wort mit einem beliebigen
Datum im Wörterbuch eintragen zu können.

    >> : def ( wrd itm -- ) swap get-dict assoc set-dict ;

Das Wort `def+` ist ein um die Berücksichtigung des Stapeleffekts
erweitertes `def`; tatsächlich wird der Stapeleffekt ignoriert und
verworfen.

    >> : def+ ( wrd [ effect ] [ body ] -- ) swap drop def ;

Das Wort `:` leitet die Definition eines neues Wortes unter einer
übersichtlicheren Syntax ein. In der aktuellen Continuation wird mit
`scan4;` nach dem Wort `;` gesucht, das das Ende der Definition
markiert. Die Definition wird in ihre Anteile zerlegt und zur
Verarbeitung durch `def+` aufbereitet.

    >> : : ( | ... '; -- quot ) 
    >>   [ ( ) swap scan4; destruct-definition def+ continue ] call/cc ;

Das Wort `scan4;` arbeitet wie ein `scan4]` oder `scan4[`. Kleine
Unterschiede im Stapeleffekt erzeugen leichte Variationen im Aufbau der
Wortdefinition.

    >> : scan4; ( ds [ ] cs -- ds cs' quot )
    >>   unpush dup
    >>   { \ ;   [ drop swap reverse ]
    >>     \ \   [ drop unpush rot \ \ push cons swap scan4; ]
    >>     :else [ rot cons swap scan4; ]
    >>     nil   [ \ syntax-error [ incomplete definition ] _|_ ]
    >>   } case ;

Das Wort `destruct-definition` zerlegt die zwischen `:` und `;`
aufgesammelten Wörter in das zu definierende Wort, den Stapeleffekt und
den "Rest", den eigentlichen Rumpf der Wortdefinition. Per `parse-quot`
werden Literal-Notationen in die entsprechenden Datentypen umgewandelt.
Die Umwandlung erfolgt damit zur Definitionszeit eines Worts und nicht
zur Laufzeit, was die wiederholte, Zeitintensive Interpretation der
Literale zur Laufzeit vermeidet.

    >> : destruct-definition ( quot -- wrd stackeffect body ) 
    >>   uncons                % extract word
    >>   ( ) swap              % prepare extraction of stack effect
    >>   dup top \ ( equal?    % extract stack effect
    >>     [ pop look4) ] when % if given
    >>   parse-quot ;          % and parse quotation

Auch das Wort `look4)` unterscheidet sich in seiner Arbeitsweise im
Grunde nicht von `scan4]`, `scan4[` und `scan4;`.

    >> : look4) ( [ ... ] quot -- [ ... ]' quot' )
    >>   unpush dup
    >>   { \ )   [ drop swap reverse swap ]
    >>     \ \   [ drop unpush rot cons swap look4) ]
    >>     :else [ rot cons swap look4) ]
    >>     nil   [ \ syntax-error [ incomplete stack effect ] _|_ ]
    >>   } case ;

### Datenwort definieren: `SYMBOL:` {#Sec:DefSymbols}

In Consize erwartet jedes Wort, die zu verarbeitenden Daten auf dem
Datastack vorzufinden. Es gibt wenige Ausnahmen von dieser Regel, und
dazu gehören all die Wörter dieses Kapitels, die die Grammatik von
Consize erweitern: `[`, `(`, `{`, `:` und das noch zu besprechende
`SYMBOL:`. Wir klassifizieren diese Wörter als "syntaktische Wörter".
Syntaktische Wörter benötigen Daten, die nicht auf dem Datastack,
sondern auf dem Callstack zu finden sind. Das ist auf den ersten Blick
nicht verträglich mit dem konkatenativen Paradigma.

Die Ordnung wird dadurch wiederhergestellt, indem diese Wörter mit Hilfe
von `call/cc` nur einen definierten Teil der Daten vom Callstack
abgreifen, die prinzipiell hätten auch auf dem Datastack stehen können,
wozu es dann eines entsprechenden "normalen" Wortes bedürfte. Ganz
deutlich wird das am Beispiel des Wortes `:`, das eine Wortdefinition
einleitet. Die Daten vom Callstack werden aufbereitet zur Verarbeitung
durch `def+`. Das syntaktische Wort `:` hat in `def+` seinen "normalen",
den Datastack verarbeitenden Gegenpart. Bei `[`, `(` und `{` ist es
sogar noch einfacher. Diese Wörter repräsentieren zusammen mit ihren
schließenden Gegenstücken ein einziges Datum auf dem Datastack.

Syntaktische Wörter haben also einzig die Funktion, aus der "normalen"
Postfix-Notation auszubrechen, um eine syntaktische Struktur anzubieten,
von der man sich Vorteile in der Wahrnehmung durch den Programmierer
bzw. die Programmiererin verspricht. Auf gut deutsch: Der Programmtext
soll lesbarer werden. Lesbarkeit und syntaktische Spielereien stehen
nicht im Widerspruch zum konkatenativen Paradigma, sie erfordern nur die
Auflösung der syntaktischen Form in "normale" konkaktenative Strukturen.

Ganz in diesem Sinne arbeitet das syntaktische Wort `SYMBOL:`. Es
erwartet genau ein Wort oben auf dem Callstack und baut den Code für die
folgende Definitionsstruktur auf. Aus

    SYMBOL: <word>

wird

    : <word> \ <word> ;

Die Definition (ohne Stapeleffekt) sorgt dafür, dass das Wort sich
selbst als Datum auf dem Datastack ablegt. Und genau das versteht
Consize unter einem Symbol. Symbole sind Wörter, die sich selbst als
Datum repräsentieren.

    >> : SYMBOL: ( | itm -- )
    >>   [ unpush dup ( \ ; ) cons \ \ push cons \ : push
    >>     swap concat continue ] call/cc ;

Jeder Gebrauch von `call/cc`, der nicht zur Umsetzung eines
syntaktischen Wortes dient, muss ernsthaft die Verträglichkeit mit dem
konkatenativen Paradigma hinterfragen. Das Wort `call/cc` macht die Tür
zur Manipulation der aktuellen Continuation weiter auf als es für das
konkatenative Paradigma notwendig ist. Tatsächlich stehen Continuations
in jüngerer Zeit in der Kritik, bei "unsachgemäßem" Gebrauch
unverträglich mit funktionalen Sprachen zu sein (Consize ist eine
funktionale Sprache), was weitreichende und ungewollte Konsequenzen
haben kann.[^3] Als Lösung gelten begrenzte Continuations (*delimited
continuations*, die auch unter dem Namen *partial continuations*
firmieren), die einen unsachgemäßen Gebrauch erst gar nicht ermöglichen.

## Die Interaktion mit Consize

Die Interaktion mit Consize beschränkt sich auf die Übergabe eines
Programms beim Aufruf der Consize-VM. Damit lässt sich nicht wirklich
arbeiten. Also gilt es, Consize die Interaktion per Konsole
"beizubringen".

### Datenrepräsentation und -Ausgabe: `repr`, `println`

Die Wörter `<space>` und `<newline>` sind nützliche Helferlein. Beide
Wörter erleichtern ein wenig die Konstruktion von Ausgaben über die
Konsole.

    >> : <space> ( -- space ) \space char ;
    >> : <newline> ( -- newline ) \newline char ;

Das Wort `println` steht für *print line*; eine Abstraktion, die die
Ausgabe auf der Konsole mit einem Zeilenumbruch enden lässt.

    >> : println ( -- ) print <newline> print flush ;

Die Consize-VM hat keinen Zugriff darauf, wie Daten innerhalb der VM
gespeichert und kodiert sind. Es ist nicht einmal festgelegt, wie
Stapel, Mappings, Funktionen und "Nichts" ausgegeben werden sollen. Nur
für Wörter ist durch `print` in der Consize-VM eine Repräsentation
gegeben, die dem Wortnamen entspricht.

Für die Repräsentation der verschiedensten Datentypen zeichnet sich das
Wort `repr` verantwortlich. Hier wird festgelegt, wie die Werte der
Datentypen dargestellt (repräsentiert) werden sollen. Aus naheliegenden
Gründen werden die Literal-Notationen für Stapel und Mappings verwendet,
so wie Sie sie bereits aus
Kap. [\[Sec:Basics\]](#Sec:Basics){reference-type="ref"
reference="Sec:Basics"} kennen. Nicht zuletzt erlaubt die Symmetrie von
Repräsentation und Literal-Notation, dass eine Repräsentation eines
Wertes grundsätzlich auch wieder von Consize eingelesen werden kann. Nur
für Funktionen gibt es keine sinnvolle Repräsentation, weshalb
einheitlich die Darstellung `<fct>` gewählt wird.

Da Consize nur für Wörter eine Repräsentation kennt, müssen die
Repräsentationen für die zusammengesetzten Datentypen aus Einzelwörtern
mit `word` zu einem Repräsentationswort zusammengesetzt werden.
Selbstverständlich ist der Prozess rekursiv.

    >> : repr ( itm -- wrd ) 
    >>   dup type
    >>   { \ wrd [ ]
    >>     \ stk [ ( ) \ [ push <space> push swap 
    >>             [ repr push <space> push ] each
    >>             \ ] push reverse word ]
    >>     \ map [ unmap ( ) \ { push <space> push swap
    >>             [ repr push <space> push ] each
    >>             \ } push reverse word ]
    >>     \ fct [ drop \ <fct> ]
    >>     \ nil [ drop \ nil ]
    >>     :else [ \ repr-error [ unknown type ] _|_ ]
    >>   } case ;

Die Repräsentation eines Stapels hat immer eine öffnende und eine
schließende Klammer. Sollen die äußeren eckigen Klammern samt der
Leerräume entfernt werden, so hilft `unbracket-stk-repr`. Ein leerer
Stapel wird nach Entfernung der Klammern auf ein Leerzeichen reduziert.

    >> : unbracket-stk-repr ( wrd -- wrd' ) % '[ ... ]' => '...'
    >>   unword
    >>     pop pop reverse pop pop reverse
    >>     dup empty? [ <space> push ] when
    >>   word ;

### Die Interaktion über die Konsole, die `repl`

[Lisp](http://de.wikipedia.org/wiki/Lisp) gilt als die zweitälteste
Programmiersprache nach Fortran. Mit Lisp kam die
[*Read-Evaluate-Print-Loop*](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
in die Welt. Die REPL beschreibt die Interaktion des Programmierers bzw.
der Programmiererin mit Lisp über die Konsole: Die Eingabe wird
eingelesen (*read*), der eingegebene Ausdruck ausgewertet (*evaluate*)
und das Ergebnis der Auswertung auf der Konsole ausgegeben (*print*).
Dieser Ablauf wiederholt sich wieder und wieder -- das ist die Schleife
(*loop*) der Interaktion.

Die REPL beschreibt das universelle Ablaufschema aller interaktiven
Sprachen, zu denen Python, Ruby, Perl und eben auch Consize gehören.

Der `reader` macht über das "`>`"-Zeichen (samt Leerzeichen) auf sich
aufmerksam, nimmt per `read-line` eine Eingabe entgegen, entfernt aus
der Eingabe per `uncomment` die Kommentare und aktiviert den Tokenizer
mit `tokenize`. Das Resultat ist eine Quotierung auf dem Datastack.
Damit `uncomment` funktioniert, muss ein `<newline>` zur eingelesenen
Eingabezeile hinzugefügt werden.

    >> : reader ( -- quot )
    >>   \ > print <space> print flush read-line
    >>   ( ) <newline> push cons word
    >>   uncomment tokenize ;

Der `evaluator` ist gleichzusetzen mit `call` in Consize.

    >> : evaluator call ;

Der `printer` gibt das Ergebnis der Evaluation, den Datastack, auf der
Konsole aus.

    >> : printer ( -- )
    >>   get-ds reverse repr unbracket-stk-repr println ;

Die `repl` ist die sich wiederholende Abfolge von `reader`, `evaluator`
und `printer`.

    >> : repl reader evaluator printer repl ;

So einfach ist es, eine Programmiersprache mit einer REPL zu versehen!
Allerdings muss eine interaktive Programmiersprache eine Voraussetzung
erfüllen: Kurze syntaktische Einheiten müssen gültige Programme
darstellen und inkrementell den Programmzustand verändern können. Beide
Belange erfüllt Consize. Traditionelle Compilersprachen wie Java, C, C++
und C# sind allein schon von ihrer Grammatik nicht darauf ausgelegt,
"Kleinstprogramme" zuzulassen.

### Dateien lesen und starten: `(l)load`, `(l)run` {#Sec:Dateien}

Das Laden eines Consize-Programms erfordert nach dem Einlesen (`slurp`)
die Entfernung aller Kommentare (`uncomment`) und das auf das Tokenizing
reduzierte Parsen des Quelltextes. Das Wort `run` ruft das geladene
Programm auf.

Mit `lload` und `lrun` gibt es die entsprechenden Wörter, wenn das
Consize-Programm als "literarisches Programm" (*literate program*, siehe
Kap. [\[Sec:Parsing\]](#Sec:Parsing){reference-type="ref"
reference="Sec:Parsing"}), vorliegt.

    >> : load ( wrd -- quot ) slurp uncomment tokenize ;
    >> : lload ( wrd -- quot ) slurp undocument uncomment tokenize ;
    >> : run ( wrd -- ... ) load call ;
    >> : lrun ( wrd -- ... ) lload call ;

Die folgenden drei Wörter sind nicht viel mehr als Abkürzungen, die bei
der (Weiter-)Entwicklung der Prelude von Nutzen sind.

    >> : prelude ( -- ... ) \ prelude.txt run ;
    >> : test-prelude ( -- ... ) \ prelude-test.txt run ;

### Abbruch und Reflexion: `exit`, `abort`, `source`, `clear`

Consize ist ein [reflexives
Programmiersystem](http://de.wikipedia.org/wiki/Reflexion_(Programmierung)),
d.h. es kann auf seinen aktuellen Programmzustand zugreifen und ihn
verändern; manchmal spricht man auch von
[Introspektion](http://de.wikipedia.org/wiki/Reflexion_(Programmierung)).
Die Fähigkeit dazu ist in der Consize-VM in dem Wort `stepcc` angelegt.
Der Programmzustand ist gegeben durch das Wörterbuch, den Data- und den
Callstack.

Die folgenden Wörter vereinfachen den Zugriff auf den aktuellen
Programmzustand: `source` gibt den mit einem Wort assoziierten Wert aus
dem Wörterbuch auf der Konsole aus. Das Wort `get-ds` legt den Datastack
auf dem Datastack ab (was seltsam klingen mag, aber funktioniert),
`set-ds` verändert den Datastack und mit `clear` kann der Datastack
"gelöscht" werden.

    >> : source ( word -- ) lookup repr println ;

    >> : get-ds ( -- stk ) [ swap dup push swap continue ] call/cc ;
    >> : set-ds ( stk -- ) [ swap top swap continue ] call/cc ;
    >> : clear ( -- ) ( ) set-ds ;

Das Wort `abort` unterbricht die Programmausführung und bietet die REPL
zur Interaktion an. Das Wort `exit` beendet die Arbeit der Consize-VM.
Sobald der Callstack gänzlich abgearbeitet, d.h. leer ist, hat die
Consize-VM ihre Aufgabe erfüllt.

    >> : abort ( -- ) [ drop [ printer repl ] continue ] call/cc ;
    >> : exit  ( -- ) [ drop ( ) continue ] call/cc ;

### Debugging: `break`, `step`

In den [Urzeiten der
Computerei](http://de.wikipedia.org/wiki/Computer#Entwicklung_des_modernen_turingm.C3.A4chtigen_Computers)
bestanden die Rechner teils aus elektromechanischen
[Relais](http://de.wikipedia.org/wiki/Relais) und teils aus rein
elektronischen Bauteilen wie
[Röhren](http://de.wikipedia.org/wiki/Elektronenr%C3%B6hre). Sie dürfen
sich diese Bauteile in den Größendimensionen eines Daumens und größer
vorstellen. Die damaligen Rechner beanspruchten mit ihren mehreren
Tausend Bauteilen nicht nur den Platz ganzer Schränke, sondern den
ganzer Räume. So soll einst ein Käfer, zu Englisch *bug*, eine
Fehlfunktion ausgelöst haben, als er in den Wirrungen des elektronischen
Allerleis herumkrabbelte, einen Kurzschluss auslöste und sein Leben
ließ. Seit diesem historisch dokumentierten Ereignis werden auch die
[Programmfehler](http://de.wikipedia.org/wiki/Programmfehler) in der
Software als "Bugs" bezeichnet.

Seinerzeit gestaltete sich die Suche nach einem verkohlten Käfer in den
unendlichen Weiten der Hardware als Herausforderung. Mit der Erfindung
des [Integrierten
Schaltkreises](http://de.wikipedia.org/wiki/Integrierter_Schaltkreis)
(*integrated circuit*, IC) und der darauf folgenden drastischen
Miniaturisierung der Hardware, gehört diese Art der Fehlersuche der
Vergangenheit an. Doch nicht minder schwer und aufwendig ist bisweilen
die Suche nach den meist unfreiwillig eingebauten "Bugs" in der
Software.

Die Suche nach dem Softwarefehler nennt man "Debugging" und das dazu
verwendete Hilfsmittel als
"[Debugger](http://de.wikipedia.org/wiki/Debugger)". Eine zentrale
Funktion eines Debuggers ist die Einzelschritt-Ausführung eines Programm
ab einem definierten
[Haltepunkt](http://de.wikipedia.org/wiki/Debugger#Haltepunkte), dem
*breakpoint*. So kann man sozusagen in Zeitlupe, Schritt für Schritt
verfolgen, was das Programm tut und zwischen den Einzelschritten den
aktuellen Programmzustand inspizieren. All das soll helfen, einen
Softwarefehler systematisch einzukreisen und zu entdecken.

Das Wort `break` definiert einen Haltepunkt. Das Wort legt die aktuelle
Continuation auf dem Datastack ab und bietet dazu den gewohnten
interaktiven Dialog an.

    >> : break ( -- ds cs ) [ printer repl ] call/cc ;

Ähnlich ist auch das Wort `error` definiert, so dass ein
Verarbeitungsfehler in Consize kontrolliert aufgefangen werden kann:

    >> : error ( -- ) [ \ error printer repl ] call/cc ;

Das Wort `step` führt einen Rechenschritt mit der auf dem Datastack
befindlichen Continuation aus.

    >> : step ( ds cs -- ds' cs' )
    >>   dup empty? [ get-dict -rot stepcc rot drop ] unless ;

### Unit-Testing: `unit-test`

Der [Softwaretest](http://de.wikipedia.org/wiki/Softwaretest) ist eine
qualitätssichernde Maßnahme und gerade auf der Modulebene so wichtig,
dass eine Unterstützung zur Formulierung und Ausführung von
[Modultests](http://de.wikipedia.org/wiki/Modultest) (*unit tests*)
nicht fehlen soll. Für praktisch jede Programmiersprache wird für diesen
Zweck eine [Umgebung für
Unit-Tests](http://de.wikipedia.org/wiki/Liste_von_Modultest-Software)
bereitgestellt, die das Testen vereinfacht. In Consize ist so etwas in
zwei Zeilen Code programmiert, wenn man auf die Ausgabe auf der Konsole
verzichtet. Mit Konsolen-Ausgaben braucht es ein paar Zeilen mehr.

    >> : unit-test ( result quot -- )
    >>   [ \ test print [ <space> print repr print ] bi@ ] 2keep 
    >>   [ fcall equal? ] 2keep
    >>   rot
    >>     [ <space> print \ passed println 2drop ]
    >>     [ <space> print \ failed println \ with print <space> print
    >>       nip fcall repr println abort ]
    >>   if ;

Ein Unittest erwartet den antizipierten Inhalt des Datastacks (`result`)
nach Abarbeitung des in `quot` abgelegten Programms. Produziert der
Aufruf von `quot` nicht das mit `result` vorgegebene Resultat, bricht
die Ausführung ab und das erwartete Ergebnis wird zusammen mit der
Abbruchmeldung ausgegeben. Die Angabe des erwarteten Ergebnisses hilft,
den Fehlschlag des Tests besser zu verstehen.

    > ( 5 ) [ 2 3 + ] unit-test
    test [ 5 ] [ 2 3 + ] passed

    > ( 7 ) [ 2 3 + ] unit-test
    test [ 7 ] [ 2 3 + ] failed
    with [ 5 ]

## Serialisierung, Consize-Dumps und Bootstrapping

In einer funktionalen Programmiersprache mit referentieller Transparenz
existiert das Konzept der Referenz nicht, was die Serialisierung von
Daten sehr einfach macht. Insofern ist es nicht schwer, das Wörterbuch
oder einen Teil davon in einer Datei abzuspeichern.

### Die Serialisierung von Daten: `serialize`

Mit der [Serialisierung](http://en.wikipedia.org/wiki/Serialization)
eines Datums ist eine Beschreibungsform gemeint, die z.B. zur
sequentiellen Ablage auf einem Datenträger zwecks Speicherung geeignet
ist und eine vollständige Rekonstruktion des Datums erlaubt.

Consize serialisiert Daten so, wie Sie es in der Einleitung zu Consize
in
Kap. [\[Sec:Datenstrukturen\]](#Sec:Datenstrukturen){reference-type="ref"
reference="Sec:Datenstrukturen"} (S.ff.) kennengelernt haben. Das Wort
`serialize` automatisiert den Vorgang, ein Datum einzig mit den Wörtern
der Consize-VM in eine Wortfolge zur Erzeugung des Datums zu übersetzen.

    >> : serialize ( quot -- quot' )
    >>   get-ds [ clear ] dip uncons     
    >>   [ -serialize- get-ds ] dip
    >>   swap reverse push set-ds ;

    >> : -serialize- ( item -- stream-of-items )
    >>   dup type
    >>   { \ wrd [ \ \ swap ] 
    >>     \ stk [ \ emptystack swap reverse [ -serialize- \ push ] each ]
    >>     \ map [ unmap -serialize- \ mapping ]
    >>     \ nil [ drop \ emptystack \ top ]
    >>     \ fct [ drop \ \ \ <non-serializeable-fct> ]
    >>     :else [ \ serialization-error [ invalid type ] _|_ ]
    >>   } case ;

Mit `call` können serialisierte Daten wieder rekonstruiert werden.

    > clear [ 1 hello 2 ] serialize
    [ emptystack \ 2 push \ hello push \ 1 push ]
    > call
    [ 1 hello 2 ]

### Ein Schnappschuss des Wörterbuchs: `dump`

Das Wort `dump` serialisiert ein übergebenes Wörterbuch und speichert es
im angegebenen Ziel. Das serialisierte Format wird um Code ergänzt, so
dass beim Einlesen das Wörterbuch nicht nur rekonstruiert, sondern
anschließend mit dem aktuellen Wörterbuch ge`merge`d wird.

    >> : dump ( dict filename -- )
    >>   swap serialize [ get-dict merge set-dict ] concat
    >>   repr unbracket-stk-repr swap spit ;

Man nennt das Erfassen und das Speichern des aktuellen Programmzustands
eines Programmsystems auch einen "Dump erzeugen". Seien Sie übrigens ein
wenig geduldig, das Erzeugen eines Dumps nimmt etwas Zeit in Anspruch.

Wozu ist ein Dump von Consize überhaupt von Nutzen?

Die Version der Prelude, die Sie aktuell lesen, ist die Prelude im
Klartext. Diese Fassung der Prelude verwendet die in
Kap. [1.7](#Sec:Grammatik+){reference-type="ref"
reference="Sec:Grammatik+"} vorgestellten syntaktischen Erweiterungen
für eine programmierfreundliche Darstellung des Quelltextes. Mit dieser
Darstellung geht nur ein kleines Problem einher: Das Einlesen der
Prelude dauert ein wenig, da das inkrementelle Definieren von Wörtern
und das Auflösen syntaktischer Kodierungen etwas Zeit benötigt. Viel
effizienter ist es, einen mit `dump` erzeugten Dump der Prelude
einzulesen. Dann startet die Consize-VM die Prelude wesentlich
schneller.

Wenn Sie mit `get-dict \ prelude-dump.txt dump` einen Dump der Prelude
erzeugen, kann das Argument beim Starten der Consize-VM entsprechend
angepasst werden:

    "\ prelude-dump.txt run say-hi"

Per Dump ist die Prelude auf meinem Rechner um den Faktor 15-20 mal
schneller geladen, als wenn die Prelude als Programmcode im "Klartext"
prozessiert werden muss. Im ersten Fall wird nur das Wörterbuch
rekonstruiert, im letzten Fall muss das Wörterbuch erst inkrementell
konstruiert werden.

### Bootstrapping Consize: `bootimage` {#Sec:Bootstrapping}

Will man Consize mit dem Programmcode der Prelude starten, so kann das
nicht gehen: In der Prelude werden syntaktische Wörter benutzt (siehe
Kap. [1.7](#Sec:Grammatik+){reference-type="ref"
reference="Sec:Grammatik+"}), die Consize zu Beginn nicht kennt.

Das ist der Grund, warum die Prelude mit dem Laden des sogenannten
Bootimage beginnt (siehe
Kap. [1.1.2](#Sec:LoadBootimage){reference-type="ref"
reference="Sec:LoadBootimage"}). Das Bootimage ist ein Dump eines
minimalen Wörterbuchs, das all die Wörter enthält, die notwendig sind,
um die Verarbeitung der Prelude mit ihren syntaktischen Erweiterungen
vorzubereiten.

    >> : bootstrapping-dict ( -- dict )
    >>   [ def def+
    >>     cons uncons unpush -rot over
    >>     SYMBOL: case when if choose call fcall
    >>     scan4] scan4[ parse-quot destruct-definition
    >>     : scan4; look4)
    >>     read-word read-mapping ]
    >>   (  \ [  \ (  \ {  ) concat
    >>   dup [ lookup ] map zip cat mapping ;

Mit dem Wörterbuch `bootstrapping-dict` ist leicht mittels `bootimage`
ein initialer Dump produziert.

    >> : bootimage ( -- )
    >>   bootstrapping-dict \ bootimage.txt dump ;

Ursprünglich habe ich das Bootimage per Hand geschrieben. Anfangs gab es
auch keine gesonderte Datei mit dem Bootimage, die notwendigen
Definitionen waren direkter Bestandteil der Prelude. Inzwischen nimmt
mir das Wort `bootimage` die Arbeit zu großen Teilen ab. Ich muss
lediglich darauf achten, dass alle syntaktischen Wörter und die in den
Wortdefinitionen verwendeten Wörter in dem Wörterbuch des Bootimages
enthalten sind. Die Serialisierung und Speicherung als Datei habe ich
schon zu einem sehr frühen Zeitpunkt der Entstehungsgeschichte der
Prelude automatisiert.

Dieser Automatismus verschleiert, wie das Bootimage historisch
entstanden ist. Ursprünglich war einiges an Handarbeit nötig, um die
Verarbeitung der Prelude mit den Literalen für Stapel und Mappings und
mit der Notation für Definitionen zu ermöglichen. Um den Weg
nachvollziehbar zu machen, sei hier der Ausgangspunkt des Bootimages,
die Entstehung des Wortes `def`, ausführlich beschrieben.

Das Wort `def` ist essentiell. Es steht im Brennpunkt aller weiterer
Aktivitäten, die immer darauf abzielen, neue Wörter dem Wörterbuch
hinzuzufügen. Aus Kap. [1.7.2](#Sec:DefWords){reference-type="ref"
reference="Sec:DefWords"} kennen Sie die Definition:

    : def ( wrd itm -- ) swap get-dict assoc set-dict ;

Zu Beginn steht uns diese Schreibweise in Consize nicht zur Verfügung.
Beim Start von Consize gibt es ausschließlich die Wörter der Consize-VM.
Wir müssen uns den gewünschten Programmierkomfort Schritt für Schritt
erarbeiten.

Angenommen, das Wort `def` wäre in Consize bereits definiert, dann
könnten wir `def` immerhin mit sich selbst definieren.

    \ def [ swap get-dict assoc set-dict ] def

Aber wie kann ein Wort sich selbst definieren ohne bereits definiert zu
sein? Natürlich geht das nicht. Aber der Zirkelschluss, dass sich ein
Wort selbst definiert, lässt sich händisch auflösen. Informatiker nennen
diese Technik
"[Bootstrapping](http://de.wikipedia.org/wiki/Bootstrapping_(Informatik))".
Wir ersetzen einfach `def` mit seiner eigenen Definition!

    \ def [ swap get-dict assoc set-dict ] swap get-dict assoc set-dict

Noch steht uns allerdings eines im Weg. Am Anfang der Prelude können wir
nicht die Notation mit den eckigen Klammern nutzen. Wir müssen die
Quotierung ebenfalls händisch aufbauen, sprich serialisieren.

    \ def
    emptystack \ set-dict push \ assoc push \ get-dict push \ swap push
    swap get-dict assoc set-dict

Das ist exakt der Code, mit dem die Prelude einst begann. Schrittweise
kamen andere Wörter hinzu: `def+`, `cons`, `choose`, `if` usw. Die
Reihenfolge der Wörter war getrieben von der Notwendigkeit, sich rasch
nützliche Hilfsmittel zu schaffen, so dass das Programmieren in Consize
zunehmend angenehmer wurde. Die mit einem Wort assoziierten Quotierungen
habe ich per Hand serialisieren müssen.

Ist dieser mühsame Prozess einer initialen Prelude zur Verarbeitung
syntaktischer Wörter einmal bewältigt, dann kann die "normale" Prelude
geladen, ein Bootimage erzeugt und der manuelle Vorbereitungsteil
verworfen werden. Fortan können nach dem Start des Bootimages Änderungen
an der Prelude geladen und eventuell ein neues, aktualisiertes Bootimage
generiert werden. Plötzlich ist nicht mehr erkenntlich, was zuerst da
war: der Dump oder die Prelude. Man braucht ein Bootimage, um die
Prelude zu laden -- und eine Prelude, um ein Bootimage zu erzeugen.

Das ist kurios und erinnert sehr an das
[Henne/Ei-Problem](http://de.wikipedia.org/wiki/Henne-Ei-Problem). Was
war zuerst da, die Henne oder das Ei? Ohne Huhn kein Ei und ohne Ei kein
Huhn. Oder am Beispiel von `def` ist es gar der Selbstbezug: ohne `def`
kein `def`. Wir Informatiker halten uns nicht lange mit solchen
philosophisch anmutenden Fragestellungen auf und durchbrechen per
Bootstrapping die Selbstbezüglichkeit. Das Ergebnis: Der Kreislauf von
Huhn und Ei ist in Gang gesetzt. Auf eben diese Weise haben wir das Wort
`def` aus der Taufe gehoben, um die restlichen Wörter zu definieren.
Auch ist `def` nun mit sich selber definierbar. Ist das einmal
geschehen, können Sie kess die Frage nach dem "Was war zuerst da?"
stellen, und die Menschheit in Debatten über den Anfang der Dinge
verstricken.[^4]

## Zum Schluß

### Begrüßung: `say-hi`

Die Prelude begrüßt mit `say-hi` den Anwender bzw. die Anwenderin und
startet die REPL. Nun ist Consize zur Interaktion bereit!

    >> : say-hi ( -- )
    >>   [ This is Consize -- A Concatenative Programming Language ]
    >>   ( ) [ push <space> push ] reduce
    >>   pop reverse word println
    >>   repl ;

### Von der Dokumentation zum Code

Die Dokumentation zur Prelude, die Sie gerade lesen, enthält den
vollständigen Code zur Prelude; das sind all die Textstellen, die mit
"`>> `" (inkl. Leerzeichen) ausgewiesen sind. Dieses Dokument ist also
selbst ein Beispiel für ein "literarisches Programm". Sie können den
Quellcode der Prelude aus der Dokumentation mit dem folgendem Programm
aus dem [LaTeX](http://de.wikipedia.org/wiki/LaTeX)-File extrahieren und
unter einem neuen Dateinamen abspeichern.

    > \ Consize.Prelude.tex slurp undocumment \ <filename> spit

Achten Sie darauf, dass Sie sich nicht ungewollt die Datei mit der
aktuellen Prelude überschreiben.

[^1]: `call` ist bereits in der Consize-VM definiert, siehe
    Kap. [\[sec:core.start\]](#sec:core.start){reference-type="ref"
    reference="sec:core.start"}. Da `call` nicht zwingend Teil der VM
    sein muss, wird die Definition in der Prelude wiederholt.

[^2]: Trivial sind solche Überlegungen nicht, wie der Beitrag "[Reducers
    in Clojure 1.5](http://heise.de/-1871934)" von Stefan Kamphausen auf
    heise-Developer aufzeigt.

[^3]: <http://lambda-the-ultimate.org/node/4586> bietet einen guten
    Einstieg in die Diskussion.

[^4]: Sie dürfen davon ausgehen, dass Hühner nicht per Bootstrapping
    entstanden sind ;-)
