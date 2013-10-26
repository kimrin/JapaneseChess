# very large values
const Infinity = 100000

const OUDANSENTE =  [1200,1200,900,600, 300, -10,   0,    0,    0]::Array{Int,1}
const OUDANGOTE   = [   0,   0,  0, 10,-300,-600,-900,-1200,-1200]::Array{Int,1}

#@iprofile begin
function Eval( nextMove::Int, p::Board, gs::GameStatus)
    score::Int = 0
    i::Int = 0
    bbp::BitBoard = uint128(0)
    from::Int = 0

    bbp = p.WhitePieces
    tebanP::Int = SENTE
    while bbp > uint128(0)
        from = trailing_zeros(bbp)
        bbp $= BitSet[from+1]
        q::Int = p.square[from+1]
        koma::Int = q & 0x0f
        score += MATERIAL[koma]
    end

    bbp = p.BlackPieces
    tebanP = GOTE
    while bbp > uint128(0)
        from = trailing_zeros(bbp)
        bbp $= BitSet[from+1]
        q::Int = p.square[from+1]
        koma::Int = q & 0x0f
        score -= MATERIAL[koma]
    end

    for i = MJFU:MJHI
        score += p.WhitePiecesInHands[i] * MATERIAL[i] #MATERIAL_CAPTURE[i]
        score -= p.BlackPiecesInHands[i] * MATERIAL[i] #MATERIAL_CAPTURE[i]
    end

    if (nextMove == GOTE)
        score = -score
    end
    return score
end
#end # @iprofile