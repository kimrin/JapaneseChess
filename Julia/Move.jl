#       Following 2 lines of code is an MVV/LVA scheme:
#	val = 128 * PIECEVALUES[capt.getCapt()] + PIECEVALUES[capt.getPiec()]; 
#	if (capt.isPromotion()) val += 512 * PIECEVALUES[capt.getProm()];

function MVVLVA(c_koma::Int, flag::Int, piece::Int)
    v::Int = 0
    # c_koma::Int = seeMoveCapt(m)
    # piece::Int = seeMovePiece(m) & 0x0f
    capt::Int = c_koma & 0x0f
    piece2::Int = piece & 0x0f

    matCapt::Int = (capt == MJNONE)?0:MATERIAL[capt]
    matPiece::Int = (piece2 == MJNONE)?0:MATERIAL[piece2]

    v = 128 * matCapt + matPiece
    if (flag & FLAG_NARI) == FLAG_NARI
        v += 512 * matPiece
    end

    return v
end

# 早速immutable構文を使ってみるなど(^_^;)

immutable type Move
    move::Uint
    value::Int
    Move(Piece::Int,From::Int,To::Int,Flags::Int,Capt::Int,value::Int) = new(((From&0x000000ff)<<24)|((To&0x000000ff)<<16)|((Capt&0x0000000f)<<12)|((Flags&0x00000007)<<8)|(Piece&0x0000001f),MVVLVA(Capt,Flags,Piece))
end

seeMoveFrom(m::Move)  = int((m.move & 0xff000000)>>>24)
seeMoveTo(m::Move)    = int((m.move & 0x00ff0000)>>>16)
seeMoveCapt(m::Move)  = int((m.move & 0x0000f000)>>>12)
seeMoveFlag(m::Move)  = int((m.move & 0x00000f00)>>>8)
seeMovePiece(m::Move) = int(m.move & 0x0000001f)

const FLAG_NARI = int(0x1) # 成ったときに可能手にフラグを立てる
const FLAG_TORI = int(0x2) # 駒を取ったときに可能手にフラグを立てる
const FLAG_UCHI = int(0x4) # 駒を打ったときに可能手にフラグを立てる

# あとは必要に応じて関数を追加する。先手か後手かなど

