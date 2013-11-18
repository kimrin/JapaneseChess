Mecha Lady Shogi
===========================

A Mecha Lady Shogi program: Julia based Japanese Chess (Shogi) Engine

This Japanese Chess Engine works with
the "Shogi Dokoro" Shogi UI frontend system.

--------------------------------------------------

About This Project

--------------------------------------------------

* Julia language based Japanese Chess Engine
* (Currently) weak Shogi playing ability
* Your pull-requests are welcome!
* Tested only in Linux (not yet tested in Windows and MacOSX)

==================================================

How to Install
--------------------------------------------------

1. Install these software dependencies:
      * Julia programming language (of course!)
      * mono (for running Shogi Dokoro)
      * Shogi Dokoro Shogi User Interface
      * Gnu Make
      * Gnu C
2. Clone this project.
3. In project directory, run the following command: `make sharedlib`
4. Run the Shogi Dokoro UI Interface: `mono Shogidokoro.exe`

How to Play
--------------------------------------------------

Run the Shogi Dokoro UI and register Julia/Main.jl as the Shogi Engine.
Please add "#!/your/Julia/executable/path" to the top of Julia/Main.jl.
For example: #!/home/kimrin/julia-master/julia

(Before registering the Shogi Engine, comment out Main.jl's "please commented out when registration"
require command lines, and register. After registration, uncomment these lines.)

A necessary file `fv.bin` is not in our repogitory,
due to a different distribution license.

Please download a recent "Bonanza" Shogi program and copy the file `fv.bin` into this directory.

I'll describe how to play using Shogi Dokoro UI later...

License
--------------------------------------------------
MIT License

