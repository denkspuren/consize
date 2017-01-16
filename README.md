# Consize

Consize is a concatenative programming language. It is a close relative to the [Factor programming language](https://factorcode.org/). The word "Consize" is intentionally misspelled, it is a combination of the words "concatenative" and "size". Concatenative programs tend to be small in size and concise. 

I designed Consize for research purposes and for educational purposes. For example, Consize is used in my master course "Kernel Architectures in Programming Languages" (Kernel-Architekturen in Programmiersprachen) at the Department of Mathematics, Natural Sciences and Informatics, University of Applied Sciences Mittelhessen (Technische Hochschule Mittelhessen), Germany.

Consize comes with comprehensive documentation explaining the concatenative paradigm, the interpreter and the built-in library, the so called _prelude_. Consize comes with comprehensive documentation. The documentation is written in German, since my German students are my primary target audience. Though English is the _lingua franca_ in informatics, it is a barrier to learn new concepts of an uncommon programming paradigm in a foreign language. Nonetheless, I might consider rewriting the documentation in English.

I feel always thrilled by the fact that the interpreter is not more than 150 lines of code written in Clojure. Basically, Consize is written in Consize and bootstrapped from a small image, which has also been produced by and with Consize.

Regarding conciseness: Consize has numerous words for functional programming, most words being composed of one, two or three lines of code; Consize comes with a unit test framework implemented in eight lines of code; you can set breakpoints and step through the code for debugging purposes implemented in three lines of code; serialization and producing image dumps comes also in some few lines. Do you have an interest in meta-programming? Not only has Consize a meta-protocol to handle unknown words, but _continuations_ which allow you to manipulate the future of computations and is used to implement an _ad hoc_ parser to extend the grammar of Consize.

Whet your appetite? You might head over reading the [documentation](/doc/Consize.pdf) first.

Enjoy,

Dominikus Herzberg, [@denkspuren](https://twitter.com/denkspuren)


## Run Consize

Running Consize requires Clojure 1.5. Right now, the code is not compatible with Clojure 1.8. This is on my todo list.

~~~
>java -cp clojure-1.5.1-slim.jar clojure.main consize.clj "\ prelude.txt run say-hi"
~~~

Be patient, wait for a moment -- and Consize show up with

~~~
This is Consize -- A Concatenative Programming Language
>
~~~

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

## Generate the Documentation

To produce the PDF document yourself, install a TeX distribution on your computer such as [MikTeX](https://miktex.org/) for Windows. Start the compilation process with `Consize.tex`. On Windows you might use `TeXworks` for that purpose, which is released with MikTeX.

