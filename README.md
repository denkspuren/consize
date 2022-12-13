# Consize

Consize is a [concatenative programming language](https://en.wikipedia.org/wiki/Concatenative_programming_language). It is a close relative to the [Factor programming language](https://factorcode.org/). The word "Consize" is intentionally misspelled, it is a combination of the words "concatenative" and "size". Concatenative programs tend to be concise and small in size. 

I designed Consize for research purposes and for educational purposes. For example, Consize is used in my masters course "Kernel Architectures in Programming Languages" (Kernel-Architekturen in Programmiersprachen) at the Department of Mathematics, Natural Sciences and Informatics, University of Applied Sciences Mittelhessen (Technische Hochschule Mittelhessen), Germany.

Consize comes with comprehensive documentation explaining the concatenative paradigm, the interpreter and the built-in library, the so called _prelude_. The documentation is written in German, since my German students are my primary target audience. Though English is the _lingua franca_ in informatics, it is a barrier to learn new concepts of an uncommon programming paradigm in a foreign language. Nonetheless, I might consider rewriting the documentation in English.
Until then consider using e.g. [Google's website translator](https://translate.google.com/?op=websites) with the markdown variant of the [documentation](https://github.com/denkspuren/consize/blob/master/doc/Consize.md) (thanks a lot to @D00mch for producing the markdown version for that purpose).

I feel always thrilled by the fact that the raw interpreter is no more than 150 lines of code written in [Clojure](https://clojure.org). Basically, Consize is written in Consize and bootstrapped from a small image, which has also been produced by and with Consize.

Regarding conciseness: Consize has numerous words for functional programming, most words being composed of one, two or three lines of code; Consize comes with a unit test framework implemented in eight lines of code; you can set breakpoints and step through the code for debugging purposes implemented in three lines of code; serialization and producing image dumps comes also in some few lines. Do you have an interest in meta-programming? Not only has Consize a meta-protocol to handle unknown words, but _continuations_ which allow you to manipulate the future of computations -- continuations are used to implement an _ad hoc_ parser to extend the grammar of Consize.

Whet your appetite? You might head over reading the [documentation](/doc/Consize.pdf) first.

Enjoy,

Dominikus Herzberg, [@denkspuren](https://twitter.com/denkspuren)
https://www.thm.de/mni/dominikus-herzberg

## Installation

Consize is implemented in Clojure. Since Clojure depends on the Java Virtual Machine, the JVM, the first two installation steps are:

1. Install the JVM on your computer. Visit [java.com](http://www.java.com), download the installer and execute it.
2. Go to [clojure.org](http://clojure.org) and install Clojure. Follow the instructions for your operating system, see ["Getting started"](https://clojure.org/guides/getting_started).

Check, if Clojure can be executed on your computer. Open a [command shell](http://en.wikipedia.org/wiki/Command_shell) (on Windows, the `powershell` is used) and try, if Clojure starts up. Be patient on a slow computer.

    PS C:\Users\Dominikus> clj
    Clojure 1.10.3
    user=>

If Clojure is running on your computer, that's great. Proceed with the installation of Consize. To quit Clojure press the [Control key](http://en.wikipedia.org/wiki/Control_key) `Ctrl` (or `Strg` on a German keyboard) and `C`. If Clojure does not work on your computer, consult an expert or get some help on the Web.

For Consize, either clone the [GitHub repository](https://github.com/denkspuren/consize) or download the code as a zip-file and unzip it. Change to `/src` in the `consize` folder. The following files are essential:

* `consize.clj` -- that's the Consize VM implemented in Clojure
* `bootimage.txt` -- required by Consize to process the prelude
* `prelude-plain.txt` -- the prelude provides a basic infrastructure for programming in Consize.
* `prelude.txt` -- a serialized version of the prelude, which is faster to load
* `prelude-test.txt` -- a suite of test cases checking if everything is working properly

Type the following in your command line:
 
    clj -M consize.clj "\ prelude-plain.txt run say-hi"

For shorter start-up time, you might also run:

    clj -M consize.clj "\ prelude.txt run say-hi"

Be careful to correctly reproduce the above line. On a slow computer you might need to wait some few seconds to see Consize displaying:

    This is Consize -- A Concatenative Programming Language
    >

Excellent, you are done. You successfully installed Consize!

## Some First Steps in Consize

For example, type in

~~~
> 2 3 +
5
> clear

> 2 5 [ 1 + ] bi@
3 6
clear
~~~

To define the factorial function:

~~~
> : ! ( n -- n! ) dup 0 equal? [ drop 1 ] [ dup 1 - ! * ] if ;

> 4 !
24
> 6 !
24 720
~~~

Run the suite of unit tests to check if everything works as expected.

~~~
\ prelude-test.txt run
~~~

To quit Consize type `exit`.

Read the [documentation](/doc/Consize.pdf) to understand how Consize works and how programming in Consize is done.

> If you are interested in doing some research on concatenative programming, see my announcement (in German): [Compiler-Optimierung durch partielle Interpretation umgesetzt für die konkatenative Sprache Consize](research/PartialInterpretation.Topic.md); this might result in a beautiful master thesis ;-) 

For your convenience, you might want to create a [batch file](http://en.wikipedia.org/wiki/Batch_file) on Windows or a [shell script](http://en.wikipedia.org/wiki/Shell_script) on Linux/OS X. On Windows my batch file named `consize.bat` looks like this:

    @echo off
    powershell clj -M consize.clj "\ prelude-plain.txt run say-hi"
    pause

All I have to do is to click on `consize.bat` and Consize is started.

## How to Extract the Prelude from the Documentation?

The prelude is a Consize program extending Consize considerably for practical use. Without the prelude there is no interactive console to interact with (called the REPL, _Read Evaluate Print Loop_), there are no means to define new words etc. You wouldn't have much fun with Consize without the prelude.

The prelude is written as a _literate program_ (see [literate programming](https://en.wikipedia.org/wiki/Literate_programming)), that means the code is embedded in its documentation. Literate programming is a technique to keep the documentation and the code in sync.

Have a look at [Consize.Prelude.tex](/doc/Consize.Prelude.tex) and watch out for lines starting with either `>>` or `%>>`; the `%`-sign marks a comment in LaTeX. All these lines make up the prelude (with the marking prefix removed).

To extract the prelude from the documentation, you do not need a special program, Consize has the word `undocument` for that.

> There is no need to extract the prelude if you are not interested in updating and/or extending Consize. Consize is delivered with "batteries included", i.e. with a prelude and a tiny bootimage. So you might stop here and just enjoy running and using Consize.

Run Consize and type the following in the REPL; the word `slurp` reads a file, the word `spit` writes a file.

~~~
> \ ../doc/Consize.Prelude.tex slurp undocument \ new.prelude-plain.txt spit
~~~

You will find a file named `new.prelude-plain.txt` in your `/src` directory. You can restart Consize with the new prelude. Leave Consize with entering `exit` and restart Consize on the command line interface:

~~~
> clj -M consize.clj "\ new.prelude-plain.txt run say-hi"
~~~

To produce an image of the current status of the dictionary, type

~~~
This is Consize -- A Concatenative Programming Language
> get-dict \ new.prelude-dump.txt dump
~~~

The image file `new.prelude-dump.txt` loads faster than the plain source code file `new.prelude-plain.txt`. The reason is that the source code requires syntactic preprocessing to fill the dictionary with word definitions whereas the image file just reconstructs the dictionary.

It's a good idea to verify whether something is broken. Run the test suite with each version of the Prelude, `new.prelude-plain.txt` and `new.prelude-dump.txt`. Start each version separately, run the tests, exit for testing the other version.

~~~
> clj -M consize.clj "\ new.prelude-plain.txt run say-hi"
This is Consize -- A Concatenative Programming Language
> \ prelude-test.txt run
~~~

~~~
> clj -M consize.clj "\ new.prelude-dump.txt run say-hi"
This is Consize -- A Concatenative Programming Language
> \ prelude-test.txt run
~~~

If you want to, you can also generate `bootimage.txt`. The bootimage is a dump of a minimalistic directory that includes all the word definitions required to load the prelude. To produce the bootimage type the following in the REPL; take care, the current version of the bootimage gets overwritten by that -- you might create a copy beforehand.

~~~
> bootimage
~~~

After that, run both versions of Consize again (plain file and image file) and run the test suite one more time. If there are no problems, you are almost done.

Delete the old versions of the prelude and rename the ones you have created:

* rename `new.prelude-plain.txt` to `prelude-plain.txt`
* rename `new.prelude-dump.txt` to `prelude.txt`

Congratulations, you are done!

By the way, did you notice that we had to use a running version of the prelude and the bootimage to extract a new version of the prelude from the documentation and generate a fresh bootimage afterwards? This is a typical process for image-based self-referential implementations. Otherwise you would have to extract the prelude by hand and to generate the bootimage by hand -- which I did for the very first incarnation of the bootimage.

## Generate the Documentation

> If you have no interest in updating the documentation, skip this section!

To produce the PDF document yourself, install a TeX distribution on your computer such as [MikTeX](https://miktex.org/) for Windows. Start the compilation process with `Consize.tex`. On Windows you might use `TeXworks` for that purpose, which is released with MikTeX.
