## How to get Consize running?

Consize is implemented in Clojure. Since Clojure depends on the Java Virtual Machine, the JVM, the first two installation steps are:

1. Install the JVM on your computer. Visit [java.com](http://www.java.com), download the installer and execute it.
2. Go to [clojure.org](http://clojure.org) and install Clojure. Follow the instructions for your operating system, see ["Getting started"](https://clojure.org/guides/getting_started).

Check, if Clojure can be executed on your computer. Open a [command shell](http://en.wikipedia.org/wiki/Command_shell) (on Windows, the `powershell` is used) and try, if Clojure starts up. Be patient on a slow computer.

    PS C:\Users\Dominikus> clj
    Clojure 1.10.1
    user=>

If Clojure is running on your computer, that's great. Proceed with the installation of Consize. To quit Clojure press the [Control key](http://en.wikipedia.org/wiki/Control_key) `Ctrl` (or `Strg` on a German keyboard) and `C`. If Clojure does not work on your computer, consult an expert or get some help on the Web.

For Consize, either clone the [GitHub repository](https://github.com/denkspuren/consize) or download the code as a zip-file and unzip it. Change to `/src` in the `consize` folder. The following files are essential:

* `consize.clj` -- that's the Consize VM implemented in Clojure
* `bootimage.txt` -- required by Consize to process the prelude
* `prelude-plain.txt` -- the prelude provides a basic infrastructure for programming in Consize.
* `prelude-test.txt` -- a suite of test cases checking if everything is working properly

Type the following in your command line:
 
    clj consize.clj "\ prelude-plain.txt run say-hi"

Be careful to correctly reproduce the above line. On a slow computer you might need to wait some few seconds to see Consize displaying:

    This is Consize -- A Concatenative Programming Language
    >

Excellent, you are done. You successfully installed Consize!

To quit Consize type `exit`.

For your convenience, you might want to create a [batch file](http://en.wikipedia.org/wiki/Batch_file) on Windows or a [shell script](http://en.wikipedia.org/wiki/Shell_script) on Linux/OS X. On Windows my batch file named `consize.bat` looks like this:

    @echo off
    powershell clj consize.clj "\ prelude-plain.txt run say-hi"
    pause

All I have to do is to click on `consize.bat` and Consize is started.
