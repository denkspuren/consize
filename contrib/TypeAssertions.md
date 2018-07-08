
# Optionale Typenrestriktionen für consize

```consize
>> %%% Type Assertions for consize
>>
>> 
```

## Inhalt

- [Inhalt](#inhalt)
- [Hintergrund](#hintergrund)
- [Problem](#problem)
- [Aufgabe](#aufgabe)
- [Einleitung](#einleitung)
- [Abhängigkeiten](#abhängigkeiten)
- [Konzept](#konzept)
    - [Grundideen](#grundideen)
        - [Typinferenz zur Laufzeit](#typinferenz-zur-laufzeit)
        - [Typenprädikate](#typenprädikate)
    - [Anforderungsanalyse](#anforderungsanalyse)
- [Realisierung](#realisierung)
    - [Hilfsdefinitionen](#hilfsdefinitionen)
        - [Operationen für Wörter](#operationen-für-wörter)
        - [Listenoperationen](#listenoperationen)
        - [Mengen- und Wörterbuchoperationen](#mengen--und-wörterbuchoperationen)
        - [Operationen zur Typenkonvertierung](#operationen-zur-typenkonvertierung)
        - [Diverse Operationen](#diverse-operationen)
        - [Wörtliche Version von scan4](#wörtliche-version-von-scan4)
        - [Parseroperationen und Input-Enkodierung](#parseroperationen-und-input-enkodierung)
        - [Verschachtelte Werte in Stapeleffekten](#verschachtelte-werte-in-stapeleffekten)
    - [Definition der Typensprache](#definition-der-typensprache)
        - [Arten von Typen](#arten-von-typen)
        - [Grammatik der Beschreibungssprache für Typen](#grammatik-der-beschreibungssprache-für-typen)
        - [Grammatik für die Stapeleffekte](#grammatik-für-die-stapeleffekte)
        - [Abstrakter Syntaxbaum](#abstrakter-syntaxbaum)
        - [Parser für die Typensprache](#parser-für-die-typensprache)
        - [Orientierungshilfe Grammatik, Parser und abstrakter Syntaxbaum](#orientierungshilfe-grammatik-parser-und-abstrakter-syntaxbaum)
    - [Einige Typen und Typkonstruktoren](#einige-typen-und-typkonstruktoren)
    - [Materialisierung von Prädikaten von Typen](#materialisierung-von-prädikaten-von-typen)
    - [Typenkombinatoren und weitere Typen](#typenkombinatoren-und-weitere-typen)
    - [Durchsetzen von Vor- und Nachbedingungen](#durchsetzen-von-vor--und-nachbedingungen)
    - [Ändern des Wortdefinitionsprozesses](#Ändern-des-wortdefinitionsprozesses)
- [Aussicht](#aussicht)
    - [Überladen von Wortdefinitionen](#Überladen-von-wortdefinitionen)
    - [Optimierungen](#optimierungen)
    - [Weiterentwicklungen](#weiterentwicklungen)

## Hintergrund

In Rahmen des Moduls "CS5341: Kernel-Architekturen in Programmiersprachen" an der Technischen Hochschule Mittelhessen untersuchen Studierende Programmiersprachen, deren Kern- bzw. Kernelimplementierung klein ist.
Programmiersprachen mit kleinem Kern werden im Folgenden als Kernelsprachen bezeichnet.
Obwohl diese Sprachen einen kleinen Kern haben, ermöglichen Metaprogrammierwerkzeuge, dass sie über sich selbst reflektieren können.
Eine veränderte und ausdrucksmächtigere Syntax kann so beispielsweise in der Kernelsprache selbst implementiert werden.

In dieser Ausarbeitung soll sich auf die Programmiersprache "consize" (https://github.com/denkspuren/consize) konzentriert werden.

Consize ist eine konkatenative Kernelsprache.
Programme in konkatenativen Programmiersprachen sind Folgen von Wörtern.
Berechnungen in consize finden auf dem Datenstapel statt.
Neben dem Datenstapel gibt es noch den Programmstapel, auf dem sich das auszuführende Programm befindet.
Weitere Informationen über die Elemente (Programmstapel, Datenstapel und Wörterbuch) und über das Modell der Ausführung kann der [Dokumentation von consize](https://github.com/denkspuren/consize/blob/master/doc/Consize.pdf) (Kapitel 2.6: Datenstapel und Programmstapel, Kapitel 2.7: Atomare und nicht-atomare Wörter und Kapitel 3.11: Der Interpreter: stepcc) entnommen werden.

Anders als bei applikativen Programmiersprachen werden Wörter komponiert, indem sie sequenziell genannt werden.
Der Lambda-Ausdruck `x => h(g(f(x)))` kann durch das konkatenative Programm `f g h` beschrieben werden.

In consize ist es möglich eigene Wörter zu definieren und somit eine Wortfolge mit einem Namen zu assoziieren.
Wörter bieten somit eine Abstraktionsmöglichkeit über Teilprogramme, auf ähnliche Art, wie das Funktionen oder Prozeduren in imperativen und funktionalen Programmiersprachen tun.

## Problem

Wortdefinitionen in konkatenativen Programmiersprachen werden typischerweise durch Stapeleffekte dokumentiert.
Stapeleffekte beschreiben welche Werte auf dem Stapel erwartet werden und welche das Wort auf dem Stapel hinterlassen wird.

> Hinweis:
> In diesem Dokument werden die Begriffe Stapel, Sequenz und Liste synonym verwendet.
> Mit diesen Begriffen ist die immutable, einfach-verkettete Liste gemeint.

Stapeleffekte sind Versprechen beziehungsweise Vereinbarungen des Wortautors an die Nutzer.
Sie versichern, dass sich das Wort wie angegeben verhält.
Die Beschreibungsqualität der Wortdokumentation wird durch die Ausdrucksfähigkeit des Autors limitiert.

In der folgenden Abbildung wird beispielhaft die Definition und somit die Implementierung und die Dokumentation des Wortes `cons` gezeigt.
```consize
: cons ( itm stk -- [ itm & stk ] ) swap push ;
```

Es existiert kein strenger Formalismus für die Syntax der Stapeleffekte.
Die Syntax hat keine Auswirkung auf das definierte Programm.

Manche Wörter stellen Vor- und Nachbedingungen an ihre erwarteten Argumente.
Es folgen zwei Beispiele.
- Das Wort `cons` stellt Anforderungen an seine Argumente: `stk` muss ein Stapel sein. Ist dies nicht der Fall, ist es nicht möglich dem `stk` das `itm` vorzuhängen. Dieses Verhalten wird versucht mit den Stapeleffekten im vorigen Beispiel auszudrücken. Im Fehlerfall wird das Wort einen Fehler anzeigen.
- Das Wort `+` erwartet zwei Zahlen auf dem Stapel und liefert deren Summe (in Zeichen `( a b -- a+b )`). Ist diese Vorbedingung nicht erfüllt, wirft das Wort einen Fehler.

Eine Möglichkeit zur Überprüfung der Argumenttypen bietet das eingebaute Wort `type`.
Dieses Wort ermöglicht es die Art des Wertes (Typ) auf seiner obersten Strukturebene abzufragen.
Der auf diese Weise abgefragte Typ ermöglicht einen Vergleich von erwarteten und tatsächlichem Typ.

Die Überprüfung mit `type` arbeitet allerdings nur auf dem Wert selbst.
Ist der Wert beispielsweise ein Stapel, sind keine Überprüfungen der Elementtypen durch das Wort `type` möglich.
Gleiches gilt für den Typ Wörterbuch, dessen Schlüssel- und Wertpaare man unter Umständen ebenfalls validieren möchte.
Hinzu kommt, dass consize nur fünf Typen (`wrd`, `stk`, `fkt`, `nil` und `map`) kennt.
Werte anderer Typen werden mit Hilfe von Werten dieser Typen kodiert:
- Wahrheitswerte oder Zahlen werden als Worte dargestellt. Dabei werden die Wahrheitswerte "wahr" und "falsch" als `t` und `f` und Zahlen als Worte, die nur aus Dezimalzeichen bestehen, kodiert.
- Zusammengesetzte Werte werden mit Hilfe von Sequenzen oder Wörterbüchern erstellt. Wörterbücher der gleichen Struktur (Strukturgleichheit) repräsentieren hierbei Werte des gleichen Typen.
Mit Wörterbüchern können beispielsweise ADTs (vgl. [Kodierung von algebraischen Datentypen in consize](https://github.com/denkspuren/consize/blob/master/contrib/AlgebraicDataTypes.md#encoding)) oder [Klassen für Objektorientierte Programmierung](https://github.com/denkspuren/consize/blob/master/examples/oo.txt) repräsentiert werden.

Möchte man Vorbedingungen in Form von Typenprüfungen für Kollektionstypen oder andere selbstdefinierte, zusammengesetzte Typen etablieren, müssen diese Überprüfungen ausprogrammiert und im Fall eines Verstoßes gegen die Voraussetzungen einen Fehler geworfen werden.
Überprüfungen dieser Art werden "Zusicherungen" oder auch "Restriktionen" (assertions) genannt.

Besonders für strikte und/oder verschachtelte Anforderungen sind diese Überprüfungen allerdings aufwändig, schwerfällig und fehleranfällig (Beispielsweise für die Anforderung "Erwarte eine Liste von Listen, deren Elemente Funktionen sind").

## Aufgabe

Aus den zuvor genannten Problemen ergibt sich der Wunsch nach einer Typrestriktion, die aus der Angabe des entsprechenden Stapeleffekts generiert wird.

Typprüfungen sind nicht nur für Argumente, sondern auch für Rückgabewerte möglich.
In der folgenden Abbildung werden die Vor- und Nachbedingungen von `cons'` beispielhaft als Typensignatur im Stapeleffekt notiert.
```consize
: cons' ( x xs:Stk<Any> -- res:Stk<Any> ) swap push ;
```
Die Typensignatur beschreibt, dass das zweite Argument (`xs`) und auch der Returnwert (`res`) eine Liste mit beliebigen Werten sein muss.
Für das Argument `x` sind keine Voraussetzungen notiert: Es kann also beliebige Werte annehmen.

Die Implementierung und Dokumentation solcher Typrestriktionen ist Ziel dieser Arbeit.

## Einleitung

In diesem Dokument werden optionale Typenrestriktionen (type assertions) für consize vorgestellt.
Ziel ist es also ein System zu entwickeln, welches Wörter mit Typangaben in Stapeleffekten absichert: Nur Werte des angegebenen Typen sollen erlaubt und alle anderen verboten werden.
Beim Verstoß gegen die vorausgesetzten Typen soll das System einen Fehler melden.
Weiter noch soll dieses System in consize entwickelt werden.
Demnach wird keine neue statisch typisierte Sprache entwickelt, sondern es wird ein Laufzeitsystem entworfen, welches Typüberprüfungen als optionales Feature zu consize hinzufügt.

## Abhängigkeiten

Im Rahmen des Moduls "CS5341: Kernel-Architekturen in Programmiersprachen" wurde neben diesem Dokument eine [Parser-Combinator Bibliothek](https://github.com/denkspuren/consize/blob/master/contrib/ParserCombinators.md) und eine Erweiterung entwickelt, die consize um algebraische Datentypen erweitert (vgl. [AlgebraicDataTypes](https://github.com/denkspuren/consize/blob/master/contrib/AlgebraicDataTypes.md)).
Das in diesem Dokument vorgestellte Programm hängt von beiden Bibliotheken ab.

## Konzept

Das folgende, vorgestellte Konzept stellt einen Lösungsansatz für die Problem- und Aufgabenstellung (vgl. [Problem](#problem) und [Aufgabe](#aufgabe)) dar.

Es werden zunächst die [Grundideen](#grundideen) vorgestellt.
Anschließend wird im Abschnitt [Anforderungsanalyse](#anforderungsanalyse) beschrieben, welche Mechanismen nötig sind, um die ausgewählte Idee umzusetzen.

### Grundideen

Der Kern der Aufgabenstellung sind Typen, deren Repräsentierungen und die Zugehörigkeitsüberprüfung eines Wertes zu diesen Typen.
Die anderen Teilaufgaben, wie beispielsweise das Parsen der Stapeleffekte und die Absicherung der Worte, sind zwar nicht unwichtig, werden dennoch zweitrangig betrachtet:
Zuerst muss der Kern der Aufgabenstellung modelliert und entworfen werden.
Später wird dieser dann auf die gesamte Aufgabenstellung erweitert.

Im Folgenden werden zwei Ideen vorgestellt:
1. Die Idee der [Typinferenz zur Laufzeit](#typinferenz-zur-laufzeit) beschreibt ein System, dass Typen aus der Struktur der Werte konstruiert.
2. Die Idee der [Typenprädikate](#typprädikate) beschreibt ein System, bei dem Typen durch Prädikate repräsentiert werden.

#### Typinferenz zur Laufzeit

Das Herzstück der Idee ist die Einführung eines Wortes `type2`, welches ähnlich wie `type` den Typ eines Wertes liefert.
Anstatt jedoch wie `type` nur die Art des Wertes auf seiner obersten Strukturebene zu betrachten, konstruiert `type2` den vollständigen Typ anhand der Struktur des Wertes.

> Hinweis:
> Natürlich wäre es möglich, dass das hier vorgestellte Wort `type2` `type` ersetzt.
> In dieser Ausarbeitung wird `type2` allerdings als Alternative definiert, sodass es möglich wird bei Bedarf detailliertere Typinformationen eines Wertes abzufragen.

Der Typ eines Wertes ist in consize nicht eindeutig:
Der Wert `5` kann sowohl eine Zahl, ein Wort, ein Zeichen und eine Ziffer sein.
Die Konsequenz daraus ist, dass `type2` eine Menge von Typen für einen Wert zurückgeben muss.
Der Sonderfall "Leermenge" bedeutet, dass sich der betrachtete Wert nicht typisieren lässt.

Die Überprüfung auf Typzugehörigkeit mithilfe dieser Methode ist trivial:
Ein Wert `x` ist vom Typ `T`, wenn `T` in der Typmenge von `x` existiert.

Mit diesem Ansatz können Typen als Wörter (`wrd`) repräsentiert werden.
Das Wort `type2` liefert also eine Menge von Wörtern.

Zur technischen Realisierung werden folgende Komponenten benötigt:
1. Eine Komponente, die es ermöglicht, Typen zu definieren.
2. Ein zentraler Ort, an dem alle Definitionen abgelegt werden.
3. Ein Algorithmus, der auf den Typ eines Wertes schließt.

Die notwendigen Komponenten werden im Folgenden einzeln besprochen:
1. Zur Bekanntmachung von Typen kann beispielsweise ein Wort `define-type` eingeführt werden, dass das Prädikat und den Namen des Typen an einer zentralen Stelle sammelt.
Definitionen können auch zusätzlich über eine Syntaxerweiterung (beispielsweise `typedef`) vorgenommen werden.
Beispielsweise könnte eine Registrierung der Typen `Wrd` und `Int` durch den folgenden Code erreicht werden:
    ```consize
    typedef Wrd [ type \ wrd equal? ] ;
    typedef Int [ dup type \ wrd equal? swap integer? and ] ;
    ```

2. Die Registrierung könnte technisch durch das Eintragen der Prädikate und Namen im Wörterbuch oder in einer im Wörterbuch abgelegten Liste realisiert werden.

3. Der Laufzeit-Typinferenzsalgorithmus sammelt alle Typen auf, die auf den betrachteten Wert passen und liefert diese zurück. Der Inferenz-Algorithmus sei im Folgenden gegeben:
    <!--- let \; R = [ \left \langle P_1,N_1 \right \rangle, \left \langle P_2,N_2 \right \rangle ... \left \langle P_n,N_n \right \rangle ] -->
    ![Menge der bekannten Typen](https://latex.codecogs.com/gif.latex?let%20%5C%3B%20R%20%3D%20%5B%20%5Cleft%20%5Clangle%20P_1%2CN_1%20%5Cright%20%5Crangle%2C%20%5Cleft%20%5Clangle%20P_2%2CN_2%20%5Cright%20%5Crangle%20...%20%5Cleft%20%5Clangle%20P_n%2CN_n%20%5Cright%20%5Crangle%20%5D) \
Sei `R` die Menge der bekannten Typen und das Tupel <code>(P<sub>i</sub>, N<sub>i</sub>)</code> die `i`-te Typdefinition, mit dem Prädikat <code>P<sub>i</sub></code> und dem Namen des Typen <code>N<sub>i</sub></code>.
    <!--- let \; param(name,x_1,...,x_n) = name \oplus "{<}" \oplus x_1 \oplus ... \oplus x_n \oplus "{>}" --> 
    ![Erstellung eines parametrisierten Typen](https://latex.codecogs.com/gif.latex?let%20%5C%3B%20param%28name%2Cx_1%2C...%2Cx_n%29%20%3D%20name%20%5Coplus%20%22%7B%3C%7D%22%20%5Coplus%20x_1%20%5Coplus%20...%20%5Coplus%20x_n%20%5Coplus%20%22%7B%3E%7D%22) \
Sei `param` eine Funktion, die die Repräsentierung für einen parametrisierten Typen erstellt.
    <!--- \begin{matrix} -->
    <!--- let \; prop(name, E_1, ..., E_n) = \\  -->
    <!--- \;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;\;  \{\;param(name, x_1, ..., x_n) \; | \left \langle x_1, ..., x_n \right \rangle \in E_1 \times ... \times E_n\;\} -->
    <!--- \end{matrix} -->   
    ![Propagierung von Typparameter-Informationen](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bmatrix%7D%20let%20%5C%3B%20prop%28name%2C%20E_1%2C%20...%2C%20E_n%29%20%3D%20%5C%5C%20%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%5C%3B%20%5C%7B%5C%3Bparam%28name%2C%20x_1%2C%20...%2C%20x_n%29%20%5C%3B%20%7C%20%5Cleft%20%5Clangle%20x_1%2C%20...%2C%20x_n%20%5Cright%20%5Crangle%20%5Cin%20E_1%20%5Ctimes%20...%20%5Ctimes%20E_n%5C%3B%5C%7D%20%5Cend%7Bmatrix%7D) \
    Sei `prop` eine Funktion, die den Parameter `name` kombinatorisch mit allen Elementen der Typmengen kombiniert und damit die Information der Typparameter propagiert. Dabei ist <code>E<sub>i</sub></code> die Typmenge, die den `i`-ten Typparameter eines parametrisierten Typen beschreibt.
    <!--- let \; disp(match, name) = \left\{\begin{matrix} -->
    <!--- \{name\} & if\;\; match = & t \\ -->
    <!--- \emptyset & if\;\; match = & f \\ -->
    <!--- prop(name, E_1, ..., E_n) & if\;\; match = & [E_1, ..., E_n] -->
    <!--- \end{matrix}\right. -->
    ![Fallunterscheidung Basistypen, Kollektionstypen](https://latex.codecogs.com/gif.latex?let%20%5C%3B%20disp%28match%2C%20name%29%20%3D%20%5Cleft%5C%7B%5Cbegin%7Bmatrix%7D%20%5C%7Bname%5C%7D%20%26%20if%5C%3B%5C%3B%20match%20%3D%20%26%20t%20%5C%5C%20%5Cemptyset%20%26%20if%5C%3B%5C%3B%20match%20%3D%20%26%20f%20%5C%5C%20prop%28name%2C%20E_1%2C%20...%2C%20E_n%29%20%26%20if%5C%3B%5C%3B%20match%20%3D%20%26%20%5BE_1%2C%20...%2C%20E_n%5D%20%5Cend%7Bmatrix%7D%5Cright.) \
Sei `disp` die Funktion, die basierend auf dem Ergebnis vom Prädikat `P` eine Fallunterscheidung durchführt, ob es sich um einen Typen mit oder ohne Typargumente handelt.
    <!--- let \; T(v) = \bigcup \;\; \{ \; disp(P(v),N) \;| \left \langle P,N \right \rangle \in R \;\} -->
    ![Funktion, die die Typmenge liefert](https://latex.codecogs.com/gif.latex?let%20%5C%3B%20T%28v%29%20%3D%20%5Cbigcup%20%5C%3B%5C%3B%20%5C%7B%20%5C%3B%20disp%28P%28v%29%2CN%29%20%5C%3B%7C%20%5Cleft%20%5Clangle%20P%2CN%20%5Cright%20%5Crangle%20%5Cin%20R%20%5C%3B%5C%7D) \
Sei `T` die Funktion, die die Typmenge für den Wert `v` liefert.
\
Der Algorithmus unterscheidet im wesentlichen zwischen zwei Arten von Werten:
- Es gibt einfache oder auch Basiswerte, die nicht aus anderen Werten zusammengesetzt sind. Beispiele dafür sind Zahlen, Worte, Funktionen und `nil`. Prädikate für diese Typen liefern `t` oder `f`, je nachdem ob der Wert zum Typ passt oder nicht.
- Es gibt aber auch Werte, die aus anderen Werten komponiert wurden. Dazu gehören beispielsweise Kollektionen, wie Stapel oder Wörterbücher, sowie algebraische Datentypen. Bei der Inferenz der Typen dieser Werte ergeben sich die Typargumente aus den Elementwerten. Prädikate für diesen Typen liefern `f` oder eine Liste von Mengen, in der für jedes Typargument genau eine Typmenge steht. \
Beispiele:
    - Prädikate für Stapel liefern im Erfolgsfall immer eine Liste mit genau einer Typmenge. Angenommen das Prädikat `Stk` liefert `[ [ Int Wrd ] ]`. Nun wird jeder Typ aus der Typmenge mit der Zeichenkette `Stk` kombiniert. Das Ergebnis für die Kombinierung ist `[ Stk<Int> Stk<Wrd> ]`. Bei dem betrachteten Wert handelt es sich also entweder um eine Liste von Zahlen oder eine Wortliste.
    - Prädikate für Wörterbücher liefern im Erfolgsfall immer eine Liste mit genau zwei Typmengen. Angenommen das Prädikat `Map` liefert `[ [ Int Wrd ] [ Int Wrd ] ]`. Durch das kombinatorische Verbinden mit der Zeichenkette `Map`, erhält man `[ Map<Int,Int> Map<Int,Wrd> Map<Wrd,Int> Map<Wrd,Wrd> ]`. Es handelt sich bei dem betrachteten Wert also um ein Wörterbuch mit einer der geschlussfolgerten Konstellation für Typen der Schlüssel-Wert-Paare. \

    Eine mögliche und sinnvolle Implementierung für das Prädikat `Stk` wird im Folgenden gegeben:

    ```consize
    typedef Stk [
      dup type \ stk equal?
      [ [ type2 ] map intersect-list ( ) cons ]
      [ drop false ]
      if
    ] ;
    ```
    Die Schnittmenge der Typen aller Listenelemente bildet das Typargument für Stapel im vorausgehenden Beispiel.

    Die Inferenz für die Sequenz `( 42 \ hello )` würde dann wie folgt arbeiten:
    1. `type2` durchsucht alle bekannten Typen. Es sei angenommen, dass in diesem Beispiel nur die Typen `Int`, `Wrd` und `Stk` definiert wurden. Der betrachtete Wert ist ein Stapel, was das von `Stk` definierte Prädikat erkennen wird.
        2. Während der Überprüfung auf Typzugehörigkeit des Stapels werden die Typen der Listenelemente inferiert. `42 type2` liefert `[ Wrd Int ]` und `\ hello type2` `[ Wrd ]`.
        3. Durch die Schnittmengenbildung der Typmengen der Listenelemente wird der Typ auf `[ Wrd ]` eingeschränkt.
    4. Der Typ der Sequenz kann deswegen auf `[ Stk<Wrd> ]` festgelegt werden.


Als weiterführende Idee gibt es hierzu noch die Minimierung der Typmenge durch Einführen einer Art Subtypenrelation.
Die Definition einer dieser Relationen könnte wie folgt aussehen:
```consize
define-relation Int <: Wrd ;
```
Dabei hat `A <: B` die Bedeutung: `A` hat mindestens die Eigenschaften von `B`, möglicherweise aber mehr.

Wäre diese Relation für alle Typen bekannt, kann `type2` nur die speziellsten Typen zurückliefern und dadurch die Menge minimieren.

Das soll folgendes Beispiel verdeutlichen:
- Seien die Typen `Wrd`, `Int`, `Digit`, `Char` mit ihren offensichtlichen Bedeutungen definiert.
- Seien des Weiteren die für consize sinnvollen Relationen `Int <: Wrd`, `Char <: Wrd`, `Digit <: Char`, `Digit <: Int` bekannt.
- Sei außerdem `Stk` kovariant und es gilt daher: `Stk<T> <: Stk<U>`, wenn `T <: U`.
- Das Programm `5 type2` würde dann statt der Menge `[ Wrd Int Digit Char ]` die Menge `[ Digit ]` zurückgeben.

Wird die Typmenge optimiert, muss die Relation `<:` vom Test der Typzugehörigkeit eines Wertes beachtet werden.
Angenommen ein Wort `w` erwartet ein Wert vom Typ `B` als Argument.
Sei weiterhin angenommen, dass für ein Argument `x` <code>T(x) &cap; {B} = &empty;</code> und <code>A &isin; T(x)</code> gilt.
Ohne die Relation würde es beim Aufruf mit dem Argument `x` zu einem Fehlerfall kommen.
Gilt `A <: B` können Werte vom Typ `A` an jeder Stelle, an der Werte vom Typ `B` erwartet werden, verwendet werden.
Somit könnte `w` mit `x` fehlerfrei aufgerufen werden.

Die hier vorgestellte Methode zur Typinferenz kann mit manchen Typdefinitionen nicht umgehen.
Definiert man beispielsweise den Typ `Id` terminiert die Typinferenz nicht mehr.
```consize
typedef Id [ type2 ] ;
```
Es ist also Vorsicht bei der Definition von Typen geboten.

Die vorgestellte Idee ist sehr aufwändig, sowohl in der Entwicklung, als auch für den Nutzer der Typen.
Sie bringt außerdem einen erhöhten Laufzeitaufwand mit sich.
Dieser ist gegeben durch die Konstruktion und die Minimierung der Typmengen, sowie durch die laufzeitaufwändige Typzugehörigkeitsprüfung (im Falle der Minimierung).
Konstruiert werden Typmengen durch eine Suche aller bekannten Typen und das kombinatorische Erzeugen von Typrepräsentierungen für parametrisierte Typen, was ebenfalls nicht praxistauglich ist.
Ein weiterer Nachteil ist, dass mit dieser Methode nicht alle Typen inferiert werden können (`Id`).

Die zugrundeliegende Idee dieser Methode ist die Verwendung von Prädikaten zur Entscheidung von Typzugehörigkeiten.
Diese alleine betrachtet scheint einfacher und leichtgewichtiger zu sein – vor allem auch in der Hinsicht des Laufzeitaufwands.
Außerdem konzentriert sich diese Methode auf das Wesentliche: die Zugehörigkeitsprüfung.
Aus diesen Gründen wird diese Idee im nächsten Abschnitt ([Typenprädikate](#typenprädikate)) genauer betrachtet.

#### Typenprädikate

Die Typüberprüfung mit der Hilfe von Prädikaten scheint eine einfache und naive Lösung zu sein.
Bei dieser Idee werden Typen durch Prädikate repräsentiert, die für jeden Wert entscheiden, ob er diesem Typ angehört oder nicht.
Weder die Virtuelle Maschine noch die Prelude müssen zur Realisierung dieser Idee angepasst werden:
Die gesamte Methode lässt sich in Form einer Bibliothek implementieren.

In consize werden also werden Typen als Wörter realisiert die Prädikate (Quotierungen) liefern.
Damit man diese Typwörter von anderen Wörtern unterscheiden kann, werden diese in diesem Dokument konventionell groß geschrieben.

Die Typen `Wrd`, `Fkt` und `Nil` werden von den gleichnamigen Wörter definiert.
Sie liefern Prädikate, welche mithilfe von `type` die Typzugehörigkeitsprüfung durchführen.
Mögliche Implementierungen der Typen könnten wie folgt aussehen:
```consize
: Wrd ( -- tpe ) [ type \ wrd equal? ] ;
: Fkt ( -- tpe ) [ type \ fkt equal? ] ;
: Nil ( -- tpe ) [ type \ nil equal? ] ;
```

Typen wie `Stk` und `Map` sind jedoch Typenkonstruktoren und damit abstrakt.
Sie liefern erst einen konkreten Datentypen, wenn man sie mit konkreten Typen parametrisiert.
Dieser Ansatz kann für die Implementierung von Typenkonstruktoren übernommen werden:
Typenkonstruktoren werden durch Worte implementiert, die Prädikate für ihre Elementtypen annehmen und dann ein Prädikat für den resultierenden Datentyp liefern.
In anderen Worten definierten Typkonstruktoren Transformatoren für Prädikate.

Im Folgenden sei eine beispielhafte Implementierung für den Typkonstruktor `Stk` gegeben.
```consize
: Stk ( elemtpe -- tpe )
  [ swap dup type \ stk equal?
    [ swap all? ]
    [ 2drop false ]
    if
  ] curry ;
```

Gleichermaßen könnte man auch mit den algebraischen Datentypen oder anderen zusammengesetzten Typen verfahren.

Diese Methode zur Typüberprüfung wird auch in anderen Programmiersprachen eingesetzt.
Ein historisches Beispiel für eine solche Sprache ist [Prolog](https://en.wikipedia.org/wiki/Prolog), für die es die Bibliothek mavis (vgl. [Quellcode](https://github.com/mndrix/mavis/blob/master/prolog/mavis.pl), [Pack](http://www.swi-prolog.org/pack/list?p=mavis) oder [Prolog in Production](https://www.youtube.com/watch?v=G_eYTctGZw8)) gibt, die optionale Typprüfungen mitbringt.

Die Implementierung durch Typenprädikate scheint sinnvoll, einfach, aber dennoch elegant zu sein:
Für den Entwickler ist es einfach neue Typen einzuführen und es ist keine Änderung der VM und Prelude notwendig.
Bewähren konnte sich die Idee bereits in Prolog unter Zuhilfenahme der vorgestellten Bibliothek.

Deswegen wird im nächsten Kapitel (vgl. [Anforderungsanalyse](#anforderungsanalyse)) diese Idee weiter betrachtet.

### Anforderungsanalyse

In diesem Kapitel soll analysiert werden, was geschehen muss, damit die Idee der [Typenprädikate](#typenprädikate) umgesetzt und auf die vollständige Aufgabenstellung (vgl. [Aufgabe](#aufgabe)) erweitert werden kann.
Zur Erinnerung: Die Typenprädikate sollen dazu verwendet werden, Aufrufe der Wörter abzusichern und nur bestimmte, erwartete Werte sollen zugelassen werden.

Hierfür muss eine Beschreibungssprache für Typangaben in Stapeleffekten definiert werden (vgl. [Grammatik der Beschreibungssprache für Typen](#grammatik-der-beschreibungssprache-für-typen)).
Ein im Kapitel [Parser für die Typensprache](#parser-für-die-typensprache) definierter Parser wird dazu verwendet die Stapeleffekte zu erkennen.
Für jeden Parameter des Wortes wird ein Prädikat generiert (vgl. [Materialisierung von Prädikaten von Typen](#materialisierung-von-prädikaten-von-typen)), mit dem es dann möglich wird die durch die Typangaben eingeführten Vor- und Nachbedingungen zu etablieren (vgl. [Durchsetzen von Vor- und Nachbedingungen](#durchsetzen-von-vor--und-nachbedingungen)).
Als letztes muss der Prozess der Wortdefinition so angepasst werden, dass ein Parsen und Generieren der Prädikate durchgeführt wird.
Das geschieht im Kapitel [Ändern des Wortdefinitionsprozesses](#Ändern-des-wortdefinitionsprozesses).

## Realisierung

In diesem Kapitel wird die Lösung zum Problem vorgestellt.

> Hinweis:
> Wörter, die den Präfix `--` haben, stellen private Definitionen dar und sollten nur von dem Modul selbst verwendet werden.

### Hilfsdefinitionen

```consize
>> % ============================ auxiliary definitions =============================
>>
>>
```

#### Operationen für Wörter

```consize
>> : --glue ( wrd1 wrd2 -- wrd1wrd2 ) [ unword ] bi@ concat word ;
```
`--glue` konkateniert zwei Wörter und liefert die Konkatenation.

```consize
> \ foo \ bar --glue
foobar
```

```consize
>> : --glue-unicode ( w -- \uw ) \ \u swap --glue ;
>> 
>> 
```
Das Wort `--glue-unicode` hängt `\u` vor das Wort `w`.

```consize
> \ c0de --glue-unicode
\uc0de
```

#### Listenoperationen

```consize
>> : --stack ( x -- [ x ] ) ( ) cons ;
```
`--stack` konstruiert eine Liste, deren einziges Element `x` ist.

```consize
> 42 --stack
[ 42 ]
```

```consize
>> : --flatten ( seqofseqs -- seq ) ( ) [ concat ] reduce ;
```
`--flatten` akzeptiert eine Liste von Listen und konstruiert die Konkatenation aller Sublisten.

```consize
> ( ( ) ( 1 ) ( 2 3 ) ( 4 5 6 ) ) --flatten
[ 1 2 3 4 5 6 ]
```

```consize
>> : --flatmap ( seq q -- seq ) map --flatten ;
```
`--flatmap` ist die Kombination aus `map` und `--flatten`.

```consize
> ( 1 2 3 ) [ dup --stack cons ] --flatmap
[ 1 1 2 2 3 3 ]
```

```consize
>> : --override ( seq v -- seq' ) [ swap drop ] curry map ;
```
`--override` liefert eine Kopie von `seq` bei der alle Werte durch `v` ersetzt wurden.

```consize
> ( 0 ( 1 ) [ drop true ] { \ key \ value } ) 42 --override
[ 42 42 42 42 ]
```

```consize
>> : --replicate ( n v -- seq ) swap 1 swap [a,b] swap --override ;
```
Das Wort `--replicate` konstruiert eine Liste der Länge `n` durch `n`-maliges Wiederholen des Wertes `v`.

```consize
> 5 \ | replicate
[ | | | | | ]
```

```consize
>> : --contains ( seq v -- t/f ) [ equal? ] curry any? ;
```
Mit `--contains` kann man feststellen, ob die Sequenz `seq` den Wert `v` enthält.

```consize
> ( ) 5 --contains
f

> ( 5 ) 5 --contains
t

> ( 1 1 5 1 1 ) 5 --contains
t
```

```consize
>> : --contains-all ( haystack needles -- t/f ) swap [ swap --contains ] curry all? ;
```
`--contains-all` prüft, ob alle Werte aus der Sequenz `needles` in der Sequenz `haystack` vorkommen.

```consize
> ( ) ( ) --contains-all
t

> ( ) ( 1 ) --contains-all
f

> ( 1 ) ( 1 ) --contains-all
t

> ( 1 2 ) ( 1 ) --contains-all
t
```

```consize
>> : --intersperse ( seq v -- seq' ) [ [ --stack ] bi@ swap concat ] curry --flatmap pop ;
>> 
>> 
```
Das Wort `--intersperse` konstruiert eine Liste, in der jeweils zwei aufeinanderfolgende Elemente der Sequenz `seq` durch `v` separiert wurden.

```consize
> ( 1 2 3 4 5 ) \ + --intersperse
[ 1 + 2 + 3 + 4 + 5 ]
```

#### Mengen- und Wörterbuchoperationen

```consize
>> : --set ( seq -- set ) [ [ nil ] cons ] --flatmap mapping ;
```
Das Wort `--set` konstruiert ein Wörterbuch, dessen Schlüssel die Elemente aus der Sequenz `seq` sind. Jeder der Schlüssel ist mit dem Wert `nil` assoziiert.

```consize
> ( 1 2 3 ) --set
{ 1 nil 2 nil 3 nil }
```

```consize
>> : --map-values ( map quot -- map' )
>>   [ dup [ keys ] [ values ] bi* ] dip map zip --flatten mapping ;
>> 
>> 
```
Das Wort `--map-values` ermöglicht es die Werte des Wörterbuchs `map` mithilfe der Quotation `quot` zu transformieren.

```consize
> { a 1 b 2 c 3 } [ 10 + ] --map-values
{ a 11 b 12 c 13 }
```

#### Operationen zur Typenkonvertierung

```consize
>> : --hex-lookup ( -- map )
>>   { \ 0 \ 0 \ 1 \ 1 \ 2 \ 2  \ 3  \ 3 \ 4  \ 4 \ 5  \ 5 \ 6  \ 6 \ 7  \ 7
>>     \ 8 \ 8 \ 9 \ 9 \ 10 \ A \ 11 \ B \ 12 \ C \ 13 \ D \ 14 \ E \ 15 \ F } ;
>> 
>> : --hex-helper ( acc dec-n -- hex-n )
>>   dup 0 ==
>>   [ drop ]
>>   [ dup [ 16 div ] dip 16 mod
>>     --hex-lookup nil get
>>     dup nil equal?
>>     [ error ]
>>     [ rot cons swap --hex-helper ]
>>     if
>>   ]
>>   if ;
>> 
>> : --hex ( dec-n -- hex-n )
>>   dup 0 ==
>>   [ 0 ]
>>   [ ( ) swap --hex-helper word ]
>>   if ;
>> 
```
Das Wort `--hex` wandelt eine Dezimalzahl in eine Hexadezimalzahl um.
Es verwendet dazu ein Wörterbuch zum Umrechnen der Ziffern (siehe `--hex-lookup`) und ein rekursives Hilfswort `--hex-helper`.

```consize
> 49374 --hex
C0DE
```

```consize
>> : --int-to-char ( n -- c )
>>   --hex unword dup size dup 4 <
>>   [ 4 swap - 0 --replicate [ word ] bi@ swap --glue --glue-unicode char ]
>>   [ dup 4 ==
>>     [ drop --glue-unicode char ]
>>     [ error ]
>>     if
>>   ]
>>   if ;
>> 
>> 
```
Mit dem Wort `--int-to-char` lassen sich Zahlen zu Unicode-Zeichen konvertieren.

```consize
> 32 --int-to-char <space> equal?
t

> 10 --int-to-char <newline> equal?
t

> 97 45 122 [ --int-to-char ] tri@
a - z
```

#### Diverse Operationen

```consize
>> : --2swap ( a b c d -- c d a b ) [ -rot ] dip -rot ;
>> 
```
`--2swap` tauscht ein Paar von Werten mit dem darunterliegenden Paar.

```consize
> c d a b --2swap
a b c d
```

```consize
>> : --pred-and ( x y -- pred' )
>>   [ [ over ] dip --2swap call
>>     [ call ] [ 2drop false ] if
>>   ] 2curry ;
>> 
>> : --pred-or ( x y -- pred' )
>>   [ [ over ] dip --2swap call
>>     [ 2drop true ] [ call ] if
>>   ] 2curry ;
>> 
```
Die Wörter `--pred-and` und `--pred-or` konstruieren ein zusammengesetztes Prädikat aus den Einzelprädikaten.
Die Ergebnisse der Einzelprädikate `x` und `y` werden mit dem entsprechenden Operator (`and` und `or`) kombiniert.

```consize
> 2 [ 1 equal? ] [ 2 equal? ] --pred-and call
f

> 2 [ 2 equal? ] [ 2 equal? ] --pred-and call
t

> 2 [ 2 equal? ] [ 1 equal? ] --pred-and call
f

> 1 [ 2 equal? ] [ 2 equal? ] --pred-and call
f

> 2 [ 1 equal? ] [ 2 equal? ] --pred-or call
t

> 2 [ 2 equal? ] [ 1 equal? ] --pred-or call
t

> 2 [ 1 equal? ] [ 1 equal? ] --pred-or call
f

> 2 [ 2 equal? ] [ 2 equal? ] --pred-or call
t
```

```consize
>> : --char-range ( start end -- range )
>>   [a,b] [ --int-to-char ] map ;
>> 
```
Das Wort `--char-range` ermöglicht das Erstellen einer Sequenz, die alle Zeichen von `start` bis `end` (beide inklusive, gegeben durch die ASCII-Werte der Zeichen) enthält.

```consize
> 97 122 --char-range
[ a b c d e f g h i j k l m n o p q r s t u v w x y z ]
```

```consize
>> : --take-datastack-rec ( ... acc n -- seq )
>>   dup 0 <=
>>   [ drop ]
>>   [ -rot cons swap 1 - --take-datastack-rec ]
>>   if ;
>> 
>> : --take-datastack ( n -- seq )
>>   dup integer? [ ( ) swap --take-datastack-rec ] [ error ] if ;
>> 
>> 
```
Das Wort `--take-datastack` nimmt die obersten `n` Elemente vom Datenstapel und liefert sie als  Sequenz in umgekehrter Reihenfolge zurück.

```consize
> 1 2 3 4 5 5 --take-datastack
[ 1 2 3 4 5 ]
```

#### Wörtliche Version von scan4

```consize
>> : --literally-scan4-parser-everything ( -- parser )
>>   [ drop true ] parser-predicate ;
>> 
>> : --literally-scan4-parser-listcommon ( start end -- parser )
>>   dup
>>   [ parser-item parser-not
>>     --literally-scan4-parser-word parser-append-right parser-rep
>>   ] curry parser-lazy
>>   [ 2dup ] dip -rot
>>   [ parser-item ] bi@ parser-between -rot
>>   [ [ --stack ] bi@ swapd concat concat ] 2curry parser-map ;
>> 
>> : --literally-scan4-parser-list ( -- parser ) \ ( \ ) --literally-scan4-parser-listcommon ;
>> : --literally-scan4-parser-quot ( -- parser ) \ [ \ ] --literally-scan4-parser-listcommon ;
>> : --literally-scan4-parser-dict ( -- parser ) \ { \ } --literally-scan4-parser-listcommon ;
>> 
>> : --literally-scan4-parser-word ( -- parser )
>>   ( --literally-scan4-parser-list
>>     --literally-scan4-parser-quot
>>     --literally-scan4-parser-dict
>>     --literally-scan4-parser-everything
>>   ) parser-choice ;
>> 
>> : --literally-scan4-parser ( end -- parser )
>>   parser-item parser-not --literally-scan4-parser-word parser-append-right parser-rep
>>   [ [ dup type
>>       { \ wrd [ --stack ]
>>         \ stk [ ]
>>       } case
>>     ] --flatmap
>>   ] parser-map ;
>> 
>> : --literally-scan4 ( seq end -- match rest )
>>   % Returns the words before `end` (exclusive) and the words after `end` also exclusive.
>>   --literally-scan4-parser swap parser-run dup
>>   \ status swap nil get \ success equal?
>>   [ dup \ value swap nil get swap \ input swap nil get pop ]
>>   [ drop error ]
>>   if ;
>> 
>> 
```
Das Wort `--literally-scan4` ist ähnlich wie das in der Prelude definierte `scan4]`.
Der Unterschied ist, dass `scan4]` bei der ersten schließenden Klammer aufhört.
Damit beispielsweise jedoch das Parsen von verschachtelten Werten in Stapeleffekten (vgl. [Verschachtelte Werte in Stapeleffekten](#verschachtelte-werte-in-stapeleffekten)) oder die Definitionen der Wörter `type-repr(` und `type-pred(` (vgl. Wort `type-repr(` in Kapitel [Parser für die Typensprache](#parser-für-die-typensprache) und `type-pred(` in Kapitel [Materialisierung von Prädikaten von Typen](#materialisierung-von-prädikaten-von-typen)) möglich wird, müssen diese beim Parsen beachtet werden.
`--literally-scan4` verwendet den Parser, der mithilfe von `--literally-scan4-parser` konstruiert wird, der wiederum auf den Parsern `--literally-scan4-parser-list`, `--literally-scan4-parser-quot`, `--literally-scan4-parser-dict` und `--literally-scan4-parser-everything` basiert.
Als Ergebnis liefert `--literally-scan4`:
- den Präfix der Liste bis zum ersten Vorkommen von `end`, unter Berücksichtigung von consize-Werten (Listen, Quotierungen und Wörterbücher) und
- den Rest der Liste.

```consize
> ( \ ( 8 \ ) \ ) ) \ ) --literally-scan4
[ ( 8 ) ] [ ]
```

#### Parseroperationen und Input-Enkodierung

Die Parser-Combinator Bibliothek definiert Wertparser, also Parser, die Muster in Sequenzen von Werten erkennen können.
Damit jedoch eine Neuinterpretation der Stapeleffekte mit einer für consize untypischen Syntax möglich wird, müssen die Parser allerdings mit Zeichenketten arbeiten.
Deswegen werden in diesem Abschnitt Hilfswörter für Zeichenparser definiert.

```consize
>> : --char-list ( seq-of-words -- list )
>>   [ unword ] map <space> --stack --intersperse --flatten ;
>> 
```
Das Wort `--char-list` transformiert eine Sequenz aus Wörter zu einer Sequenz aus Zeichen, die mit einem Leerzeichen (`<space>`) separiert wurden.

```consize
> ( hello world ) --char-list
[ h e l l o   w o r l d ]
```

```consize
>> : --chars ( seq -- seq' )
>>  [ dup type
>>    { \ stk   [ --chars ]
>>      \ wrd   [ unword ]
>>      \ :else [ repr --chars ]
>>    } case ] --flatmap ;
>> 
```
`--chars` funktioniert ähnlich wie `--char-list`, es kann aber beliebige rekursive Strukturen zu Sequenzen von Zeichen konvertieren.
`--chars` fügt außerdem keine Leerzeichen zur Trennung der Worte ein.

```consize
> ( \ hello, <space> \ world <space> ( 1 2 3 ) \ ! ) --chars
[ h e l l o ,   w o r l d   1 2 3 ! ]
```

```consize
>> : --parser-word-exact ( w -- parser )
>>   dup empty?
>>   [ error ]
>>   [ dup unword [ parser-item ] map unpush [ parser-and ] reduce
>>     swap [ ] curry parser-onsuccess
>>   ]
>>   if ;
>> 
```
Das Wort `--parser-word-exact` konstruiert einen Parser, der eine konstante Zeichenkette erkennt.
Dieses Wort bietet die gleiche Funktionalität wie `parser-item`, aber der durch `--parser-word-exact` erstellte Parser arbeitet auf Zeichenketten (und ist somit ein Zeichenparser), anstatt auf Werten.

```consize
> \ hello --parser-word-exact ( \ hello \ world ) --char-list parser-run
{ input [   w o r l d ] value hello status success }
% `hello` wurde als Wert zurückgegeben
% `[   w o r l d ]` ist der verbleibende, nicht-konsumierte Input

% Zum Vergleich dazu die Ausführung eines Wertparsers:
> \ hello parser-item ( \ hello \ word ) parser-run
{ input [ world ] value hello status success }
```

```consize
>> : --spaces ( parser -- parser' )
>>   <space> --parser-word-exact parser-rep swap parser-append-right ;
>> 
```
Das Wort `--spaces` erweitert einen Parser `parser`, sodass er beliebige, vorangestellte Leerzeichen konsumiert.

```consize
> \ foo --parser-word-exact --spaces   % parser
> 50 <space> --replicate               % input: [ <50 spaces> ]
> ( \ foo \ bar ) --char-list concat   % input: [ <50 spaces> f o o <space> b a r ]
> parser-run
{ input [   b a r ] value foo status success }
```

```consize
>> : --parser-wrapword ( parser before-wrd after-wrd -- parser' )
>>   [ --parser-word-exact --spaces ] bi@ parser-between ;
```
Das Wort `--parser-wrapword` arbeitet genauso wie `parser-between`, mit dem Unterschied, dass aus den erwarteten Wörtern `before-wrd` und `after-wrd` Zeichenparser erstellt werden, die führende Leerzeichen konsumieren.

```consize
> 1 --parser-word-exact \ ( \ ) --parser-wrapword ( \ (1) ) --char-list parser-run
{ input [ ] value 1 status success }
```

```consize
>> : --charwise-scan4-flatten ( parser -- parser' )
>>   [ [ dup type
>>       { \ wrd [ --stack ]
>>         \ stk [ ]
>>       } case
>>     ] --flatmap
>>   ] parser-map ;
>> 
>> : --charwise-scan4-parser-separator ( -- parser )
>>   <space> --parser-word-exact parser-rep1 ;
>> 
>> : --charwise-scan4-parser-word ( -- parser )
>>   --charwise-scan4-parser-separator parser-not
>>   [ drop true ] parser-predicate
>>   parser-append-right parser-rep1
>>   [ word ] parser-map ;
>> 
>> : --charwise-scan4-parser-listcommon ( start end -- parser )
>>   dup
>>   [ --parser-word-exact --charwise-scan4-parser-separator parser-or parser-not
>>     --charwise-scan4-parser-value parser-append-right
>>     --charwise-scan4-parser-separator parser-repsep --spaces --charwise-scan4-flatten
>>   ] curry parser-lazy
>>   [ 2dup ] dip -rot
>>   [ --parser-word-exact --spaces ] bi@ parser-between -rot
>>   [ [ --stack ] bi@ swapd concat concat ] 2curry parser-map ;
>> 
>> : --charwise-scan4-parser-list ( -- parser ) \ ( \ ) --charwise-scan4-parser-listcommon ;
>> : --charwise-scan4-parser-quot ( -- parser ) \ [ \ ] --charwise-scan4-parser-listcommon ;
>> : --charwise-scan4-parser-dict ( -- parser ) \ { \ } --charwise-scan4-parser-listcommon ;
>> 
>> : --charwise-scan4-parser-value ( -- parser )
>>   ( --charwise-scan4-parser-list
>>     --charwise-scan4-parser-quot
>>     --charwise-scan4-parser-dict
>>     --charwise-scan4-parser-word
>>   ) parser-choice ;
>> 
>> : --charwise-scan4-parser ( end -- parser )
>>   --parser-word-exact dup parser-not --charwise-scan4-parser-value parser-append-right
>>   --charwise-scan4-parser-separator parser-repsep --charwise-scan4-flatten
>>   swap --spaces parser-append-left ;
>> 
>> : --charwise-scan4 ( seq end -- match rest )
>>   % Returns the words before `end` (exclusive) and the words after `end` also exclusive.
>>   --charwise-scan4-parser swap parser-run dup
>>   \ status swap nil get \ success equal?
>>   [ dup \ value swap nil get swap \ input swap nil get pop ]
>>   [ drop error ]
>>   if ;
>> 
```
Das Wort `--charwise-scan4` funktioniert wie `--literally-scan4`, arbeitet allerdings auf Zeichenketten, anstatt auf Listen von Werten.

```consize
> ( \ ( 8 \ ) \ ) ) --char-list \ ) --charwise-scan4
[ ( 8 ) ] [ ]
```

```consize
>> : --parse-words ( seq-of-words parser - value/nil )
>>   % Only accept, if success AND the remaining input is empty 
>>   swap --char-list parser-run
>>   dup \ status swap nil get \ success equal?
>>   [ dup \ input swap nil get empty?
>>     [ \ value swap nil get ]
>>     [ drop nil ]
>>     if
>>   ]
>>   [ drop nil ]
>>   if ;
>> 
```
Das Wort `--parse-words` nimmt eine Wort-Sequenz (`seq-of-words`) an und lässt auf dieser den Parser `parser` laufen.
Es liefert genau dann den geparsten Wert, wenn der Parser den Inhalt akzeptiert hat und wenn der verbleibende Input leer ist.
War der Parseversuch nicht erfolgreich (sowohl `error` als auch `failure`) oder war der verbleibende Input ist nicht leer, liefert das Wort `nil`.

```consize
> ( 1 ) 1 parser-item --parse-words
1

> ( 2 ) 1 parser-item --parse-words
nil

> ( 1 2 ) 1 parser-item --parse-words
nil
```

```consize
>> : --parser-oneof ( seq -- parser )
>>   --set [ nil get nil equal? not ] curry parser-predicate ;
>> 
```
Das Wort `--parser-oneof` konstruiert einen Parser, der alle Werte akzeptiert, die in der Sequenz `seq` enthalten sind.

```consize
> ( 1 2 3 4 ) --parser-oneof ( 1 ) parser-run
{ input [ ] value 1 status success }

> ( 1 2 3 4 ) --parser-oneof ( 5 ) parser-run
{ message <elided> input [ 5 ] status failure }
```

#### Verschachtelte Werte in Stapeleffekten

```consize
>> : destruct-definition ( quot -- wrd stackeffect body )
>>   uncons                        % wrd rest
>>   dup top \ ( equal?            % wrd rest t/f
>>   [ pop \ ) --literally-scan4 ] when
>>   parse-quot ;
>> 
>> 
```
Das Wort `destruct-definition` überschreibt die gleichnamige Definition aus der Prelude.
Durch das Überschreiben wird es möglich verschachtelte Klammern in Stapeleffekten zu formulieren.
Folgende Definition von `cons'` wird nach dem Überschreiben möglich.
```consize
: cons' ( x xs -- ( x & xs ) ) cons ;
```

### Definition der Typensprache

In diesem Kapitel werden zuerst die [Arten von Typen](#arten-von-typen) beschrieben, die unterstützt werden sollen.
Anschließend ist die [Grammatik der Beschreibungssprache für Typen](#grammatik-der-beschreibungssprache-für-typen) abgebildet, die dann zur [Grammatik für die Stapeleffekte](#grammatik-für-die-stapeleffekte) erweitert wird.
Ist die Sprache definiert, wird ein [Abstrakter Syntaxbaum](#abstrakter-syntaxbaum) eingeführt, der diese repräsentiert.
Im darauf folgenden Abschnitt ist ein [Parser für die Typensprache](#parser-für-die-typensprache) definiert, der diese erkennt und Instanzen des Syntaxbaumes liefert.
Anschließend wird für Regeln der Grammatik, Parserkonstruktoren und Konstruktoren des abstrakten Syntaxbaums eine Orientierungshilfe gegeben (vgl. [Orientierungshilfe Grammatik, Parser und abstrakter Syntaxbaum](#orientierungshilfe-grammatik-parser-und-abstrakter-syntaxbaum)).
Die in diesem Kapitel gegebene Tabelle, zeigt welche Grammatikregeln von welchen Parsern geparst werden und von welchem Konstruktor diese Informationen aufgenommen werden.

#### Arten von Typen

Über die bereits mehrfach angesprochenen Typenprädikate oder Typenkonstruktoren ist es möglich nominale (`Int`, `Wrd` usw.) und parametrisierte (`Stk<Int>`, `Stk<Stk<Wrd>>` usw.) Typen zu definieren.
Das geschieht in dem gleichnamige Wörter in consize eingeführt werden.

Neben diesen benannten gibt es noch die anonymen, strukturbeschreibenden Typen.
Die Verwendung dieser ist nur in den Stapeleffekten möglich.

Es werden zwei Varianten von strukturellen Wörterbüchern und drei Varianten von heterogenen Listen definiert.

Es gibt einen ...
- Typ, der exakt die Struktur eines Wörterbuches beschreibt (`{ x: Int y: Wrd }`). Dieser Typ akzeptiert einen Wert genau dann, wenn er ein Wörterbuch ist, das alle spezifizierten Schlüssel hat und dessen Werte den angegebenen Typen entsprechen.
- Typ, der die Minimalanforderung an ein Wörterbuch beschreibt (`{ x: Int y: Wrd ... }`). Der Unterschied zum vorigen Wörterbuchtyp ist, dass dieser auch auf die Wörterbücher passt, die nicht genannte Schlüssel enthalten.
- Typ, der alle Elementtypen einer Liste aufzählt (`[ Int Wrd Bool ]`). Dieser Typ beschreibt die Listenwerte, deren Elemente den aufgezählten Typen entsprechen.
- Typ, der die Typen der Anfangselemente einer Liste aufzählt (`[ Int Wrd ... ]`). Der Unterschied zum vorher definierten Listentyp ist, dass dieser auch Listen akzeptiert, die mehr Elemente haben als die aufgezählten. Die Typen der Elemente die nicht aufgezählt wurden, werden von diesem Typen nicht eingeschränkt.
- Typ, der aus einem Kopftyp und einem Resttyp, unter Zuhilfenahme des rechtsassoziativen `::`-Operators, zusammengesetzt wurde (`Int :: Wrd :: HNil`). Alle nicht leere Listen, dessen Kopf dem Kopftyp und dessen Rest dem Resttyp entspricht, gehören zu dem Typ.

Vereinigungsmengen- und Schnittmengentypen runden die Ausdrucksmächtigkeit der Typen in den Stapeleffekten ab.
Sie erlauben es die Typen `A & B` (Schnittmengentyp) und `A | B` (Vereinigungsmengentyp) zu konstruieren, die die Eigenschaften von beiden (Schnittmengentyp) oder von mindestens einem (Vereinigungsmengentyp) der zugrundeliegenden Typen haben.

Strukturelle, Vereinigungs- und Schnittmengentypen werden nicht als Worte definiert.
Sie sind nur über die Typangabe in Stapeleffekten beschreibbar.
Prädikate dieser Typen werden aus den Typangaben in den Stapeleffekten unter Zuhilfenahme der nominalen und parametrisierten Typen programmatisch generiert.

#### Grammatik der Beschreibungssprache für Typen

Im Folgenden ist die Grammatik in erweiterter Backus-Naur-Form für die Beschreibungssprache für Typen gegeben.

```
Type = UnionType ;

UnionType        = IntersectionType , { '|' , IntersectionType } ;
IntersectionType = HlistType , { '&' , HlistType } ;
HlistType        = SimpleType , { '::' , SimpleType } ;

SimpleType = PredicateType
           | ListType
           | DictionaryType
           | NameType
           | '(' , Type , ')'
           ;

Ellipsis = '..' | '...' ;
Binding  = Name , ':' , Type ;

PredicateType  = '[[' , Program , ']]' ;
ListType       = '[' , { Type } , [ Ellipsis ] , ']';
DictionaryType = '{' , { Binding } , [ Ellipsis ] , '}' ;
NamedType      = Identifier , { Type } ;

Identifier      = IdentifierStart , { IdentifierPart } ;
IdentifierStart = [a-zA-Z] ;
IdentifierPart  = [a-zA-Z0-9!\?'_\-\+\/\*] ;
```

Die Grammatikregel `Program` wird an dieser Stelle nicht aufgeführt, sie ist in [Kapitel 2.4 der Dokumentation von consize](https://github.com/denkspuren/consize/blob/master/doc/Consize.pdf) durch die Regel `<program>` gegeben.

#### Grammatik für die Stapeleffekte

Mit den folgenden Grammatikregeln wird die [Grammatik der Beschreibungssprache für Typen](#grammatik-der-beschreibungssprache-für-typen) zur Grammatik für die Stapeleffekte erweitert.

```
Binding+ = Name
         | Binding
         | ConsizeValue
         ;

Signature = '(' , { Binding+ } , '--' , { Binding+ } , ')' ;
```

Wird kein Typ in den Stapeleffekten angegeben, soll jeder Wert akzeptiert werden.
So besteht die Möglichkeit selektiv zu wählen, welche der Argumente an der Typüberprüfung teilnehmen.
Daher wird die Regel `Binding+` eingeführt, die diese Flexibilität für Stapeleffekte definiert.
Die Grammatikregel `ConsizeValue` ist äquivalent zur Regel `<item>` in [Kapitel 2.4 der Dokumentation von consize](https://github.com/denkspuren/consize/blob/master/doc/Consize.pdf).

#### Abstrakter Syntaxbaum

Nun, da die Grammatik der Beschreibungssprache definiert ist, wird ein Abstrakter Syntaxbaum definiert, der diese Sprache modelliert.
Der algebraische Datentyp wird so gewählt, dass es für jede typbeschreibende Grammatikregel einen Konstruktor gibt.

```consize
>> % ============================ abstract syntax trees =============================
>> 
>> 
>> % Note:
>> % - tpt means type-tree, which is a meta-representation of a type
>> % - tpe means type, which are the predicates deciding values
>> 
>> data Tpt = NameTpt name              % Int, Wrd
>>          | PredTpt predicate         % [[ drop true ]]
>>          | CtorTpt ctor args         % Stk<Int>
>>          | InterTpt left right       % Int & Wrd
>>          | UnionTpt left right       % Int | Wrd
>>          | StructExTpt structure     % { x: Int y: Bool }
>>          | StructFuzzyTpt structure  % { n: Int ... }
>>          | ListConsTpt hdtpt tltpt   % Int :: Wrd :: HNil
>>          | ListExTpt structure       % [ Int Int Bool ]
>>          | ListFuzzyTpt structure    % [ Int Bool ... ]
>>          ;
>> 
>> data Binding = MkBinding name tpt ;
>> 
>> data StackEffect = Signature preconditions postconditions ;
>> 
>> 
```

> Anzumerken ist, dass die Abkürzung `tpt` für Typ-Syntaxbaum (type tree) und `tpe` für Typ (type) steht.
> Immer wenn die Abkürzung `tpt` verwendet wird, ist von den Knoten des Syntaxbaums, also der Metarepräsentierung für Typen, die Rede.
> Wird die Abkürung `tpe` verwendet, sind die Typen, also die Typprädikate gemeint.

#### Parser für die Typensprache

Der im Folgenden gelistete Parser erkennt die vorgestellte [Grammatik für die Stapeleffekte](#grammatik-für-die-stapeleffekte).

```consize
>> %  ==================================== parser ====================================
>> 
>> 
>> : --<parser> ( parser -- parser' ) \ < \ > --parser-wrapword ;
>> : --[[parser ( parser -- parser' )  \ [[ --parser-word-exact --spaces swap parser-append-right ;
>> : --[parser] ( parser -- parser' ) \ [ \ ] --parser-wrapword ;
>> : --(parser) ( parser -- parser' ) \ ( \ ) --parser-wrapword ;
>> : --{parser} ( parser -- parser' ) \ { \ } --parser-wrapword ;
>> 
>> : --valid-identifiers-common ( -- seq )
>>   65 90  --char-range    % A - Z
>>   97 122 --char-range    % a - z
>>   concat ;
>> 
>> : --valid-identifiers-start ( -- seq ) --valid-identifiers-common ;
>>   
>> : --valid-identifiers-rest ( -- seq )
>>   --valid-identifiers-common
>>   48 57 --char-range concat   % 0 - 9
>>   [ ! ? ' _ - + / * ] concat ;
>> 
>> : --parser-ident-fst ( -- parser ) --valid-identifiers-start --parser-oneof ;
>> : --parser-ident-rst ( -- parser ) --valid-identifiers-rest --parser-oneof ;
>> : --parser-ident ( -- parser ) --parser-ident-fst --parser-ident-rst parser-rep [ cons word ] parser-append-map ;
>> 
>> : --parser-parse-quot ( -- parser ) \ ]] --charwise-scan4-parser [ PredTpt ] parser-map ;
>> 
>> : --parser-ellipsis ( -- parser )
>>   \ ... \ .. [ --parser-word-exact --spaces ] bi@ parser-or ;
>> 
>> : --parser-list ( -- parser )
>>   [ --parser-type ] parser-lazy parser-rep
>>   --parser-ellipsis parser-opt
>>   [ empty? [ ListExTpt ] [ ListFuzzyTpt ] if ]
>>   parser-append-map ;
>> 
>> : --parser-binding ( -- parser )
>>   --parser-ident --spaces \ : --parser-word-exact --spaces parser-append-left
>>   --parser-type [ MkBinding ] parser-append-map ;
>> 
>> : --parser-dic ( -- parser )
>>   [ --parser-binding ] parser-lazy parser-rep
>>   [ [ unapply-seq ] --flatmap mapping ] parser-map
>>   --parser-ellipsis parser-opt
>>   [ empty? [ StructExTpt ] [ StructFuzzyTpt ] if ]
>>   parser-append-map ;
>> 
>> : --parser-name-type ( -- parser )
>>   --parser-ident --spaces
>>   [ --parser-type ] parser-lazy \ , --parser-word-exact --spaces
>>   parser-rep1sep --<parser> parser-opt
>>   [ --flatten dup empty?
>>     [ drop NameTpt ]
>>     [ CtorTpt ]
>>     if
>>   ] parser-append-map ;
>> 
>> : --msg-invalid-type ( -- w ) ( \ couldn't <space> \ parse <space> \ a <space> \ type ) word ;
>> 
>> : --parser-type-3 ( -- parser )
>>   ( --parser-parse-quot --spaces --[[parser
>>     --parser-list --[parser]
>>     --parser-dic  --{parser}
>>     --parser-name-type
>>     [ --parser-type ] parser-lazy --(parser)
>>     --msg-invalid-type parser-failure
>>   ) parser-choice ;
>> 
>> : --hlist-type ( seq-of-types -- tpt )
>>   reverse unpush [ swap ListConsTpt ] reduce ;
>> 
>> : --parser-type-2 ( -- parser )
>>   --parser-type-3 dup \ :: --parser-word-exact --spaces swap
>>   parser-append-right parser-rep
>>   [ dup empty?
>>     [ drop ]
>>     [ cons --hlist-type ]
>>     if  
>>   ] parser-append-map ;
>> 
>> : --parser-type-1 ( -- parser )
>>   --parser-type-2 \ & --parser-word-exact --spaces [ [ InterTpt ] ] parser-onsuccess parser-chainl1 ;
>> 
>> : --parser-type-0 ( -- parser )
>>   --parser-type-1 \ | --parser-word-exact --spaces [ [ UnionTpt ] ] parser-onsuccess parser-chainl1 ;
>> 
>> : --parser-type ( -- parser ) --parser-type-0 ;
>> 
>> 
>> : --parser-signature-binding ( -- parser )
>>   --parser-binding
>>   --parser-ident --spaces [ \ Any NameTpt MkBinding ] parser-map parser-or
>>   --charwise-scan4-parser-word [ drop \ _ \ Any NameTpt MkBinding ] parser-map parser-or ;
>> 
>> : --parser-signature ( -- parser )
>>   --parser-signature-binding
>>   parser-rep dup \ -- --parser-word-exact --spaces swap parser-append-right
>>   [ Signature ] parser-append-map ;
>> 
>> 
```

```consize
>> : --do-parse-type ( seq-of-words -- value/nil ) --parser-type --parse-words ;
>> 
```
Das Wort `--do-parse-type` stellt eine bequeme Möglichkeit dar, den Parser für Typen aufzurufen.

```consize
> ( \ Wrd ) --do-parse-type
{ adt-values [ name ] adt-ctor NameTpt adt-data { name Int } adt-type Tpt }
% Dies ist die Repräsentierung des ADT-Wertes `\ Wrd NameTpt`.
% Das Wort arbeitet somit wie gewünscht.

> ( \ Int|Wrd ) --do-parse-type
{ adt-values [ left right ] adt-ctor UnionTpt adt-data { left { adt-values [ name ] adt-ctor NameTpt adt-data { name Int } adt-type Tpt } right { adt-values [ name ] adt-ctor NameTpt adt-data { name Wrd } adt-type Tpt } } adt-type Tpt }
% Dies ist die Repräsentierung des ADT-Wertes `\ Int \ Wrd [ NameTpt ] bi@ UnionTpt`.
% Das Wort arbeitet somit wie gewünscht.
```

Im Anschluss an die Definition des Parsers wird er als Teil der öffentlichen Schnittstelle präsentiert.
Das geschieht mit dem folgenden Wort.

```consize
>> : type-repr( ( Type ')' -- type-repr )
>>   [ \ ) --literally-scan4 [ --do-parse-type push ] dip continue ] call/cc ;
>> 
>> 
```
Das Wort `type-repr(` erwartet eine Typangabe, gefolgt von einer schließenden Klammer, was die Schreibweise `type-repr( Type )` ermöglicht.
Handelt es sich bei dem Argument für `type-repr(` um eine syntaktisch valide Typangabe, liefert das Wort die Repräsentierung (also ein `tpt`).
Andernfalls liefert das Wort `nil`.

```consize
> type-repr( Int )
{ adt-values [ name ] adt-ctor NameTpt adt-data { name Int } adt-type Tpt }
% Dies ist die Repräsentierung des ADT-Wertes `\ Int NameTpt`.
% Das Wort arbeitet somit wie gewünscht.

> type-repr( Int | Wrd )
{ adt-values [ left right ] adt-ctor UnionTpt adt-data { left { adt-values [ name ] adt-ctor NameTpt adt-data { name Int } adt-type Tpt } right { adt-values [ name ] adt-ctor NameTpt adt-data { name Wrd } adt-type Tpt } } adt-type Tpt }
% Dies ist die Repräsentierung des ADT-Wertes `\ Int \ Wrd [ NameTpt ] bi@ UnionTpt`.
% Das Wort arbeitet somit wie gewünscht.

% Für weitere Beispiele siehe [Unit-Tests](https://github.com/denkspuren/consize/blob/master/contrib/typeassertions-test.txt).
```

#### Orientierungshilfe Grammatik, Parser und abstrakter Syntaxbaum

Um eine Orientierungshilfe für Grammatik, Parser und abstrakten Syntaxbaum zu geben, werden in folgender Tabelle die Elemente der Definitionen in Bezug gesetzt.

| Beschreibung                                   | Beispiel                    | Grammatikregel   | Konstruktor      | Parserkonstruktor            |
|------------------------------------------------|-----------------------------|------------------|------------------|------------------------------|
| Namen, Bezeichner                              | `Int, a+b, prime?`          | Identifier       | -                | `--parser-ident`             |
| Sprachelemente der höchsten Priorität          | -                           | SimpleType       | -                | `--parser-type-3`            |
| Inline Typenprädikate                          | `[[ drop true ]]`           | PredicateType    | `PredTpt`        | `--parser-parse-quot`        |
| Auslassungspunkte                              | `...` oder `..`             | Ellipsis         | -                | `--parser-ellipsis`          |
| Heterogene Listen: Aufzählung der Elementtypen | `[Int Bool Wrd]`            | ListType         | `ListExTpt`      | `--parser-list`              |
| Heterogene Listen: Präfix der Elementtypen     | `[Int Bool ...]`            | ListType         | `ListFuzzyTpt`   | `--parser-list`              |
| Strukturelle Maps: Aufzählung der Elementtypen | `{ x: Int y: Wrd }`         | DictionaryType   | `StructExTpt`    | `--parser-dic`               |
| Strukturelle Maps: Teilmenge der Elementtypen  | `{ x: Int .. }`             | DictionaryType   | `StructFuzzyTpt` | `--parser-dic`               |
| Nominelle Typen                                | `Int`, `Wrd`, `Bool`        | NamedType        | `NameTpt`        | `--parser-name-type`         |
| Parametrisierte Typen                          | `Stk<Int>`, `Map<Wrd,Int>`  | NamedType        | `CtorTpt`        | `--parser-name-type`         |
| Namensbindung eines Typen                      | `x: Int`                    | Binding          | `MkBinding`      | `--parser-binding`           |
| Heterogene Listen: Mit `::`-Operator           | `Int :: HNil`               | HlistType        | `ListConsTpt`    | `--parser-type-2`            |
| Schnittmengentypen                             | `Wrd & Int`                 | IntersectionType | `InterTpt`       | `--parser-type-1`            |
| Vereinigungsmengentypen                        | <code>Wrd &#124; Int</code> | UnionType        | `UnionTpt`       | `--parser-type-0`            |
| Gesamtparser für Typenbeschreibungen           | -                           | Type             | -                | `--parser-type`              |
| Beschreibung der Stapeleffekten                | `x: Int y: Int -- x+y: Int` | Signature        | `Signature`      | `--parser-signature`         |
| Erweiterte Bindings für Stapeleffekte          | `x: Int`, `a`, `( x & xs )` | Binding+         | -                | `--parser-signature-binding` |

### Einige Typen und Typkonstruktoren

```consize
>> % ======================= types and their representations ========================
>> 
>> 
>> % Types are just predicates.
>> 
```

In diesem Abschnitt sollen einige benannte Typen, wie sie im Kapitel [Anforderungsanalyse](#anforderungsanalyse) besprochen wurden, eingeführt werden.

```consize
>> : Any ( -- tpe ) [ drop true ] ;
>> : Nothing ( -- tpe ) [ drop false ] ;
>> 
```
Die Wörter `Any` und `Nothing` führen den allgemeinsten und den spezifischsten Typ ein.

| Wort    | abstrakte Beschreibung | wertbezogene Beschreibung         |
|---------|------------------------|-----------------------------------|
| Any     | allgemeinster Typ      | Alle Werte gehören zum Typ Any.   |
| Nothing | speziellster Typ       | Kein Wert gehört zum Typ Nothing. |

```consize
>> : --native-type ( typeName -- type ) [ type ] swap [ equal? ] curry concat ;
>> 
>> : Wrd ( -- tpe ) \ wrd --native-type ;
>> : Fkt ( -- tpe ) \ fct --native-type ;
>> : Null ( -- tpe ) \ nil --native-type ;
>> : StkTpe ( -- tpe ) \ stk --native-type ;
>> : MapTpe ( -- tpe ) \ map --native-type ;
>> 
```
Die Wörter `Wrd`, `Fkt`, `Null`, `StkTpe` und `MapTpe` definieren die gleichnamigen Typen.
Bei der Ausführung liefern sie Prädikate, welche mithilfe des eingebauten Wortes `type` Werte auf ihren Typ prüfen.

Anmerkungen:
- Das Wort, welches auf den Typ `nil` prüft, wurde `Null` anstatt `Nil` genannt, damit ein algebraischer Datentyp `data List = Cons hd tl | Nil` definiert werden kann. Der auf diese Weise eingeführte Konstruktor `Nil` und das gleichnamige Typwort würden umeinander konkurrieren: Die spätere Definition würde die frühere überschreiben.
- Die Namen `Stk` und `Map` werden an dieser Stelle nicht verwendet, da diese für die Typkonstruktoren reserviert sind. Stattdessen werden die Wörter `StkTpe` und `MapTpe` genannt, die auf die jeweiligen Kollektionen prüfen.

```consize
>> % Type constructors however are just words that take in the
>> % type-representations (predicates) for their type parameters
>> % and return concrete predicates.
>> 
```

```consize
>> : Id ( elemtpe -- tpe ) ;
>>
```
Das Wort `Id` führt den Identitätstypkonstruktor ein.
Er gibt sein Typargument zurück.
Es gilt also `T = Id<T>` für einen beliebigen Typen `T`.

```consize
>> : Stk ( elemtpe -- tpe )
>>   StkTpe swap [ all? ] curry --pred-and ;
>> 
```
Das Wort `Stk` führt den gleichnamigen Typkonstruktor für Sequenzen ein.
Nachdem das von diesem Wort erstellte Prädikat überprüft hat, dass es sich um eine Liste handelt wird das Prädikat `elemtpe` auf alle Listenelemente angewandt.
Nur wenn das Prädikat alle Listenelemente akzeptiert, hat die betrachtete Liste diesen Typ.

```consize
>> : Map ( key-tpe value-tpe -- tpe )
>>   [ [ values ] [ Stk ] bi* call ] curry swap
>>   [ [ keys ] [ Stk ] bi* call ] curry swap
>>   --pred-and MapTpe swap --pred-and ;
>> 
```
`Map` führt den Typkonstruktor für Wörterbücher ein.
Wird dieser auf seine Typargumente angewandt, liefert er ein Prädikat, welches prüft, ob der betrachtete Wert ein Wörterbuch ist und dann die Schlüssel-Wert-Paare unter Zuhilfenahme der jeweiligen Prädikate validiert.

```consize
>> : Option ( value-tpe -- tpe )
>>   [ swap
>>     [ Option / None [ drop true   ]
>>       Option / Some [ swap call   ]
>>       :else         [ 2drop false ]
>>     ] adtmatch
>>   ] curry ;
>> 
>> : List ( elemtpe -- tpe )
>>   [ swap
>>     [ List / Nil  [ drop true ]
>>       List / Cons [ swapd over --2swap call
>>                     [ List call   ]
>>                     [ 2drop false ]
>>                     if
>>                   ]
>>       :else       [ 2drop false ]
>>     ] adtmatch
>>   ] curry ;
>> 
```
Die Wörter `Option` und `List` definieren Typkonstruktoren für gleichnamige algebraische Datentypen. Sie funktionieren analog zu `Stk` und `Map`.

```consize
>> : HNil ( -- tpe )
>>   StkTpe [ empty? ] --pred-and ;
>>
```
Das Wort `HNil` (Kurzversion von "heterogenous Nil") beschreibt den Typ der leeren, heterogenen Liste.
Das von diesem Wort gelieferte Prädikat validiert, dass der betrachtete Wert eine leere Sequenz ist.

Die in diesem Kapitel eingeführten Typen lassen sich nicht nur in Stapeleffekten, sondern auch manuell verwenden.
Das soll im Folgenden zur Schau gestellt werden.
```consize
> \ hello Nothing call
f

> \ hello Wrd call
t

> \ hello Any call
f

> 5 Fkt call
f

> ( 1 2 3 ) Wrd Stk call
t

> ( 1 2 3 ) Fkt Stk call
f
```

### Materialisierung von Prädikaten von Typen

```consize
>> % ============================ generating predicates =============================
>> 
>> 
```

Nachdem die Beschreibungssprache für Typen definiert und einige Typen eingeführt wurden, gilt es als nächstes Prädikate für alle Typen in dem Stapeleffekt einer Definition zu generieren.
Diese Aufgabe übernimmt das Wort `--type-predicate`, welches seinerseits die folgenden Hilfswörter benötigt:

```consize
>> : --quotation-named-tpt ( name -- tpe )
>>   [ lookup call dup Tpt? [ --type-predicate ] when call ] curry ;
>> 
```
Das Wort `--quotation-named-tpt` liefert ein Prädikat, welches, wenn es evaluiert wird, unter dem Namen im Wörterbuch das assoziierte Prädikat nachschlägt und folgend auf den betrachteten Wert anwendet.
Diese bedarfsgetriebene Evaluierung ist für rekursive Typen, die in Kapitel [Typenkombinatoren und weitere Typen](#typenkombinatoren-und-weitere-typen) eingeführt werden, notwendig.

```consize
> \ hello \ Wrd --quotation-named-tpt call
t

> 42 \ Nothing --quotation-named-tpt call
f
```

```consize
>> : --quotation-param-tpt ( ctor args -- tpe )
>>   [ --type-predicate ] map swap
>>   [ unstack ] dip lookup call ;
>> 
```
Das Wort `--quotation-param-tpt` konstruiert ein Prädikat, welches die Definition des Wortes mit dem Namen gegeben durch `ctor` nachschlägt, die Typprädikate für die Typargumente durch einen rekursiven Aufruf von `--type-predicate` erstellt und anschließend die nachgeschlagene Definition mit diesen Typargumenten aufruft.

```consize
> ( \ test ) \ Stk \ Wrd NameTpt --stack --quotation-param-tpt call
t
```

```consize
>> : --quotation-keys-structural-tpe ( map strict -- quot )
>>   % `strict`: if true: all keys must match,
>>   %           if false: a subset of the keys must match
>>   [ [ [ keys --set ] bi@ ] dip
>>     [ equal? ]
>>     [ [ keys ] bi@ --contains-all ]
>>     if
>>   ] 2curry ;
>> 
>> : --quotation-values-structural-tpe ( map -- quot )
>>   [ dup keys -rot
>>     [ rot
>>       [ swap nil get ] curry
>>       bi@ call
>>     ] 2curry
>>     all?
>>   ] curry ;
>> 
>> : --quotation-map-structural-tpt ( map strict -- tpe )
>>   [ [ --type-predicate ] --map-values ] dip
>>   dupd --quotation-keys-structural-tpe swap
>>   --quotation-values-structural-tpe --pred-and
>>   MapTpe swap --pred-and ;
>> 
```
Das Wort `--quotation-map-structural-tpt` konstruiert ein Prädikat, welches strukturelle Wörterbuchtypen validiert.
Das Prädikat wird aus drei einzelnen zusammengesetzt:
1. Ein Prädikat (`MapTpe`) prüft, ob der betrachtete Wert ein Wörterbuch ist.
2. Ein zweites Prädikat (erstellt mit `--quotation-keys-structural-tpe`) validiert die Schlüssel. Je nach Modus wird eine Teilmenge (`StructFuzzyTpt`) oder die Gesamtmenge (`StructExTpt`) der Schlüssel mit denen vom Benutzer angegebenen verglichen.
3. Ein drittes Prädikat (erstellt mit `--quotation-values-structural-tpe`) prüft für jeden Wert, ob dieser dem angegeben Typ entspricht.

```consize
> { \ x \ test } { \ x \ Wrd NameTpt } true --quotation-map-structural-tpt call
t

> { \ x \ test \ y \ test2 } { \ x \ Wrd NameTpt } false --quotation-map-structural-tpt call
t
```

```consize
>> : --verify-listed-hlist-tpe ( values tpes strict -- t/f )
>>   -rot swap dup empty?
>>   [ drop swap drop empty? ]
>>   [ swap dup empty?
>>     [ 2drop not ]
>>     [ [ unpush ] dip
>>       uncons [ call ] dip swap
>>       [ rot --verify-listed-hlist-tpe ]
>>       [ 3drop false ]
>>       if
>>     ]
>>     if
>>   ]
>>   if ;
>> 
>> : --quotation-listed-hlist-tpe ( tpes strict -- quot )
>>   StkTpe -rot [ --verify-listed-hlist-tpe ] 2curry --pred-and ;
>> 
>> : --quotation-listed-hlist-tpt ( tpes strict -- quot )
>>   [ [ --type-predicate ] map ] dip --quotation-listed-hlist-tpe ;
>> 
```
Das Wort `--quotation-listed-hlist-tpt` generiert ein Prädikat, welches aufgezählte, heterogene Listen validiert.
Je nach Modus, werden alle Listenelemente (`ListExTpt`) oder nur der Präfix der Liste (`ListFuzzyTpt`) auf die jeweils angegebenen Typen geprüft.
Das Prädikat wird aus zwei anderen zusammengesetzt:
- `StkTpe` stellt fest, ob es sich bei dem betrachteten Wert um eine Sequenz handelt und
- das zweite Prädikat validiert die Listenelemente mit dem rekursiven Hilfswort `--verify-listed-hlist-tpe`.

```consize
> ( \ hello ) ( \ Wrd NameTpt ) true --quotation-listed-hlist-tpt call
t

> ( \ hello \ world ) ( \ Wrd NameTpt ) true --quotation-listed-hlist-tpt call
f

> ( \ hello \ world ) ( \ Wrd NameTpt ) false --quotation-listed-hlist-tpt call
t
```

```consize
>> : --quotation-cons-hlist-tpe ( hdtpe tltpe -- quot )
>>   StkTpe [ empty? not ] --pred-and -rot
>>   [ -rot [ unpush ] dip call
>>     [ swap call   ]
>>     [ 2drop false ]
>>     if
>>   ] 2curry --pred-and ;
>> 
>> : --quotation-cons-hlist-tpt ( hdtpt tltpt -- quot )
>>   [ --type-predicate ] bi@ --quotation-cons-hlist-tpe ;
>> 
```
Das Wort `--quotation-cons-hlist-tpt` erstellt Prädikate, die die mit dem `::`-Operator erzeugte Typen von heterogenen Listen validieren.
Diese werden jeweils aus dem Prädikat zur Listenerkennung (`StkTpe`) dem Prädikat zur Überprüfung, dass die Liste nicht leer ist und dem Prädikat, welches den Kopf und den Rest der Liste validiert, zusammengesetzt.

```consize
> ( \ hello \ world ) \ Wrd \ Wrd \ HNil [ NameTpt ] tri@ ListConsTpt --quotation-cons-hlist-tpt call
t

> ( \ hello ) \ Wrd \ Wrd \ HNil [ NameTpt ] tri@ ListConsTpt --quotation-cons-hlist-tpt call
f
```

```consize
>> : --type-predicate ( tpt -- tpe )
>>   [ NameTpt         [ --quotation-named-tpt ]
>>     CtorTpt         [ --quotation-param-tpt ]
>>     PredTpt         [ ]
>>     InterTpt        [ [ --type-predicate ] bi@ --pred-and ]
>>     UnionTpt        [ [ --type-predicate ] bi@ --pred-or  ]
>>     StructExTpt     [ true  --quotation-map-structural-tpt ]
>>     StructFuzzyTpt  [ false --quotation-map-structural-tpt ]
>>     ListExTpt       [ true  --quotation-listed-hlist-tpt ]
>>     ListFuzzyTpt    [ false --quotation-listed-hlist-tpt ]
>>     ListConsTpt     [ --quotation-cons-hlist-tpt ]
>>   ] adtmatch ;
>> 
```
Das Wort `--type-predicate` konstruiert Typenprädikate für alle Typrepräsentierungen.
- Im Fall eines `PredTpt` wird schlichtweg das geparste Prädikat übernommen.
- Bei `InterTpt` und `UnionTpt` werden die Prädikate der zugrundeliegenden Typen konstruiert und mit dem entsprechenden Operator (`--pred-and` und `--pred-or`) kombiniert.
- Die Prädikatenerstellung in allen anderen Fällen wird an die jeweiligen, vorher eingeführten Hilfswörter delegiert.

```consize
> 5 \ Wrd \ Any [ NameTpt ] bi@ UnionTpt --type-predicate call
t

> 5 \ Wrd \ Any [ NameTpt ] bi@ InterTpt --type-predicate call
t

> 5 \ Nothing \ Any [ NameTpt ] bi@ UnionTpt --type-predicate call
t

> 5 \ Nothing \ Any [ NameTpt ] bi@ InterTpt --type-predicate call
f

> ( 42 ) [ ( 42 ) equal? ] PredTpt  --type-predicate call
t

> ( 42 ) [ drop false ] PredTpt  --type-predicate call
f

% Für Nutzungsbeispiele für alle anderen Typarten siehe entsprechendes Hilfswort.
```

```consize
>> : --do-materialize-pred ( seq-of-words -- pred/nil )
>>   --do-parse-type dup nil equal?
>>   [ drop nil ]
>>   [ --type-predicate ]
>>   if ;
>> 
```
Das Wort `--do-materialize-pred` stellt eine bequeme Möglichkeit dar, den Parser der Typensprache und die Materialisierung der Typenprädikate anzustoßen.

```consize
> ( \ Wrd ) --do-materialize-pred
<Prädikat für `Wrd` ausgelassen>

> ( \ Wrd|Stk<Wrd> ) --do-materialize-pred
<Prädikat für `Wrd | Stk<Wrd>` ausgelassen>
```

Im Anschluss an die Definition der Materialisierung von Typenprädikaten wird sie als Teil der öffentlichen Schnittstelle präsentiert.
Dies geschieht mit dem folgenden Wort.

```consize
>> : type-pred( ( Type ')' -- pred )
>>   [ \ ) --literally-scan4 [ --do-materialize-pred push ] dip continue ] call/cc ;
>> 
```
Das Wort `type-pred(` erwartet eine Typangabe, gefolgt von einer schließenden Klammer, was die Schreibweise `type-pred( Type )` ermöglicht.
Dieses Wort liefert das Typprädikat für den gegeben Typen oder `nil`, falls der Typ syntaktisch nicht korrekt ist.

```consize
> type-pred( Wrd )
<Prädikat für `Wrd` weggelassen>

> type-pred( Wrd | Stk<Wrd> )
<Prädikat für `Wrd | Stk<Wrd>` weggelassen>
```

### Typenkombinatoren und weitere Typen

Nachdem nun in Kapitel [Einige Typen und Typkonstruktoren](#einige-typen-und-typkonstruktoren) Basistypen eingeführt wurden, folgen Typkombinatoren und weitere Typen.

```consize
>> % =============================== type combinators ===============================
>> 
>> 
```

```consize
>> : --enum ( seq -- tpe )
>>   --set [ nil get nil equal? not ] curry ;
>> 
```
Das Wort `--enum` ist ein Hilfswort zur Erschaffung von Enumerationstypen.
Es generiert ein Prädikat, welches prüft, ob der betrachtete Wert in der Sequenz `seq` vorkommt.

```consize
>> : Bool ( -- tpe ) ( false true ) --enum ;
>> : DecDigit ( -- tpe ) 48 57 --char-range --enum ;
>> : BinDigit ( -- tpe ) ( 0 1 ) --enum ;
>> : HexDigit ( -- tpe ) --hex-lookup keys --enum ;
>> 
```
Mit dem Wort `--enum` lassen sich beispielsweise die Enumerationstypen `Bool`, `DecDigit`, `BinDigit`, `HexDigit` einführen.

Typen für Assoziationslisten von Wörterbüchern lassen sich induktiv mithilfe der heterogenen Listen beschreiben.
Dabei beschreiben jeweils zwei aufeinanderfolgende Typen ein Schlüssel-Wert-Paar des Wörterbuches.
Eine Assoziationsliste ist entweder leer, oder hat ein Schlüssel-Wert-Paar und eine Restliste.

Für Eigenschaften dieser Art werden die folgenden Hilfswörter eingeführt, mit denen es bequem möglich ist heterogene Listentypen zu erstellen.

```consize
>> : --recurring-hcons-type ( [tpes] tltpe -- tpe )
>>   [ [ PredTpt ] map ] [ PredTpt ] bi*
>>   [ reverse ] dip [ swap ListConsTpt ] reduce
>>   --type-predicate ;
>> 
>> : --recurring-each ( ..tpes tltpe k -- tpe )
>>   [ --take-datastack ] curry dip --recurring-hcons-type ;
>> 
>> : Each ( atpe tltpe -- tpe ) 1 --recurring-each ;
>> : Twice ( atpe btpe tltpe -- tpe ) 2 --recurring-each ;
>> : Thrice ( atpe btpe ctpe tltpe -- tpe ) 3 --recurring-each ;
>> 
```
Die Wörter `Each`, `Twice`, `Thrice` und deren Generalisierung `k --recurring-each` erwarten `1 + 1`, `2 + 1`, `3 + 1` und `k + 1` Typprädikate auf dem Datenstapel.
Sei <code>P<sub>i</sub></code> das `i`-te Prädikat.
Aus den Prädikaten wird das Prädikat der heterogenen Liste <code>P<sub>1</sub> :: ... :: P<sub>k</sub> :: P<sub>k + 1</sub></code> erstellt.

Gäbe es nun zusätzlich die Möglichkeit, dass sich ein Typ auf sich selbst beziehen kann, würde das die Nutzung von rekursiven Typen eröffnen.
Damit wäre es also möglich den Typ einer Assoziationsliste zu formulieren.
Dies kann erreicht werden indem die Definition von Typenalias möglich gemacht wird.

Die Einführung von Typenalias bringt allerdings noch einen weiteren Nutzen:
Alias ermöglichen die Definition von Typen mithilfe der eingeführten Typenbeschreibungssprache.
Damit könnte man die Beschreibungssprache und den Parser dafür wiederverwenden.

Typenalias werden im Folgenden eingeführt.

```consize
>> : --parser-typedef ( -- parser )
>>   --parser-ident \ = parser-item [ --spaces ] bi@ parser-append-left
>>   [ --parser-type ] parser-lazy [ MkBinding ] parser-append-map ;
>> 
>> : --do-handle-typedef ( raw -- )
>>   --parser-typedef --parse-words dup nil equal?
>>   [ drop ]
>>   [ unapply --type-predicate [ ] curry def ]
>>   if ;
>> 
>> : typedef ( Identifier '=' Type ';' -- )
>>   [ \ ; --literally-scan4 [ --do-handle-typedef ] dip continue ] call/cc ;
>> 
```
Das Wort `typedef` ermöglicht die Definition von Typalias.
Es erwartet auf dem Programmstapel die Definition des Alias in der Form `Identifier , '=' , Type , ';'`.
Der Parser, der von `--parser-typedef` konstruiert wird, erkennt diese Definition.
Im Falle eines erfolgreichen Parseversuchs wird ein Typwort definiert, welches das durch den Typen beschriebene Prädikat liefert.

Mithilfe des Schlüsselworts `typedef` werden nun die folgenden Typen definiert.

```consize
>> typedef Int = Wrd & [[ integer? ]] ;
>> typedef Nel = [ Any .. ] ;
>> typedef WordStack = Nel & Stk<Wrd> ;
>> typedef AdtValue = {..} & [[ --is-adt-instance? ]] ;
>> 
>> 
```
Anmerkung:
`Nel` ist die englische Abkürzung von nichtleerer Liste (non-empty list).

Nun ist es möglich selbstbezogene Typen mit wiederholenden Eigenschaften zu definieren.
Das wird am bereits beschriebenen Beispiel "Assoziationsliste von Wörterbüchern" in zwei Variationen im Folgenden getan:
```consize
> typedef Translations1 = HNil | Wrd :: Wrd :: Translations1 ;
> typedef Translations2 = HNil | Twice<Wrd, Wrd, Translations2> ;
```

### Durchsetzen von Vor- und Nachbedingungen

Bis zu dieser Stelle kann das vorgestellte Programm Typen parsen und daraus Prädikate generieren.
Diese sollen nun in diesem Kapitel dazu eingesetzt werden die Typüberprüfungen für Worte zu implementieren.

```consize
>> % ========================== establishing preconditions ==========================
>> 
>> 
```

Schlägt die Typüberprüfung fehl, werden die Fehler `precondition-error` oder `postcondition-error` geworfen, je nachdem gegen welche der Bedingungen (Vor- oder Nachbedingung) verstoßen wurde.
Zusätzlich wird noch der Name des Wortes und der Bezeichner des Parameters angegeben.

```consize
>> : precondition-error ( wrd bindingname -- )
>>   [ \ precondition-error printer repl ] 2curry call/cc ;
>> 
>> : postcondition-error ( wrd bindingname -- )
>>   [ \ postcondition-error printer repl ] 2curry call/cc ;
>> 
```

```consize
>> : --establish-*conditions ( wrd errquot args-bindings -- )
>>   dup empty?
>>   [ 3drop ]
>>   [ unpush unstack unapply swapd --type-predicate call
>>     [ drop --establish-*conditions ]
>>     [ [ drop ] dip swap call ]
>>     if
>>   ]
>>   if ;
>> 
>> : --generate-*conditions ( wrd bindings errquot -- quot )
>>   [ swap dup size [ --take-datastack ] curry
>>     [ 3 --take-datastack ] dip dip
>>     [ dup [ unstack ] dip ] dip unstack [ rot ] dip zip
>>     --establish-*conditions
>>   ] 3curry ;
>> 
>> : --establish-preconditions-and-postconditions ( wrd body signature -- wrd body' )
>>   [ [ dup ] dip swap ] dip unapply [ over dup ] dip
>>   [ postcondition-error ] --generate-*conditions
>>   [ \ .postconditions --glue dup ] dip def
>>   -rot dupd
>>   [ precondition-error ] --generate-*conditions
>>   [ \ .preconditions --glue dup ] dip def
>>   [ --stack ] bi@
>>   rot concat swap concat ;
>> 
>> 
```
Das Wort `--establish-preconditions-and-postconditions` ist für die Absicherung eines Wortes zuständig.
Wird es mit dem Namen des Wortes (`wrd`), seiner (ungesicherten) Implementierung (`body`) und den Stapeleffekten (`signature`; Werte des Datentyp `StackEffect`) aufgerufen, liefert es eine geänderte Implementierung zurück, die eine Typüberprüfung durchführt.
Das Umschreiben des Programms folgt immer dem selben Muster: Die Definition des Wortes `<name>` mit der Implementierung `[ #words ]` wird zu dem Programm `[ <name>.preconditions #words <name>.postconditions ]` umgeschrieben.
Neben dem Umschreiben des Programms werden ebenfalls die Wörter `<name>.preconditions` und `<name>.postconditions` definiert, die den Überprüfungsalgorithmus der Argument- und Rückgabewerte realisieren.
Die Implementierungen dieser Wörter werden von `--generate-*conditions` generiert.
Im Wesentlichen sammelt das von `--generate-*conditions` bereitgestellte Programm für jedes Name-Wert-Paar aus den Stapeleffekten einen Wert vom Datenstapel auf und überprüft jeweils ob der Typ zu dem entsprechenden Datum passt.
Das paarweise Überprüfen wird dabei vom Hilfswort `--establish-*conditions` realisiert.

```consize
> \ plus [ + ]                                                   % name and implementation of a word
> ( \ x \ Int NameTpt MkBinding \ x \ Int NameTpt MkBinding )    % representation of parameters
> ( \ res \ Int NameTpt MkBinding ) Signature                    % representation of return values
> --establish-preconditions-and-postconditions
plus [ plus.preconditions + plus.postconditions ]

% Es wurden die Worte `plus.preconditions` und `plus.postconditions` definiert

> \ plus.preconditions \ plus.postconditions [ lookup nil equal? not ] bi@
t t
```

### Ändern des Wortdefinitionsprozesses

Nun sind fast alle Ziele der Problem- und Aufgabenstellung (vgl. [Problem](#problem) und [Aufgabe](#aufgabe)) erreicht:
- Das Programm kann Stapeleffekte parsen und die Prädikate erzeugen.
- Programme können umgeschrieben werden, sodass die Argumenttypen dieser validiert werden.

Damit nun Wörter mit Typangaben abgesichert werden, ist die Änderung des Wortdefinitionsprozesses notwendig.

```consize
>> % =========================== hook for type assertions ===========================
>> 
>> 
```

Die Überschreibbarkeit von Wortdefinition ermöglicht ein einfaches Ändern von Wortsemantiken und damit auch des Wortdefinitionsprozesses.
Der letzte Zeitpunkt, des in der Prelude implementierten Definitionsprozess, bei dem die Informationen über Stapeleffekte noch bekannt sind, ist die Implementierung des Wortes `def+`.
Dieses verwirft die Stapeleffekte und delegiert die Wortdefinition an das Wort `def`.
Um das Ignorieren der Stapeleffekte zu verhindern, wird im Folgenden das Wort `def+` überschrieben und zu Gunsten der Typüberprüfung abgeändert.
Das Wort `--handle-stackeffect` ist hierfür für das Parsen und den Aufruf von `--establish-preconditions-and-postconditions` zuständig.

```consize
>> : --handle-stackeffect ( name body eff -- name body' )
>>   --parser-signature --parse-words dup nil equal?
>>   [ drop ]
>>   [ --establish-preconditions-and-postconditions ]
>>   if ;
>> 
>> : def+ ( wrd [ effect ] [ body ] -- )
>>   swap --handle-stackeffect def ;
>> 
>> 
```

Durch das Überschreiben von `def+` nehmen alle folgenden Wortdefinition den Weg über das Wort `--handle-stackeffect`, dass sich um die Typüberprüfungen kümmert.
Das Überschreiben schließt das hier vorgestellte Programm ab.

Das folgende Beispiel zeigt die Wortdefinition eines Wortes `plus` mit Typenangaben.
Bei dessen Aufrufe werden nun die Typen der Argumente mit den erwarteten Typen verglichen und beim Abweichen wird einen Fehler angezeigt.
Zur Veranschaulichung wird das Wort einmal mit Werten des erwarteten und zweimal mit Werten von unerwarteten Typen aufgerufen.

```consize
> : plus ( x:Int y:Int -- x+y:Int ) + ;

> 1 2 plus
3

> 1 \ test plus
[ test 1 ] [ + plus.postconditions printer repl ] plus y precondition-error

> \ test 2 plus
[ 2 test ] [ + plus.postconditions printer repl ] plus x precondition-error
```

Ebenfalls zur Veranschaulichung folgt ein Beispiel, bei dem gegen die definierten (und offensichtlich falsch formulierten) Typen der Rückgabewerte verstoßen wird.

```consize
> : incorrect-plus ( x:Int y:Int -- x+y:Stk<Int> ) + ;

> 1 2 incorrect-plus
[ 3 ] [ printer repl ] incorrect-plus x+y postcondition-error
```

## Aussicht

### Überladen von Wortdefinitionen

Die mit diesem Dokument eingeführte Typprüfung von Argumenten ist bereits an sich nützlich.

Zusätzlich bringen die Typangaben auch die Möglichkeit zur Überladung von Wörtern mit.
Die Grundidee hiervon ist, dass beim Aufrufen eines Wortes, abhängig vom Typ seiner Argumente, die am "besten passendste" Implementierung ausgewählt und die Argumente an diese delegiert wird.

Für die Auswahl der passendsten Implementierung müssen alle Überladungen bekannt sein und es muss definiert sein, wann eine Überladung "besser" geeignet ist als eine andere.

Angenommen man will das Wort `repr` überladen, sodass dieses Sequenzen von Binärzahlen als einziges Wort anstatt als Stapel serialisiert, so könnte die Überladung dafür wie folgt aussehen:
```consize
overload repr ( v:Stk<BinDigit> -- w ) word ;
```

Das Schlüsselwort `overload` könnte in diesem Fall die Implementierung von `repr` dahingehend ändern, dass zu Beginn eines Aufrufs eine Selektion die gewünschte Implementierung auf Grundlage des Argumenttyps auswählt.

Ein sinnvolles Maß dafür, wann ein Wort passender ist als ein anderes, ist die Spezifität der Argumenttypen.
Spezifitäten könnten die Benutzer über Relationen, ähnlich wie in Kapitel [Typinferenz zur Laufzeit](#typinferenz-zur-laufzeit) beschrieben, für jeden Typen selbst definieren.
Im Fall, dass mehrere Implementierungen zutreffen, würde dann ein Laufzeitfehler auftreten.

Das Überladen von Wörtern könnte auch die Fehlersuche in consize-Programmen positiv beeinflussen.
Rückblickend hätte das Feature besonders bei der Entwicklung oder Verwendung von Parsern geholfen:
Ein Überladen des Wortes `repr` hätte das Anzeigen von Parsern auf der Repl auf abstraktem Level möglich gemacht, anstatt diese als Quotierung anzuzeigen.
Eine abstrakte Darstellung hätte einen tieferen Einblick in den Aufbau des Parsers gegeben, als es die Quotierung ermöglicht.

Der Parser `42 parser-item \ | parser-item parser-repsep` hätte damit als `repsep(item(42),item(|))` anstatt `[ \ [ \ [ \ [ \ 42 swap dup empty? [ [ --x-expected-but-empty ] dip parse-result-failure ] [ dup top rot dup rot equal? [ swap pop parse-result-success ] [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ] if ] if ] \ [ \ [ \ [ \ [ \ [ \ | swap dup empty? [ [ --x-expected-but-empty ] dip parse-result-failure ] [ dup top rot dup rot equal? [ swap pop parse-result-success ] [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ] if ] if ] \ [ \ 42 swap dup empty? [ [ --x-expected-but-empty ] dip parse-result-failure ] [ dup top rot dup rot equal? [ swap pop parse-result-success ] [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ] if ] if ] -rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input -rot --stack swap push swap parse-result-success ] if-not ] if-not ] \ [ unstack swap drop ] swap rot parser-run swap get-dict func swap dup \ status swap --getn \ success equal? [ swap drop ] [ dup \ value swap --getn --stack rot apply unstack \ value rot assoc ] if-not ] \ [ \ [ \ [ \ | swap dup empty? [ [ --x-expected-but-empty ] dip parse-result-failure ] [ dup top rot dup rot equal? [ swap pop parse-result-success ] [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ] if ] if ] \ [ \ 42 swap dup empty? [ [ --x-expected-but-empty ] dip parse-result-failure ] [ dup top rot dup rot equal? [ swap pop parse-result-success ] [ swap dup top rot swap --x-expected-but-y swap parse-result-failure ] if ] if ] -rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input -rot --stack swap push swap parse-result-success ] if-not ] if-not ] \ [ unstack swap drop ] swap rot parser-run swap get-dict func swap dup \ status swap --getn \ success equal? [ swap drop ] [ dup \ value swap --getn --stack rot apply unstack \ value rot assoc ] if-not ] [ parser-no-epsilon ] bi@ -rot swap parser-run dup \ status swap --getn \ success equal? [ dup \ input swap --getn swap \ value swap --getn --stack --parser-rep1-with-first-rec ] [ swap drop ] if ] \ [ [ ] swap parse-result-success ] -rot [ dup ] dip swap parser-run dup \ status swap --getn dup \ success equal? swap \ error equal? or [ [ drop drop ] dip ] [ drop parser-run ] if ] -rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input rot swap parser-run dup \ status swap --getn \ success equal? [ swap drop ] [ --parse-result-success-value-input -rot --stack swap push swap parse-result-success ] if-not ] if-not ] \ [ unstack swap push ] swap rot parser-run swap get-dict func swap dup \ status swap --getn \ success equal? [ swap drop ] [ dup \ value swap --getn --stack rot apply unstack \ value rot assoc ] if-not ] \ [ [ ] swap parse-result-success ] -rot [ dup ] dip swap parser-run dup \ status swap --getn dup \ success equal? swap \ error equal? or [ [ drop drop ] dip ] [ drop parser-run ] if ]` angezeigt werden können.

Damit man Parser-Werte (Quotierungen) allerdings unterscheiden kann, müssten die Werte etwa mit der Hilfe von Wörterbüchern markiert, oder die Kurzrepräsentierung zusammen mit den Parser-Quotierungen konstruiert werden.

### Optimierungen

Die Typenprüfung zur Laufzeit, wie sie auch in diesem Dokument vorgestellt wird, bringt einen Laufzeitmehraufwand mit sich.
Um diesem Mehraufwand entgegenzutreten bieten sich unterschiedliche Optimierungen an.

Beispielsweise könnte die [partielle Interpretation](https://github.com/denkspuren/consize/blob/master/research/PartialInterpretation.Topic.md) einen Geschwindigkeitsvorteil bringen, indem die generierten Wörter `<name>.preconditions` und `<name>.postconditions` partiell evaluiert und damit optimiert werden.

Darüber hinaus könnte auch eine Spezialisierung einer Aufrufkette ebenfalls einen Vorteil bringen:
Die Typüberprüfungen könnten in diesem Fall an den Anfang der Berechnung verlagert, und alle zwischenzeitigen Überprüfungen eliminiert werden.
Besonders für typsichere Worte, die andere typgesicherte Worte rufen, würde die Spezialisierungen einen Vorteil bringen, denn einmal überprüft müssen die Argumente bei gleichbleibender Typrestriktion nicht mehrfach überprüft werden.

Im Folgenden wird beispielhaft die Definition der Fakultätsfunktion betrachtet.
Bei jedem ihrer Aufrufe (auch bei den rekursiven) wird eine Typprüfung durchgeführt (siehe Beispiel).
Spezialisiert man nun die Aufrufkette des Wortes `!`, wie weiter oben beschrieben, erreicht man, dass die Typprüfung nur ein einziges Mal ausgeführt wird.
```consize
> typedef LogAny = [[ \ ! --glue println true ]] ;   % fake type, that logs values

> : ! ( n: Int & LogAny -- n! ) dup 0 == [ drop 1 ] [ dup 1 - ! * ] if ;

% output without specialisation
> 5 !
5!
4!
3!
2!
1!
0!
120

% output if we had specialisation
> 5 !
5!
120
```

### Weiterentwicklungen

Die Implementierung des in diesem Dokument vorgestellten Programm lässt sich in vielerlei Hinsicht erweitern:
Beispielsweise wäre die Definition von Typalias durch Typparameter erweiterbar.
Damit würde die folgende Definition möglich werden:
```consize
typedef Boxed<$T> = { value: $T } ;
```
In diesem Fall würde dann ein Wort `Boxed` generiert werden, was das Verhalten eines Typkonstruktors realisiert.
Es müsste also eine Quotierung generiert werden, die das Prädikat für das Typargument `$T` an die spezifizierte Stelle im Syntaxbaum schreibt und das dadurch entstehende Prädikat liefert.

