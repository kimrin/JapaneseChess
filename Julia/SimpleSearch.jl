function SimpleQsearch( gs::GameStatus, ply::Int, alpha::Int, beta::Int, depth::Float64, typeX::Int, InCheck::Bool, cutNode::Bool)
    # quiescence search
    val::Int = 0
    val2::Int = 0
    teban::Int = ((ply & 0x1) == 0)?gs.side:(gs.side$1)
    bestValue::Int = -Infinity
    ev_sign = ((ply & 0x01) == 0)?1:-1

    PvNode::Bool = (typeX == PV)

    if gs.timedout
        return 0
    end
    gs.triangularLength[ply+1] = ply
    if in_check( teban, gs.board)
        return SimplePVS( gs, ply, 1.0, alpha, beta, typeX, !cutNode)
    else
        bestValue = EvalBonanza( gs.side, gs.board, gs)

        if bestValue >= beta
            return bestValue
        end
        if (PvNode) && (bestValue > alpha)
            alpha = bestValue
        end
    end

    if (gs.inodes) & 1023 == 0
        now = time_ns()
        period::Int = now - gs.nsStart
        if period > MAXTHINKINGTIME
            gs.timedout = true
            return 0
        end
    end

    if float(ply) > (gs.depth + 3.0) # changed!
        return alpha
    end

    gs.MoveBeginIndex = gs.moveBufLen[ply+1]
    gs.moveBufLen[ply+1+1] = generateQBB(gs.board, gs.moveBuf, teban, gs.moveBufLen[ply+1], gs)

    # if gs.moveBufLen[ply+2] == 0 # added by T.K. 20130430 23:15
    #     return val
    # end
    beg = gs.moveBufLen[ply+1]+1
    for i = beg:gs.moveBufLen[ply+2]
        makeMove( gs.board, i, gs.moveBuf, teban)
        if in_check( teban, gs.board)||((gs.moveBuf[i].move & 0x00000300) == 0)
            #println("check!")
            takeBack( gs.board, i, gs.moveBuf, teban)
        else
	    gs.inodes += 1
	    val = -SimpleQsearch( gs, ply+1, -beta, -alpha, depth - 1.0, typeX, false,!cutNode)
            takeBack( gs.board, i, gs.moveBuf, teban)

            if val > bestValue
                bestValue = val
                if (val > alpha)
                    if (PvNode)&&(val < beta)
                        alpha = val
                        # both sides want to maximize from *their* perspective
                        gs.pvmovesfound += 1

                        gs.triangularArray[ply+1,ply+1] = gs.moveBuf[i]
		        # save this move
                        for j = (ply +1+1):gs.triangularLength[ply+1+1]
                            gs.triangularArray[ply+1,j] = gs.triangularArray[ply+1+1,j]
                            # and append the latest best PV from deeper plies
                        end
                        gs.triangularLength[ply+1] = gs.triangularLength[ply + 1+1]
                        rememberPV(gs)
                    else
                        return val
                    end
                end
            end
        end
    end
    bestValue
end

function SimplePVS( gs::GameStatus, ply::Int, depth::Float64, alpha::Int, beta::Int, typeX::Int, cutNode::Bool)

    PvNode = (typeX == PV)||(typeX == Root) 
    RootNode = (typeX == Root)

    movesfound::Int = 0
    gs.pvmovesfound = 0
    teban::Int = ((ply & 0x1) == 0)?gs.side:gs.side$1
    bestValue::Int = -Infinity
    gs.triangularLength[ply+1] = ply
    ev_sign = ((ply & 0x01) == 0)?1:-1

    if (gs.inodes) & 1023 == 0
        now = time_ns()
        period::Int = now - gs.nsStart
        if period > MAXTHINKINGTIME
            gs.timedout = true
            return 0
        end
    end

    # 0.5手延長うまくいかない。qsearchがPVSをも一回呼ぶため。
    movesfound = 0
    gs.pvmovesfound = 0
    gs.MoveBeginIndex = gs.moveBufLen[ply+1]
    gs.moveBufLen[ply+1+1] = generateBB(gs.board, gs.moveBuf, teban, gs.moveBufLen[ply+1], gs)

    beg = gs.moveBufLen[ply+1]+1
    for i = beg:gs.moveBufLen[ply+2]
        selectmove( gs, ply, i, depth)
        makeMove( gs.board, i, gs.moveBuf, teban)
        ext::Float64 = 0.0
        if i == beg
            ext = 0.5
        end
        pvMove = PvNode && (i == beg)

        newDepth = depth - 1.0 + ext

        if in_check( teban, gs.board)
            #println("check!")
            takeBack( gs.board, i, gs.moveBuf, teban)
        else
	    gs.inodes += 1
	    movesfound += 1

            if (newDepth < 1.0)
                gs.followpv = false
            end

#            val = (newDepth < 1.0)? -SimpleQsearch( gs, ply+1, -(alpha+1), -alpha, 0.0, NonPV, false, !cutNode):-SimplePVS( gs, ply+1, newDepth, -(alpha+1), -alpha, NonPV, !cutNode)
            
#            if (PvNode && (PvNode || (val > alpha && (RootNode || value <beta))))
                if (newDepth < 1.0)
                    gs.followpv = false
                end
                val = (newDepth < 1.0)? -SimpleQsearch( gs, ply+1, -beta, -alpha, 0.0, PV, false, false):-SimplePVS( gs, ply+1, newDepth, -beta, -alpha, PV, false)
#            end

            takeBack( gs.board, i, gs.moveBuf, teban)

            if gs.timedout
                return 0
            end
            
            if val > bestValue
                bestValue = val

                if val > alpha
                    # both sides want to maximize from *their* perspective
                    gs.pvmovesfound += 1

                    gs.triangularArray[ply+1,ply+1] = gs.moveBuf[i]
	            # save this move
                    for j = (ply +1+1):gs.triangularLength[ply+1+1]
                        gs.triangularArray[ply+1,j] = gs.triangularArray[ply+1+1,j]
                        # and append the latest best PV from deeper plies
                    end
                    gs.triangularLength[ply+1] = gs.triangularLength[ply + 1+1]
                    rememberPV(gs)

                    if (PvNode)&&(val < beta)
                        alpha = val
                    else
                        if gs.board.nextMove == GOTE
                            gs.blackHeuristics[seeMoveFrom(gs.moveBuf[i])+1,seeMoveTo(gs.moveBuf[i])+1] += int(depth*depth)
                        else
                            gs.whiteHeuristics[seeMoveFrom(gs.moveBuf[i])+1,seeMoveTo(gs.moveBuf[i])+1] += int(depth*depth)
                        end
                        break
                    end
                end
                if bestValue >= beta
                    if gs.board.nextMove == GOTE
                        gs.blackHeuristics[seeMoveFrom(gs.moveBuf[i])+1,seeMoveTo(gs.moveBuf[i])+1] += int(depth*depth)
                    else
                        gs.whiteHeuristics[seeMoveFrom(gs.moveBuf[i])+1,seeMoveTo(gs.moveBuf[i])+1] += int(depth*depth)
                    end
                    break
                end
            end
        end
    end

    if gs.pvmovesfound > 0
        if gs.board.nextMove == GOTE
            gs.blackHeuristics[seeMoveFrom(gs.triangularArray[ply+1,ply+1])+1,seeMoveTo(gs.triangularArray[ply+1,ply+1])+1] += int(depth*depth)
        else
            gs.whiteHeuristics[seeMoveFrom(gs.triangularArray[ply+1,ply+1])+1,seeMoveTo(gs.triangularArray[ply+1,ply+1])+1] += int(depth*depth)
        end
    end
    if movesfound == 0
	if in_check(teban, gs.board)
            return (-Infinity + ply-1)
        end
    end

    bestValue
end

#end # @iprofile