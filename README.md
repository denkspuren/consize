# Consize
Consize is a concatenative programming language.

## Run Consize

Running Consize requires Clojure 1.5. Right now, the code is not compatible with Clojure 1.8.

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

