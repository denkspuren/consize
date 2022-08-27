# Von der Gleichheit und der Identität {#Sec:GleichheitIdentitaet}

Zwischen dem Konzept der Gleichheit und dem der Identität gibt es einen
wichtigen Unterschied. Was gleich ist, muss nicht identisch sein. Aber
was identisch ist, muss gleich sein. Zwei Zwillinge mögen sich bis aufs
Haar gleichen, identisch (d.h. ein und dieselbe Person) sind sie deshalb
nicht. Zwei Fotos ein und derselben Person zeigen nicht die gleiche
Person (sofern das eine Bild keinen Doppelgänger darstellt), sondern
dieselbe Person. Die gezeigte Person ist identisch.

Aber wie ist Gleichheit definiert? Und wie die Identität?

## Gleich ist, was aus gleichen Werten bei gleicher Struktur besteht

Gleich ist, was gleich aussieht. Diese Definition ist einfach
verständlich und intuitiv. Etwas formaler ausgedrückt: Zwei Datenwerte
sind gleich, wenn sich ihre Repräsentationen auf dem Datastack nicht
voneinander unterscheiden. Der Test auf Gleichheit ist ein syntaktischer
Vergleich: Ist die Folge der die Daten repräsentierenden Zeichen gleich,
dann sind auch die Daten gleich. Für Wörter trifft diese Definition von
Gleichheit zu, für Stapel anscheinend auch -- doch sie greift zu kurz.

    > clear hello hello equal?
    t
    > [ a b c ] [ a b c ] equal?
    t t

Bei zusammengesetzte Datentypen spielen die strukturellen Bedingungen,
die die Struktur organisieren, eine entscheidende Bedeutung bei der
Frage, was gleich ist. Ganz deutlich wird das bei Mappings. Da die
Anordnung der Assoziationspaare in einem Mapping unerheblich ist, müssen
zwei Mappings nicht gleich aussehen, um gleich zu sein.

    > { 1 2 3 4 } { 3 4 1 2 } equal?
    t

Wir müssen die Definition der Gleichheit erweitern: Zwei Datenstrukturen
vom gleichen Typ (es macht keinen Sinn etwa Mappings mit Stapeln zu
vergleichen) sind dann gleich, wenn ihre Strukturelemente unter
Beachtung der strukturgebenden Eigenschaften gleich sind.

Das klingt kompliziert, ist es aber nicht. Zwei Wörter sind gleich, wenn
sie gleich aussehen. Zwei Stapel sind gleich, wenn alle ihre Elemente in
der selben Reihenfolge (von "oben" bis "unten") gleich sind. Zwei
Mappings sind gleich, wenn sie die gleiche Menge an Schlüsselwerten
haben und die Schlüsselwerte jeweils mit den gleichen Zielwerten
assoziiert sind.

Die Definition ist rekursiv. Die Elemente eines Stapels oder eines
Mappings sind jeweils auf Gleichheit zu testen, die ihrerseits Stapel
oder Mappings sein können usw. Irgendwann muss die Untersuchung auf
Gleichheit auf Wörter oder leere Stapel oder leere Mappings stoßen,
damit die Gleichheit zweier Datenstrukturen entschieden werden kann.

## Identität ist Verfolgbarkeit

Wenn Sie ein Element auf dem Datenstack "mit den Augen" eindeutig
verfolgen können, dann handelt es sich um ein und dasselbe, um das
identische Element. Ein `swap` oder `rot` mag die Position eines
Elements auf dem Datastack verändern, die Operation verändert aber nicht
das Element und erst recht nicht seine Identität. Diese Operationen sind
identitätserhaltend.

Doch der Sachverhalt des Identitätserhalts geht über ein einfaches
Datengeschiebe auf dem Datastack hinaus. Es macht Sinn, auch die
folgende Wortfolge als identitätserhaltend zu definieren: Wenn Sie ein
Element auf einen Stack `push`en und dann mit `top` von dort wieder
erhalten, auch dann haben Sie das Element eindeutig verfolgen können.
Wir können den Identitätserhalt ausdrücken über den folgenden
Zusammenhang: ein `push top` hat dasselbe Ergebnis wie ein `swap drop`;
letzteres gibt uns die Möglichkeit zu sagen, dass die Identität des
Elements durch den Vorgang `push top` nicht verloren geht, da `swap`
identitätserhaltend ist und `drop` den "lästigen" Stapel einfach
"vernichtet". Sie können sich an der Konsole davon überzeugen, dass
beide Programme ergebnisgleich sind.

    > clear emptystack hi
    [ ] hi
    > push top
    hi
    > clear emptystack hi
    [ ] hi
    > swap drop
    hi

Das Wort `identical?` dient zur Abfrage, ob die zwei obersten Elemente
auf dem Datastack identisch sind. Sind sie es, so legt `identical?` ein
`t` für *true* als Ergebnis auf dem Datastack ab, ansonsten `f` für
*false*. Der Stackeffekt ist `( itm1 itm2 -- t/f )`.

In unserem Fall heißt das: Das Wort `hi` *vor* Anwendung von `push top`
muss mit dem Wort `hi` *nach* Anwendung von `push top` identisch sein.
Wir müssen für die Erzeugung der Vorher/Nachher-Situation ein `dup`
verwenden, um einen Vergleich überhaupt möglich zu machen. In Consize
ausgedrückt heißt das: Sind `[ ] hi` auf dem Datenstack gegeben, dann
*muss* das nachstehende Programm ein `t` ergeben. Und so ist es auch,
wie Sie an der Konsole ausprobieren können -- vergessen Sie nicht, zuvor
ein `[ ] hi` auf den Datastack zu bringen.

    > dup rot swap push top identical?
    t

Dieses Ergebnis kann nur zustande kommen, wenn `dup` ein
identitätserhaltendes Wort ist. Wir können das sogar beweisen: Da sich
`push top` durch `swap drop` ersetzen lassen, ist das obige Programm
ergebnisgleich mit:

    > dup rot swap swap drop identical?
    t

Da ein doppeltes `swap` den Tausch auf dem Stack rückgängig macht, kann
das Programm verkürzt werden zu:

    > dup rot drop identical?
    t

Die Wörter `rot drop` "vernichten" lediglich das dritte Element auf dem
Datenstack von oben. Das Wort `identical?` vergleicht deshalb das durch
`dup` duplizierte Element auf dem Datastack. Das Programm

    dup identical?

kann nur `t` als Ergebnis haben, wenn `dup` identitätserhaltend ist.

Die Erkenntnis ist entscheidend. Das Konzept der Identität, d.h. der
Verfolgbarkeit fordert dem Wort `dup` eine identitätserhaltende Wirkung
ab. Das ergibt sich zwingend aus der Überlegung, dass die Identität
eines Elements dadurch gegeben ist, dass man es gleichermaßen mit einem
Zeiger auf seinem Weg auf dem Datastack und als Element beim `push`en
und `top`en auf einem Stapel verfolgen kann. Unter diesen Annahmen
*muss* `dup` die Identität beim Anlegen eines Duplikats erhalten.

## Identitäten durch Referenzen

Auch wenn Sie argumentativ verstanden haben, dass `dup` ein identisches
Element auf dem Datastack ablegt, so ist doch schwer anschaulich
nachzuvollziehen, warum gleiche Elemente auf dem Datastack mal identisch
sind und mal nicht.

    > clear hi hi identical?
    f
    > hi dup identical?
    f t

Wie erklärt sich, dass die gleichen Worte nicht identisch sind, ein
ge`dup`tes Wort hingegen schon?

Wir haben das Konzept der Identität eingeführt mit der Idee, ein Datum
auf seinem Weg auf dem Datenstack eindeutig verfolgen zu können. In der
Tat ist das Konzept des Verfolgers -- der Fachbegriff lautet "Referenz"
oder auch "Zeiger" -- eine Alternative, um sich zu veranschaulichen,
wann zwei Elemente identisch sind bzw. wann sie es nicht sind.

Wenn Sie das Wort `hi` eingeben, erzeugt Consize auf dem Datenstack ein
*neues* Wort. Jedes Mal, wenn Sie `hi` eingeben, wird ein neues Wort
erzeugt. Die Wörter gleichen einander zwar, sind aber nicht identisch.

Mit dem Wort `dup` wird genau das nicht getan: `dup` erzeugt kein neues,
gleiches Wort, sondern es wird nur eine Referenz des Wortes auf dem
Stack abgelegt. Es ist wie mit den zwei Fotos, die ein und dieselbe
Person zeigen -- die Fotos sind gleichsam Referenzen auf ein und
dieselbe Person; die Fotos sind nicht die Person.

Die Daten, die sich auf dem Datastack befinden, tummeln sich tatsächlich
irgendwo im Speicher Ihres Computers. Der Datastack besteht
ausschließlich aus Referenzen, die auf die Daten im Speicher zeigen.
Wann immer Sie `hi` eingeben, wird das Wort im Speicher angelegt und
eine Referenz verweist vom Datastack auf dieses Wort. Das Wort `dup`
erzeugt kein neues Wort, sondern dupliziert nur die Referenz. Somit
zeigen zwei Referenzen auf dasselbe Datenelement. Da man bei der Ausgabe
des Datastacks die Referenzen nicht sieht, sondern nur die
Repräsentationen der referenzierten Daten, ist die Täuschung perfekt:
Man kann nicht erkennen, welche Daten auf dem Datastack identisch sind.

Den Blick hinter die Kulissen erlaubt einzig `identical?`. `identical?`
schaut nämlich, ob zwei Referenzen auf ein und dasselbe Datum verweisen.
Ist dem so, dann liefert `identical?` ein `t` zurück, ansonsten `f`. Das
Wort `equal?` wird also immer erst einmal auf `identical?` testen, um
sich den Test auf Gleichheit der Daten möglicherweise zu ersparen.

## Referenzielle Transparenz durch Immutabilität

Das Konzept der Referenz ist ein Alternativkonzept, das die Idee der
Identität (der Verfolgbarkeit von Daten) anschaulicher erfasst.
Tatsächlich arbeiten Implementierungen funktionaler Sprachen intern sehr
oft mit Referenzen. Referenzen optimieren die interne Datenhaltung. Es
ist deutlich schneller und speichergünstiger, bei einem `dup` eine
Referenz zu kopieren statt die Kopie eines Datums anzulegen, was bei
Stapeln und Mappings sehr aufwendig sein kann. Abseits solcher
Effizienzüberlegungen hat das Konzept der Referenz bzw. der Identität
keine Auswirkungen oder Effekte bei der Ausführung von funktionalen oder
deklarativen Programmen. Man spricht deshalb auch von referenzieller
Transparenz. Mit anderen Worten: Ob man intern mit Referenzen arbeitet
oder nicht, ohne das Wort `identical?` ist überhaupt nicht auszumachen,
ob mit Referenzen gearbeitet wird oder nicht. Das Referenzkonzept hat
keine Bedeutung in der funktionalen Programmierung.

Die referenzielle Transparenz wird in funktionalen Sprachen -- und damit
auch in Consize -- durch die Unveränderlichkeit (Immutabilität) der
Daten gewährleistet. Ein Datum kann niemals und unter keinen Umständen
verändert (mutiert) werden. Wenn wir beispielsweise ein Element auf
einen Stack `push`en, wird der Stack niemals verändert, sondern ein
neuer Stack erzeugt, der alle Element des bisherigen Stacks inklusive
des ge`push`ten Elements enthält. Der Stack *vor* dem `push` kann
niemals mit dem Stack *nach* dem `push` identisch sein.[^1] In
imperativen Programmiersprachen werden Sie feststellen, dass das
Verändern von Daten über die Referenz die Identität erhält.

Wenn Mutabilität zur referentiellen Transparenz führt, ist das Konzept
der Referenz und damit der Identität eigentlich hinfällig, oder? Wozu
gibt es dann das Wort `identical?` in Consize?

Der Einwand ist vollkommen berechtigt. Man kann das Konzept der
Identität in einer funktionalen Sprache wie Consize zwar definieren und
einführen, die Programmausführung kann und darf davon jedoch nicht
abhängen.

Der Grund, warum ich das Wort `identical?` dennoch in Consize
aufgenommen habe, ist ein didaktischer: Sie sollen sich des Unterschieds
von Gleichheit und Identität sehr wohl bewusst sein. Insbesondere in
imperativen Programmiersprachen wie Java oder C# macht es einen
erheblichen Unterschied, ob Sie mit einer Referenz arbeiten oder nicht;
dort sind die meisten Datentypen mutabel und über die Referenz
veränderbar. In Consize brauchen Sie nur in Daten zu denken, in vielen
imperativen Sprachen müssen Sie in Daten und Referenzen denken. Das
heißt: In Consize ist `equal?` alles, was sie brauchen, um Daten zu
vergleichen. Mit `identical?` haben Sie den Luxus, die Verfolgbarkeit
eines Datums auf dem Datenstack zu testen -- darüber hinaus ist das
Konzept (in einer funktionalen Sprache) nutzlos. Weder darf noch kann
ein Programm in Consize von `identical?` abhängen -- weshalb das Wort
konsequenterweise auch gar nicht erst genutzt werden, besser noch: gar
nicht erst existieren sollte.

Darum seien Sie an dieser Stelle wieder in eine Welt ohne `identical?`
entlassen.

[^1]: Wie ein `push pop` dennoch identitätserhaltend sein kann, ist eine
    Sache der intern verwendeten Datenstrukturen. Die Datenstruktur des
    Stapels kann sehr gut in Form einer [einfach verketteten
    Liste](http://de.wikipedia.org/wiki/Doppelt_verkettete_Liste#Einfach_verkettete_Liste)
    realisiert werden.
