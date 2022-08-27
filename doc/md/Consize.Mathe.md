# Mathematische Grundlagen

Consize ist eine funktionale Programmiersprache, die nicht -- wie meist
üblich -- auf dem Lambda-Kalkül, sondern auf einem Homomorphismus
beruht, der Programme mit Funktionen und die Konkatenation von
Programmen mit Funktionskomposition in Beziehung setzt

## Der konkatenative Formalismus in denotationeller Semantik

Gegeben sei ein Vokabular $V=\{w_1, w_2, \dots\}$ mit einer
[Menge](http://de.wikipedia.org/wiki/Menge_(Mathematik)) von Wörtern.
Die Menge aller nur erdenklichen Sequenzen, die mit den Wörtern des
Vokabulars $V$ gebildet werden können -- das beinhaltet sowohl die leere
Sequenz als auch beliebige Verschachtlungen -- sei mit $S^V$ bezeichnet
und werde mit Hilfe der [Kleeneschen
Hülle](http://de.wikipedia.org/wiki/Kleenesche_und_positive_H%C3%BClle)
definiert; $S$ sei aus $V$ abgeleitet zu $S=\{[w_1],[w_2],\dots\}$:

$$S^V=S^{\ast}\cup(S^{\ast})^{\ast}\cup((S^{\ast})^{\ast})^{\ast}\cup\dots$$

Der Operator zur Konkatenation $\oplus: S^V\times S^V \rightarrow S^V$
konkateniere zwei Sequenzen
$[s_1,\dots,s_n]\oplus[s_1',\dots,s_m']=[s_1,\dots,s_n,s_1',\dots,s_m']$.
$(S^V,\oplus,[\,])$ bildet einen
[Monoid](http://de.wikipedia.org/wiki/Monoid): Die Operation der
Konkatenation ist in sich geschlossen, die leere Sequenz ist das
[neutrale Element](http://de.wikipedia.org/wiki/Neutrales_Element) der
Konkatenation, und das [Gesetz der
Assoziativität](http://de.wikipedia.org/wiki/Assoziativgesetz) gilt.

Gegeben sei weiterhin die Menge der
[Funktionen](http://de.wikipedia.org/wiki/Funktion_(Mathematik))
$F=\{f_1, f_2, \dots\}$, wobei für alle Funktionen $f\in F$ gilt:
$f:S^V_{\bot}\rightarrow S^V_{\bot}$. Das Symbol $\bot$ markiert in der
[denotationellen
Semantik](http://de.wikipedia.org/wiki/Denotationelle_Semantik) den
Fehlerfall, $S^V_{\bot}=S^V\cup\{\bot\}$. Es gilt: $f(\bot)=\bot$.

Der Operator zur [Komposition zweier
Funktionen](http://de.wikipedia.org/wiki/Komposition_(Mathematik))
$;:(S^V_{\bot}\rightarrow S^V_{\bot}) \times
(S^V_{\bot}\rightarrow S^V_{\bot}) \rightarrow
(S^V_{\bot}\rightarrow S^V_{\bot})$ definiere die Komposition zweier
Funktionen $f:S^V_{\bot}\rightarrow S^V_{\bot}$ und
$g:S^V_{\bot}\rightarrow S^V_{\bot}$ als
$f;g: S^V_{\bot}\rightarrow S^V_{\bot}$, wobei gilt $(f;g)(s)=g(f(s))$
für alle $s\in S^V_{\bot}$. Das neutrale Element der
Funktionskomposition ist die
[Identitätsfunktion](http://de.wikipedia.org/wiki/Identische_Abbildung)
$id:S^V_{\bot}\rightarrow S^V_{\bot}$ mit $id(s)=s$ für alle
$s\in S^V_{\bot}$. $(S^V_{\bot},;,id)$ bildet ebenfalls einen Monoid.

Zu den beiden Monoiden, der Konkatenation von Sequenzen und der
Komposition von Funktionen, gesellen sich zwei weitere Funktionen, um
die Bedeutung (Denotation) einer Sequenz als "Programm" zu definieren.
Wir nennen eine solche Sequenz auch "Quotierung".

Das Wörterbuch werde durch eine Funktion $D:V\rightarrow F$ gegeben:
Jedes Wort ist eindeutig mit einer Funktion assoziiert. Die Funktion
$self:S^V\rightarrow (S^V\rightarrow S^V)$ sei definiert als
$self(s)(s')=[s]\oplus s'$, $s, s'\in S^V$.

Die Denotation $\ldenote s \rdenote$ einer Sequenz $s\in S^V$ liefert
immer eine Sequenz verarbeitende Funktion zurück und ist definiert über
sämtliche Spielarten, die für die Sequenz $s$ denkbar sind: (1) wenn sie
leer ist, (2) wenn sie ein einziges Wort enthält, (3) wenn sie eine
einzige Sequenz enthält, und (4) wenn die Sequenz aus den vorigen
Möglichkeiten zusammengesetzt ist.

1.  $\ldenote [\,] \rdenote = id$

2.  $\ldenote [ w] \rdenote = f$ für $w\in V$ und $f=D(w)$

3.  $\ldenote [ s] \rdenote = self(s)$ für $s\in S^V$.

4.  $\ldenote s_1\oplus s_2 \rdenote =
           \ldenote s_1 \rdenote ; \ldenote s_2 \rdenote$ für
    $s_1,s_2\in S^V$.

Die vier Gleichungen betonen den
[Homomorphismus](http://de.wikipedia.org/wiki/Homomorphismus): Die
Konkatenation von Sequenzen findet ihr Abbild in der Komposition von
Funktionen. Für
[Turing-Vollständigkeit](http://de.wikipedia.org/wiki/Turing-Vollst%C3%A4ndigkeit)
genügt ein Homomorphismus allein nicht. Es fehlt etwas, das die
[Selbstbezüglichkeit](http://de.wikipedia.org/wiki/Selbstbez%C3%BCglichkeit)
herstellt -- das entscheidende Merkmal turingvollständiger Systeme

Den notwendigen Selbstbezug stellt die zu $self$ inverse Funktion
$self^{-1}$ her. Die Funktion sei definiert über den Zusammenhang

$$(self;self^{-1})(s) = \ldenote s \rdenote$$

Das mit der Funktion $self^{-1}$ assoziierte Wort heiße `call`. Statt
diese Assoziation als Bestandteil des Wörterbuchs einzufordern, gelte
mit `call` $\notin V$ die fünfte "Regel":

1.  $\ldenote [$`call`$] \rdenote = self^{-1}
    \Rightarrow
    \ldenote [s]\oplus[$`call`$] \rdenote = \ldenote s \rdenote$

Elementarer kann man eine Programmiersprache kaum mehr formalisieren. Es
ist das Minimum dessen, was in Anlehnung an die
[Kategorientheorie](http://de.wikipedia.org/wiki/Kategorientheorie) den
Formalismus zu einer [kartesisch abgeschlossen
Kategorie](http://de.wikipedia.org/wiki/Kartesisch_abgeschlossene_Kategorie)
(*cartesian closed category*) und damit turingvollständig macht.

Die Implikationen sind beachtlich: Der konkatenative Formalismus
entledigt sich einer "Bürde" des Lambda-Kalküls: Variablen. Variablen
sind in diesem System vollkommen überflüssig, was Begründungen über
Consize-Programme erheblich vereinfacht und das gedankliche Mitführen
von Umgebungsvariablen (wie in der Veranschaulichung des
[Lambda-Kalküls](http://de.wikipedia.org/wiki/Lambda-Kalk%C3%BCl)
üblich) unnötig macht.

Das notwendige Arrangieren von Argumenten auf dem Stapel übernehmen so
genannte Stack-Shuffler, die ihrerseits Funktionen sind und sich somit
vollkommen einfügen in das Schema der Funktionskomposition.

Der konkatenative Formalismus ist -- ähnlich dem Lambda-Kalkül -- in
dieser extremen Reduktion kaum einsatztauglich für praktische
Programmierzwecke. Entscheidend ist die Einführung benamter
Abstraktionen. Namen sind wichtige "Krücken" in der Begrenzung des
menschlichen Intellekts sich anonyme Abstraktionen praktisch kaum merken
zu können.

## Der Bezug zur operationalen Semantik, der Consize-VM

Der konkatenative Formalismus und die [operationale
Semantik](http://de.wikipedia.org/wiki/Operationale_Semantik) scheinen
sich auf den ersten Blick fremd zu sein. Tatsächlich ist die
operationale Semantik dem konkatenativen Formalismus sehr treu.

Wörter, Funktionen und Sequenzen (in Consize durch Stapel implementiert)
sind leicht in Deckung gebracht. Die Funktion von Mappings (in anderen
Sprachen auch als Hashmaps, assoziative Arrays oder Dictionaries
bezeichnet) kann durch Stapel emuliert werden. Mappings sind für ihren
Einsatzzweck jedoch deutlich effizienter als es Stapel sind.

Die folgenden Betrachtungen beziehen sich auf die operationale Semantik,
so wie sie in
Kap. [\[Sec:Continuations\]](#Sec:Continuations){reference-type="ref"
reference="Sec:Continuations"} durch das Wort `stepcc` definiert ist.
Dabei gehen wir ausführlich auf die drei Fallunterscheidungen bei der
Beschreibung von `stepcc` ein (S.  ff.).

Die scheinbare Erweiterung, das globale Wörterbuch nicht nur auf die
Assoziation mit Funktionen zu beschränken und auf Quotierungen
auszudehnen, begründet sich in den Gleichungen (2) und (4). Statt neue
Funktionen über die Funktionskomposition zu bilden und im Wörterbuch mit
Wörtern zu assoziieren, stellt Gleichung (4) die Option in den Raum,
eine Quotierung im Wörterbuch einzutragen. Semantisch ändert sich
dadurch nichts, solange jede Quotierung so weit auf Einzelwörter
"dekonkateniert" und durch assoziierte Quotierungen aufgelöst wird, bis
eine Funktion im Wörterbuch die Ausführung der Funktion laut Gleichung
(2) einfordert. `stepcc` setzt diese Option konsequent um.

Diese Option hat mehrere, entscheidende Vorteile: Erstens sind auf diese
Weise zwanglos benamte Abstraktionen eingeführt. Unbenamte Quotierungen
werden als "anonyme Abstraktionen" bezeichnet, benamte, sprich über das
Wörterbuch assoziierte Quotierungen als "benamte Abstraktionen".

Zweitens fehlt Funktionen eine sie identifizierende Repräsentation; alle
Funktionen werden durch `<fct>` repräsentiert. Würde Consize
ausschließlich Wörter mit Funktionen assoziieren, so wären die
Repräsentationen der Funktionsabstraktionen aussagelos. Dagegen sprechen
die in Quotierungen enthaltenen Wörter Klartext; sie sind identisch mit
dem Programmtext bei der Programmierung. Damit ist die Reflektion von
Abstraktionen in Consize sehr einfach.

Das hat drittens zur Folge, dass man den Callstack bzw. Quotierungen
nicht nur einfach reflektieren, sondern ebenso einfach manipulieren
kann. Davon macht `call/cc` Gebrauch, indem es die auf dem Datastack
liegende Quotierung zum Programm macht und die "übrige" Continuation
frei gibt zur beliebigen Manipulation. Streng genommen kann mit
`call/cc` der konkatenative Formalismus ausgehebelt werden, da eine
uneingeschränkte Manipulation der rechnerischen Zukunft eines Programms
möglich ist. Übt man ein wenig Programmierdisziplin und nutzt `call/cc`
im Sinne einer *delimited continuation*, so ist das unkritisch und
wieder im Einklang mit dem konkatenativen Formalismus. So ist denn auch
die Realisierung von `call` (Gleichung (5)) mittels `call/cc`
unproblematisch wie auch das Parsen von Klammern zur Laufzeit.

Anbei bemerkt zeigt die Diskussion einen interessanten Zusammenhang auf:
Delimited Continuations sind das Laufzeitäquivalent einer
Vorverarbeitung einer Quotierung vor ihrem Aufruf mit `call`.

Viertens kann ein konkatenatives Programmiersystem auch gänzlich anders,
nämlich über ein Rewriting System mit Pattern Matching und Pattern
Instantiation implementiert werden, was insbesondere das Stack-Shuffling
so gut wie überflüssig macht.

Das Meta-Wort `read-word` ist ein pragmatisches Feature, um auch
unbekannte, nicht im Wörterbuch aufgeführte Wörter in Anwendung von
Gleichung (2) grundsätzlich mit einer Funktion zu assoziieren.

Ähnlich zu `read-word` ist `read-mapping` ein Feature, um Mappings --
die ja auch durch Stapel umgesetzt werden könnten -- gemäß Gleichung (3)
zu behandeln oder ihnen, sofern ein Mapping etwas anderes darstellen
soll, eine Sonderbehandlung zukommen zu lassen.

Wenn `itm` weder ein Wort noch ein Mapping ist, dann muss es ein Stapel,
eine Funktion oder "nil" sein. Gleichung (3) beschreibt die Behandlung
eines Stapels. Funktionen sind entsprechend der dargelegten
Argumentation wie Quotierungen, d.h. ebenfalls wie Stapel zu behandeln.
Da "nil" in Consize nur im Kontext von Stapeln eine Funktion hat, ist
auch hier Gleichung (3) schlüssig angewendet.

Die Consize-Implementierung ist ein zu Lehrzwecken geeignetes Beispiel,
welche Design-Optionen ein Formalismus erlaubt, um ihn als Virtuelle
Maschine zu realisieren. Die Funktion `stepcc` beansprucht keine 20
Zeilen Code in ihrer Implementierung.
