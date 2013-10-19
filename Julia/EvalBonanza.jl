#PcPcOnSq(k::Int,i::Int,j::Int) = pc_on_sq[k,int((i+1)*(i)/2)+(j)] # bug
PcPcOnSq(k::Int,i::Int,j::Int) = pc_on_sq[k,int((i-1)*(i)/2)+(j-1)+1]

function make_list( list0::Array{Int,1}, list1::Array{Int,1}, p::Board, gs::GameStatus)
    list2::Array{Int,1} = [0 for x=1:35]::Array{Int,1}
    nlist::Int = 15
    score::Int = 0
    sq_bk0::Int = p.kingposB
    sq_wk0::Int = p.kingposW
    sq_bk1::Int = 82 - p.kingposW
    sq_wk1::Int = 82 - p.kingposB
    
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_pawn  + p.BlackPiecesInHands[MJFU]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_lance + p.BlackPiecesInHands[MJKY]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_knight+ p.BlackPiecesInHands[MJKE]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_silver+ p.BlackPiecesInHands[MJGI]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_gold  + p.BlackPiecesInHands[MJKI]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_bishop+ p.BlackPiecesInHands[MJKA]]
    score += kkp[sq_bk0,sq_wk0, 1+ kkp_hand_rook  + p.BlackPiecesInHands[MJHI]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_pawn  + p.WhitePiecesInHands[MJFU]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_lance + p.WhitePiecesInHands[MJKY]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_knight+ p.WhitePiecesInHands[MJKE]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_silver+ p.WhitePiecesInHands[MJGI]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_gold  + p.WhitePiecesInHands[MJKI]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_bishop+ p.WhitePiecesInHands[MJKA]]
    score -= kkp[sq_bk1,sq_wk1, 1+ kkp_hand_rook  + p.WhitePiecesInHands[MJHI]]

    n2::Int = 1
    bb::BitBoard = p.bb[MJGOFU]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_pawn + sq + 1
        list2[n2]    = e_pawn + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_pawn + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJFU]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_pawn + sq + 1
        list2[n2]    = f_pawn + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_pawn + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOKY]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_lance + sq + 1
        list2[n2]    = e_lance + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_lance + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJKY]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_lance + sq + 1
        list2[n2]    = f_lance + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_lance + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOKE]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_knight + sq + 1
        list2[n2]    = e_knight + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_knight + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJKE]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_knight + sq + 1
        list2[n2]    = f_knight + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_knight + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOGI]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_silver + sq + 1
        list2[n2]    = e_silver + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_silver + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJGI]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_silver + sq + 1
        list2[n2]    = f_silver + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_silver + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = (p.bb[MJGOKI]|p.bb[MJGOTO]|p.bb[MJGONY]|p.bb[MJGONK]|p.bb[MJGONG])
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_gold + sq + 1
        list2[n2]    = e_gold + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_gold + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = (p.bb[MJKI]|p.bb[MJTO]|p.bb[MJNY]|p.bb[MJNK]|p.bb[MJNG])
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_gold + sq + 1
        list2[n2]    = f_gold + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_gold + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOKA]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_bishop + sq + 1
        list2[n2]    = e_bishop + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_bishop + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJKA]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_bishop + sq + 1
        list2[n2]    = f_bishop + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_bishop + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOUM]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_horse + sq + 1
        list2[n2]    = e_horse + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_horse + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJUM]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_horse + sq + 1
        list2[n2]    = f_horse + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_horse + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGOHI]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_rook + sq + 1
        list2[n2]    = e_rook + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_rook + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJHI]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_rook + sq + 1
        list2[n2]    = f_rook + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_rook + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    n2 = 1
    bb = p.bb[MJGORY]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = f_dragon + sq + 1
        list2[n2]    = e_dragon + ((80 - sq)+1)
        score += kkp[sq_bk0,sq_wk0,kkp_dragon + sq + 1]
        nlist += 1
        n2    += 1
    end

    bb = p.bb[MJRY]
    while bb > uint128(0)
        sq::Int = trailing_zeros(bb)
        bb $= BitSet[sq+1]
        list0[nlist] = e_dragon + sq + 1
        list2[n2]    = f_dragon + ((80 - sq)+1)
        score += kkp[sq_bk1,sq_wk1,kkp_dragon + (80 - sq)+1]
        nlist += 1
        n2    += 1
    end

    for i = 1:(n2-1)
        list1[nlist-i] = list2[i]
        #println("list1[",nlist,"-",i," = ", nlist-i, "] = list2[",i,"]")
    end

    if nlist > 53
        println("nlist is larger than 53.")
    end

    return nlist-1, score
end

function EvalBonanza(nextMove::Int, p::Board, gs::GameStatus)
    list0::Array{Int,1} = [0 for x=1:53]::Array{Int,1}
    list1::Array{Int,1} = [0 for x=1:53]::Array{Int,1}

    list0[ 1] = f_hand_pawn   + p.BlackPiecesInHands[MJFU] + 1
    list0[ 2] = e_hand_pawn   + p.WhitePiecesInHands[MJFU] + 1
    list0[ 3] = f_hand_lance  + p.BlackPiecesInHands[MJKY] + 1
    list0[ 4] = e_hand_lance  + p.WhitePiecesInHands[MJKY] + 1
    list0[ 5] = f_hand_knight + p.BlackPiecesInHands[MJKE] + 1
    list0[ 6] = e_hand_knight + p.WhitePiecesInHands[MJKE] + 1
    list0[ 7] = f_hand_silver + p.BlackPiecesInHands[MJGI] + 1
    list0[ 8] = e_hand_silver + p.WhitePiecesInHands[MJGI] + 1
    list0[ 9] = f_hand_gold   + p.BlackPiecesInHands[MJKI] + 1
    list0[10] = e_hand_gold   + p.WhitePiecesInHands[MJKI] + 1
    list0[11] = f_hand_bishop + p.BlackPiecesInHands[MJKA] + 1
    list0[12] = e_hand_bishop + p.WhitePiecesInHands[MJKA] + 1
    list0[13] = f_hand_rook   + p.BlackPiecesInHands[MJHI] + 1
    list0[14] = e_hand_rook   + p.WhitePiecesInHands[MJHI] + 1

    list1[ 1] = f_hand_pawn   + p.WhitePiecesInHands[MJFU] + 1
    list1[ 2] = e_hand_pawn   + p.BlackPiecesInHands[MJFU] + 1
    list1[ 3] = f_hand_lance  + p.WhitePiecesInHands[MJKY] + 1
    list1[ 4] = e_hand_lance  + p.BlackPiecesInHands[MJKY] + 1
    list1[ 5] = f_hand_knight + p.WhitePiecesInHands[MJKE] + 1
    list1[ 6] = e_hand_knight + p.BlackPiecesInHands[MJKE] + 1
    list1[ 7] = f_hand_silver + p.WhitePiecesInHands[MJGI] + 1
    list1[ 8] = e_hand_silver + p.BlackPiecesInHands[MJGI] + 1
    list1[ 9] = f_hand_gold   + p.WhitePiecesInHands[MJKI] + 1
    list1[10] = e_hand_gold   + p.BlackPiecesInHands[MJKI] + 1
    list1[11] = f_hand_bishop + p.WhitePiecesInHands[MJKA] + 1
    list1[12] = e_hand_bishop + p.BlackPiecesInHands[MJKA] + 1
    list1[13] = f_hand_rook   + p.WhitePiecesInHands[MJHI] + 1
    list1[14] = e_hand_rook   + p.BlackPiecesInHands[MJHI] + 1

    nlist::Int = 0
    score::Int = 0

    nlist, score = make_list( list0, list1, p, gs)
    #for i = 1:nlist
    #    if list0[i] >= fe_end
    #        println("list0[",i,"]=",list0[i])
    #    end
    #    if list1[i] >= fe_end
    #        println("list1[",i,"]=",list1[i])
    #    end
    #end
    sq_bk::Int = p.kingposB
    sq_wk::Int = 82 - p.kingposW
    
    sum::Int = 0

    for i = 1:nlist
        k0::Int = list0[i]
        k1::Int = list1[i]
        for j = 1:i-1
            l0::Int = list0[j]
            l1::Int = list1[j]
            #try
                sum += PcPcOnSq( sq_bk, k0, l0)
                sum -= PcPcOnSq( sq_wk, k1, l1)
            #catch
            #    println("sq_bk=",sq_bk,",sq_wk=",sq_wk)
            #    println("k0=",k0,",k1=",k1)
            #    println("l0=",l0,",l1=",l1)
            #    println("i,j=",i,",",j)
            #    quit()
            #end
        end
    end

    score += sum
    score += 32 * Eval( SENTE, p, gs)

    if nextMove == GOTE
        score = -score
    end

    score = int(score/32)

    noise = (rand(Uint32) % 6) - 3
    score += noise

    return score
end