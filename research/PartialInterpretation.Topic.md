# Compiler-Optimierung durch partielle Interpretation umgesetzt für die konkatenative Sprache Consize

**Ausschreibung einer Master-Thesis in der Informatik**

Betreuer: Prof. Dr. Dominikus Herzberg, THM

> Dieses Thema ist offen zur Bearbeitung. Melden Sie sich bei mir, wenn Sie Interesse haben. Das Thema ist primär geeignet für Master-Studierende der Informatik, die sich tiefergehend mit funktionaler Programmierung auseinandersetzen möchten. -- Dominikus Herzberg

<!-- TOC depthFrom:2 -->

- [Hintergrund](#hintergrund)
- [Problemstellung](#problemstellung)
- [Aufgabe](#aufgabe)
    - [Einstieg: Automatisierte Ableitung von `swap`](#einstieg-automatisierte-ableitung-von-swap)
    - [Deforestation am Beispiel der Fakultätsberechnung](#deforestation-am-beispiel-der-fakultätsberechnung)
    - [Kompilierung nach partieller Interpretation](#kompilierung-nach-partieller-interpretation)
- [Voraussetzungen](#voraussetzungen)
- [Arbeitsmaterialien](#arbeitsmaterialien)
    - [Konkatenative Programmierung: Consize, Factor](#konkatenative-programmierung-consize-factor)
    - [Partial Evaluation](#partial-evaluation)
    - [Deforestation](#deforestation)
- [Historie](#historie)

<!-- /TOC -->

## Hintergrund

Das konkatenative Programmierparadigma gehört zu den funktionalen Programmierstilen. Allerdings sind konkatenative Sprachen nicht [applikativ](https://en.wikipedia.org/wiki/Applicative_programming_language) ausgelegt (wie fast alle verbreiteten funktionalen Sprachen), sondern man programmiert einzig über die Verknüpfung von Funktionen, was man auch [_function level programming_](https://en.wikipedia.org/wiki/Function-level_programming) oder [_tacit programming_](https://en.wikipedia.org/wiki/Tacit_programming) nennt. Die daraus resultierende Besonderheit ist, dass man ohne Variablen auskommt, was die Programmierung verändert, aber auch Vorteile mit sich bringt:

* Die Argumentation mittels Programmersetzungen (_equational reasoning_) ist extrem einfach, da keine Bindungskontexte durch Variablen berücksichtigt werden müssen
* Mit geeigneten Abstraktionen kann man nicht nur sehr komfortabel, sondern auch sehr kompakt und dennoch ausdrucksstark programmieren

Eine weitere Besonderheit ist, dass es einen [Homomorphismus](https://de.wikipedia.org/wiki/Homomorphismus) gibt: Die Ebene der Funktionen und deren Verknüpfung durch Funktionskomposition lässt sich eins zu eins abbilden auf eine Ebene von Programmen aus Wörtern und deren Verknüpfung durch Konkatenation (Aneinanderkettung) -- daher stammt der Name für dieses Programmierparadigma.

Mit der Sprache [Consize](https://github.com/denkspuren/consize) liegt eine offene und frei verfügbare Implementierung einer konkatenativen Sprache vor. Consize wurde zu Lehr- und Forschungszwecken entwickelt. Knapp 150 Zeilen Clojure-Code genügen für den Sprachkern, der Rest der Sprache ist in Consize selbst definiert. Die Sprache ist ausführlich dokumentiert, es gibt reichlich Anschauungsmaterial.

## Problemstellung

Der Homomorphismus, der konkatenativen Sprachen zugrunde liegt, kann dafür genutzt werden, um einen Interpreter und einen Compiler in ein und derselben Umgebung abzubilden und umzusetzen. Wenn man primitive Funktionen als die "Assemblersprache" eines Compilers betrachtet, dann kann man den Unterschied Compiler zu Interpreter wie folgt verstehen:

* Einem Interpreter entspricht die wiederholte Anwendung eines Reducers (`reduce`) zur schrittweisen Umsetzung der Komposition (bei Funktionen) bzw. Konkatenation (bei Wörtern), bis ein Fixpunkt erreicht ist; dabei ist zu beachten:
  - Der Reducer kann auf Wortebene arbeiten, wobei ihm ein Mapping (`map`) zur Abbildung primitiver Wörter zu Funktionen und der Konkatenation von zusammengesetzten Wörtern vorgeschaltet ist
  - Der Reducer kann auf Funktionsebene arbeiten, was aber faktisch der Umsetzung einer verlangsamten Komposition entspricht, dem Stilmittel des Compilers (so zu sehen in [`confunc.java`](https://gist.github.com/denkspuren/4ea764b832efc157c7cc855868c3738c))
* Einem Compiler liegt die Komposition von Funktionen zur Verknüpfung von Rechenprozessen zu einer neuer Funktion als Mittel der Programmerstellung zugrunde; primitive Funktionen verstehen sich hier als funktionale "Assemblerbefehle"

Kurzum: Ein Interpreter arbeitet auf Wortebene, ein Compiler übersetzt die Wortebene in eine Funktionskomposition. Der Ausführung des Kompilats entspricht die Anwendung der erstellten Funktionskomposition.

Ein einmal kompiliertes (aus Funktionen zusammengesetztes) Programm entzieht sich einer weiteren Optimierung. Darum muss ein konkatenatives Programm zunächst auf Wortebene optimiert werden. In dieser Arbeit soll untersucht werden, inwiefern die Technik der partiellen Interpretation genutzt werden kann, um den Code zu optimieren. 

Mit partieller Interpretation ist die Interpretation eines Programmfragments gemeint, dessen Interpretation so weit wie möglich durchgeführt wird, obwohl der eigentliche Input zur Abarbeitung fehlt. Mit anderen Worten: Ein Programm wird trotz fehlender Aufrufparameter so weit wie möglich interpretiert.

## Aufgabe

Die Idee der partiellen Interpretation ist für Consize zu entwickeln, was genutzt werden soll zur Optimierung des Quellcodes inkl. der sogenannten _Deforestation_. Anschließend ist der optimierte Quellcode zu kompilieren, um die Ausführungsgeschwindigkeit auszureizen.

Im Moment ist vollkommen offen, ob die Consize-Implementierung mit geringfügigen Ergänzungen (vermutlich mit der Einführung weniger Konzepte wie z.B. der Idee der Stapelreferenz) als partieller Interpreter arbeiten kann. Oder ob die Umsetzung eines konkatenativen Umschreibsystems (_rewriting system_) die Realisierung partieller Interpretation deutlich vereinfacht; in dem Fall entspräche der Kompilierung die Generation von komponierten Lambda-Ausdrücken.

### Einstieg: Automatisierte Ableitung von `swap`

Das Wort `swap` vertauscht die obersten zwei Werte auf dem Stapel. So einfach die Funktion ist, sie lässt sich auch über die primitiven Wörter `dup`, `rot` und `drop` definieren:

```
: swap ( x y -- y x ) dup rot rot drop ;
```

Es ist naheliegend, auf diese Realisierung zu verzichten und `swap` aus Performanzgründen direkt über eine primitive Funktion zu implementieren. Andererseits könnte eine partielle Interpretation selbst herausfinden, dass die Folge aus `dup`, `rot`, `rot` und `drop` die obersten zwei Stapelwerte vertauscht:

```
#X #Y swap =
#X #Y dup rot rot drop =
#X #Y #Y rot rot drop =
#Y #Y #X rot drop =
#Y #X #Y drop =
#Y #X
```

Damit ließe sich nun eine Funktion kompilieren, die direkt die Vertauschung realisiert und nicht als Funktionskomposition der primitiven Funktionen `dup`, `rot` und `drop` aufgesetzt ist. 

Die zu untersuchende Frage ist, wie ein Wort wie z.B. `dup` (das erste in der Auflösung von `swap`) in partieller Interpretation (d.h. ohne Argumente auf dem Stack) zu einer Auflösung kommt, die ein Top-Element auf dem Stapel unterstellt und damit arbeitet -- ähnlich wie die oben verwendeten benamten Platzhalter wie `#X` und `#Y`. Die Platzhalter kann man auch als benamte Referenzen auf Stapelwerte verstehen, die mit ihrer Einführung auch gleichzeitig den Wert vom Datenstapel entfernen. (Die Notation ist in der Dokumentation zu Consize erklärt im Kapitel "Patterns and Rewriting Rules".)

Ansätze zur Umsetzung könnten sich finden lassen bei sogenannten [_fried quotations_](http://docs.factorcode.org:8080/content/article-fry.html) und dem Wort [`fry`](http://docs.factorcode.org:8080/content/vocab-fry.html); diese Ideen sind der kontakenativen Sprache [Factor](https://factorcode.org/) entnommen. Auch die Definition von `swap` als [Macro](http://docs.factorcode.org:8080/content/article-macros.html) könnte eine Lösung sein.

Mit der Lösung für `swap` sollten automatisch auch weitere Vereinfachungen gefunden werden wie z.B.

* `#X dup drop = #X`; die Folge von `dup drop` kann man nicht mit der Identiätsfunktion gleichsetzen, da ein `dup` nur möglich ist, wenn ein Element auf dem Stack liegt.
* `dup dip drop = call`
* `#X #Y swap swap = #X #Y`
* `[ #T @R ] unpush = [ @R ] #T`

### Deforestation am Beispiel der Fakultätsberechnung

In der Folge sollte mit Hilfe partieller Interpretation gezeigt werden, dass Consize das zu tun in der Lage ist, was in der Literatur salopp als _deforestation_ genannt wird; damit ist gemeint, dass die Erzeugung von Listen "wegoptimiert" wird.

Ein Beispiel: Die Fakultät z.B. von 5 kann _high level_ und sehr anschaulich definiert werden als das Produkt `prod` aus der Zahlenfolge `[ 1 2 3 4 5 ]`, die man mit `1 5 [a,b]` erzeugen kann.

```
> : fact ( n -- n! ) 1 swap [a,b] prod ;

> 5 fact
120
```

Das Wort `[a,b]` erzeugt die Zahlenfolge, `prod` ist über `reduce` realisiert; dem Reduzierer ist das neutrale Element der Multiplikation mitzugeben.

```
> 1 5 [a,b]
[ 1 2 3 4 5 ]
> 1 [ * ] reduce
120
```

Mit geeigneten Definitionen für einen Generator wie `[a,b]` und einem Reduzierer wie `reduce` sollte es gelingen (Anregungen dazu [hier](http://www.ccs.neu.edu/home/amal/course/7480-s12/deforestation-notes.pdf)), mittels partieller Interpretation den Rumpf der `fact`-Definition umzuschreiben in einen Ausdruck, der in etwa dem entspricht, was sich ergibt, wenn man die Fakultät rekursiv berechnet:

```
> : fact ( n -- n! ) dup 1 equal? [ dup 1 - fact * ] unless ;
```

Die rekursive Definition kommt ohne das Konstrukt der Liste aus und ist aus dem Grund wesentlich performanter.

### Kompilierung nach partieller Interpretation

Der durch partielle Interpretation optimierte Quellcode ist anschließend auf die Funktionsebene zu übersetzen, sprich zu kompilieren. Als Test sind die Prelude von Consize und ausgewählte Beispiele über partielle Interpretation zu optimieren, zu kompilieren und auszuführen.

## Voraussetzungen

Sie sollten sich ein wenig auskennen mit funktionaler Programmierung, keine Berührungsängst mit dem Lambda-Kalkül haben und auch formale Betrachtungen nicht scheuen. Wenn Sie nach einem Blick in die Consize-Dokumentation Lust an der Annäherung an konkatenative Sprachen haben, dann sind Sie hier richtig.

Die theoretischen Grundlagen sind zwar wichtig, aber Sie werden merken, dass die Arbeit sehr praktisch ist. Denn es geht darum, Ideen und Konzepte in Consize umzusetzen. Und da haben Sie einen einfachen Gradmesser, der Ihnen den Weg weist: Je kürzer die Programme sind, desto wahrscheinlicher ist es, dass Sie des Pudels Kern gefunden haben, dass Sie einer guten Lösung nahe gekommen sind.

## Arbeitsmaterialien

### Konkatenative Programmierung: Consize, Factor

* Dominikus Herzberg: [Implementierung und Dokumentation zu Consize](https://github.com/denkspuren/consize)
* Dominikus Herzberg: [Konkatenative Programmierung mit Lambda-Ausdrücken](https://gist.github.com/denkspuren/4ea764b832efc157c7cc855868c3738c)
* [Factor Programming Language](https://factorcode.org/)

### Partial Evaluation

* William R. Cook: [Compilation by Partial Evaluation](http://www.cs.utexas.edu/~wcook/presentations/2011-PartialEval-simple.pdf)
* Michael Sperber und Peter Thiemann: [Realistic Compilation By Partial Evaluation](http://www.deinprogramm.de/sperber/papers/realistic-compilation-by-pe.pdf)

### Deforestation

* Patrick M. Krusenotto: [Funktionale Programmierung und Metaprogrammierung](https://doi.org/10.1007/978-3-658-13744-1), Springer, 2016
* [Morphismen in der funktionalen Programmierung](https://de.wikipedia.org/wiki/Funktionale_Programmierung#Mathematische_Konzepte), Wikipedia
* Jacob B. Schwartz: [Eliminating Intermediate Lists in pH](https://dspace.mit.edu/handle/1721.1/86511), Master Thesis, MIT, 1999
* Vincent St-Amour: [Deforestation](http://www.ccs.neu.edu/home/amal/course/7480-s12/deforestation-notes.pdf), April 26, 2012 (diese Notizen habe ich auch im Consize-Repository abgelegt, weil sie entscheidend und wichtig für diese Arbeit sind)

## Historie

Die Idee beschäftigt mich schon lange, sie hat sich aber endgültig konkretisiert am 13./14. März 2018 und ist dokumentiert durch zwei Tweets:

<blockquote class="twitter-tweet" data-lang="de"><p lang="de" dir="ltr">Lesefluss<br>* Krusenotto: Funktionale Programmierung und Metaprogrammierung, 2016<br>* Wikipedia: Funktionale_Programmierung#Mathematische_Konzepte<br>* Schwartz: Eliminating Intermediate Lists in pH, 1999<br>* St-Amour: Deforestation, 2012<br>generiert Ideen für konkatenative Sprache Consize <a href="https://t.co/UrrwXng65I">pic.twitter.com/UrrwXng65I</a></p>&mdash; Dominikus Herzberg (@denkspuren) <a href="https://twitter.com/denkspuren/status/973886410796224512?ref_src=twsrc%5Etfw">14. März 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Links:<br>* Krusenotto: <a href="https://t.co/Z9JVde8m8C">https://t.co/Z9JVde8m8C</a><br>* Wikipedia: <a href="https://t.co/NHXVnFKSSX">https://t.co/NHXVnFKSSX</a><br>* Schwartz: <a href="https://t.co/zBFceJuI4Q">https://t.co/zBFceJuI4Q</a><br>* St-Amour: <a href="https://t.co/fS7MA0IzAG">https://t.co/fS7MA0IzAG</a><br>* Consize: <a href="https://t.co/XIRKAnl1JN">https://t.co/XIRKAnl1JN</a></p>&mdash; Dominikus Herzberg (@denkspuren) <a href="https://twitter.com/denkspuren/status/973890962735927297?ref_src=twsrc%5Etfw">14. März 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
