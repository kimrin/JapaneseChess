const combine = 2

const EnableSlide = [0, # MW_KOMA_FU   = 1,   // 歩兵
                     1, # MW_KOMA_KY   = 2,   // 香車
                     0, # MW_KOMA_KE   = 3,   // 桂馬
                     0, # MW_KOMA_GI   = 4,   // 銀将
                     0, # MW_KOMA_KI   = 5,   // 金将
                     1, # MW_KOMA_KA   = 6,   // 角行
                     1, # MW_KOMA_HI   = 7,   // 飛車
                     0, # MW_KOMA_OU   = 8,   // 玉将／王将
                     0, # MW_KOMA_TO   = 9,   // と
                     0, # MW_KOMA_NY   = 10,  // 成香
                     0, # MW_KOMA_NK   = 11,  // 成桂
                     0, # MW_KOMA_NG   = 12,  // 成銀
                     0, # MW_KOMA_NARI_KIN_IS_ABSENT = 13,  // 金は成らない
                     combine,  # MW_KOMA_UM   = 14,  // 馬
                     combine]::Array{Int,1}  # MW_KOMA_RY   = 15,  // 龍

# 各駒ごとの効きの数
# スライドする駒の場合はその方向の数
# UM/RYが4なのは、１つづつ動ける方向が4つの意味
const koma_num_of_moves = [1, # MW_KOMA_FU   = 1,   // 歩兵
                           1, # MW_KOMA_KY   = 2,   // 香車
                           2, # MW_KOMA_KE   = 3,   // 桂馬
                           5, # MW_KOMA_GI   = 4,   // 銀将
                           6, # MW_KOMA_KI   = 5,   // 金将
                           4, # MW_KOMA_KA   = 6,   // 角行
                           4, # MW_KOMA_HI   = 7,   // 飛車
                           8, # MW_KOMA_OU   = 8,   // 玉将／王将
                           6, # MW_KOMA_TO   = 9,   // と
                           6, # MW_KOMA_NY   = 10,  // 成香
                           6, # MW_KOMA_NK   = 11,  // 成桂
                           6, # MW_KOMA_NG   = 12,  // 成銀
                           0, # MW_KOMA_NARI_KIN_IS_ABSENT = 13,  // 金は成らない
                           4, # MW_KOMA_UM   = 14,  // 馬(角行のslideの効きを付加する)
                           4]::Array{Int,1} # MW_KOMA_RY   = 15,  // 龍(飛車のslideの効きを付加する)


const koma_moves_offset =  [-11   0   0   0   0   0   0   0  0; # fu
                            -11   0   0   0   0   0   0   0  0; # ky
                            -23 -21   0   0   0   0   0   0  0; # ke
                            -12 -11 -10  10  12   0   0   0  0; # gi
                            -12 -11 -10  -1   1  11   0   0  0; # ki
                            -12 -10  10  12   0   0   0   0  0; # ka
                            -11  -1   1  11   0   0   0   0  0; # hi
                            -12 -11 -10  -1   1  10  11  12  0; # ou
                            -12 -11 -10  -1   1  11   0   0  0; # to
                            -12 -11 -10  -1   1  11   0   0  0; # ny
                            -12 -11 -10  -1   1  11   0   0  0; # nk
                            -12 -11 -10  -1   1  11   0   0  0; # ng
                              0   0   0   0   0   0   0   0  0; # nari_kin (none)
                            -11  -1   1  11   0   0   0   0  0; # um(non slide directions)
                            -12 -10  10  12   0   0   0   0  0]::Array{Int,2} # ry(non slide directions)

# mailbox81と一緒に使う。
# たとえばmailbox81[SQ91]=23で、
# mailbox[23] = 0となっている。
# つまりSQ = mailbox[mailbox81[SQ]]
# この辺Tom Kerrigan Simple Chessという
# 小さいチェスプログラムからアイデアを貰って
# 将棋向けに拡張しています。いわゆるmailbox方式
const mailbox = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                 -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                 -1,  0,  1,  2,  3,  4,  5,  6,  7,  8, -1,
                 -1,  9, 10, 11, 12, 13, 14, 15, 16, 17, -1,
                 -1, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1,
                 -1, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1,
                 -1, 36, 37, 38, 39, 40, 41, 42, 43, 44, -1,
                 -1, 45, 46, 47, 48, 49, 50, 51, 52, 53, -1,
                 -1, 54, 55, 56, 57, 58, 59, 60, 61, 62, -1,
                 -1, 63, 64, 65, 66, 67, 68, 69, 70, 71, -1,
                 -1, 72, 73, 74, 75, 76, 77, 78, 79, 80, -1,
                 -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                 -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]::Array{Int,1}

# mailboxの逆関数
const mailbox81 = [23, 24, 25, 26, 27, 28, 29, 30, 31,
                   34, 35, 36, 37, 38, 39, 40, 41, 42,
                   45, 46, 47, 48, 49, 50, 51, 52, 53,
                   56, 57, 58, 59, 60, 61, 62, 63, 64,
                   67, 68, 69, 70, 71, 72, 73, 74, 75,
                   78, 79, 80, 81, 82, 83, 84, 85, 86,
                   89, 90, 91, 92, 93, 94, 95, 96, 97,
                   100,101,102,103,104,105,106,107,108,
                   111,112,113,114,115,116,117,118,119]::Array{Int,1}

function CanMoveTo( teban::Int, from::Int, to::Int, koma::Int)
    ret::Int = true
    categ::Int = koma & 0x0f;

    if (MJFU <= categ <= MJKE)
    else
        return ret
    end

    if teban == SENTE
        if (categ == MJFU)&&(to < A8)
            ret = false
        elseif (categ == MJKY)&&(to < A8)
            ret = false
        elseif (categ == MJKE)&&(to < A7)
            ret = false
        end
    elseif teban == GOTE
        if (categ == MJFU)&&(to > I2)
            ret = false
        elseif (categ == MJKY)&&(to > I2)
            ret = false
        elseif (categ == MJKE)&&(to > I3)
            ret = false
        end
    end

    ret
end

const canpromA = [ 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]::Array{Int,1}
#                 FU,KY,KE,GI,KI,KA,HI,OU,TO,NY,NK,NG,nk,UM,RY

function CanIPromote( teban::Int, from::Int, to::Int, koma::Int)
    flag::Int = false
    f_y::Int = 0
    t_y::Int = 0

    if (koma != MJNONE)&&(teban == (koma>>>4))
    else
        return flag # 相手の駒は成れない
    end
    koma_plain::Int = koma & 0x0f

    enableProm = canpromA[koma_plain]
    if enableProm == 1
        koma_plain += MJNARI
    else
        return flag;
    end

    f_y = int(floor(from / 9))
    t_y = int(floor(to / 9))

    if teban == SENTE
        if (((f_y<=8)&&(f_y>=0))&&((t_y<=2)))
            flag = true
        end
        if (((t_y<=8)&&(t_y>=0))&&((f_y<=2)))
            flag = true
        end
    elseif teban == GOTE
        if ((f_y<=8)&&(t_y>=6))
            flag = true
        end
        if ((t_y<= 8)&&(f_y>=6))
            flag = true
        end
    end
    return flag
end

#@iprofile begin
function recycleMove(fu_bit_array::Uint,
	             teban::Int,
                     koma::Int,
	             p::Board,
	             out::Array{Move,1},
	             count::Int32,
	             gs::GameStatus)
    # 基本、盤面情報を元に「打ち」となる可能手を生成すればよい
    # 香車、桂馬の場合は手番ごと禁じ手となる盤面の隅への着手をチェックする
    # 歩の場合は盤面のハジへの着手とともに、２歩のチェックを行う
    komadai::Int = (teban == SENTE) ? MO_MOVE_SENTE: MO_MOVE_GOTE
    from::Int = 0
    to::Int   = 0
    i::Int    = 0
    j::Int    = 0
    value::Int= 0
    enable_move::Uint = 0
    fubi = uint32(fu_bit_array)
    co::Int32 = count

    if teban == SENTE
        from = A8    # 二段より手前
        to   = NumSQ # 九段まで
    elseif teban == GOTE
        from = A9    # 一段から
        to   = I2    # 八段まで
    end

    if koma == MJFU  # ここに本当は打ち歩詰めの判定処理が入る
        # とりあえず王の前に打てないようにすれば反則は防げるが、貴重な着手を無駄にするかも
    elseif koma == MJKY
        fu_bit_array = 0x1ff;
    elseif koma == MJKE
        fu_bit_array = 0x1ff;
        if teban == SENTE
            from = A7    # 三段より手前
            to   = NumSQ # 九段まで
        else
            from = A9    # 一段から
            to   = I3    # 七段まで
        end
    else # おそらく制限なし
        fu_bit_array = 0x1ff;
        from = A9
        to = NumSQ # 基本どこでも打てる
    end
    fubit::Uint32 = 0
    komaval::Int = koma|(teban<<4)

    for i = from:to
        if koma == MJFU
            j = (i-1) % 9
            #println("fubit=",hex(fu_bit_array), ", sq=", p.square[i], ", koma=", koma)
            fubit = uint32(1) << j
            enable_move = fubi & fubit
            #println("[",i,"][j=",j,"]: enable_move = 0x", hex(enable_move))
            if enable_move == 0
                continue
            end
            if (p.square[i] == MJNONE)&&(enable_move != 0)
                # 可能手生成
                # value = (komadai << 24) | (i << 16) | MW_FLAG_UCHI | teban | (koma&0x0f);
                # value = (komadai << 24) | (i << 16) | koma | teban | MW_FLAG_UCHI;
                # out[count].move = value;
                co += 0x00000001
                out[co] = Move(komaval,komadai,i-1,FLAG_UCHI,0,0)::Move # value = 0          
            end
        else
            if p.square[i] == MJNONE
                # 可能手生成
                # value = (komadai << 24) | (i << 16) | MW_FLAG_UCHI | teban | (koma&0x0f);
                # value = (komadai << 24) | (i << 16) | koma | teban | MW_FLAG_UCHI;
                # out[count].move = value;
                co += 0x00000001
                out[co] = Move(komaval,komadai,i-1,FLAG_UCHI,0,0)::Move # value = 0          
            end
        end
    end
    co
end
#end # @iprofile

function in_check( s::Int, p::Board)
    i::Int = 0

    for i = 0:(NumSQ-1)
        banpos::Int = p.square[i+1]
        pos_koma::Int = banpos & 0x0f
	if banpos == MJOU|(s<<4)
	    return NewAttack( s$1, i, p)
        end
    end
    return true  # shouldn't get here
end

function NewAttack(teban::Int, # 効きを調べる駒の種類
                   pos::Int,   # 効きを調べる升目（0 origin）
                   p::Board)
    i::Int = 0
    n::Int = 0
    for x = 0:(NumSQ-1)
        banpos::Int       = p.square[x+1] # 動かす駒
        pos_koma::Int     = banpos & 0x0f # 動かす駒の種類
        pos_sengo::Int    = (banpos & 0x10) >>> 4
        if (pos_koma != MJNONE)&&(pos_sengo == teban)
            bo::Bool = NewAttackSub( teban, pos, x, p)
            if bo
                return true
            end
        end
    end
    false
end

function NewAttackSub(teban::Int,
	              pos::Int,
	              from::Int,
	              p::Board)
    i::Int = 0
    n::Int = 0
    banfrom::Int      = p.square[from+1]            # 動かす駒
    from_koma::Int    = banfrom & 0x0f              # 動かす駒の種類
    num_of_moves::Int = koma_num_of_moves[from_koma]# 駒の動かせる方向数
    enable_s::Int     = EnableSlide[from_koma]      # slide pieceか否か
    teban_flag        = (teban == SENTE) ? 1: -1    # 先手なら１、後手ならー１
    nari::Bool        = false                       # 成りフラグ
    canMove::Bool     = false                       # 動かすことが可能なら1
    koma_teban::Int   = 0                           # 駒（移動先）の手番

    while true # UM,RY用のループ
        for i = 1:num_of_moves
            n = from
            while true
                n = mailbox[mailbox81[n+1] + (teban_flag*koma_moves_offset[from_koma,i])+1]
                if n == -1
                    break
                else
	            # make a move
	            nari = CanIPromote( teban, from, n, banfrom);
	            canMove = CanMoveTo(teban, from, n, banfrom);
                    newkoma = p.square[n+1]
	            koma_teban = (newkoma & 0x10) >>> 4;
	            if (newkoma != MJNONE) && (koma_teban == teban)
                        # 同じ種類の駒
                        if n == pos
                            return true
                        end
	                break
	            elseif (newkoma != MJNONE)&&(koma_teban == (teban$1))
	                # 駒取り
	                if nari
                            if n == pos
                                return true
                            end
                        end
                        if canMove
                            if n == pos
                                return true
                            end
                        end
	                break
                    else
	                if nari
                            if n == pos
                                return true
                            end
                        end
	                if canMove
                            if n == pos
                                return true
                            end
                        end
                    end
                end
                if enable_s == 1
                else
                    break
                end
            end
        end
        if enable_s == combine
            from_koma -= MJNARI # UM -> KA, RY -> HI
            enable_s = 1
        else
            break
        end
    end
    false
end

# function attack(teban::Int,
# 	        pos::Int,
# 	        p::Board)
#     i::Int = 0
#     n::Int = 0

#     nari::Bool        = false                       # 成りフラグ
#     canMove::Bool     = false                       # 動かすことが可能なら1
#     value::Int        = 0                           # 可能手の値
#     koma_teban::Int   = 0                           # 駒（移動先）の手番

#     plus1pos =  pos+1

#     for x = 0:(NumSQ-1)
#         banpos::Int       = p.square[x+1]             # 動かす駒
#         pos_koma::Int     = banpos & 0x0f               # 動かす駒の種類
#         num_of_moves::Int = (pos_koma == 0)?0:koma_num_of_moves[pos_koma] # 駒の動かせる方向数
#         enable_s::Int     = (pos_koma == 0)?0:EnableSlide[pos_koma]       # slide pieceか否か
#         teban_flag        = (teban == SENTE) ? 1: -1    # 先手なら１、後手ならー１
#         while true # UM,RY用のループ
#             for i = 1:num_of_moves
#                 n = x
#                 while true
#                     n = mailbox[mailbox81[n+1] + (teban_flag*koma_moves_offset[pos_koma,i])+1]
# 	            nari = CanIPromote( teban, x, n, banpos);
# 	            canMove = CanMoveTo(teban, x, n, banpos);
#                     if n == -1
#                         break
#                     else
#                         newkoma::Int = p.square[n+1]
# 	                koma_teban = (newkoma & 0x10) >>> 4;

# 	                if (newkoma != MJNONE) && (koma_teban == teban)
# 	                    break
# 	                elseif (newkoma != MJNONE)&&(koma_teban == ((teban==SENTE)?GOTE:SENTE))
#                             # 取り
# 	                    if nari
#                                 if n == pos
#                                     return true
#                                 end
#                             end
#                             if canMove
#                                 if n == pos
#                                     return true
#                                 end
#                             end
#                             break
#                         else
#                             # 空白のマスに進む
# 	                    if nari
#                                 if n == pos
#                                     return true
#                                 end
#                             end
#                             if canMove
#                                 if n == pos
#                                     return true
#                                 end
#                             end
#                         end
#                     end
#                     if enable_s == 1
#                     else
#                         break
#                     end
#                 end
#             end
#             if enable_s == combine
#                 pos_koma -= MJNARI # UM -> KA, RY -> HI
#                 #println("combine,koma=",pos_koma)
#                 enable_s = 1
#                 #continue
#             else
#                 break
#             end
#         end
#     end

#     false
# end


#println("AA offset    = ", koma_moves_offset[6,2])
function mailbox0x88(teban::Int,
	             pos::Int,
	             p::Board,
	             out::Array{Move,1}, # outは可能手バッファの先頭
	             count::Int32,         # countは既に見つけた可能手の個数
	             gs::GameStatus)
    i::Int = 0
    n::Int = 0
    banpos::Int       = p.square[pos+1]             # 動かす駒
    pos_koma::Int     = banpos & 0x0f               # 動かす駒の種類
    num_of_moves::Int = koma_num_of_moves[pos_koma] # 駒の動かせる方向数
    enable_s::Int     = EnableSlide[pos_koma]       # slide pieceか否か
    teban_flag        = (teban == SENTE) ? 1: -1    # 先手なら１、後手ならー１
    nari::Bool        = false                       # 成りフラグ
    canMove::Bool     = false                       # 動かすことが可能なら1
    value::Int        = 0                           # 可能手の値
    koma_teban::Int   = 0                           # 駒（移動先）の手番

    while true # UM,RY用のループ
        for i = 1:num_of_moves
            n = pos
            while true
                #println("A pos=",pos,", n=",n, ", koma = ", pos_koma, ", i = ", i, ", numofmoves= ", num_of_moves)
                #println("A mailbox81 = ", mailbox81[n+1])
                #println("A offset    = ", koma_moves_offset[pos_koma,i])
                n = mailbox[mailbox81[n+1] + (teban_flag*koma_moves_offset[pos_koma,i])+1]
                #println("B pos=",pos,", n=",n)
                if n == -1
                    break
                else
	            # make a move
	            nari = CanIPromote( teban, pos, n, banpos);
	            canMove = CanMoveTo(teban, pos, n, banpos);
	            # value = (pos << 24) | (n << 16);
                    newkoma = p.square[n+1]
	            koma_teban = (newkoma & 0x10) >>> 4;
	            if (newkoma != MJNONE) && (koma_teban == teban)
	                break
	            elseif (newkoma != MJNONE)&&(koma_teban == ((teban==SENTE)?GOTE:SENTE))
	                # 駒取り
	                if nari
	                    count += 1
                            out[count] = Move(banpos+MJNARI,pos,n,FLAG_NARI|FLAG_TORI,p.square[n+1]&0x0f,0)::Move # value = 0
                            InsertMoveAB(count,out,gs)
                        end
                        if canMove
                            count += 1
                            out[count] = Move(banpos,pos,n,FLAG_TORI,p.square[n+1]&0x0f,0)::Move # value = 0
                            InsertMoveAB(count,out,gs)
                        end
	                break
                    else
	                if nari
                            count += 1
                            out[count] = Move(banpos+MJNARI,pos,n,FLAG_NARI,0,0)::Move # value = 0
                            InsertMoveAB(count,out,gs)
                        end
	                if canMove
	                    count += 1
	                    out[count] = Move(banpos,pos,n,0,0,0)::Move # value = 0
                            InsertMoveAB(count,out,gs)
                        end
                    end
                end
                if enable_s == 1
                else
                    break
                end
            end
        end
        # println("count = ", count)
        if enable_s == combine
            pos_koma -= MJNARI # UM -> KA, RY -> HI
            #println("combine,koma=",pos_koma)
            enable_s = 1
            #continue
        else
            break
        end
    end
    count
end

function mailboxQ0x88(teban::Int,
	              pos::Int,
	              p::Board,
	              out::Array{Move,1}, # outは可能手バッファの先頭
	              count::Int32,         # countは既に見つけた可能手の個数
	              gs::GameStatus)
    i::Int = 0
    n::Int = 0
    banpos::Int       = p.square[pos+1]             # 動かす駒
    pos_koma::Int     = banpos & 0x0f               # 動かす駒の種類
    num_of_moves::Int = koma_num_of_moves[pos_koma] # 駒の動かせる方向数
    enable_s::Int     = EnableSlide[pos_koma]       # slide pieceか否か
    teban_flag        = (teban == SENTE) ? 1: -1    # 先手なら１、後手ならー１
    nari::Bool        = false                       # 成りフラグ
    canMove::Bool     = false                       # 動かすことが可能なら1
    value::Int        = 0                           # 可能手の値
    koma_teban::Int   = 0                           # 駒（移動先）の手番

    while true # UM,RY用のループ
        for i = 1:num_of_moves
            n = pos
            while true
                #println("A pos=",pos,", n=",n, ", koma = ", pos_koma, ", i = ", i, ", numofmoves= ", num_of_moves)
                #println("A mailbox81 = ", mailbox81[n+1])
                #println("A offset    = ", koma_moves_offset[pos_koma,i])
                n = mailbox[mailbox81[n+1] + (teban_flag*koma_moves_offset[pos_koma,i])+1]
                #println("B pos=",pos,", n=",n)
                if n == -1
                    break
                else
	            # make a move
	            nari = CanIPromote( teban, pos, n, banpos);
	            canMove = CanMoveTo(teban, pos, n, banpos);
	            # value = (pos << 24) | (n << 16);
                    newkoma = p.square[n+1]
	            koma_teban = (newkoma & 0x10) >>> 4;
	            if (newkoma != MJNONE) && (koma_teban == teban)
	                break
	            elseif (newkoma != MJNONE)&&(koma_teban == ((teban==SENTE)?GOTE:SENTE))
	                # 駒取り
	                if nari
	                    count += 1
                            out[count] = Move(banpos+MJNARI,pos,n,FLAG_NARI|FLAG_TORI,p.square[n+1]&0x0f,0)::Move # value = 0
                            InsertMove(count,out,gs)
                        end
                        if canMove
                            count += 1
                            out[count] = Move(banpos,pos,n,FLAG_TORI,p.square[n+1]&0x0f,0)::Move # value = 0
                            InsertMove(count,out,gs)
                        end
	                break
                    else
	                if nari
                            count += 1
                            out[count] = Move(banpos+MJNARI,pos,n,FLAG_NARI,0,0)::Move # value = 0
                            InsertMove(count,out,gs)
                        end
                    end
                end
                if enable_s == 1
                else
                    break
                end
            end
        end
        # println("count = ", count)
        if enable_s == combine
            pos_koma -= MJNARI # UM -> KA, RY -> HI
            #println("combine,koma=",pos_koma)
            enable_s = 1
            #continue
        else
            break
        end
    end
    count
end

# 可能手生成（first draft）
# 昔あった持ち駒bit arrayは盤面を参照すればいらないはず
# 盤面を進める・戻すのはmakeMove/takeBackが行う
# 一手詰めを検出していない、非合法手を含んだ配列を返す
#@iprofile begin
function generateMoves(p::Board,           #     /* IN:盤面 */
	               out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	               teban::Int,         #     /* 可能手を生成する手番 */
                       co::Int,
	               gs::GameStatus)

    i::Int = 0
    j::Int = 0
    count::Int32 = int32(co)
    fu_bit_array::Uint = 0x1ff # 歩を打てない筋に対応するbitが0になる
    # MW_u08t *k = &(p->ban[0]);

    # 歩のある筋をfu_bit_arrayにセット: ２歩の検出のため
    for i = 0:(NumSQ-1)
        j = i % 9
        val::Int = p.square[i+1]
        if val & 0x0f == MJFU
            if (val & 0x10) >>> 4 == teban
	        fu_bit_array &= ~(1<<j) # jは(9-段+1): 左から何列目か
            end
        end                  
    end
    #println("fu_bit_array = 0x", hex(fu_bit_array))

    # ここから可能手生成部
    # まず駒を動かすことで生成できる手を生成する
    # k = &(p->ban[0]);
    for i = 0:(NumSQ-1)
        koma::Int = p.square[i+1]
        komateban::Int = (koma&0x10)>>>4
        if (koma != MJNONE)&&(komateban == teban) # 自分の駒をまず拾い出して可能手生成
            count = mailbox0x88( teban, i, p, out, count, gs)
        end
    end

    # 打つ手を生成する
    # k = &(p->ban[0]);
    ##println("uchu!(count = ", count, ")")
    # MW_u08t fromIdx = (teban == SENTE) ? MO_HI_SENTE: MO_HI_GOTE;
    # MW_u08t toIdx = (teban == SENTE) ? MO_SENTE_OFFSET: MO_GOTE_OFFSET;
    fromIdx::Int = MJHI
    toIdx::Int =   MJFU
    for j = fromIdx:-1:toIdx
        uchiGoma = j
        if teban == SENTE
            if p.WhitePiecesInHands[j] == 0
            else
              count = recycleMove( fu_bit_array, teban, uchiGoma, p, out, count, gs)
            end
        else
            if p.BlackPiecesInHands[j] == 0
            else
              count = recycleMove( fu_bit_array, teban, uchiGoma, p, out, count, gs)
            end
        end
    end
    #println("return value of generate move = ", count)
    count # 可能手の通算の数を返す
end
#end # @iprofile begin

function generateQMoves(p::Board,           #     /* IN:盤面 */
	                out::Array{Move,1}, #     /* IN/OUT: 可能手を格納する配列*/
	                teban::Int,         #     /* 可能手を生成する手番 */
                        co::Int,
	                gs::GameStatus)

    i::Int = 0
    j::Int = 0
    count::Int32 = int32(co)

    # ここから可能手生成部
    # まず駒を動かすことで生成できる手を生成する
    # k = &(p->ban[0]);
    for i = 0:(NumSQ-1)
        koma::Int = p.square[i+1]
        komateban::Int = (koma&0x10)>>>4
        if (koma != MJNONE)&&(komateban == teban) # 自分の駒をまず拾い出して可能手生成
            count = mailboxQ0x88( teban, i, p, out, count, gs)
        end
    end

    count # 可能手の通算の数を返す
end

function SujiDanFrom(from::Int)
    s1::UTF8String = ""
    if from == MO_MOVE_SENTE
        s1 = "駒台"
    elseif from == MO_MOVE_GOTE
        s1 = "駒台"
    else
        s1 = string(SUJISTR[9- (from%9)],DANSTR[int(floor(from/9)) + 1])
    end
    s1
end

function SujiDanTo(to::Int)
    #println("to=",to,"suji=",9-(to%9),", dan=",int(to/9)+1)
    s1::UTF8String = string(SUJISTR[9- (to%9)],DANSTR[int(floor(to/9)) + 1])
    s1
end

function Move2String(m::Move)
    from::Int  = seeMoveFrom(m)
    to::Int    = seeMoveTo(m)
    capt::Int  = seeMoveCapt(m)
    flag::Int  = seeMoveFlag(m)
    piece::Int = seeMovePiece(m)
    sengo::Int = (piece & 0x10) >>> 4

    captstr::UTF8String = ""
    naristr::UTF8String = ""
    uchistr::UTF8String = ""

    if capt != 0
        captstr = string(KOMASTR[capt],"取り")
    end
    if flag & FLAG_NARI != 0
        naristr = "成り"
    end
    if flag & FLAG_UCHI != 0
        uchistr = "打ち"
    end

    s::String = string(TEBANSTR[sengo+1],SujiDanTo(to),"(",SujiDanFrom(from),")",KOMASTR[piece&0x0f],captstr,naristr,uchistr)
    s
end

function makeMoveOld(q::Board,
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
        q.square[to+1] = (teban << 4)|int(koma)
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
            q.square[from+1] = MJNONE
        end
    else
        # 駒を取る
        if (komavalTo & 0x10) == (teban << 4)
            # illegal move!
            println("Illegal move! (",Move2String(out[moveIdx]),")")
        else
            q.square[to+1] = (teban << 4)|koma
            komavalTo::Int = komavalTo & 0x0f
            normalKoma = (komavalTo > MJOU) ? komavalTo - MJNARI: komavalTo
            if teban == SENTE
                q.WhitePiecesInHands[normalKoma] += 1
                #println("mochiW(",normalKoma,") = ", q.WhitePiecesInHands[normalKoma])
            else
                q.BlackPiecesInHands[normalKoma] += 1
                #println("mochiB(",normalKoma,") = ", q.BlackPiecesInHands[normalKoma])
            end
            q.square[from+1] = MJNONE
        end
    end
    q.nextMove $= 1
end

# レジスタ使いすぎ。。。
function takeBackOld(q::Board,
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
        q.square[to+1] = MJNONE
        if teban == SENTE
            q.WhitePiecesInHands[uchiGoma] += 1
        else
            q.BlackPiecesInHands[uchiGoma] += 1
        end
    elseif tori == FLAG_TORI
        # toの駒をfromに戻す（case 3と同じ）
        # その上で駒台の駒をtoに戻す
        komatmp = q.square[to+1]
        # 成っていた場合は表に戻す
        q.square[from+1] = (nari == FLAG_NARI) ? komatmp - MJNARI: komatmp
        if q.square[from+1] == MJOU
            q.kingposW = from+1
        elseif q.square[from+1] == MJGOOU
            q.kingposB = from+1
        end
        # 駒台の駒を元のtoに戻す。
        q.square[to+1] = removed | ((teban$1)<< 4) # 相手の駒に
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
        # 成っていた場合は表に戻す
        q.square[from+1] = (nari == FLAG_NARI) ? komatmp - MJNARI: komatmp
        if q.square[from+1] == MJOU
            q.kingposW = from+1
        elseif q.square[from+1] == MJGOOU
            q.kingposB = from+1
        end
    end
    q.nextMove $= 1
end

function findPosition(st::ASCIIString) # 0 origin
    fromSuji::Int = int(st[1] - '0')
    fromDan::Int  = int(st[2] - '`')
    #println("(suji,dan) = ",fromSuji, ",",fromDan)
    return (fromDan-1)*NumFile + (9-fromSuji)
    # return BOARDINDEX[fromSuji,fromDan] - 1
end

function findIndex(out::Array{Move,1},move::ASCIIString,sengo::Int,
                   Start::Int,End::Int)
    index::Int = -1
    nari::Int = 0
    uchiKoma::Int = 0
    uchi::Int = 0
    i::Int = 0

    if '1' <= move[1] <= '9' # normal move
        from = findPosition(move[1:2])
        to   = findPosition(move[3:4])
        if length(move) == 5
            if move[5] == '+'
                #println("NARI!")
                nari = FLAG_NARI
            end
        end
    else # Uchi
        uchi = FLAG_UCHI
        if sengo == SENTE
            from = MO_MOVE_SENTE
        else
            from = MO_MOVE_GOTE
        end
        uchiKoma = get(usiDict,move[1:1],0)|(sengo<<4)
        to = findPosition(move[3:4])
    end
    #println("from=", from, ", to=", to)
    mm::Move = Move(sengo<<4,from,to,nari|uchi,0,0)::Move
    lhs::Int = mm.move & 0xffff05f0
    lhs2::Int = mm.move & 0xfffff000
    #println("start,end = ", Start, ", ", End)
    for i = Start:End
        # println("# lhs = ", hex(lhs), ", out[i].move = ", hex(out[i].move & 0xfffff5f0))
        if (out[i].move & 0xffff0000) == (mm.move & 0xffff0000)
            #println("move[",i,"(",Start,",",End,")] = ", hex(out[i].move),",lhs=",hex(lhs),",move=",move)
        end
        if lhs == (out[i].move & 0xffff05f0)
            if uchi > 0
                if (out[i].move & 0x1f) == uchiKoma
                    index = i
                    break
                end
            else    
                index = i
                break
            end
        end
        if lhs2 == (out[i].move & 0xffff0f00)
            #println("lhs2=",hex(lhs2),"move=",hex(out[i].move))
        end
    end
    return index
end

function move2USIString(m::Move)
    ret::String = ""
    nari::Int = 0
    capt::String = ""
    from::String = ""
    to::String = ""

    if (m.move & 0x00000400) == 0x00000400 # UCHI
        capt = num2usiDict[int(m.move & 0x1f)]
        to   = USISQNAME[seeMoveTo(m)+1]
        ret = string(capt,"*",to)
    else # 普通の手
        to   = USISQNAME[seeMoveTo(m)+1]
        from = USISQNAME[seeMoveFrom(m)+1]
        if (m.move & 0x00000100) == 0x00000100
            nari = FLAG_NARI
            ret = string(from,to,"+")
        else
            ret = string(from,to)
        end
    end
    return ret
end

function IndexTest()
    count::Int = 0
    for j = 'a':'i'
        for i = '9':-1:'1'
            sq = string(i,j)
            println("sq=",sq)
            idx::Int = findPosition(sq)
            println("index=",idx)
            println("USI[",idx+1,"] = ", USISQNAME[idx+1])
            if (sq == USISQNAME[idx+1])
                count += 1
            end
        end
    end
    println(count," matched.")
end

#IndexTest()

function GenMoveTest(gs::GameStatus)
    bo = Board()
    #board = SquareInit(HIRATE,[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],SENTE,bo)
    sfenHirate = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1"
    board = InitSFEN(sfenHirate, bo)
    DisplayBoard(board)
    sfen = "8l/1l+R2P3/p2pBG1pp/kps1p4/Nn1P2G2/P1P1P2PP/1PS6/1KSG3+r1/LN2+p3L w Sbgn3p 124"::String
    bo2 = Board()
    board2 = InitSFEN(sfen, bo2)
    DisplayBoard(board2)
    out = [Move(0,0,0,0,0,0) for n = 1:1000]
    #history = [0 for x = 1:NumSQ, y = 1:NumSQ]
    println("generate moves!")
    num::Int32 = 0
    tic()
    for x = 1:100000 # 10000
        num = generateMoves(board2,#board,
	                    out,                    #     /* IN/OUT: 可能手を格納する配列*/
	                    SENTE, #board.nextMove,         #     /* 可能手を生成する手番 */
	                    #(board2.nextMove == SENTE)? GOTE:SENTE, #board.nextMove,         #     /* 可能手を生成する手番 */
                            0,
	                    gs)
    end
    toc()
    println("return value of generate move = ", num)
    for i = 1:num
        println(hex(out[i].move),":",Move2String(out[i]))
    end
    #@iprofile report

    v::Int = Eval( SENTE, board2)
    println("eval = ",v)

    num = generateMoves(board, out, SENTE, 0, gs)
    for i = 1:num
        makeMove(board,
		 i,
		 out,
		 SENTE)
        takeBack(board,
		 i,
		 out,
		 SENTE)
    end
    num = generateMoves(board, out, GOTE, 0, gs)
    for i = 1:num
        makeMove(board,
		 i,
		 out,
		 GOTE)
        takeBack(board,
		 i,
		 out,
		 GOTE)
    end
    DisplayBoard(board)
    v = Eval( SENTE, board)
    println("eval = ",v)
    for i = 0:(NumSQ-1)
        print("[")
        if NewAttack(SENTE, i, board)
            #println("SQ[",SQUARENAME[i+1],"](SENTE) is attacked!")
            print("S")
        else
            print("_")
        end
        if NewAttack(GOTE, i, board)
            #println("SQ[",SQUARENAME[i+1],"](GOTE ) is attacked!")
            print("G")
        else
            print("_")
        end
        print("]")
        if (i % 9) == 8
            println()
        end
    end
end

#GenMoveTest()
