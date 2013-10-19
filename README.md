Mecha Lady Shogi
===========================

A Mecha Lady Shogi program: Julia based Japanese Chess (Shogi) Engine

This Japanese Chess Engine dedicates
for "Shogi Dokoro" Shogi UI frontend system.

--------------------------------------------------

About This Project

--------------------------------------------------

* Julia language based Japanese Chess Engine
* (still now) weak Shogi playing ability
* Your pull-requests are welcome!
* Run in only Linux platform (not yet tested in Windows and MacOSX)

==================================================

How to Install
--------------------------------------------------

First of all, install these dependence software:

* Julia programming language (off course!)
* mono (for running Shogi Dokoro)
* Shogi Dokoro Shogi Interface
* Gnu Make
* Gnu C

Second, in project directory, run these commands

* make sharedlib

And run the Shogi Dokoro UI Interface:

* mono Shogidokoro.exe

How to Play
--------------------------------------------------

run the Shogi Dokoro UI Interface and regstrate Julia/Main.jl as Shogi Engine.
please add "#!/your/Julia/executable/path" to top of Julia/Main.jl.


(Before registrate Shogi Engine, comment out Main.jl's "please commented out in registration"
require command lines, and registrate. After registrattion, uncomment out these lines.)

A necessary file "fv.bin" in top directory is not in our repogitory 
(Because of different distribution LICENSE).

Please download recent "Bonanza" Shogi program and copy "fv.bin" into this directory.

I'll describe how to play Shogi Dokoro UI Interface in later...

License
--------------------------------------------------
MIT License







