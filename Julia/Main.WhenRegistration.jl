#!/home/kimura/Julia1027/julia/julia

const MECHAJYO_VERSION = "0.7"

function setupIO()
    stdinx::Ptr{Uint8} = 0
    stdoutx::Ptr{Uint8} = 0
    ret = ccall((:setunbuffering, "../lib/libMJ.so.1"), Int32, ())
end

setupIO()
s = readline(STDIN)
s = chomp(s)
bookfile = "./Joseki.db"
usebook  = true

if s == "usi"
    println("id name Mecha Jyoshi Shogi ",MECHAJYO_VERSION)
    println("id author Sayuri TAKEBE, Mio WATANABE, Rieko TSUJI and Takeshi KIMURA")
    println("option name BookFile type string default $(bookfile)")
    println("option name UseBook type check default $(usebook)")
    println("usiok");
end
