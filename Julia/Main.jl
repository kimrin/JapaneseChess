#!/home/kimura/Julia130928/julia/julia
# 
# メカ女子将棋システム (C) 2013 メカ女子将棋部☆
# 
# メカ女子将棋部：
# 
# 竹部　さゆり（女流三段）様
#   メカさゆりん
# 渡辺　弥生（女流一級）様
#   メカみおたん
# T.R.　（女子大学院生）様
#   メカりえぽん
# 木村　健（メカウーサーメカ担当、実装責任者）
#   メカきむりん、プロジェクトリーダー、小五女子w
# 
#

const MECHA_JYOSHI_SHOGI = 1
const MECHAJYO_VERSION = "0.6"

srand(1234)

#require("Profile")
#using IProfile

require("BoardConsts.jl") #remain when registration
require("Board.jl")       #remain when registration
require("Move.jl")        #remain when registration
require("GameStatus.jl")  #remain when registration
require("OldGenMove.jl")  #comment out when registration
require("BitBoard.jl")    #remain when registration
require("fvbin.jl")       #comment out when registration
require("Eval.jl")        #comment out when registration
require("EvalBonanza.jl") #comment out when registration
require("GenMove.jl")     #comment out when registration
require("Search.jl")      #comment out when registration
require("PVS.jl")         #comment out when registration
require("SimpleSearch.jl")#comment out when registration

# おまじない
function setupIO()
    stdinx::Ptr{Uint8} = 0
    stdoutx::Ptr{Uint8} = 0
    ret = ccall((:setunbuffering, "../lib/libMJ.so.1"), Int32, ())

    gs = InitGS()
    InitTables(gs)
    #BBTest2(gs)
    #BBTestForMoveGeneration(gs)
    return gs
end

function producer()
    while true
        s = readline(STDIN)
        s = chomp(s)
        produce(s)
        if s == "quit" || s == "exit"
            break
        end
    end
end

function main()
    sfenHirate = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1"
    li::Array{ASCIIString,1} = ["" for x = 1:100]::Array{ASCIIString,1}
    li2::Array{ASCIIString,1} = ["" for x = 1:100]::Array{ASCIIString,1}
    lilen = 0
    lilen2 = 0
    side::Int = SENTE # default
    count::Int = 0
    count2::Int = 0
    gs = setupIO()
    #GenMoveTest(gs)
    t = Task(producer)
    while true
        st = consume(t)
        #println("consumed $st")
        if st == "quit" || st == "exit"
            break
        elseif st == "usi"
            println("id name Mecha Jyoshi Shogi ",MECHAJYO_VERSION)
            println("id author Sayuri TAKEBE, Mio WATANABE, Rieko TSUJI and Takeshi KIMURA")
            println("option name BookFile type string default $(gs.bookfile)")
            println("option name UseBook type check default $(gs.usebook)")
            println("usiok");
        elseif st == "isready"
            srand(time_ns())
            println("readyok")
        elseif beginswith(st,"setoption")
            if beginswith(st,"setoption name USI_Ponder value true")
                gs.canponder = true
            elseif beginswith(st,"setoption name USI_Ponder value false")
                gs.canponder = false
            elseif beginswith(st,"setoption name USI_Hash value ")
                gs.hashsize = uint32(st[length("setoption name USI_Hash value "):])
            elseif beginswith(st,"setoption name BookFile value ")
                gs.bookfile = st[length("setoption name BookFile value "):]
            else
            end
        elseif beginswith(st,"usinewgame")
            # do nothing
            out = [Move(0,0,0,0,0,0) for n = 1:30000]
            history = [0 for x = 1:NumSQ, y = 1:NumSQ]
        elseif beginswith(st,"position startpos")
            li = split(st)
            count = 0
            count2 = 0
            if li[2] == "startpos" # 平手
                if size(li,1) == 2 # 初手
                    gs.board = InitSFEN(sfenHirate, gs.board)
                    count = 0
                    side = SENTE
                else
                    if size(li,1) == 4
                        side = GOTE
                    end
                    gs.board = InitSFEN(sfenHirate, gs.board)
                    count = 0

                    for x = 4:size(li,1)
                        count = 0
                        if iseven(x) # 先手
                            count2 = generateMoves(gs.board, out, SENTE, count, gs)
                            idx = findIndex(out,li[x],SENTE,count+1,count2)
                            if idx == -1
                                idx = 1
                                println("Warning: cannot find move:", li[x])
                            elseif idx == 0 # resign
                                # do nothing
                                println("Warning: invalid moves:", li[x])
                            else
                                #println("index = ", idx)
                                makeMove(gs.board,
		                         idx,
		                         out,
		                         SENTE)
                                #println("move=",move2USIString(out[idx]))
                            end
                        else # 後手
                            count2 = generateMoves(gs.board, out, GOTE, count, gs)
                            idx = findIndex(out,li[x],GOTE,count+1,count2)
                            if idx == -1
                                idx = 1
                                println("Warning: cannot find move:", li[x])
                            elseif idx == 0 # resign
                                # do nothing
                                println("Warning: invalid moves:", li[x])
                            else
                                #println("index = ", idx)
                                makeMove(gs.board,
		                         idx,
		                         out,
		                         GOTE)
                                #println("move=",move2USIString(out[idx]))
                            end
                        end
                        
                    end
                end
                #DisplayBoard(gs.board)
            end
        elseif beginswith(st,"position sfen")
            li = split(st)
            count = 0
            count2 = 0
            sfen = join(li[3:6]," ")
            #println("sfen=",sfen)
            if li[2] == "sfen" # 平手
                if size(li,1) == 6 # 初手
                    gs.board = InitSFEN(sfen, gs.board)
                    count = 0
                    side = SENTE
                else
                    if size(li,1) == 8
                        side = GOTE
                    end
                    gs.board = InitSFEN(sfen, gs.board)
                    count = 0
                    
                    for x = 8:size(li,1)
                        count = 0
                        if iseven(x) # 先手
                            count2 = generateMoves(gs.board, out, SENTE, count, gs)
                            idx = findIndex(out,li[x],SENTE,count+1,count2)
                            if idx == -1
                                idx = 1
                                println("Warning: cannot find move:", li[x])
                            elseif idx == 0 # resign
                                # do nothing
                                printlpn("Warning: invalid moves:", li[x])
                            else
                                #println("index = ", idx)
                                makeMove(gs.board,
		                         idx,
		                         out,
		                         SENTE)
                                #println("move=",move2USIString(out[idx]))
                            end
                        else # 後手
                            count2 = generateMoves(gs.board, out, GOTE, count, gs)
                            idx = findIndex(out,li[x],GOTE,count+1,count2)
                            if idx == -1
                                idx = 1
                                println("Warning: cannot find move:", li[x])
                            elseif idx == 0 # resign
                                # do nothing
                                println("Warning: invalid moves:", li[x])
                            else
                                #println("index = ", idx)
                                makeMove(gs.board,
		                         idx,
		                         out,
		                         GOTE)
                                #println("move=",move2USIString(out[idx]))
                            end
                        end
                    end
                end
            end
            #DisplayBoard(gs.board)
        elseif beginswith(st,"go")
            li2 = split(st)
            btime::Int = parseint(li2[3],10)
            wtime::Int = parseint(li2[5],10)
            byoyomi::Int = parseint(li2[7],10)
            #if in_check( side, gs.board)
            #    println("check!")
            #end
            count2 = generateMoves(gs.board, out, side, 0, gs)
            count3 = generateBB(gs.board, out, side, 0, gs)

            if count2 == 0
                println("bestmove resign")
            else
                # chose random moves
                #randomIndex::Int = rand(Uint32) % (count2)
                Index::Int = -1
                #m::Move = think(side,gs)
                m::Move = thinkASP(side,gs)
                #println("move=",m)
                for q = 1:count2
                    if out[q].move == m.move
                        Index = q
                        break
                    end
                end
                if Index == -1
                    println("bestmove resign")
                else
                    makeMove(gs.board,Index,out,side)
                    if in_check( side, gs.board)
                        #println("check!")
                    end
                    println("bestmove ",move2USIString(out[Index]))
                    #@iprofile report
                end
            end
        elseif beginswith(st,"gameover")
            # do nothing
        else
            println("COMMAND NOT FOUND($st)")
        end
        #println("COMMAND: $st")
    end
end

main()
