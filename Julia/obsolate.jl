##### unused codes #####
##### do not import! #####

function makeMoveBroken(q::Board,
		        moveIdx::Int,
		        out::Array{Move,1},
		        teban::Int)
    #println("moveIdx=",moveIdx)
    m::Move = out[moveIdx]
    from::Int    = seeMoveFrom(m)
    to::Int      = seeMoveTo(m)
    koma::Int    = seeMovePiece(m) & 0x0f
    komadai::Int = (teban == SENTE) ? MO_MOVE_SENTE: MO_MOVE_GOTE
    komavalTo = q.square[to+1]
    # seeMoveCapt(m)
    # seeMoveFlag(m)
    if komavalTo == MJNONE
        # そのまま置く、打ちも含む
        #println("q.square[",to+1,"] = ", q.square[to+1])
        q.square[to+1] = (teban << 4)|int(koma)
        tmpko = q.square[to+1]
        #println("teban=",teban,"koma=",koma)
        q.bb[q.square[to+1]] |= BitSet[to+1]
        #println("q.square[to+1] = ", q.square[to+1])
        #DisplayBitBoard( q.bb[q.square[to+1]], false)
        if q.square[to+1] == MJOU
            q.kingposW = to+1
        elseif q.square[to+1] == MJGOOU
            q.kingposB = to+1
        end
        if from > NumSQ # 駒台から一つ駒を取り除く
            if from == MO_MOVE_SENTE
                q.WhitePiecesInHands[koma] -= 1
                #println("mochiWR(",koma,") = ", q.WhitePiecesInHands[koma])
                if q.WhitePiecesInHands[koma] < 0
                    println("Shotage of Mochigoma array (koma = ,",koma,")")
                end
            else
                q.BlackPiecesInHands[koma] -= 1
                #println("mochiBR(",koma,") = ", q.BlackPiecesInHands[koma])
                if q.BlackPiecesInHands[koma] < 0
                    println("Shotage of Mochigoma array (koma = ,",koma,")")
                end
            end
        else
            if q.square[from+1] == MJNONE
                println("from=",from,", that is wrong case!",Move2String(out[moveIdx]),")")
            else
                q.bb[q.square[to+1]] &= ~BitSet[from+1]
            end
            q.square[from+1] = MJNONE
        end
    else
        # 駒を取る
        if (komavalTo & 0x10) == (teban << 4)
            # illegal move!
            println("Illegal move!(1) (",Move2String(out[moveIdx]),")")
        else
            q.bb[q.square[to+1]] $= BitSet[to+1]
            q.square[to+1] = (teban << 4)|koma
            q.bb[q.square[to+1]] |= BitSet[to+1]
            komavalTo::Int = komavalTo & 0x0f
            normalKoma = (komavalTo > MJOU) ? komavalTo - MJNARI: komavalTo
            if teban == SENTE
                q.WhitePiecesInHands[normalKoma] += 1
                #println("mochiW(",normalKoma,") = ", q.WhitePiecesInHands[normalKoma])
            else
                q.BlackPiecesInHands[normalKoma] += 1
                #println("mochiB(",normalKoma,") = ", q.BlackPiecesInHands[normalKoma])
            end
            q.bb[q.square[from+1]] &= ~BitSet[from+1]    
            q.square[from+1] = MJNONE
        end
    end
    q.WhitePieces = uint128(0)
    q.BlackPieces = uint128(0)
    for piece = MJFU:MJRY
        q.WhitePieces |=q.bb[piece]
        q.BlackPieces |=q.bb[piece+MJGOTE]
    end
    q.nextMove $= 1

    consistencyBoard(q)
end

# レジスタ使いすぎ。。。
function takeBackBroken(q::Board,
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

    if (uchi == FLAG_UCHI) # case 1: 打ち。toの駒を駒台に戻す
        uchiGoma = q.square[to+1] & 0x0f
        q.bb[q.square[to+1]] &= ~BitSet[to+1]
        q.square[to+1] = MJNONE
        if teban == SENTE
            q.WhitePiecesInHands[uchiGoma] += 1
        else
            q.BlackPiecesInHands[uchiGoma] += 1
        end
    elseif tori == FLAG_TORI
        if removed == MJNONE
            println("Illegal move! (No Captured Piece with FLAG_TORI)")
        end
        # toの駒をfromに戻す（case 3と同じ）
        # その上で駒台の駒をtoに戻す
        komatmp = q.square[to+1]
        # 成っていた場合は表に戻す
        q.square[from+1] = (nari == FLAG_NARI) ? komatmp - MJNARI: komatmp
        if (nari == FLAG_NARI)
            q.bb[q.square[from+1]+MJNARI] &= ~BitSet[from+1]
            q.bb[q.square[from+1]] |= BitSet[from+1]
        else
            q.bb[q.square[from+1]] |= BitSet[from+1]
        end
        if q.square[from+1] == MJOU
            q.kingposW = from+1
        elseif q.square[from+1] == MJGOOU
            q.kingposB = from+1
        end
        # 駒台の駒を元のtoに戻す。
        #q.bb[q.square[to+1]] $= BitSet[to+1]
        q.square[to+1] = removed | ((teban$1)<< 4) # 相手の駒に
        if removed != MJNONE
            q.bb[q.square[to+1]] |= BitSet[to+1]
        end
        if teban == SENTE
            q.WhitePiecesInHands[removedOmote] -= 1
            if q.WhitePiecesInHands[removedOmote] < 0
                println("Illegal Move (takeBack,TORI,White)")
            end
        else
            q.BlackPiecesInHands[removedOmote] -= 1
            if q.BlackPiecesInHands[removedOmote] < 0
                println("Illegal Move (takeBack,TORI,Black)")
            end
        end
    else # case 3: 駒台の絡まない普通の指し手。toをfromに戻すだけ
        komatmp = q.square[to+1]
        q.square[to+1] = MJNONE
        q.bb[komatmp] &= ~BitSet[to+1]
        # 成っていた場合は表に戻す
        q.square[from+1] = (nari == FLAG_NARI) ? komatmp - MJNARI: komatmp
        if (nari == FLAG_NARI)
            q.bb[q.square[from+1]+MJNARI] &= ~BitSet[from+1]
            q.bb[q.square[from+1]] |= BitSet[from+1]
        else
            q.bb[q.square[from+1]] |= BitSet[from+1]
        end
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
    consistencyBoard(q)
end
