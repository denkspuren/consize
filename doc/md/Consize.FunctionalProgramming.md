# Funktionale Programmierung

Consize ist eine funktionale Sprache. Also müssen Funktionen -- soviel
lässt die Klassifizierung erraten -- eine bedeutende Rolle spielen. Zwar
wissen Sie, dass primitive Wörter wie `dup` oder `push` im Wörterbuch
mit Funktionen assoziiert sind. Ansonsten geht es aber immer nur um
Wörter, Stapel, Mappings und bisweilen um "Nichts". Die Frage ist
durchaus berechtigt: Was hat das denn nun alles mit Funktionen zu tun?
Diese Frage möchte Ihnen dieses Kapitel beantworten.

Eine zweite Frage schließt sich an: Wie denkt es sich funktional? Wenn
Sie von einer imperativen Programmiersprache kommen, werden Sie einige
Dinge vermissen und andere merkwürdig finden. Dieses Kapitel will Ihnen
einen Einstieg in die funktionale Denke mit Consize bieten.

## Die Idee der Funktion

In einer funktionalen Programmiersprache steht das Konzept der Funktion
im Mittelpunkt. Und in der Tat ist damit der Funktionsbegriff aus der
Mathematik gemeint.

Im Mathematik-Unterricht haben Sie Funktionen z.B. geschrieben als
$f(x)=x^2+2x$. Man hat Ihnen erklärt, dass die Variable $x$ einen
beliebigen Wert aus einer Menge repräsentiert, wie z.B. aus der Menge
der Natürlichen Zahlen $\mathbb{N}$, und dass die Ergebniswerte
ebenfalls Elemente einer Menge sind. Sie haben das notiert als
$f:\mathbb{N}\rightarrow\mathbb{N}$. Eine Funktion bildet Werte aus
einer Ausgangsmenge auf Werte einer Zielmenge ab. Zur Berechnung
konkreter Funktionswerte haben Sie dann so etwas geschrieben wie
$f(3)=15$.

In der Schule geht man in der Regel ein wenig darüber hinweg, sauber zu
unterscheiden zwischen der Definition einer Funktion und der Anwendung
einer Funktion.

-   Eine **Funktionsdefinition** wie $f(x)=x^2+2x$ legt fest, dass es
    eine Funktion unter dem Namen $f$ gibt, die ein Argument namens $x$
    erwartet und die gleich dem Ausdruck $x^2+2x$ ist. Gerade der letzte
    Punkt ist wichtig: Die Funktion dient als Abstraktion eines
    Rechenausdrucks, in dem Fall eines arithmetischen Ausdrucks. Oder
    anders herum: Der arithmetische Ausdruck löst die Funktion auf. Die
    mathematische Schreibung mit dem Gleichheitszeichen zieht keine
    Interpretation der anderen vor.

-   Eine **Funktionsanwendung** wie $f(3)$ wendet die Funktion $f$ auf
    den Wert $3$ an. Das heißt: Der Wert $3$ ersetzt $x$ (der
    Fachausdruck ist "substituiert"), was zur Folge hat, dass
    gleichermaßen das $x$ im Rechenausdruck durch $3$ substituiert wird.
    Damit lässt sich der Rechenausdruck nach den arithmetischen Regeln
    zu $15$ auswerten -- das Ergebnis der Funktionsanwendung. Sprich
    $f(9)=15$. Der Wert $f(9)$ kann durch $15$ ersetzt werden.

Das Problem mit der Funktionsdefinition ist, dass sie nicht sauber
unterscheidet zwischen dem Namen einer Funktion und der Idee der
Funktion, die als Abstraktion für einen Rechenausdruck dient. Dieser
Problematik nahm sich [Alonzo
Church](http://en.wikipedia.org/wiki/Alonzo_Church) an. Er erfand den
sogenannten
[Lambda-Kalkül](http://de.wikipedia.org/wiki/Lambda-Kalk%C3%BCl). Eine
namensfreie, anonyme Funktion wird mit dem griechischen Symbol $\lambda$
(ein kleines "Lambda") ausgewiesen. Die Schreibweise $f(x)=x^2+2x$ ist
vielmehr eine Kurzform für

$$f = \lambda(x)(x^2+2x)$$

Da Mathematiker gerne auf Klammern verzichten, finden Sie meist die
etwas veränderte Notation

$$f = \lambda x.x^2+2x$$

Das meint: $f$ ist eine Variable -- nicht anders als es $x$ ist --, die
gleichgesetzt ist mit einer anonymen Funktion, die eine Variable $x$ als
Argument hat. Und diese Funktion abstrahiert den Rechenausdruck
$x^2+2x$.

Die Funktionsanwendung $f(3)$ (manchmal auch ohne Klammern als $f\; 3$
geschrieben) übersetzt sich zu

$$f(3) = (\lambda x.x^2+2x)(3) = 3^2+2\cdot 3 = 15$$

Der Lambda-Kalkül kennt übrigens nur das Konzept der Funktion.[^1] Es
gibt keine booleschen Werte für *wahr* und *falsch*, keine Zahlen, keine
Stapel, keine Mappings, nichts dergleichen. Der Witz ist, dass Daten
mittels Funktionen kodiert werden. Das scheint auf den ersten Blick
erstaunlich zu sein, ist es aber nicht wirklich. Ihr Rechner kodiert
alles mit Einsen und Nullen. Die Bitfolge `10110111` mag ebenso eine
Instruktion wie auch ein Datum sein. Ähnlich kann man auch alles mit
Funktionen kodieren.

Für praktische Zwecke verkompliziert die Beschränkung auf Funktionen
unsere Betrachtungen. Gehen wir also davon aus, dass es neben den
Funktionen noch Daten gibt, und zwar genau die, die auch in Consize
bekannt sind: Wörter, Stapel, Mappings und `nil`. Für die Menge aller
Wörter verwenden wir den Großbuchstaben $W$, für die Menge aller Stapel
$S$, für Mappings $M$, für die Menge mit dem Element `nil` $N$. Ein
beliebiges Datum (ein `item`) kann ein Element aus der Vereinigungsmenge
$I$ sein; Funktionen lassen wir hier absichtlich als Daten außen vor.

$$I = W\cup S \cup M \cup N$$

Und noch eine Annahme machen wir, damit der Bezug zu Consize einfach
bleibt: Eine Funktion kann grundsätzlich nur einen Stapel als Argument
entgegen nehmen; und sie liefert immer einen Stapel als Ergebnis zurück.
An diese Regel halten sich ausnahmslos alle Funktionen der Consize-VM.
Formal ausgedrückt heißt das: Jede beliebige Funktion in Consize bildet
einen Stapel auf einen Stapel ab: $S\rightarrow S$. Den Fehlerfall, dass
eine Funktion einen ungültigen Stapel zur Verarbeitung vorgelegt
bekommt, lassen wir der Einfachkeit halber unberücksichtigt. Die Menge
aller Funktionen, die einen Stapel verarbeiten und einen Stapel
zurückgeben, bezeichnen wir mit $F$.

## Funktionskomposition

Mit der Consize-VM ist Ihnen ein fest vorgegebener Satz an
stapelverarbeitenden Funktionen gegeben. Damit ließe sich nicht viel
anfangen, wenn es die Funktionkomposition nicht gäbe. Aus zwei oder mehr
Funktionen kann eine neue Funktion erstellt werden.

Die Komposition zweier Funktionen $f$ und $g$, geschrieben als
$f\circ g$ ist definiert als

$$(f\circ g)(s) = g(f(s))$$

Die Idee der Funktionskomposition ergibt sich aus der verschachtelten
Funktionsanwendung. Erst wird $f$ auf $s$ angewendet, dann $g$ auf das
sich ergebende Resultat von $f(s)$. Damit die Komposition funktioniert,
muss das Resultat $f(s)$ vom Typ her zum Typ des Arguments von $g$
passen. Da hier nur Stapel umhergereicht werden, ist die Voraussetzung
erfüllt.

Mit Hilfe der Funktionskomposition lassen sich neue Funktionen
definieren, wie z.B. die Funktion $-rot$ aus der doppelten Anwendung der
Funktion $rot$:

$$-rot = rot \circ rot$$

Eine Funktion wie $unpush$ läßt sich definieren als

$$unpush = dup \circ pop \circ swap \circ top$$

Wie Sie wissen, arbeiten Sie in Consize nicht direkt mit Funktionen,
sondern mit Wörtern, genauer, mit Wörtern in Stapeln, sogenannten
Quotierungen. Lediglich die primitiven Wörter sind über das Wörterbuch
mit Funktionen assoziiert. Nicht-primitive Wörter können (müssen aber
nicht) mit einer Quotierung assoziiert sein.

Es ist der Interpreter der Consize-VM, d.h. die über `stepcc` gegebene
Funktion, die einen Bezug herstellt von Quotierungen zu Funktionen und
zur Funktionskomposition. Die dahinter stehende Mathematik basiert auf
drei Formeln. Die ersten beiden Formeln sind die Basis für einen
sogenannten Homomorphismus: Funktionen und Funktionskomposition finden
ihre Entsprechung in Quotierungen und der Konkatenation. Die dritte
Formel definiert den Umgang mit Daten.

## Die Mathematik zu Consize

Die Mathematik zu Consize benötigt nicht unbedingt die Idee eines
Stapels, sondern -- etwas freier -- die Idee einer Folge (*sequence*)
von null oder mehr Elementen $[s_1,\dots,s_n]$. Die Konkatenation
$\oplus$ zweier Stapel bzw. Folgen $s$ und $s'$ ergibt sich aus der
Zusammenstellung der Elemente beider Folgen zu einer neuen Folge unter
Beibehaltung der Reihenfolge der Elemente:

$$s\oplus s' = [s_1,\dots,s_n]\oplus [s'_1,\dots,s'_m]
           = [s_1,\dots,s_n,s'_1,\dots,s'_m]$$

Der leere Stapel bzw. die leere Folge ist das neutrale Element der
Konkatenation. Es gilt für einen beliebigen Stapel $s$:

$$s\oplus[\;] = [\;]\oplus s = s$$

Programme in Consize sind immer Quotierungen, also Stapel mit
irgendwelchen Elementen aus $I$. Als Abstraktion gilt der Mechanismus,
eine Quotierung mit einem bislang nicht verwendetem Wort mit einer
beliebigen Quotierung gleichzusetzen. Zum Beispiel definiert sich das
Wort `-rot` zu

`[ -rot ] = [ rot rot ]`

Sie erahnen sicherlich die Nähe zur oben dargestellten
Funktionskomposition. Bevor wir darauf im Detail eingehen, wollen wir
das Wörterbuch der Consize-VM explizit mit Hilfe einer Funktion
$vm: [ W ] \rightarrow F$ abbilden. Nur Quotierungen mit einem einzigen
Wort können mit einer Funktion assoziiert sein.[^2]

Aufruf einer Quotierung

:   Der Aufruf eines Stapels $s$ mit einer Quotierung $q$ als oberstem
    Element ($[q]\oplus s$)[^3] ist gleich der mit der Quotierung
    assozierten Funktion angewendet auf den Stapel $s$.

    $$call([q]\oplus s) = vm(q)(s)$$

    Der Aufruf einer Quotierung definiert die Semantik (Bedeutung,
    Interpretation) eines Stapels als Programm.

Dekomposition einer Quotierung

:   Eine aus mehreren Elementen bestehende Quotierung $q$ kann als
    Konkatenation von Teilquotierungen $q=q_L\oplus q_R$ verstanden
    werden. Die Interpretation der Konkatenation übersetzt sich in die
    Funktionskomposition der Interpretationen der Teilquotierungen.

    $$vm(q_L\oplus q_R) = vm(q_L) \circ vm(q_R)$$

    Faktisch zerlegt diese Gleichung eine zu interpretierende Quotierung
    in ihre kleinstmöglichen Teilprogramme, in eine Reihe von
    Quotierungen mit nur einem Element. Zu diesen einelementigen
    Quotierungen müssen über $vm$ jeweils Funktionen abgebildet sein.
    Eine leere Quotierung findet ihre funktionale Entsprechung in der
    Identitätsfunktion $id(s)=s$ -- die Sequenz $s$ bleibt unverändert.
    Wenn kein Programmierfehler vorliegt, lässt sich jede Quotierung auf
    Daten und primitive Wörter der Virtuellen Maschine herunterbrechen.

Apropos Daten. Es muss eine Möglichkeit geben, Daten (Stapel, Mappings,
\"Nichts\" und Wörter, die als Daten verstanden und nicht interpretiert
werden sollen) in einer Quotierung unangetastet auf dem Stapel
abzulegen. Dazu dient die Funktion $self(i)$.

Interpretation von Daten

:   Die Funktion $self(i)$ nimmt ein Element $i$ (*item*) entgegen und
    erzeugt eine Funktion, die eine Sequenz $s$ als Argument erwartet,
    um das Element $i$ der Sequenz hinzuzufügen.[^4]

    $$self(i) = \lambda s.[i]\oplus s$$

    Somit gilt für die Interpretation eines Datenelements $i$ in einer
    Quotierung:

    $$vm([i]) = self(i)$$

Was wollen uns die Formeln eigentlich sagen? Im Grunde ist die
Angelegenheit glasklar, aber man muss sich an diese sehr kondensierte
Ausdruckform der Mathematik gewöhnen. Freisprachlich ausgedrückt
definieren die Formeln die Bedeutung einer Quotierung als Programm. Eine
Quotierung, verstanden als eine Konkatenation von Teilquotierungen mit
nur einem Element, hat eine klare funktionale Entsprechung, wenn man sie
aufruft: Die Auflösung der Teilquotierung findet eine Abbildung auf
Funktionen der VM, die Konkatenation wird zur Funktionskomposition. Das
ist es, was Consize zu einer funktionalen Sprache macht.

Mit den Worten der Mathematik ausgedrückt: Die Abbildung des Monoids
$(S,\oplus,[\;])$ auf den Monoiden $(F,\circ,id)$ ist ein
Homomorphismus.

Jetzt, da Ihnen die Funktion $self$ bekannt ist, kann die Funktions

$$call([q]\oplus s) = vm(q)(s)$$

mit $q$ als Quotierung und $s$ als Sequenz auch ausgedrückt werden als

$$self(q)\circ call = vm(q)$$

Die Anwendung von $vm(q)$ auf $s$ tritt dabei vollkommen in den
Hintergrund.[^5] Das "Befüllen" der Sequenz $s$ kann vollständig über
$self$ erfolgen und ist damit Teil eines konkatenativen Programms. Damit
reicht es, zur Auswertung $vm(q)$ lediglich auf eine leere Sequenz
anzuwenden.

$$\begin{aligned}
self(q)\circ vm([\mathtt{call}]) &= vm(q) \\
    vm([q]\oplus[\mathtt{call}]) &= vm(q) 
\end{aligned}$$

Der Homomorphismus, der eine Quotierung auf die Komposition von
Funktionen abbildet, macht allein einen Formalismus noch nicht
turingvollständig. Es fehlt der grundlegende Mechanismus des
Selbstbezugs im Sinne eines Selbstaufrufs. Das ist leicht zu
realisieren, indem `call` Teil der Virtuellen Maschine wird.

$$vm([\mathtt{call}])=call % Selbstbezug!!!$$

Mit dieser Definition untersuchen wir das Verhalten von `call` als
Bestandteil einer Quotierung. Mit `call` sei eine Quotierung $q$
aufgerufen; $r$ bilde den Rest der Quotierung ab.

$$\begin{aligned}
self([q]\oplus [\mathtt{call}]\oplus r)\circ call
&= vm([q]\oplus    [\mathtt{call}]  \oplus r)    \\
&= vm([q])\circ vm([\mathtt{call}]) \circ vm(r)  \\
&=  vm([q])\circ call                \circ vm(r) \\
&= self(q) \circ call                \circ vm(r) \\
&=   vm(q)                           \circ vm(r) \\
&=   vm(q         \oplus                      r) \\
&= self(q\oplus r) \circ call
\end{aligned}$$

Die Gleichungen fördern eine interessante Eigenschaft ans Tageslicht.
Der Aufruf einer Quotierung per `call` entspricht einer Konkatenation
der Quotierung mit dem Quotierungsanteil nach `call`. Statt den `call`
einer Quotierung funktional über die Funktion $call$ aufzulösen, kann
alternativ die Konkatenation der Quotierung mit dem Programmanteil nach
`call` durchgeführt werden. Es ist unnötig, $call$ als Funktion
bereitzustellen, sofern die Virtuelle Maschine mit dem Auftreten des
Wortes `call` umzugehen weiß. Unter der Voraussetzung, dass sich auf dem
anzuwendenden Stapel $s$ eine Quotierung $q$ befindet, gilt nämlich:

$$vm([q]\oplus[\mathtt{call}]\oplus r) =
vm(q \oplus r)$$

Der Consize-Interpreter arbeitet genau mit dieser Umsetzung des Wortes
`call`.[^6]

## Funktionen & Rekursion

## filter, map und Co

## Keine Variablen: Stapelschieberei und Kombinatoren

## Seiteneffekte

## Was kümmert mich die Zukunft, wenn ich keine Vergangenheit habe

## Und sonst?

## History {#history .unnumbered}

-   Start of writing on this chapter

[^1]: Es heißt tatsächlich "der Lambda-Kalkül" und nicht "das
    Lambda-Kalkül".

[^2]: Das Wörterbuch der Consize-VM hat als Schlüsseleinträge Wörter und
    keine in einem Stapel verpackte Wörter. Der Grund ist, dass `stepcc`
    das Wort bereits aus einer Quotierung extrahiert hat.

[^3]: Achtung, $q\oplus s$ konkateniert Quotierung $q$ und Sequenz $s$.
    Es soll aber die Quotierung als Element ganz links in der Sequenz
    auftauchen! Darum muss es $[q]\oplus s$ heißen.

[^4]: Die Gleichung ist eine Kurzform von
    $self = \lambda i.(\lambda s.[i]\oplus s)$.

[^5]: $(self(q)\circ call)(s)=call([q]\oplus s)=vm(q)(s)$

[^6]: Mit der Variante
    $vm([\mathtt{call}]\oplus r)([q]\oplus s)=vm(q\oplus r)(s)$.
