# Erste Schritte mit Consize: Die Basics {#Sec:Basics}

## Programme sind Texte

Wenn Sie mit einer
[Programmiersprache](http://de.wikipedia.org/wiki/Programmiersprache)
etwas anfangen möchten, dann müssen Sie ein
[Programm](http://de.wikipedia.org/wiki/Computerprogramm) schreiben, das
von den Ausdrucksmitteln der Programmiersprache Gebrauch macht. Ein
Programm ist nichts weiter als Text, sprich eine Folge von
Einzelzeichen.

Praktisch alle Programmiersprachen verarbeiten Programme in Form von
[Textdateien](http://de.wikipedia.org/wiki/Textdatei). Das heißt, Sie
schreiben den Programmtext (auch
[Quelltext](http://de.wikipedia.org/wiki/Quelltext), Quellcode oder kurz
nur Code bezeichnet) mit Hilfe eines sogenannten Texteditors und
speichern den Programmtext als Datei ab. Ein
[Texteditor](http://de.wikipedia.org/wiki/Texteditor) ist eine
Anwendung, die Ihnen das Schreiben und Bearbeiten von Textdateien
ermöglicht. Bekannte und weit verbreitete Editoren sind zum Beispiel
[jEdit](http://www.jedit.org) und
[Notepad++](http://www.notepad-plus-plus.org/). Wenn Sie Programme in
z.B. [Java](http://de.wikipedia.org/wiki/Java_(Programmiersprache)) oder
[C#](http://de.wikipedia.org/wiki/C-Sharp) schreiben, dann wird Ihnen
ein einfacher Editor meist nicht mehr genügen. Sie greifen dann auf eine
sogenannte "[Integrierte
Entwicklungsumgebung](http://de.wikipedia.org/wiki/Integrierte_Entwicklungsumgebung)"
(*Integrated Development Environment*, IDE) wie
[Eclipse](http://de.wikipedia.org/wiki/Eclipse_(IDE)) oder [Visual
Studio](http://de.wikipedia.org/wiki/Visual_Studio) zurück. Eine IDE ist
im Grunde eine Art erweiterter Editor, der zusätzliche, die
Programmierarbeit unterstützende Anwendungen integriert. Für Consize
reicht jedoch ein einfacher Texteditor zum Schreiben von Programmtexten
vollkommen aus.

Consize verarbeitet nicht nur Programme in Form von Textdateien, Sie
können mit Consize auch direkt über die
[Konsole](http://de.wikipedia.org/wiki/Kommandozeile) interagieren. Als
Konsole bezeichnet man eine Ein- und Ausgabeeinheit, die eine
Schnittstelle zu einer Anwendung herstellt. Unter den verschiedensten
[Betriebssystemen](http://de.wikipedia.org/wiki/Betriebssystem) wird
Ihnen eine Konsole meist in Form eines
[Fensters](http://de.wikipedia.org/wiki/Fenster_(Computer)) bereit
gestellt. In der Regel ist die Interaktion über eine Konsole rein
textuell, sprich über einen Fensterausschnitt auf dem Bildschirm und die
Tastatur. Die [Maus](http://de.wikipedia.org/wiki/Computermaus) oder
andere Eingabegeräte spielen dabei praktisch keine Rolle. Mittlerweile
gibt es viele sehr populäre Programmiersprachen, mit denen Sie direkt
über die Konsole interagieren können. Dazu gehören
[Python](http://de.wikipedia.org/wiki/Python_(Programmiersprache)),
[Ruby](http://de.wikipedia.org/wiki/Ruby_(Programmiersprache)) und auch
[JavaScript](http://de.wikipedia.org/wiki/JavaScript). Diese Sprachen
werden gerne als
[Skriptsprachen](http://de.wikipedia.org/wiki/Skriptsprache) bezeichnet,
was historische Gründe hat.

Ganz gleich, ob Sie Consize eine Textdatei als Programm lesen und
verarbeiten lassen oder über die Konsole mit Consize interagieren: es
geht immer um Text. Und so ist es wichtig zu wissen, welche Texte der
reinen Form nach -- der Fachbegriff lautet Syntax -- für Consize gültige
Programmtexte darstellen. Jede Programmiersprache hat ihre eigene
[Syntax](http://de.wikipedia.org/wiki/Syntax#Die_Syntax_formaler_Sprachen_.28formale_Syntax.29).
Typischerweise sind die Syntax-Regeln (die Regeln, welche Zeichenfolgen
gültige Programmtexte sind) in Form einer [formalen
Grammatik](http://de.wikipedia.org/wiki/Formale_Grammatik) angegeben.

## Wie Consize denkt: Die Ur-Grammatik von Consize {#Sec:UrGrammatik}

Die Grammatik legt anhand einer Reihe von
[Produktionsregeln](http://de.wikipedia.org/wiki/Produktionsregel)
genauestens fest, welche Zeichen wie aufeinander folgen dürfen. Da
allein die Berücksichtigung der Produktionsregeln genügt, um zu
entscheiden, ob ein Text (sprich, eine Zeichenfolge) ein gültiges
Programm ist oder nicht, spricht man auch von einer "[kontextfreien
Grammatik](http://de.wikipedia.org/wiki/Kontextfreie_Grammatik)". Ob das
Programm denn auch ein funktionsfähiges Programm ist, das ist eine Frage
der
[Semantik](http://de.wikipedia.org/wiki/Semantik#Semantik_in_formalen_Sprachen),
der Bedeutung von Programmausdrücken. Ein syntaktisch korrektes Programm
muss kein semantisch gültiges Programm sein.

Grammatikregeln werden üblicherweise in der [Erweiterten
Backus-Naur-Form](http://de.wikipedia.org/wiki/Erweiterte_Backus-Naur-Form)
(EBNF) oder einer verwandten Schreibweise notiert. Die Notation ist
einfach zu verstehen.

Die erlaubten, tatsächlich in einem Programmtext verwendbaren Zeichen
heißen [Terminalsymbole](http://de.wikipedia.org/wiki/Terminalsymbol)
und werden durch einfache oder doppelte Anführungszeichen ausgewiesen.
So meint das Prozentzeichen, so wie es über die Tastatur eingegeben
werden kann. Einige
[Steuerzeichen](http://de.wikipedia.org/wiki/Steuerzeichen), wie
z.B. das über die
[Tabulator-Taste](http://de.wikipedia.org/wiki/Tabulatortaste) erzeugte
Steuerzeichen, werden oft besonders notiert; das Tabulator-Steuerzeichen
etwa als '`\t`'.

[Nichtterminalsymbole](http://de.wikipedia.org/wiki/Nichtterminalsymbol)
werden aus einem Mix von Terminal- und Nichtterminalsymbolen definiert.
In einer Produktionsregel steht links vom Gleichheitszeichen das zu
definierende Nichtterminalsymbol (es wird gerne zur deutlichen
Unterscheidung von Terminalsymbolen in spitze Klammern gesetzt), rechts
davon eine oder mehrere Alternativen (ein senkrechter Strich "$|$"
trennt die Alternativen) von Terminalen und/oder Nichtterminalen. Runde
Klammern dienen zur Gruppierung. Eckige Klammern weisen ein Terminal-
oder Nichtterminalsymbol als optional aus (es darf vorkommen, muss es
aber nicht), geschweifte Klammern lassen beliebige Wiederholungen zu
(auch keinmal). Jede Regel endet mit einem Semikolon. Den Anfang eines
Kommentars leitet ein "(\*" ein, sein Ende ein "\*)".

Das Ganze ist am Beispiel leicht nachzuvollziehen. Die Grammatik von
Consize ist extrem einfach.

::: grammar
\<whitespace\> = ' ' \| '\
t' \| '\
n' \| '\
r' ;

\<separator\> = \<whitespace\> { \<whitespace\> } ;

\<symbol\> = 'a' \| \... \| 'Z' \| '0' \| \... \| '9' ; (\* more
generally, any character except \<whitespace\> characters \*)

\<word\> = \<symbol\> { \<symbol\> } ;

\<program\> = \[ \<word\> \] { \<separator\> \<word\> } \[ \<separator\>
\] ;
:::

Das Nichtterminal ([Leerraum](http://de.wikipedia.org/wiki/Leerraum))
ist definiert, entweder ein Leerzeichen (der Deutlichkeit halber als
Unterstrich dargestellt) oder ein Tabulator-Steuerzeichen oder ein
Zeilenvorschub '`\n`' oder ein Wagenrücklauf '`\r`' zu sein. Der Strich
trennt die Alternativen voneinander.

Das Nichtterminal repräsentiert ein
[Trennzeichen](http://de.wikipedia.org/wiki/Trennzeichen) und ist
definiert als ein Leerraum gefolgt von beliebig vielen weiteren s. Mit
anderen Worten: Ein besteht aus mindestens einem .

Als gilt jedes beliebige Terminalsymbol von bis und von bis . Die Punkte
"..." sind hier nur als verkürzende Schreibweise gedacht, statt alle
Terminalsymbole ausdrücklich hinschreiben zu müssen. Der Kommentar weist
darauf hin, dass die Produktionsregel für sogar noch weiter zu fassen
ist: Als kommt jedes Terminalsymbol in Frage, das nicht als gilt.

Ein Wort in Consize besteht aus mindestens einem . Und ein Programm
beginnt optional mit einem , es schließt optional mit und erlaubt
dazwischen beliebig viele Wiederholungen aus und .

Wenn Sie sich die Regel für ein Programm durch den Kopf gehen lassen, so
werden Sie eine interessante Beobachtung machen: Es ist unmöglich, ein
syntaktisch ungültiges Programm für Consize zu verfassen. Welchen
Programmtext auch immer Sie Consize vorsetzen: Ein Programm wird
schlicht an den Grenzen von Leerräumen in Wörter zerlegt. Im Extremfall
besteht ein Consize-Programm aus nicht einmal einem einzigen Zeichen.

Da Consize einzig an den Wörtern eines Programms interessiert ist, fällt
die Analyse und Zerlegung eines Programmtextes in Wörter sehr leicht
aus. Es gibt kaum eine andere Programmiersprache, die eine derart
primitive Syntax hat. Man könnte die Syntax auch als extrem robust
bezeichnen, gemäß der zweiten Hälfte des von [Jonathan
Postel](http://de.wikipedia.org/wiki/Jonathan_Postel) formulierten
[Robustheitsgrundsatzes](http://de.wikipedia.org/wiki/Robustheitsgrundsatz):
"[be liberal in what you accept from
others](http://tools.ietf.org/html/rfc761#page-13)". Ganz so "liberal"
wird Consize jedoch nicht bleiben, weil zu viel Freiheit keine
Strukturen bietet.

## Das Parsen eines Programms

Wenn Consize eine Textdatei lädt und den dort enthaltenen Text als
Programm ausführen soll, dann geht das nicht sofort. Ein paar
Vorarbeiten sind notwendig. Der Text muss daraufhin untersucht werden,
ob er der Grammatik entspricht. Und erst wenn das der Fall ist, dann
kann der Programmtext weiter analysiert und verarbeitet werden, bis er
schlussendlich als Programm ausgeführt wird. Die Aufgaben von der
Grammatikanalyse bis hin zur Vorbereitung der Programmausführung werden
als "Parsen" (*parsing*) bezeichnet. Der dafür verantwortliche
Programmteil heißt "[Parser](http://de.wikipedia.org/wiki/Parser)".

Nun ist die Grammatik von Consize so einfach, dass sich das Parsen auf
zwei Schritte beschränkt. Im ersten Schritt entfernt Consize aus dem
Programmtext Kommentare. Ein
[Kommentar](http://de.wikipedia.org/wiki/Kommentar_(Programmierung)) ist
ein für die Programmausführung vollkommen irrelevanter Textteil, den ein
Programmierer bzw. eine Programmiererin nutzen kann, um Anmerkungen für
sich und andere Leser(innen) des Programmtexts zu hinterlassen.

Im zweiten Schritt zerlegt Consize den Programmtext in logische
Einheiten, sogenannte
"[Token](http://de.wikipedia.org/wiki/Token_(Compilerbau))". Diesen
Vorgang übernimmt ein Programm, das
"[Tokenizer](http://de.wikipedia.org/wiki/Tokenizer)" heißt; der
Tokenizer ist eine ganz einfache Form eines Parsers. Im Fall von Consize
zerlegt der Tokenizer den Programmtext einfach an den Leerstellen () in
eine Folge von Wörtern (). Die Token sind Wörter.

Machen Sie folgende einfache Übung: Legen Sie eine Textdatei mit
nachstehendem Inhalt an und speichern Sie den Text in einer Datei namens
`test.txt` und zwar in dem Verzeichnis, in dem sich auch Consize
befindet. Wenn Sie wollen, fügen Sie beginnende Leerzeichen hinzu oder
verändern Sie den Text beliebig.

    I'm a syntactically valid line of code! % though meaningless
    Bye bye

Starten Sie Consize und geben Sie folgendes ein:

    > clear \ test.txt slurp
    I'm a syntactically valid line of code! % though meaningless
    Bye bye

Consize liest ("schlürft", *slurp*) den Inhalt der Datei `test.txt` ein.
Das Ergebnis sieht exakt so aus, wie das, was Sie mit dem Editor in die
Datei geschrieben haben.

Nun entfernen wir mit `uncomment` die Kommentare. In Consize beginnt ein
Kommentar mit dem Prozentzeichen "`%`" und endet am Ende der Zeile.

    > uncomment
    I'm a syntactically valid line of code!

    Bye bye

Lassen Sie sich von der eingefügten "Extrazeile" nicht irritieren; je
nach verwendetem Betriebssystem ist die Extrazeile möglicherweise bei
Ihnen auch nicht zu sehen.[^1] Entscheidend ist, dass der Kommentar
verschwunden ist.

Die Zerlegung des entkommentierten Programms geschieht mit `tokenize`.

    > tokenize
    [ I'm a syntactically valid line of code! Bye bye ]

Was Sie hier sehen, ist das Ergebnis der Zerlegung des entkommentierten
Programms in eine Folge von neun Wörtern. Sie bekommen das Ergebnis in
Form einer Datenstruktur präsentiert, die sich Stapel nennt; das zeigen
die eckigen Klammern an.

Sie können das erste Wort `I'm` mit `unpush` vom Stapel holen und
dahinter ablegen.

    > unpush
    [ a syntactically valid line of code! Bye bye ] I'm

Mit `type` können Sie den Datentypen von `I'm` ermitteln; `type`
entfernt das Wort `I'm` und gibt das Ergebnis mit der Angabe `wrd`
bekannt. Es handelt sich also tatsächlich um ein Wort!

    > type
    [ a syntactically valid line of code! Bye bye ] wrd

Doch ich greife vor. Wir werden uns in Kürze mit den Datentypen
beschäftigen, die Consize anbietet.

Hätte der Programmtext nicht den Grammatikregeln entsprochen, so hätte
Consize den Text als syntaktisch ungültig zurückgewiesen. Wie Sie aber
wissen, ist die Grammatik von Consize derart primitiv und grundlegend,
dass es keine syntaktisch ungültigen Programmtexte geben kann. Consize
wird den Inhalt jeder Datei erfolgreich mit `tokenize` verarbeiten. Bei
so gut wie allen anderen Programmiersprachen ist das nicht so. Die
Grammatiken sind komplizierter und verlangen nach Strukturen, die
eingehalten werden wollen. Fordert eine Grammatik beispielsweise, dass
einer öffnenden Klammer '`(`' im Programmtext auch immer eine
schließende Klammer '`)`' folgt, dann ist ein Kurzprogramm wie z.B.
"`( 1 2 3`" ungültig: die schließende Klammer fehlt.

In der Tat ist die Grammatik von Consize so einfach, dass sie schon
wieder problematisch ist: Ohne strukturbildende Ausdrucksmittel wie
z.B. Klammern, sind Consize-Programme kaum für Menschen lesbar. Und auch
das Schreiben von Consize-Programmen ist ohne jegliche Strukturmittel
wenig spaßig.

Doch es gibt einen netten Ausweg aus dieser Situation: Wohl aber können
wir Klammern, wie z.B. `[` und `]` oder `{` und `}` als Wörter in
Consize verwenden. Wenn Sie sonst eine geklammerte Zahlenfolge als
"`[1 2 3]`" schreiben würden, müssen Sie jetzt nur Leerräume nutzen und
die Klammern in "`[ 1 2 3 ]`" werden zu eigenständigen Wörtern.

Damit können wir uns eines Tricks bedienen: Wir triggern mit diesen
Wörtern, wie z.B. bei einer öffnenden eckigen Klammer `[`, ein
Consize-Programm, das die passende schließende eckige Klammer sucht, die
dazwischen liegenden Wörter als Daten interpretiert und in eine
geeignete Datenstruktur packt. Damit simulieren wir eine Grammatikregel
für eckige Klammern.

Das mag wie ein "Hack" wirken, mit dem sich fehlende grammatische
Strukturen simulieren lassen. Im gewissen Sinne stimmt das sogar. Aber
Sie lernen auf diese Weise den Umgang mit sogenannten Continuations. Mit
Hilfe einer Continuation können Sie die Zukunft eines Programms
verändern -- ein Feature, das nur wenige Sprachen unterstützen.

## Was Consize versteht: Die erweiterte Grammatik

Obwohl die Ur-Grammatik von Consize so überaus primitiv ist, können wir
mit dem eben erwähnten Trick nachträglich Grammatikregeln simulieren.
Dieser Trick ist im sogenannten "Präludium" (Vorspiel) zu Consize
programmiert. Wir verwenden fortan den englischen Begriff "Prelude".

In der Prelude ist eine Vielzahl an kleinen Consize-Programmen abgelegt,
die das Arbeiten mit Consize praktischer und angenehmer machen --
Consize-Programme, die Consize erweitern. Darunter eben auch die
"Erweiterungen" der Grammatik.
Kap. [\[Sec:Prelude\]](#Sec:Prelude){reference-type="ref"
reference="Sec:Prelude"} befasst sich ausführlich mit der Prelude.

Sie dürfen sich die erweiterte Grammatik ungefähr wie folgt vorstellen;
die Grammatik ist nicht vollständig und vereinfacht, aber sie enthält
wichtige Regeln von Consize.

::: grammar
\<sequence\> = ('\['\|'(') { \<separator\> \<item\> } \<separator\>
('\]'\|')') ;

\<mapping\> = '' { \<separator\> \<item\> \<separator\> \<item\> }
\<separator\> '' ;

\<item\> = \<word\> \| \<sequence\> \| \<mapping\> ;

\<program\> = \[ \<item\> \] { \<separator\> \<item\> } \[ \<separator\>
\] ;
:::

In der von Consize simulierten Grammatik gibt es Folgen () von Elementen
(), einmal mit eckigen, einmal mit Runden Klammern, und Mappings mit
geschweiften Klammern. Mappings unterscheiden sich von Folgen dadurch,
dass sie paarweise Items gruppieren. Überall sorgen Leerräume () dafür,
dass weder die Klammern noch die Elemente sich "berühren" können. Die
Logik der Ur-Grammatik bleibt damit erhalten: Alles kann letztlich als
eine Folge von Wörtern interpretiert werden.

Die Grammatik hat eine Besonderheit: in ihr gibt es gegenseitige
Abhängigkeiten -- man spricht von wechselseitiger
[Rekursion](http://de.wikipedia.org/wiki/Rekursion). So bezieht sich die
Regel zu auf , wiederum kann eine sein. Auf diese Weise beschreibt die
Grammatik Verschachtelungen. Die Zeichenfolge

    [ 1 2 [ { 3 4 x y } z ] ]

ist eine gültige , die ihrerseits aus zwei Wörtern und einer weiteren
Folge mit eckigen Klammern besteht, die wiederum ein Mapping und ein
Wort beinhaltet.

Ein Programm in Consize besteht zwar nach wie vor -- wie in der
Ur-Grammatik -- aus einer Folge von Wörtern, doch die
Grammatik-Erweiterungen fordern den balancierten Gebrauch der Wörter
ein, die Klammern darstellen. Öffnende und schließende Klammern müssen
Verschachtelungen beschreiben. Bei geschweiften Klammern ist sogar stets
eine gerade Anzahl an eingebetteten Elementen gefordert.

Sie wissen noch nicht, was mit den eckigen und den geschweiften Klammern
gemeint ist, aber Namensgebungen wie und sind nicht zufällig, sondern
absichtlich so gewählt. Wenn Sie Programmiererfahrung haben, werden Sie
eher eine Idee haben, was Sequenzen und Mappings sein könnten, als wenn
Consize Ihre erste Programmiersprache ist. Ein Programmierprofi wird
immer einen Blick in die Grammatikregeln einer ihm neuen
Programmiersprache werfen, um sich zu orientieren.

Das nächste Unterkapitel wird Sie in die Datenstrukturen von Consize
einführen. Die Datentypen werden genauso dargestellt, wie Sie sie in
Consize eintippen können -- sofern die Prelude geladen ist. Die
Notationen orientieren sich an den Grammatiken für Sequenzen und
Mappings!

## Datenstrukturen {#Sec:Datenstrukturen}

Obwohl Consize laut "Ur-Grammatik" nur Wörter und keine Klammern kennt
(Klammern rüstet die Prelude nach), kann man dennoch Strukturen
aufbauen. Eben nicht auf direkte Weise, sondern mit Wörtern, die
Datenstrukturen erzeugen.

Beginnen wir mit der wichtigsten Datenstruktur in Consize, dem Stapel
(*stack*). Der Name dieser Datenstruktur ist der Vorstellung entlehnt,
die wir mit einem Stapel z.B. von Büchern, Zeitschriften oder Tellern
verbinden. Auf einem Stapel kann man etwas ablegen oder wieder entfernen
und zwar immer nur "von oben".

Diese Anschauung wird auf wenige elementare Operationen reduziert: Mit
`emptystack` wird ein leerer Stapel erzeugt, mit `push` ein Element auf
dem Stapel abgelegt, mit `pop` der Stapel um das oberste Element
reduziert, `top` gibt das oberste Element zurück.

    | item4 | <- top of stack
    | item3 | \
    | item2 |  > rest of stack (pop)
    | item1 | /
    +-------+

Schauen wir uns die Befehle einzeln an in der Interaktion mit Consize.

`emptystack` erzeugt einen leeren Stapel. Consize stellt einen Stapel
mit Hilfe eckiger Klammern dar. Ist der Stapel leer, so trennt einzig
ein Leerzeichen die öffnende von der schließenden Klammer.

    > emptystack
    [ ]

Man muss wissen, dass das "obere" Ende des Stapels links ist. Wenn wir
ein Element auf den Stapel `push`en, wird es von links her auf dem
Stapel abgelegt.

    > 3 push
    [ 3 ]
    > 4 push
    [ 4 3 ]
    > hello push
    [ hello 4 3 ]

`pop` entfernt das oberste, sprich das Element ganz links vom Stapel.
Das kann man so lange tun, bis kein Element mehr auf dem Stapel ist.
`top` holt das oberste ("linkeste") Element vom Stapel, was den Stapel
vernichtet.

    > pop
    [ 4 3 ]
    > top
    4

Vielleicht haben Sie sich schon diese Frage gestellt: Wie bekommt man
eigentlich ein Wort wie `push` selbst als Element auf einen Stapel
abgelegt?

    > emptystack \ push push
    4 [ push ]

Das Wort `\` hat eine besondere Aufgabe: Es hebt die Funktion auf, die
das nachfolgende Wort möglicherweise hat. So kann mittels `\` das Wort
`push` als reines Datum ausgewiesen und mit einem anschließenden `push`
auf einem leeren Stapel abgelegt werden.

Da Sie hier bereits mit der über die Prelude erweiterten Version von
Consize arbeiten, gibt es auch die Möglichkeit, Stapel direkt in der
Notation mit den eckigen Klammern einzugeben.

    > [ hello 4 3 ]
    4 [ push ] [ hello 4 3 ]

Zwei Stapel lassen sich mit `concat` "konkatenieren" (verbinden,
zusammenfügen).

    > concat
    4 [ push hello 4 3 ]

Consize ist eine konkatenative Programmiersprache. Hinter der
Konkatenation, dem Zusammenfügen zweier Stapel verbirgt sich ein
wichtiges Grundprinzip der Arbeitsweise von Consize.

Mit `reverse` lassen sich die Inhalte des Stapels umkehren: Das letzte
Element im Stapel wandert nach oben, das vorletzte an die zweitoberste
Stelle usw. Das ändert nichts daran, dass der Stapel immer noch von
links befüllt wird. Es dreht sich also nicht der Stapel um, sondern sein
Inhalt wird "umgekehrt".

    > reverse
    4 [ 3 4 hello push ]

Sie haben eine Menge gelernt: Sie erzeugen mit `emptystack` einen leeren
Stapel, können dem Stapel mit `push` Elemente hinzufügen und mit `pop`
wieder entfernen; `top` liefert das oberste Element eines Stapels. Mit
`concat` werden zwei Stapel miteinander verbunden (konkateniert), mit
`reverse` sein Inhalt "umgekehrt".

## Datenstapel und Programmstapel {#Sec:DataCallStack}

Consize hat eine denkbar einfache Virtuelle Maschine (VM). Sie besteht
aus zwei Stapeln und einem Wörterbuch (*dictionary*). Eine sehr einfache
Abarbeitungsvorschrift regelt das Zusammenspiel der Stapel und den
Gebrauch des Wörterbuchs.

Die beiden Stapel heißen Datenstapel (*data stack*) und Aufruf- oder
Programmstapel (*call stack*). Dabei gibt es eine Konvention: Aus
praktischen Gründen werden die beiden Stapel "liegend" dargestellt,
wobei der Datastack sein oberes Ende rechts und der Callstack sein
oberes Ende links hat. Wenn der Datastack und der Callstack gemeinsam
dargestellt werden, stoßen die Kopfenden aneinander; links ist dann der
Datastack, rechts der Callstack.

    +-----------  -----------+
    | Datastack    Callstack |
    +-----------  -----------+

Wenn wir ein Programm aus Wörtern schreiben, dann stellt die Folge von
Wörtern die Situation auf dem Callstack dar. Das Programm

    emptystack 2 push 3 push

stellt sich bei leerem Datastack wie folgt dar:

    +--  -------------------------+
    |    emptystack 2 push 3 push |
    +--  -------------------------+

Der Einfachheit halber notieren wir den Data- und den Callstack ohne die
umgrenzenden Linien und nutzen einen Trennstrich "`|`", um den Übergang
vom Datastack zum Callstack anzuzeigen:

    | emptystack 2 push 3 push

Das Programm wird schrittweise abgearbeitet. Ein Wort nach dem anderen
wird vom Callstack genommen und interpretiert, solange bis der Callstack
leer ist. Dem entspricht in der Darstellung eine Abarbeitung der Wörter
auf dem Callstack von links nach rechts.

Jedes Wort, das vom linken Ende des Callstacks "genommen" wird, hat eine
Auswirkung auf die VM von Consize. Die Bedeutung eines Wortes wird im
Wörterbuch nachgeschlagen. `emptystack` zum Beispiel ist mit einer
Funktion assoziiert, die einen leeren Stapel oben auf dem Datastack
ablegt. Nach `emptystack` stellt sich die Situation auf dem
Data-/Callstack wie folgt dar:

    [ ] | 2 push 3 push  

Das Wort `2` (nicht Zahl, sondern Wort!) ist ein "neutrales" Wort. Es
wandert direkt vom Callstack rüber auf den Datastack.

    [ ] 2 | push 3 push

Das Wort `push` erwartet oben auf dem Datastack irgendein Element und
darunter einen Stapel. `push` legt das Element oben auf dem Stapel ab.
Denken Sie daran, dass ein mit eckigen Klammern notierter Stapel sein
"offenes", "oberes" Ende *immer* auf der linken Seite hat.

    [ 2 ] | 3 push

Das Wort `3` wandert wie `2` direkt auf den Datastack.

    [ 2 ] 3 | push

Nun legt das letzte `push` das Wort `3` auf dem Stapel `[ 2 ]` als
oberstes Element ab.

    [ 3 2 ] |

Der Callstack ist nun vollständig abgearbeitet und der Datastack
beinhaltet das Ergebnis der Abarbeitung des Programms auf dem Callstack.
Voilà! Sie haben einen ersten Programmdurchlauf im Einzelschrittmodus
durch Consize mitgemacht. Schwieriger wird es kaum mehr.

Ist Ihnen etwas aufgefallen? Wenn Sie interaktiv mit Consize über die
Konsole arbeiten, geht all das, was Sie an Wörtern eingeben auf den
Callstack. Als Ergebnis der Abarbeitung zeigt Ihnen Consize den
Datastack an.

Und noch etwas ist Ihnen sicher aufgefallen. Es macht für Consize
oftmals keinen Unterschied, ob Sie in der Konsole Wörter einzeln
eingeben und direkt mit einem Enter die Abarbeitung anstoßen oder ob Sie
mehrere Wörter durch Leerzeichen getrennt in einer Zeile an Consize
übergeben. Das Ergebnis ändert sich deshalb nicht. Es gibt Ausnahmen von
dieser Regel wie z.B. das Wort `\`, dem immer ein Wort unmittelbar
nachfolgen muss. Von solchen Ausnahmen abgesehen ist es ein Leichtes,
ein Programm Wort um Wort einzugeben und die Abarbeitung so schrittweise
zu verfolgen. So lässt sich selbst das komplizierteste Programm
nachvollziehen.

## Atomare und nicht-atomare Wörter {#Sec:AtomareWoerter}

Wenn Consize ein Wort vom offenen Ende des Callstacks nimmt, schlägt
Consize die Bedeutung des Wortes in einem Wörterbuch (*dictionary*)
nach. Findet sich das Wort nicht im Wörterbuch, so landet das Wort
unversehens auf dem Datastack -- die Details erfahren Sie am Ende dieses
Kapitelabschnitts.

Findet Consize das Wort im Wörterbuch, so gibt es zwei Möglichkeiten:
Entweder ist das Wort ein atomares Wort (*atomic word*). Dann ist im
Wörterbuch für das Wort eine Funktion hinterlegt, die -- angewendet auf
den Datastack -- die Bedeutung des Wortes umsetzt. Oder das Wort ist ein
nicht-atomares Wort (*non-atomic word*). Das Wörterbuch hat zu dem Wort
einen Stapel als Eintrag, dessen Inhalt die Bedeutung des Wortes
definiert. Wir nennen diesen Stapel auch "Quotierung" (*quotation*).
Generell bezeichnen wir ein in einem Stapel "verpacktes" Programm als
Quotierung.

Schauen wir uns das am Beispiel an. Das Wort `rot` verändert die
Position der obersten drei Werte auf dem Datastack. Das dritte Element
von oben "rotiert" an die führende Stelle ganz oben auf dem Stapel, was
die vormalig obersten zwei Elemente absteigen lässt.

    > clear x y z
    x y z
    > rot
    y z x

Das einleitende `clear` räumt den Datastack auf und lässt einen leeren
Datastack zurück. Wir werden sehr oft bei den Beispielen `clear`
verwenden, um eine definierte Situation auf dem Datastack zu haben.

[]{#rotsource label="rotsource"}Mittels `\ rot source` können Sie das
Wort `rot` im Wörterbuch nachschlagen. Das Ergebnis landet nicht auf dem
Datastack, sondern wird über die Konsole ausgegeben, bevor der Inhalt
des Datastacks angezeigt wird. Der Datastack bleibt unverändert.

    > \ rot source
    <fct>
    y z x

Die Ausgabe `<fct>` besagt, dass zu `rot` eine Funktion im Wörterbuch
eingetragen ist; `rot` ist also ein atomares Wort, man sagt auch
primitives Wort.

Erinnern Sie sich noch, warum Sie bei `source` dem Wort `rot` ein `\`
voranstellen müssen? Das Quotierungswort `\` "zieht" das nachfolgende
Wort direkt auf den Datastack und verhindert damit ein Nachschlagen im
Wörterbuch samt Ausführung des Wortes.

Ein Beispiel für ein nicht-atomares Wort ist `-rot`. Es setzt sich aus
zwei `rot`-Wörtern zusammen.

    > \ -rot source
    [ rot rot ]
    y z x

Wann immer im Wörterbuch eine Quotierung die Bedeutung eines Wortes
angibt, wird die Quotierung mit dem Callstack konkateniert (aneinander
gefügt) und als neuer Callstack betrachtet. Dem Augenschein nach sieht
es so aus, als ob `-rot` auf dem Callstack durch `rot` `rot` ersetzt
wird; der Fachausdruck lautet "substituiert".

Die Auswirkungen von `-rot` kann man sich durch ein zweifaches `rot`
veranschaulichen. Die Eingabe von `-rot`

    > -rot
    x y z

wird von Consize durch `rot rot` ersetzt. Nur atomare Wörter kann
Consize direkt ausführen. Die Quotierungen zu nicht-atomaren Wörtern
werden mit dem Callstack konkateniert. Diese, im Wörterbuch
eingetragenen Quotierungen zu einem Wort, stellen "benamte
Abstraktionen" dar. Das Wort `-rot` abstrahiert die Wortfolge
`[ rot rot ]`. Anders gesagt, `-rot` ist der Name für die Abstraktion
`[ rot rot ]`.

Wenn Sie ein Wort nachschlagen, das nicht im Wörterbuch verzeichnet ist,
meldet Ihnen Consize das: Es kann nichts (`nil`) im Wörterbuch gefunden
werden.

    > \ x source
    nil
    x y z

Wörter, die nicht im Wörterbuch stehen, legt Consize standardmäßig auf
dem Datenstack ab. Das ist jedoch nur die halbe Wahrheit. Außerdem --
und das haben wir bislang unterschlagen -- legt Consize das Wort
`read-word` auf dem Callstack ab. Was nun mit dem Wort auf dem Datastack
passiert hängt davon ab, welche Abstraktion für `read-word` im
Wörterbuch hinterlegt ist.

    > \ read-word source
    [ ]
    x y z

Mit `read-word` ist ein leerer Stapel assoziiert, der in Konkatenation
mit dem Callstack den Callstack unverändert lässt. Die Definition von
`read-word` belässt folglich unbekannte Wörter auf dem Datastack. Sie
können das Wort `read-word` anpassen, um besondere Wörter gesondert
behandeln zu können.

## Mappings

Das Wörterbuch der Consize-VM ist nur ein Sonderfall einer
Datenstruktur, die wir allgemeiner als Mapping (Abbildung) bezeichnen.
Ein Mapping assoziiert einen Schlüsselwert (*key value*) mit einem
Zielwert (*target value*). Jeder Schlüsselwert kann nur genau einmal
vorkommen, somit ist die Abbildung auf einen Zielwert immer eindeutig.
Wir nennen ein Mapping dann Wörterbuch, wenn alle seine Schlüsselwerte
Wörter sind.

Ein Mapping wird in Consize mit geschweiften Klammern dargestellt.
Innerhalb der Klammern stehen in freier Abfolge Paare von Schlüssel- und
Zielwerten; das Leerzeichen dient in gewohnter Manier als Trennzeichen.

Es gibt in Consize kein direktes Wort, um ein leeres Mapping anzulegen.
Man muss zunächst einen leeren Stapel auf dem Datastack erzeugen, den
ein nachfolgendes `mapping` in ein Mapping verwandelt.

    > emptystack mapping
    { }

Um einen Schlüsselwert mit einem Zielwert zu assoziieren, muss zunächst
der Zielwert, dann der Schlüsselwert und zu guter Letzt das Mapping auf
dem Datastack liegen, das die Assoziation aufnehmen soll. Dabei kommt
uns `rot` zu Hilfe.

    > 1 mon rot
    1 mon { }
    > assoc
    { mon 1 }

Und so lassen sich weitere Paare von Schlüssel- und Zielwerten
hinzufügen.

    > 3 wed rot assoc
    { wed 3 mon 1 }

Auch ein nicht-leerer Stapel kann, sofern er eine gerade Anzahl an
Werten hat, mit `mapping` in ein Mapping überführt werden.

    > emptystack 2 push tue push
    { wed 3 mon 1 } [ tue 2 ]

Um eine vollständige Aufführung der Wochentage einer Arbeitswoche zu
haben, fügen wir noch die fehlenden Tage hinzu, bevor wir aus dem Stapel
ein Mapping machen.

    > 5 push fri push 4 push thu push
    { wed 3 mon 1 } [ thu 4 fri 5 tue 2 ]
    > mapping
    { wed 3 mon 1 } { thu 4 fri 5 tue 2 }

Die beiden Mappings lassen sich mit `merge` zu einem zusammenführen. Die
Reihenfolge der Auflistung der Schlüssel/Ziel-Paare ist ohne Bedeutung
und kann abweichen von dem, was Sie hier gezeigt bekommen.

    > merge
    { tue 2 fri 5 thu 4 wed 3 mon 1 }

Man kann nun das Mapping befragen, welcher Wert beispielsweise mit dem
Wort `wed` assoziiert ist. Dazu dient das Wort `get`, das erst einen
Schlüsselwert, dann ein Mapping und zuoberst auf dem Stapel einen Wert
erwartet, der das Ergebnis ist, falls der Schlüsselwert nicht im Mapping
vorhanden ist. `rot` wird uns wieder helfen, die gewünschte Ordnung auf
dem Datastack herzustellen.

    > key-not-found wed -rot
    wed { tue 2 fri 5 thu 4 wed 3 mon 1 } key-not-found
    > get
    3

Das über die Prelude erweiterte Consize erlaubt die Eingabe von Mappings
auch direkt über geschweifte Klammern.

    > { 1 a 2 b 3 c }
    3 { 1 a 2 b 3 c }

Mit `dissoc` lässt sich eine Schlüssel-/Zielwert-Bindung entfernen. Dazu
muss das Mapping zuoberst auf dem Datastack liegen, der betreffende
Schlüssel darunter. Hier nutzen wir gleich das verbliebene Wort `3` auf
dem Stapel.

    > dissoc
    { 1 a 2 b }

Das Wort `keys` liefert alle Schlüsselwerte eines Mappings in einem
Stapel zurück -- ohne irgendeine Garantie, in welcher Reihenfolge die
Schlüssel im Stapel aufgeführt sind.

    { 1 a 2 b }
    > keys
    [ 1 2 ]

Mappings sind eine sehr leistungsfähige und bedeutsame Datenstruktur. In
manchen Programmiersprachen tragen sie einen anderen Namen und heißen
dort etwa *Map* oder assoziative Arrays. In JavaScript sind Mappings die
Grundlage für Objekte, ähnlich in Python.

Wenn Sie sich das Wörterbuch der VM von Consize anschauen wollen -- es
ist nichts anderes als ein Mapping --, dann legt Ihnen `get-dict` das
Wörterbuch auf dem Datastack ab. Seien Sie nicht erschreckt über den
unübersichtlichen Datenwust. Sie werden im Laufe der Zeit sehr genau
verstehen, was sich so alles aus welchem Grund in dem Wörterbuch der VM
befindet.

Übrigens sind als Schlüssel- wie auch als Zielwerte beliebige Werte für
Mappings erlaubt. So darf sogar ein Stapel oder ein Mapping als
Schlüsselwert verwendet werden.

## Was sind Datenstrukturen?

Sie haben nun die drei Arten von Daten kennengelernt, die Consize
unterstützt: Wörter und in dem Zusammenhang Funktionen, Stapel und
Mappings -- man spricht auch von
[Datentypen](http://de.wikipedia.org/wiki/Datentyp). Dazu kommt noch ein
Datentyp namens *Nil* (für "Nichts"). Mehr Datentypen kennt Consize von
Haus aus nicht.

Wörter und Funktionen sind Vertreter der einfachen oder auch primitiven
Datentypen (*primitive datatypes*). Sie repräsentieren ein Datum, sie
stehen sozusagen für sich selbst. Stapel und Mappings dagegen sind zwei
Vertreter der zusammengesetzten Datentypen (*compound datatypes* oder
auch *composite datatypes*); mit ihnen wird Daten eine Struktur gegeben,
weshalb man auch von
[Datenstrukturen](http://de.wikipedia.org/wiki/Datenstruktur) spricht.

Die Struktur der Daten deutet sich in den verwendeten Notationen an. Die
eckigen Klammern für Stapel markieren den Anfang und das Ende der
Stapel-Datenstruktur; ebenso markieren die geschweiften Klammern Anfang
und Ende eines Mappings. Wie Consize die Daten jedoch intern im Speicher
organisiert, das ist Ihnen verborgen, darauf haben Sie keinen Zugriff.
Sie wissen lediglich, das Ihnen für den Umgang mit Stapel und Mappings
ein paar Worte zur Verfügung stehen.

Diese Abschottung von den Interna der eingebauten Datenstrukturen ist in
vielen Programmiersprachen so gewollt. Sie sind Teil der Sprache und man
möchte verhindern, dass Sie damit irgendwelchen Schindluder treiben.

Was Sie jedoch wissen sollten, ist, wie "teuer" Ihnen der Gebrauch der
Datenstrukturen kommt. Es gibt immer einen Preis zu zahlen und zwar in
der Währung "Zeit" und in der Währung "Speicherverbrauch". Da Ihnen in
vielen Programmiersprachen mehr Datenstrukturen als Stapel und Mappings
zur Verfügung stehen, haben Sie nicht selten die Qual der Wahl: Welche
Datenstruktur wollen Sie wofür nehmen? Das ist immer eine Frage nach:
Wie schnell bedient mich die Datenstruktur für meinen Einsatzzweck, und
wieviel Speicher frisst sie mir weg?

Mit den einzelnen Namen wie Stapel, Liste, Array, Queue -- um nur einige
zu nennen -- sind verschiedene Kosten für Zeit und Speicher verbunden.
Dabei lassen sich all diese Datenstrukturen prinzipiell über exakt die
gleichen Operationen (Wörter) ansprechen.

Zum Beispiel können Daten von einem Stapel immer nur "von oben"
abgegriffen werden. Egal wie groß der Stapel ist, das oberste Element
ist immer "sofort" erhältlich, d.h. mit einem `top` erreichbar. Das
"unterste" Element in einem Stapel kann nur sukzessive über eine Reihe
von `pop`s und einem abschließenden `top` erreicht werden. Es werden
genau so viele Wörter benötigt, um an das unterste Element zu kommen,
wie es Elemente auf dem Stapel gibt. Für den Zugriff auf das $n$-te
Element auf dem Stapel (von oben gezählt) benötigt man genau $n$ Wörter,
um an dieses Element heranzukommen.

Bei einer Liste ist der Zugriff auf das erste und das letzte Element
gleichermaßen schnell, ebenso auf das zweite und vorletzte usw. Eine
Liste ist eine Art Stapel, der von beiden Seiten gleichermaßen gut
zugreifbar ist, was in manchen Fällen von Vorteil ist.

Bei einem Array (manchmal auch Vektor genannt) kann man über einen Index
auf die Elemente zugreifen. Das erste, zweite, dritte Element, allgemein
das $n$-te Element, ist immer in der gleichen Zeit abrufbar.

Dies soll Ihnen nur einen Eindruck geben, wie sehr unterschiedliche
Datenstrukturen unterschiedliche Zugriffszeiten auf die durch sie
organisierten Daten mit sich bringen. Und dies, ohne dass Sie etwas über
die Interna der Datenhaltung zu wissen brauchen.

Jede Datenstruktur hat ihre Vor- und Nachteile. Consize ist eine
stapelbasierte Programmiersprache. Es ist das Auszeichnungsmerkmal von
Consize, dass es zur Daten- und Programmhaltung nicht mehr und genau nur
zwei Stapel benötigt -- und ein Mapping als Wörterbuch. Für die
stapelbasierten Operationen sind Stapel, es mag kaum verwundern, eben
optimal.

Ein Mapping kann man auch über einen Stapel simulieren, aber dann werden
die Zugriffszeiten auf die über die Schlüssel assoziierten Zielwerte
sehr ungünstig. Consize würde Ihnen zu langsam werden, sie hätten keinen
Spaß daran. Darum habe ich mich entschieden, Mappings in ihrer Reinform
in Consize mit aufzunehmen. Der Zugriff auf assoziierte Werte ist sehr
schnell und günstig. Aber nicht nur deshalb. Mit Mappings hat man eine
sehr hilfreiche Datenstruktur, mit der sich so manch nettes Feature in
Consize umsetzen lässt.

Ein Rat an dieser Stelle: Lernen Sie in jeder neuen Programmiersprache
die verfügbaren Datentypen kennen und finden Sie heraus, welche Vorzüge
und welche Nachteile jede Datenstruktur mit sich bringt. Informatiker
geben diese "Kosten" in Sachen Laufzeit
([Zeitkomplexität](http://de.wikipedia.org/wiki/Zeitkomplexit%C3%A4t))
und Speicherbedarf
([Platzkomplexität](http://de.wikipedia.org/wiki/Platzkomplexit%C3%A4t))
mit Hilfe der
["Big-O"-Notation](http://en.wikipedia.org/wiki/Big_O_notation) an. Zu
den Standard-Datenstrukturen gehören Stapeln, Listen, Arrays (Vektoren),
Mappings (Dictionaries, Assoziative Arrays), Queues, Bäume und Graphen
-- darüber sollten Sie Bescheid wissen.

Eine wichtige Anmerkung noch: Der Stapel ist der einzige Datentyp in
Consize für eine geordnete Ansammlung (*collection*) von Elementen. Und
oftmals wird er auch genau dafür gebraucht: Für eine Folge (*sequence*)
von Elementen. Da ist es eher unerheblich, ob dafür ein Stapel verwendet
wird oder nicht -- Consize ist da alternativlos. Stünden weitere
Datenstrukturen zur Verfügung, dann wären beispielsweise Listen oder
Arrays oft eine geeignetere Wahl für Sequenzen.

Darum wundern Sie sich bitte nicht: Wenn ich von Folgen oder Sequenzen
rede, dann ist mir die Tatsache nicht entscheidend, dass die Folge
bzw. Sequenz in Consize durch einen Stapel abgebildet wird. Dann
abstrahiere ich von der konkreten, zugrunde liegenden Datenstruktur. Und
ein anderer Name wird immer wieder fallen: der der Quotierung. Eine
Quotierung ist eine Sequenz, deren Elemente ein Programm darstellen.

Ein Mapping realisiert ebenfalls eine Datensammlung (*collection*), aber
eine ungeordnete. Die Ordnung der Schlüssel/Ziel-Paare ist ohne
Bedeutung, darauf kommt es bei Mappings nicht an.

[^1]: Ich verwende Consize zusammen mit Microsoft Windows.
