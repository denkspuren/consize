## How to get Consize running?

Consize is implemented in Clojure. Since Clojure depends on the Java Virtual Machine, the JVM, the first two installation steps are:

1. Install the JVM on your computer. Visit [java.com](http://www.java.com), download the installer and execute it.
2. Go to [clojure.org](http://clojure.org) and download the most recent stable release of Clojure. Unzip the file anywhere on your computer.

Check, if Clojure can be executed on your computer. Open a [command shell](http://en.wikipedia.org/wiki/Command_shell) (`cmd.exe` in Windows) and [change to the directory](http://en.wikipedia.org/wiki/Cd_(command)) where Clojure is installed; use `cd` for that on Windows. On my computer it looks like this:

    C:\Users\hb>cd Desktop
    C:\Users\hb\Desktop>cd clojure-1.5.1
	C:\Users\hb\Desktop\clojure-1.5.1>

Try, if Clojure starts up. Be a little bit patient on a slow computer.

    C:\Users\hb\Desktop\clojure-1.5.1>java -cp * clojure.main
    Clojure 1.5.1
    user=>

If Clojure is running on your computer, that's great. Proceed with the installation of Consize. To quit Clojure press the [Control key](http://en.wikipedia.org/wiki/Control_key) `Ctrl` (or `Strg` on a German keyboard) and `C`. If Clojure does not work on your computer, consult an expert or get some help on the Web.

For Consize you need to download the following files:

* `consize.clj` -- that's the Consize VM implemented in Clojure
* `bootimage.txt` -- required by Consize to process the prelude
* `prelude-plain.txt` -- the prelude provides a very basic infrastructure for programming in Consize.

Put the files into a directory of your choice. On Windows, create an environment variable called `%CLOJURE%` that points to the directory where Clojure is installed. If you do not know how to set an environment variable in Windows, move the files to the directory where Clojure resides. Same holds true, if you feel unsure on how to set up things on Linux or OS X.

If you copied the files to the Clojure directory, type the following in your command line:
 
    java -cp * clojure.main consize.clj "\ prelude-plain.txt run say-hi"

Alternatively, if you managed to set up `%CLOJURE%`, you go to the directory where you moved `consize.clj` to and type

	java -cp %CLOJURE%\*;*; clojure.main consize.clj "\ prelude-plain.txt run say-hi"

Be careful to correctly reproduce the above line. On a slow computer you might need to wait some few seconds to see Consize displaying:

    This is Consize -- A Concatenative Programming Language
    >

Excellent, you are done. You successfully installed Consize!

To quit Consize type `exit`.

For your convenience, you might want to create a [batch file](http://en.wikipedia.org/wiki/Batch_file) on Windows or a [shell script](http://en.wikipedia.org/wiki/Shell_script) on Linux/OS X. On Windows my batch file named `consize.bat` looks like this:

    @echo off
    set %CLOJURE%=C:\Users\hb\Desktop\clojure-1.5.1
    java -cp %CLOJURE%\*;*; clojure.main consize.clj "\ prelude-plain.txt run say-hi"

All I have to do is to click on `consize.bat` and Consize is started.
