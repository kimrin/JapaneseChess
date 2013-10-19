const MO_MOVE_SENTE = int(0x80) # 先手駒台（着手の表現時に使われる）
const MO_MOVE_GOTE  = int(0xa0) # 後手駒台（着手の表現時に使われる）

# movable squares

const movableNoSliding = [(1,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (2,-1) (2,1) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (-1,-1) (-1,1) (0,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,-1) (-1,0) (-1,1);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (1,0) (0,1) (0,-1) (-1,0) (0,0) (0,0) (0,0) (0,0);
                          (1,-1) (1,1) (-1,-1) (-1,1) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (-1,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (-2,-1) (-2,1) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (-1,-1) (-1,0) (-1,1) (1,-1) (1,1) (0,0) (0,0) (0,0);
                          (-1,-1) (-1,0) (-1,1) (0,-1) (0,1) (1,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
                          (1,-1) (1,0) (1,1) (0,-1) (0,1) (-1,-1) (-1,0) (-1,1);
                          (-1,-1) (-1,0) (-1,1) (0,-1) (0,1) (1,0) (0,0) (0,0);
                          (-1,-1) (-1,0) (-1,1) (0,-1) (0,1) (1,0) (0,0) (0,0);
                          (-1,-1) (-1,0) (-1,1) (0,-1) (0,1) (1,0) (0,0) (0,0);
                          (-1,-1) (-1,0) (-1,1) (0,-1) (0,1) (1,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0);
            #original UM #(1,0) (0,1) (0,-1) (-1,0) (0,0) (0,0) (0,0) (0,0);
            #original RY #(1,-1) (1,1) (-1,-1) (-1,1) (0,0) (0,0) (0,0) (0,0);
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0); # new UM
                          (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0) (0,0); # new RY
                          ]::Array{(Int64,Int64),2}

const isSlidePiece = [ 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0,  0, 1, 1]::Array{Int,1}
                    # FU,KY,KE,GI,KI,KA,HI,OU,TO,NY,NK,NG,NKI,UM,RY
                      


#for x = 1:size(movableNoSliding,1)
#    y = movableNoSliding[x,1:size(movableNoSliding,2)]
#end

function InitTables(gs::GameStatus)
    for sq = A9:I1
        for piece = MJFU:MJGORY
            z = uint128(0)
            y = movableNoSliding[piece,1:8]
            for p = 1:8
                dr, df = movableNoSliding[piece,p]
                r = RANKS[sq]
                f = FILES[sq]
                if (dr == 0)&&(df == 0)
                else
                    z |= setAttack( r+dr, f+df, uint128(0))
                end
            end
            gs.AttackTableNonSlide[piece,sq] = z
        end
    end

    #for piece = MJFU:MJGORY
    #    for sq = A9:I1
    #        teban::Int = (piece & 0x10)>>>4
    #        koma::Int  = piece & 0x0f

    #        if koma != 0
    #            println(TEBANSTR[teban+1],KOMASTR[koma],SQUARENAME[sq])
    #        end

    #       DisplayBitBoard(gs.AttackTableNonSlide[piece,sq],false)
    #    end
    #end

    gs.FillRank = [uint128(0) for r=1:9]::Array{BitBoard,1}
    gs.FillFile = [uint128(0) for f=1:9]::Array{BitBoard,1}

    for i = A9:I1
        r = RANKS[i]
        f = FILES[i]
        gs.FillRank[r] |= BitSet[i]
        gs.FillFile[f] |= BitSet[i]
    end

    gs.fukyBitsW = uint128(0)
    for r = 1:8
        gs.fukyBitsW |= gs.FillRank[r]
    end
    gs.fukyBitsB = uint128(0)
    for r = 2:9
        gs.fukyBitsB |= gs.FillRank[r]
    end
    gs.keBitsW = uint128(0)
    for r = 1:7
        gs.keBitsW |= gs.FillRank[r]
    end
    gs.keBitsB = uint128(0)
    for r = 3:9
        gs.keBitsB |= gs.FillRank[r]
    end

    #zeros = uint128(0)

    gs.MovableKoma = [gs.fukyBitsW gs.fukyBitsW gs.keBitsW;
                      gs.fukyBitsB gs.fukyBitsB gs.keBitsB]::Array{BitBoard,2}
    #for sengo = 1:2
    #    for koma = MJFU:MJKE
    #        println("movable[",sengo,koma,"] = ")
    #        DisplayBitBoard(MovableKoma[sengo,koma],false)
    #    end
    #end

    gs.SenteJin    = gs.FillRank[1]|gs.FillRank[2]|gs.FillRank[3]
    gs.GoteJin     = gs.FillRank[7]|gs.FillRank[8]|gs.FillRank[9]
    gs.SenteOthers = gs.FillRank[4]|gs.FillRank[5]|gs.FillRank[6]|gs.GoteJin
    gs.GoteOthers  = gs.FillRank[4]|gs.FillRank[5]|gs.FillRank[6]|gs.SenteJin

    # DisplayBitBoard(SenteJin,false)
    # DisplayBitBoard(GoteJin,false)
    # DisplayBitBoard(SenteOthers,false)
    # DisplayBitBoard(GoteOthers,false)

end

function InsertMove(idx::Int64, out::Array{Move,1}, gs::GameStatus)
    i2::Int = 0
    ban::Int = -1
    m::Move = out[idx]

    for i2 = gs.MoveBeginIndex+1:idx-1
        if m.value < out[i2].value
            # continue
        else
            ban = i2
            break
        end
    end

    if ban == -1
        # do nothing
    else
        tmpM     = out[idx]
        out[idx] = out[ban]
        out[ban] = tmpM
    end
end
function InsertMove(idx::Int32, out::Array{Move,1}, gs::GameStatus)
    InsertMove(int64(idx), out, gs)
end

function InsertMoveAB(idx::Int64, out::Array{Move,1}, gs::GameStatus)
    InsertMove(int64(idx), out, gs)
end

function InsertMoveAB(idx::Int32, out::Array{Move,1}, gs::GameStatus)
    InsertMoveAB(int64(idx), out, gs)
end

function genBB(p::Board,           #     /* IN:盤面 */
	       out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	       teban::Int,         #     /* 可能手を生成する手番 */
               co::Int,
	       gs::GameStatus)
    count::Int32 = int32(co)
    target::BitBoard = uint128(0)
    bbp::BitBoard    = uint128(0)
    
    if teban == SENTE
        target = (~p.WhitePieces) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # FU

        bbp = p.bb[MJFU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJFU,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) < A6
                    # promotion
                    count += 1

                    out[count] = Move(MJTO,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                if (to+1) >= A8
                    count += 1
                    out[count] = Move(MJFU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
            end
        end
        
        # MJKYはsliding pieceなので割愛

        # KE

        bbp = p.bb[MJKE]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJKE,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) < A6
                    # promotion
                    count += 1

                    out[count] = Move(MJNK,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                if (to+1) >= A7
                    count += 1
                    out[count] = Move(MJKE,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
            end
        end

        # GI

        bbp = p.bb[MJGI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGI,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if ((to+1) < A6 )||((from+1) < A6)
                    # promotion
                    count += 1

                    out[count] = Move(MJNG,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                count += 1
                out[count] = Move(MJGI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KI

        bbp = p.bb[MJKI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJKI,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJKI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # OU

        bbp = p.bb[MJOU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJOU,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJOU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # TO

        bbp = p.bb[MJTO]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJTO,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJTO,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # NY

        bbp = p.bb[MJNY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNY,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJNY,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # NK

        bbp = p.bb[MJNK]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNK,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJNK,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # NG

        bbp = p.bb[MJNG]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNG,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJNG,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end
    else
        target = (~p.BlackPieces) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # GOFU

        bbp = p.bb[MJGOFU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOFU,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) >= A3
                    # promotion
                    count += 1

                    out[count] = Move(MJGOTO,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                if (to+1) < A1
                    count += 1
                    out[count] = Move(MJGOFU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
            end
        end
        
        # MJKYはsliding pieceなので割愛

        # GOKE

        bbp = p.bb[MJGOKE]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOKE,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) >= A3
                    # promotion
                    count += 1

                    out[count] = Move(MJGONK,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                if (to+1) < A2
                    count += 1
                    out[count] = Move(MJGOKE,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
            end
        end

        # GOGI

        bbp = p.bb[MJGOGI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOGI,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if ((to+1) >= A3 )||((from+1) >= A3)
                    # promotion
                    count += 1

                    out[count] = Move(MJGONG,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMoveAB(count,out,gs)
                end
                # normal move
                count += 1
                out[count] = Move(MJGOGI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GOKI

        bbp = p.bb[MJGOKI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOKI,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGOKI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GOOU

        bbp = p.bb[MJGOOU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOOU,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGOOU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GOTO

        bbp = p.bb[MJGOTO]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOTO,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGOTO,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GONY

        bbp = p.bb[MJGONY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONY,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGONY,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GONK

        bbp = p.bb[MJGONK]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONK,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGONK,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GONG

        bbp = p.bb[MJGONG]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONG,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                count += 1
                out[count] = Move(MJGONG,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end
    end
    count
end

function genQBB(p::Board,           #     /* IN:盤面 */
	        out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	        teban::Int,         #     /* 可能手を生成する手番 */
                co::Int,
	        gs::GameStatus)
    count::Int32 = int32(co)
    target::BitBoard = uint128(0)
    bbp::BitBoard    = uint128(0)
    
    if teban == SENTE
        target = (~p.WhitePieces) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # FU

        bbp = p.bb[MJFU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJFU,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) < A6
                    # promotion
                    count += 1

                    out[count] = Move(MJTO,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if ((to+1) >= A8)&&(toriflag == FLAG_TORI)
                    count += 1
                    out[count] = Move(MJFU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end
        
        # MJKYはsliding pieceなので割愛

        # KE

        bbp = p.bb[MJKE]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJKE,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) < A6
                    # promotion
                    count += 1

                    out[count] = Move(MJNK,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if ((to+1) >= A7)&&(toriflag == FLAG_TORI)
                    count += 1
                    out[count] = Move(MJKE,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GI

        bbp = p.bb[MJGI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGI,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if ((to+1) < A6 )||((from+1) < A6)
                    # promotion
                    count += 1

                    out[count] = Move(MJNG,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # KI

        bbp = p.bb[MJKI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJKI,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJKI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # OU

        bbp = p.bb[MJOU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJOU,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJOU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # TO

        bbp = p.bb[MJTO]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJTO,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJTO,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # NY

        bbp = p.bb[MJNY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNY,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJNY,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # NK

        bbp = p.bb[MJNK]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNK,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJNK,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # NG

        bbp = p.bb[MJNG]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJNG,from+1]
            toru::BitBoard = dest & p.BlackPieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJNG,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end
    else
        target = (~p.BlackPieces) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # GOFU

        bbp = p.bb[MJGOFU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOFU,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) >= A3
                    # promotion
                    count += 1

                    out[count] = Move(MJGOTO,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if ((to+1) < A1)&&(toriflag == FLAG_TORI)
                    count += 1
                    out[count] = Move(MJGOFU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end
        
        # MJKYはsliding pieceなので割愛

        # GOKE

        bbp = p.bb[MJGOKE]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOKE,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if (to+1) >= A3
                    # promotion
                    count += 1

                    out[count] = Move(MJGONK,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if ((to+1) < A2)&&(toriflag == FLAG_TORI)
                    count += 1
                    out[count] = Move(MJGOKE,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GOGI

        bbp = p.bb[MJGOGI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOGI,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                if ((to+1) >= A3 )||((from+1) >= A3)
                    # promotion
                    count += 1

                    out[count] = Move(MJGONG,from,to,FLAG_NARI|toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGOGI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GOKI

        bbp = p.bb[MJGOKI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOKI,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGOKI,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GOOU

        bbp = p.bb[MJGOOU]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOOU,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGOOU,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GOTO

        bbp = p.bb[MJGOTO]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGOTO,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGOTO,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GONY

        bbp = p.bb[MJGONY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONY,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGONY,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GONK

        bbp = p.bb[MJGONK]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONK,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGONK,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end

        # GONG

        bbp = p.bb[MJGONG]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            # println("bbp")
            # DisplayBitBoard(bbp,false)
            bbp $= BitSet[from+1]
            dest::BitBoard = target & gs.AttackTableNonSlide[MJGONG,from+1]
            toru::BitBoard = dest & p.WhitePieces
            while dest > uint128(0)
                to = trailing_zeros(dest)
                # println("dest")
                # DisplayBitBoard( dest, false)
                dest $= BitSet[to+1]
                toriflag = ((toru & BitSet[to+1]) > 0)?FLAG_TORI:0
                # normal move
                if toriflag == FLAG_TORI
                    count += 1
                    out[count] = Move(MJGONG,from,to,toriflag,p.square[to+1]&0x0f,0)::Move
                    InsertMove(count,out,gs)
                end
            end
        end
    end
    count
end

function genBBDrop(p::Board,           #     /* IN:盤面 */
	           out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	           teban::Int,         #     /* 可能手を生成する手番 */
                   co::Int,
	           gs::GameStatus)
    count::Int32 = int32(co)
    target::BitBoard = uint128(0)
    bbp::BitBoard    = uint128(0)
    
    if teban == SENTE
        target = (~(p.WhitePieces|p.BlackPieces)) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # FU

        bbp = p.bb[MJFU]
        if p.WhitePiecesInHands[MJFU] > 0
            nifu = uint128(0)
            for ra = rank1:rank9
                nifu |= (bbp >>> ((ra-1)*9)& 0x01ff)
            end
            nifu = uint16((~nifu) & 0x1ff)
            fuuchi = uint128(0)
            for fi = file1:file9
                if (nifu & (0x0001 << (fi-1))) > 0
                    fuuchi |= gs.FillFile[fi]
                end
            end

            secondTarget = target & fuuchi & gs.fukyBitsW

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJFU,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KY

        bbp = p.bb[MJKY]
        if p.WhitePiecesInHands[MJKY] > 0
            secondTarget = target & gs.fukyBitsW

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJKY,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KE

        bbp = p.bb[MJKE]
        if p.WhitePiecesInHands[MJKE] > 0
            secondTarget = target & gs.keBitsW

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJKE,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GI

        bbp = p.bb[MJGI]
        if p.WhitePiecesInHands[MJGI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                #println("move=",count) # for debug purpose
                out[count] = Move(MJGI,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KI

        bbp = p.bb[MJKI]
        if p.WhitePiecesInHands[MJKI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJKI,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KA

        bbp = p.bb[MJKA]
        if p.WhitePiecesInHands[MJKA] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJKA,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # HI

        bbp = p.bb[MJHI]
        if p.WhitePiecesInHands[MJHI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJHI,MO_MOVE_SENTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end
    else
        target = (~(p.WhitePieces|p.BlackPieces)) & MaskOfBoard
        # println("target")
        # DisplayBitBoard( target, false)

        # GOFU

        bbp = p.bb[MJGOFU]
        if p.BlackPiecesInHands[MJFU] > 0
            nifu = uint128(0)
            for ra = rank1:rank9
                nifu |= (bbp >>> ((ra-1)*9)& 0x01ff)
            end
            nifu = uint16((~nifu)&0x1ff)
            fuuchi = uint128(0)
            for fi = file1:file9
                if (nifu & (0x0001 << (fi-1))) > 0
                    fuuchi |= gs.FillFile[fi]
                end
            end

            secondTarget = target & fuuchi & gs.fukyBitsB

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOFU,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KY

        bbp = p.bb[MJGOKY]
        if p.BlackPiecesInHands[MJKY] > 0
            secondTarget = target & gs.fukyBitsB

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOKY,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KE

        bbp = p.bb[MJGOKE]
        if p.BlackPiecesInHands[MJKE] > 0
            secondTarget = target & gs.keBitsB

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOKE,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # GI

        bbp = p.bb[MJGOGI]
        if p.BlackPiecesInHands[MJGI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOGI,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KI

        bbp = p.bb[MJGOKI]
        if p.BlackPiecesInHands[MJKI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOKI,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # KA

        bbp = p.bb[MJGOKA]
        if p.BlackPiecesInHands[MJKA] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOKA,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end

        # HI

        bbp = p.bb[MJGOHI]
        if p.BlackPiecesInHands[MJHI] > 0
            secondTarget = target

            while secondTarget > uint128(0)
                from = trailing_zeros(secondTarget)
                secondTarget $= BitSet[from+1]
                count += 1
                out[count] = Move(MJGOHI,MO_MOVE_GOTE,from,FLAG_UCHI,0,0)::Move
                InsertMoveAB(count,out,gs)
            end
        end
    end

    count
end

function genSlideMailbox(teban::Int,
                         p::Board,
                         out::Array{Move,1},
                         co::Int32,
                         gs::GameStatus)
    count::Int32 = co
    bbp::BitBoard    = uint128(0)

    if teban == SENTE
        # KY
        bbp = p.bb[MJKY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # KA
        bbp = p.bb[MJKA]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # HI

        bbp = p.bb[MJHI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # UM

        bbp = p.bb[MJUM]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # RY

        bbp = p.bb[MJRY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end
    else
        # KY
        bbp = p.bb[MJGOKY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # KA
        bbp = p.bb[MJGOKA]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # HI

        bbp = p.bb[MJGOHI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # UM

        bbp = p.bb[MJGOUM]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end

        # RY

        bbp = p.bb[MJGORY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailbox0x88(teban, from, p, out, count, gs)
        end
    end
    count
end

function genSlideMailboxQ(teban::Int,
                          p::Board,
                          out::Array{Move,1},
                          co::Int32,
                          gs::GameStatus)
    count::Int32 = co
    bbp::BitBoard    = uint128(0)

    if teban == SENTE
        # KY
        bbp = p.bb[MJKY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # KA
        bbp = p.bb[MJKA]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # HI

        bbp = p.bb[MJHI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # UM

        bbp = p.bb[MJUM]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # RY

        bbp = p.bb[MJRY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end
    else
        # KY
        bbp = p.bb[MJGOKY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # KA
        bbp = p.bb[MJGOKA]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # HI

        bbp = p.bb[MJGOHI]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # UM

        bbp = p.bb[MJGOUM]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end

        # RY

        bbp = p.bb[MJGORY]
        while bbp > uint128(0)
            from = trailing_zeros(bbp)
            bbp $= BitSet[from+1]
            count = mailboxQ0x88(teban, from, p, out, count, gs)
        end
    end
    count
end

#@iprofile begin
function generateBB(p::Board,           #     /* IN:盤面 */
	            out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	            teban::Int,         #     /* 可能手を生成する手番 */
                    co::Int,
	            gs::GameStatus)

    count = int(co) # 64bits

    count = genBB(p,out,teban,count,gs) # 32bits
    count = genSlideMailbox(teban,p,out,count,gs)
    count = genBBDrop(p,out,teban,int(count),gs) # 32bits

    count # 32bits
end
#end # @iprofile

#@iprofile begin
function generateQBB(p::Board,           #     /* IN:盤面 */
	             out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	             teban::Int,         #     /* 可能手を生成する手番 */
                     co::Int,
	             gs::GameStatus)

    count = int(co) # 64bits
    count = genQBB(p,out,teban,count,gs) # 32bits
    count = genSlideMailboxQ(teban,p,out,count,gs)
    count # 32bits
end
#end # @iprofile

function consistencyBoard( q::Board)
    for i = A9:I1
        sq = q.square[i]
        if sq == MJNONE
            if (q.WhitePieces & BitSet[i]) == BitSet[i]
                println("A)break board(Index=", i, ", sq=",sq,")")
            elseif (q.BlackPieces & BitSet[i]) == BitSet[i]
                println("B)break board(Index=", i, ", sq=",sq,")")
            end
            continue
        end
        if (q.bb[sq] & BitSet[i]) == BitSet[i]
        else
            println("C)break board!(Index=", i, ", sq=",sq,")")
            DisplayBoard(q)
        end
    end
end

function validateMoves(o1::Array{Move,1},o2::Array{Move,1},n1::Int32,n2::Int32)
    # m1 and m2
    M1andM2::Int = 0
    for m1 = 1:n1
        move1 = o1[m1].move 
        for m2 = 1:n2
            move2 = o2[m2].move
            if move1 == move2
                println("[A&B]:",Move2String(o1[m1]))
                M1andM2 += 1
            end
        end
    end

    # only m1
    onlyM1::Int = 0
    for m1 = 1:n1
        move1 = o1[m1].move 
        fl = false
        for m2 = 1:n2
            move2 = o2[m2].move
            if move1 == move2
                fl = true
                break
            end
        end
        if fl == false
            println("[ A ]:",Move2String(o1[m1]))
            onlyM1 += 1
        end
    end

    # only m2
    onlyM2::Int = 0
    for m2 = 1:n2
        move2 = o2[m2].move 
        fl = false
        for m1 = 1:n1
            move1 = o1[m1].move
            if move1 == move2
                fl = true
                break
            end
        end
        if fl == false
            println("[ B ]:",Move2String(o1[m1]))
            onlyM2 += 1
        end
    end

    println("validate information:")
    println("[A and B]:", M1andM2)
    println("[only in A]:", onlyM1)
    println("[only in B]:", onlyM2)
    if M1andM2 == n1 == n2
        println("Report: valid.")
    else
        println("Report: invalidate!")
    end
end

function makeMove(q::Board,
		  moveIdx::Int,
		  out::Array{Move,1},
		  teban::Int)
    m::Move      = out[moveIdx]
    from::Int    = seeMoveFrom(m)
    to::Int      = seeMoveTo(m)
    koma::Int    = seeMovePiece(m) & 0x0f
    komadai::Int = (teban == SENTE) ? MO_MOVE_SENTE: MO_MOVE_GOTE
    komavalTo::Int = q.square[to+1]
    captured::Int  = seeMoveCapt(m)
    flag::Int      = seeMoveFlag(m)
    omote::Int     = MJNONE

    # flagに何が入っているかで処理を分ける。
    　
    if (flag & FLAG_UCHI) > 0
        # 打ち
        # ・打ち＝駒台から一つ取り出して、toの位置に駒を置く
        # 　同時に対象の駒のbitboardを更新する

        # 1.駒台から駒を取り除く
        if from == komadai
            if teban == SENTE
                q.WhitePiecesInHands[koma] -= 1                
                if q.WhitePiecesInHands[koma] < 0
                    println("insufficient koma(White,",koma,")")
                end
            else
                q.BlackPiecesInHands[koma] -= 1
                if q.BlackPiecesInHands[koma] < 0
                    println("insufficient koma(Black,",koma,")")
                end
            end
        end
        # 2.toの位置に駒を置く
        q.square[to+1] = (teban << 4)|int(koma)
        # 3.toの駒のbitboardに駒を置く
        q.bb[q.square[to+1]] |= BitSet[to+1]
    elseif (flag & FLAG_TORI) > 0
        # 取り
        if (flag & FLAG_NARI) > 0
            # 取りかつ成り
            # ・取り、なおかつ成り＝toの駒を駒台に置き、toにfromの駒の成った駒を置く。
            # 　fromは空っぽに。
            # 　同時にtoの駒のbitboardからtoの駒を削除し、fromのbitboardから駒を削除する。
            # 　またfromの成った駒のbitboardのtoの位置に成った駒を置く

            q.bb[q.square[to+1]]    $= BitSet[to+1]
            q.bb[q.square[from+1]]  $= BitSet[from+1]
            q.bb[q.square[from+1]+MJNARI] |= BitSet[to+1]
            tmpkoma = komavalTo & 0x0f
            omote = (tmpkoma > MJOU)?tmpkoma-MJNARI:tmpkoma
            if teban == SENTE
                q.WhitePiecesInHands[omote] += 1
            else
                q.BlackPiecesInHands[omote] += 1
            end
            q.square[to+1]     = q.square[from+1] + MJNARI
            q.square[from+1]   = MJNONE
        else
            # ・取り＝toの駒を駒台に置き、toにfromの駒を置く。fromは空っぽに
            # 　同時に、toの駒のbitboardからtoの駒を削除し、さらにfromの駒の
            # 　bitboard内でfromからtoに駒を移動。
            # 普通の取り
            q.bb[q.square[to+1]]    $= BitSet[to+1]
            q.bb[q.square[from+1]]  $= BitSet[from+1]
            q.bb[q.square[from+1]]  |= BitSet[to+1]
            tmpkoma = komavalTo & 0x0f
            omote = (tmpkoma > MJOU)?tmpkoma-MJNARI:tmpkoma
            if teban == SENTE
                q.WhitePiecesInHands[omote] += 1
            else
                q.BlackPiecesInHands[omote] += 1
            end
            q.square[to+1]     = q.square[from+1]
            q.square[from+1]   = MJNONE
        end
    elseif (flag & FLAG_NARI) > 0
        # 普通の成り
        # ・成り＝toにfromの駒を成って置く。fromは空っぽに。
        # 　同時に、fromの駒のbitboardから駒を削除する。またtoの駒のbitboard
        # 　に成った駒を置く
        q.bb[q.square[from+1]]        $= BitSet[from+1]
        q.bb[q.square[from+1]+MJNARI] |= BitSet[to+1]
        q.square[to+1]                 = q.square[from+1] + MJNARI
        q.square[from+1]               = MJNONE
    else
        # 普通の指し手
        # ・それ以外（フラグなし）＝toにfromの駒を置く。fromは空っぽに。
        # 　同時にtoの駒のbitboard内でfromからtoに駒を移動
        q.square[to+1]        = q.square[from+1]
        q.square[from+1]      = MJNONE
        q.bb[q.square[to+1]] |= BitSet[to+1]
        q.bb[q.square[to+1]] $= BitSet[from+1]
    end

    if q.square[to+1] == MJOU
        q.kingposW = to+1
    elseif q.square[to+1] == MJGOOU
        q.kingposB = to+1
    end

    q.WhitePieces = uint128(0)
    q.BlackPieces = uint128(0)
    for piece = MJFU:MJRY
        q.WhitePieces |=q.bb[piece]
        q.BlackPieces |=q.bb[piece+MJGOTE]
    end
    q.nextMove $= 1

    #consistencyBoard(q)
end

function takeBack(q::Board,
		  moveIdx::Int,
		  out::Array{Move,1},
		  teban::Int)
    m::Move      = out[moveIdx]
    from::Int    = seeMoveFrom(m)
    to::Int      = seeMoveTo(m)
    koma::Int    = seeMovePiece(m) & 0x0f
    komadai::Int = (teban == SENTE) ? MO_MOVE_SENTE: MO_MOVE_GOTE
    removed::Int = seeMoveCapt(m)
    removedOmote = (removed > MJOU) ? removed - MJNARI : removed
    flag::Int    = seeMoveFlag(m)
    nari::Int    = flag & FLAG_NARI
    tori::Int    = flag & FLAG_TORI
    uchi::Int    = flag & FLAG_UCHI
    komatmp::Int = MJNONE

    # flag別に処理を行う

    if uchi == FLAG_UCHI
        # 打ち
        # ・打ち＝toを空っぽにし、toにあった駒を駒台に載せる
        # 　同時にtoの駒のbitboardを空にする
        uchiGoma::Int = q.square[to+1] & 0x0f
        if teban == SENTE
            q.WhitePiecesInHands[uchiGoma] += 1
        else
            q.BlackPiecesInHands[uchiGoma] += 1
        end
        q.bb[q.square[to+1]] $= BitSet[to+1]
        q.square[to+1] = MJNONE
    elseif tori == FLAG_TORI
        # 取り
        if teban == SENTE
            q.WhitePiecesInHands[removedOmote] -= 1
            if q.WhitePiecesInHands[removedOmote] < 0
                println("insufficient pieces in komadai(White,",removedOmote,")")
            end
        else
            q.BlackPiecesInHands[removedOmote] -= 1
            if q.BlackPiecesInHands[removedOmote] < 0
                println("insufficient pieces in komadai(Black,",removedOmote,")")
            end
        end

        aiteGoma::Int = ((teban$1) << 4)|removed

        if nari == FLAG_NARI
            # 取りかつ成り
            # ・取りかつ成り＝駒台（removedOmote）から駒を一つ減らし、
            # 　toの位置にremovedを相手駒にして置く。fromの位置にtoの駒を表にして移動
            # 　させる
            # 　同時に、removedの相手駒のbitboardのtoの位置に駒を置き、
            # 　toの位置の駒のbitboard内からtoの位置の駒を除くと一緒に
            #   toの位置の駒の表の駒のbitboardのfromの位置に表にした駒を置く
            q.bb[aiteGoma] |= BitSet[to+1]            
            q.bb[q.square[to+1]] $= BitSet[to+1]
            q.bb[q.square[to+1] - MJNARI] |= BitSet[from+1]

            q.square[from+1] = q.square[to+1] -MJNARI
            q.square[to+1] = aiteGoma

        else
            # 普通の取り
            # ・取り＝駒台（removedOmote）から駒を一つ減らし、
            # 　toの位置にremovedを相手駒にして置く。fromの位置にtoの駒を移動
            # 　させる
            # 　同時に、removedの相手駒のbitboardのtoの位置に駒を置き、
            # 　toの位置の駒のbitboard内でtoからfromに駒を移動する

            q.bb[aiteGoma] |= BitSet[to+1]            
            q.bb[q.square[to+1]] $= BitSet[to+1]
            q.bb[q.square[to+1]] |= BitSet[from+1]

            q.square[from+1] = q.square[to+1]
            q.square[to+1] = aiteGoma
        end
    elseif nari == FLAG_NARI
        # 普通の成り
        # ・成り＝toの位置を空っぽにする。toにあった駒を表にして、fromに置く。
        # 　同時にtoにあった駒のbitboardからtoの位置の駒を削除する
        # 　toの位置にあった駒の表の駒のbitboardの、fromの位置に表の駒を置く
        q.bb[q.square[to+1]] $= BitSet[to+1]
        q.bb[q.square[to+1] - MJNARI] |= BitSet[from+1]

        q.square[from+1] = q.square[to+1] - MJNARI
        q.square[to+1] = MJNONE

    else
        # 普通の指し手
        # ・普通の手＝toの位置を空っぽにする。toの位置の駒をfromに移動する。
        # 　同時に、toの位置の駒のbitboard内でtoからfromに駒を移動する
        q.bb[q.square[to+1]] $= BitSet[to+1]
        q.bb[q.square[to+1]] |= BitSet[from+1]

        q.square[from+1] = q.square[to+1]
        q.square[to+1] = MJNONE
    end

    if uchi != FLAG_UCHI
        if q.square[from+1] == MJOU
            q.kingposW = from+1
        elseif q.square[from+1] == MJGOOU
            q.kingposB = from+1
        end
    end

    q.WhitePieces = uint128(0)
    q.BlackPieces = uint128(0)
    for piece = MJFU:MJRY
        q.WhitePieces |=q.bb[piece]
        q.BlackPieces |=q.bb[piece+MJGOTE]
    end
    q.nextMove $= 1
    # consistencyBoard(q)
end

function islessA(a::Move, b::Move)
    if a.move > b.move
        return true
    else
        return false
    end
end

function BBTest2(gs::GameStatus)
    bo = Board()
    sfenHirate = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1"
    sfen = "8l/1l+R2P3/p2pBG1pp/kps1p4/Nn1P2G2/P1P1P2PP/1PS6/1KSG3+r1/LN2+p3L w Sbgn3p 124"::String
    board = InitSFEN(sfen, bo)
    DisplayBoard(board)
    out = [Move(0,0,0,0,0,0) for n = 1:10000]
    out2 = [Move(0,0,0,0,0,0) for n = 1:10000]
    println("generate moves!")
    num = generateBB(board,out,GOTE,0,gs)
    num2 = generateMoves(board,out2,GOTE,0,gs)
    if num != num2
        println("different moves!")
    else
        validateMoves(out,out2,num,num2)
    end
end

function BBTestForMoveGeneration(gs::GameStatus)
    bo = Board()
    sfenHirate = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1"
    board = InitSFEN(sfenHirate, bo)
    #DisplayBoard(board)
    sfen = "8l/1l+R2P3/p2pBG1pp/kps1p4/Nn1P2G2/P1P1P2PP/1PS6/1KSG3+r1/LN2+p3L w Sbgn3p 124"::String
    bo2 = Board()
    board2 = InitSFEN(sfen, bo2)
    DisplayBoard(board2)
    out = [Move(0,0,0,0,0,0) for n = 1:10000]
    out2 = [Move(0,0,0,0,0,0) for n = 1:10000]
    println("generate moves!")
    num::Int32 = 0
    tic()
    for x = 1:1000000 # 10000
        num = generateBB(board2,#board,
	                 out,                    #     /* IN/OUT: 可能手を格納する配列*/
	                 SENTE, #board.nextMove,         #     /* 可能手を生成する手番 */
                         0,
	                 gs)
    end
    toc()
    sort( out, islessA)

    println("return value of generate move = ", num)
    for i = 1:num
        ####println(hex(out[i].move),":",Move2String(out[i]))
        #println("1")
        #DisplayBoard(board2)
        makeMove(board2,
		 i,
		 out,
		 SENTE)
        #println("2")
        #DisplayBoard(board2)
        takeBack(board2,
		 i,
		 out,
		 SENTE)
        #println("3")
        #DisplayBoard(board2)
    end
    tic()
    for x = 1:1000000 # 10000
        num = generateMoves(board2,#board,
	                    out2,                    #     /* IN/OUT: 可能手を格納する配列*/
	                    SENTE, #board.nextMove,         #     /* 可能手を生成する手番 */
                            0,
	                    gs)
    end
    toc()
    println("return value of generate move = ", num)

    sort( out2, islessA)
    for i = 1:num
        #println(hex(out2[i].move),":",Move2String(out[i]))
        if out[i].move != out2[i].move
            #println("DIFF:  ", Move2String(out[i]),"<>",Move2String(out2[i]))
        else
            #println("MATCH: ", Move2String(out[i]),"<>",Move2String(out2[i]))
        end
    end


    tic()
    for x = 1:1000000 # 10000
        num = generateBB(board2,#board,
	                 out,                    #     /* IN/OUT: 可能手を格納する配列*/
	                 GOTE, #board.nextMove,         #     /* 可能手を生成する手番 */
                         0,
	                 gs)
    end
    toc()
    sort( out, islessA)
    println("return value of generate move = ", num)
    for i = 1:num
        #println(hex(out[i].move),":",Move2String(out[i]))
        #println("1")
        #DisplayBoard(board2)
        makeMove(board2,
		 i,
		 out,
		 GOTE)
        #println("2")
        #DisplayBoard(board2)
        takeBack(board2,
		 i,
		 out,
		 GOTE)
        #println("3")
        #DisplayBoard(board2)
    end
    tic()
    for x = 1:1000000 # 10000
        num = generateMoves(board2,#board,
	                    out2,                    #     /* IN/OUT: 可能手を格納する配列*/
	                    GOTE, #board.nextMove,         #     /* 可能手を生成する手番 */
                            0,
	                    gs)
    end
    toc()
    sort( out2, islessA)
    println("return value of generate move = ", num)
    for i = 1:num
        #println(hex(out2[i].move),":",Move2String(out[i]))
        if out[i].move != out2[i].move
            #println("DIFF:  ", Move2String(out[i]),"<>",Move2String(out2[i]))
        else
            #println("MATCH: ", Move2String(out[i]),"<>",Move2String(out2[i]))
        end
    end

    #@iprofile report

    v::Int = Eval( SENTE, board2)
    println("eval = ",v)
end
