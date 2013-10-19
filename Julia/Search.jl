## info command format:
## info time 203 nodes 11111111 score cp 11168 pv 5e9i+ ....

function rememberPV(gs::GameStatus)
    # remember the last PV, and also the 5 previous ones because 
    # they usually contain good moves to try
    i::Int = 0
    
    gs.lastPVLength = gs.triangularLength[1]
    #println("last length = ", gs.triangularLength[1])
    for i = 1:gs.triangularLength[1]
	gs.lastPV[i] = gs.triangularArray[1,i];
    end
end

# alpha-beta search
function AlphaBeta( gs::GameStatus, ply::Int, depth::Float64, alpha::Int, beta::Int)
    gs.triangularLength[ply+1] = ply
    ev_sign = ((ply & 0x01) == 0)?-1:1
    teban::Int = ((ply & 0x1) == 0)?gs.side:((gs.side==SENTE)?GOTE:SENTE)

    if depth <= 0.0
        return Eval( gs.board.nextMove, gs.board)
    end

    if gs.inodes > 100000
        gs.timedout = true
        return 0
    end

    gs.moveBufLen[ply+1+1] = generateMoves(gs.board, gs.moveBuf, teban, gs.moveBufLen[ply+1], gs)

    for i = gs.moveBufLen[ply+1]+1:gs.moveBufLen[ply+1+1] # 1 origin
        makeMove( gs.board, i, gs.moveBuf, teban)
        if in_check( teban, gs.board)
            #println("check!")
            takeBack( gs.board, i, gs.moveBuf, teban)
        else
            gs.inodes += 1
            val::Int = -AlphaBeta( gs, ply+1, depth-1.0, -beta, -alpha)
            takeBack( gs.board, i, gs.moveBuf, teban)
            #if val >= beta
            #    return beta
            #end
            if val > alpha
                alpha = val
		# both sides want to maximize from *their* perspective

                gs.triangularArray[ply+1,ply+1] = gs.moveBuf[i]
		# save this move
                for j = (ply +1+1):gs.triangularLength[ply+1+1]
                    gs.triangularArray[ply+1,j] = gs.triangularArray[ply+1+1,j]
                    # and append the latest best PV from deeper plies
                end
                gs.triangularLength[ply+1] = gs.triangularLength[ply + 1+1]
                rememberPV(gs)
            end
        end
    end
    alpha
end

# search driver
function think( sengo::Int, gs::GameStatus)
    move::Move = Move(0,0,0,0,0,0) # null move
    gs.lastPV = [Move(0,0,0,0,0,0) for x = 1:MaxPly]::Array{Move,1}
    gs.lastPVLength = 0
    gs.whiteHeuristics = [0 for x = 1:0xff, y = 1:0xff]::Array{Int,2}
    gs.blackHeuristics = [0 for x = 1:0xff, y = 1:0xff]::Array{Int,2}
    gs.nsStart = time_ns()
    gs.inodes = 0
    gs.timedout = false
    gs.side = sengo
    gs.board.nextMove = sengo

    for IDdepth = 1.0:1.0:15.0 #MaxPly
        gs.moveBufLen = [0 for x = 1:MaxPly]::Array{Int,1}
        gs.moveBuf = [Move(0,0,0,0,0,0) for x = 1:MaxMoves]        
        gs.triangularLength = [0 for x = 1:MaxPly]::Array{Int,1}
        gs.triangularArray  = [Move(0,0,0,0,0,0) for x = 1:MaxPly, y = 1:MaxPly]::Array{Move,2}
        gs.followpv = true
        gs.allownull = true
        gs.depth = IDdepth
        # score::Int = AlphaBeta(gs, 0, IDdepth,-Infinity,Infinity) # ply=0
        score::Int = PVS(gs, 0, IDdepth,-Infinity,Infinity) # ply=0
        # println("Depth = ", IDdepth, ", Score = ", score)
        if gs.timedout
            return gs.lastPV[1]
        end
        rememberPV(gs)
        timeInMSecs::Int = int((time_ns() - gs.nsStart)/1000000)
        NPS::Int = int(gs.inodes / ((time_ns() - gs.nsStart)/1000000000))
        ## info time 203 nodes 11111111 score cp 11168 pv 5e9i+ ....
        print("info time ",timeInMSecs," depth ", int(IDdepth), " nodes ", gs.inodes, " score cp ", score, " nps ",NPS," pv")
        for i = 1:gs.triangularLength[1]
	    print(" ",move2USIString(gs.lastPV[i]))
        end
        println()
    end
    move = gs.lastPV[1]
    return move
end

function showPVforUSI(IDdepth::Float64, score::Int64, gs::GameStatus)
    i = 0::Int
    timeInMSecs = int((time_ns() - gs.nsStart)/1000000)::Int
    NPS = int(gs.inodes / ((time_ns() - gs.nsStart)/1000000000))::Int
    ## info time 203 nodes 11111111 score cp 11168 pv 5e9i+ ....
    print("info time ",timeInMSecs," depth ", int(IDdepth), " nodes ", gs.inodes, " score cp ", score, " nps ",NPS," pv")
    for i = 1:gs.triangularLength[1]
	print(" ",move2USIString(gs.lastPV[i]))
    end
    println()
end

# search driver
function thinkASP( sengo::Int, gs::GameStatus)
    move::Move = Move(0,0,0,0,0,0) # null move
    bestMove::Move = Move(0,0,0,0,0,0) # null move # added recently
    gs.lastPV = [Move(0,0,0,0,0,0) for x = 1:MaxPly]::Array{Move,1}
    gs.lastPVLength = 0
    gs.whiteHeuristics = [0 for x = 1:0xff, y = 1:0xff]::Array{Int,2}
    gs.blackHeuristics = [0 for x = 1:0xff, y = 1:0xff]::Array{Int,2}
    gs.nsStart = time_ns()
    gs.inodes = 0
    gs.timedout = false
    gs.side = sengo
    gs.board.nextMove = sengo
    gs.tt = Dict{Uint64,TransP}()
    delta::Int = 50
    score::Int = 0
    middle::Int = 0
    smallAlpha::Int = 0
    smallBeta::Int  = 0
    for IDdepth = 1.0:1.0:60.0 #MaxPly
        hitScore::Bool = false

        while hitScore == false
            gs.moveBufLen = [0 for x = 1:MaxPly]::Array{Int,1}
            gs.moveBuf = [Move(0,0,0,0,0,0) for x = 1:MaxMoves]        
            gs.triangularLength = [0 for x = 1:MaxPly]::Array{Int,1}
            gs.triangularArray  = [Move(0,0,0,0,0,0) for x = 1:MaxPly, y = 1:MaxPly]::Array{Move,2}
            gs.followpv = true
            gs.allownull = true
            gs.MoveBeginIndex = 0

            # score::Int = AlphaBeta(gs, 0, IDdepth,-Infinity,Infinity) # ply=0
            if IDdepth == 1.0
                score = PVS(gs, 0, IDdepth,-Infinity,Infinity) # ply=0
                middle = score
                hitScore = true
                smallAlpha = middle - delta
                smallBeta  = middle + delta
                bestMove = gs.lastPV[1]
            else
                score = PVS(gs, 0, IDdepth,smallAlpha,smallBeta) # ply=0
                middle = score

                if smallAlpha == -Infinity
                    hitScore = true
                end
                if smallBeta  == Infinity
                    hitScore = true
                end

                if smallAlpha < score < smallBeta
                    hitScore = true
                elseif score <= smallAlpha
                    delta *= 2
                    smallAlpha = middle - delta
                    if delta >= 2000
                        smallAlpha = -Infinity
                    end
                    showPVforUSI(IDdepth,score,gs)
                elseif score >= smallBeta
                    delta *= 2
                    smallBeta = middle + delta
                    if delta >= 2000
                        smallBeta = Infinity
                    end
                    showPVforUSI(IDdepth,score,gs)
                end
            end
        end
        # println("Depth = ", IDdepth, ", Score = ", score)
        if gs.timedout
            return bestMove
        end
        rememberPV(gs)
        showPVforUSI(IDdepth,score,gs)
        bestMove = gs.lastPV[1]
    end
    move = bestMove
    return move
end

function ThinkTest(gs::GameStatus)
    m::Move = think(SENTE,gs)
end
