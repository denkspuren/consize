# Partielle Interpreation in Consize

> Dieses Thema ist offen zur Bearbeitung. Melden Sie sich bei mir, wenn Sie Interesse haben. Das Thema ist primär geeignet für Master-Studierende der Informatik, die sich tiefergehend mit funktionaler Programmierung auseinandersetzen möchten. -- Dominikus Herzberg

## Problemstellung

## Aufgaben

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

Die zu untersuchende Frage ist, wie ein Wort wie z.B. `dup` (das erste in der Auflösung von `swap`) in partieller Interpretation (d.h. ohne Argumente auf dem Stack) zu einer Auflösung kommt, die ein Top-Element auf dem Stapel unterstellt und damit arbeitet -- ähnlich wie die oben verwendeten benamten Platzhalter wie `#X` und `#Y`.

Ansätze könnten sich finden lassen bei sogenannten [_fried quotations_](http://docs.factorcode.org:8080/content/article-fry.html) und dem Wort [`fry`](http://docs.factorcode.org:8080/content/vocab-fry.html). Auch die Definition von `swap` als [Macro](http://docs.factorcode.org:8080/content/article-macros.html) könnte eine Lösung sein.

## Deforestation am Beispiel der Fakultätsberechnung

In der Folge sollte mit Hilfe partieller Interpretation gezeigt werden, dass Consize das zu tun in der Lage ist, was in der Literatur salopp als _deforestation_ genannt wird; damit ist gemeint, dass die Erzeugung von Listen "wegoptimiert" wird.

Ein Beispiel: Die Fakultät z.B. von 5 kann _high level_ und sehr anschaulich definiert werden als das Produkt `prod` aus der Zahlenfolge `[ 1 2 3 4 5 ]`.

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

Mittels geeigneter Definitionen für einen Generator wie `[a,b]` und einem Reduzierer wie `reduce` sollte es gelingen, mittels partieller Interpretation den Rumpf der `fact`-Definition umzuschreiben in einen Ausdruck, der in etwa dem entspricht, was sich ergibt, wenn man die Fakultät rekursiv berechnet:

```
> : fact ( n -- n! ) dup 1 equal? [ dup 1 - fact * ] unless ;
```

Die rekursive Definition kommt ohne das Konstrukt der Liste aus und ist aus dem Grund wesentlich performanter.

## Hintergrund

Das konkatenative Programmierparadigma gehört zu den funktionalen Programmierstilen. Allerdings sind konkatenative Sprachen nicht [applikativ](https://en.wikipedia.org/wiki/Applicative_programming_language) ausgelegt (wie fast alle verbreiteten funktionalen Sprachen), sondern man programmiert einzig über die Verknüpfung von Funktionen, was man auch [_function level programming_](https://en.wikipedia.org/wiki/Function-level_programming) oder [_tacit programming_](https://en.wikipedia.org/wiki/Tacit_programming) nennt. Die daraus resultierende Besonderheit ist, das man ohne Variablen auskommt, was im ersten Moment die Programmierung erschwert. Das ist im ersten Moment ungewohnt, bringt aber auch Vorteile mit sich:

* Die Argumentation mittels Programmersetzungen (_equational reasoning_) ist extrem einfach, da keine Bindungskontexte durch Variablen berücksichtigt werden müssen
* Mit Hilfe geeigneter Abstraktionen kann man nicht nur sehr komfortabel, sondern auch sehr kompakt und dennoch ausdrucksstark programmieren

Eine weitere Besonderheit ist, dass es einen [Homomorphismus](https://de.wikipedia.org/wiki/Homomorphismus) gibt: Die Ebene der Funktionen und deren Verknüpfung durch Funktionskomposition lässt sich eins zu eins abbilden auf eine Ebene von Programmen aus Wörtern und deren Verknüpfung durch Konkatenation (Aneinanderkettung) -- daher stammt der Name für dieses Programmierparadigma.

Mit der Sprache [Consize](https://github.com/denkspuren/consize) liegt eine offene und frei verfügbare Implementierung einer konkatenativen Sprache vor. Consize wurde zu Lehr- und Forschungszwecken entwickelt. Knapp 150 Zeilen Clojure-Code genügen für den Sprachkern, der Rest der Sprache ist in Consize selbst definiert. Die Sprache ist ausführlich dokumentiert, es gibt reichlich Anschauungsmaterial.

## Voraussetzungen

Sie sollten sich ein wenig auskennen mit funktionaler Programmierung, keine Berührungsängst mit dem Lambda-Kalkül haben und auch formale Betrachtungen nicht scheuen. Wenn Sie nach einem Blick in die Consize-Dokumentation Lust an der Annäherung an konkatenative Sprachen haben, dann sind Sie hier richtig.

Die theoretischen Grundlagen sind zwar wichtig, aber Sie werden merken, dass die Arbeit sehr praktisch ist. Denn es geht darum, Ideen und Konzepte in Consize umzusetzen. Und da haben Sie einen einfachen Gradmesser, der Ihnen den Weg weist: Je kürzer die Programme sind, desto wahrscheinlicher ist es, dass Sie des Pudels Kern aufgedeckt und gefunden haben, dass Sie einer guten und Lösung nahe gekommen sind. 

## Literatur

Compilation by Partial Evaluation

