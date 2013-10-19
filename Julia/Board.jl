# -*- coding: utf-8 -*-

type Board
    bb::Array{BitBoard,1} # bb[MJKI] のように使う
    WhitePieces::BitBoard
    BlackPieces::BitBoard
    OccupiedSquares::BitBoard

    WhitePiecesInHands::Array{Int,1}
    BlackPiecesInHands::Array{Int,1}

    nextMove::Int # SENTE or GOTE

    Material::Int                # incrementally updated, total material on board,
                                 # in centipawns, from white’s side of view
    square::Array{Int,1}         # incrementally updated, this array is usefull if we want to
                                 # probe what kind of piece is on a particular square.
    viewRotated::Bool            # only used for displaying the board. true or false.

    kingposW::Int
    kingposB::Int

    Board() = begin # 空っぽにする
        t = new([uint128(0) for x=1:MJGONUM]::Array{BitBoard,1},
                uint128(0),uint128(0),uint128(0),
                [0,0,0,0,0,0,0,0]::Array{Int,1},[0,0,0,0,0,0,0,0]::Array{Int,1},
                SENTE,0.0,
                [0 for x=1:NumSQ], false, 0, 0)
        t
    end
end

const BitSet = [(uint128(1) << i) for i=0:80]::Array{BitBoard,1}
#const BitSetRL90 = [BitSet[RL90[sq]] for sq=A9:I1]::Array{BitBoard,1}
#const BitSetRL45 = [BitSet[RL45[sq]] for sq=A9:I1]::Array{BitBoard,1}
#const BitSetRR45 = [BitSet[RR45[sq]] for sq=A9:I1]::Array{BitBoard,1}

function DisplayBitBoard(bb::BitBoard,isRotate::Bool)
    boardc = Array(String,NumSQ)

    for sq = 1:NumSQ
        boardc[sq] = ((bb & BitSet[sq]) != uint128(0)) ? "1": "."
    end

    println("as binary integer:")

    for i = 81:-1:1
        print("$(boardc[i])");
    end

    println("")

    println( "firstOne=", leading_zeros(bb),
            ", LastOne=", trailing_zeros(bb),
            ", BitCnt=", count_ones(bb))

    println("")

    if isRotate

        println("   ihgfedcba")
        for rank = 1:NumRank
            print("   ")
            for file = NumFile:-1:1
	        print(boardc[FR2IDX(file,rank)])
            end
            println(" $rank")
        end
        println("")
    else
        println("   abcdefghi")
        for rank = NumRank:-1:1
            print(" $rank ")
            for file = 1:NumFile
	        print(boardc[FR2IDX(file,rank)])
            end
            println("")
        end
        println("")
    end
end

function inBoard( irank::Int, ifile::Int)
    ( irank >= rank1 ) && (irank <= rank9) && (ifile >= file1) && (ifile <= file9 )
end

function setAttack( irank::Int, ifile::Int, bb::BitBoard )
    if inBoard( irank, ifile)
        bb $= BitSet[FR2IDX(ifile,irank)]
    end
    bb
end

function SquareInit(sq::Array{Int,1}, mochi_sente::Array{Int,1}, mochi_gote::Array{Int,1}, sengo::Int, bo::Board)
    bo.bb = [uint128(0) for x=1:MJGONUM]::Array{BitBoard,1}
    bo.WhitePieces = uint128(0)::BitBoard
    bo.BlackPieces = uint128(0)::BitBoard
    bo.OccupiedSquares = uint128(0)::BitBoard

    bo.WhitePiecesInHands = mochi_sente::Array{Int,1}
    bo.BlackPiecesInHands = mochi_gote::Array{Int,1}

    bo.Material = 0::Int

    bo.nextMove = sengo::Int

    bo.square = [0 for x=1:NumSQ]::Array{Int,1}
    bo.viewRotated = false::Bool

    for idx = 1:NumSQ
        piece = sq[idx]
        bo.square[idx] = piece
        if piece == MJNONE
            continue
        end
        if piece == MJOU
            bo.kingposW = idx
        elseif piece == MJGOOU
            bo.kingposB = idx
        end

        if piece > MJGOTE
            bo.Material -= MATERIAL[piece&0x0f]
        elseif piece >= MJFU
            bo.Material += MATERIAL[piece&0x0f]
        end
        bo.bb[piece] |= BitSet[idx]
    end

    for piece = MJFU:MJOU
        bo.Material -= bo.BlackPiecesInHands[piece]*MATERIAL_CAPTURE[piece]
        bo.Material += bo.WhitePiecesInHands[piece]*MATERIAL_CAPTURE[piece]
    end

    for piece = MJFU:MJRY
        bo.WhitePieces |=bo.bb[piece]
        bo.BlackPieces |=bo.bb[piece+MJGOTE]
    end

    bo.OccupiedSquares = bo.WhitePieces | bo.BlackPieces

#    for i = 1:(MJGONUM-1)
#        println(PIECENAMES[i+1])
#        DisplayBitBoard( bo.bb[i], false)
#    end
#    println("White Pieces:")
#    DisplayBitBoard( bo.WhitePieces, false)
#    println("Black Pieces:")
#    DisplayBitBoard( bo.BlackPieces, false)
#    println("Occupied Squares:")
#    DisplayBitBoard( bo.OccupiedSquares, false)

    bo
end

function InitSFEN(sfen::String, bo::Board)
    rank::Int = 9
    file::Int = 1
    promote::Int = 0
    sq::Array{Int,1}
    sengo::Int = SENTE

    fen, bw, mochi, num = split(sfen)
    sq = [0 for x = A9:I1]::Array{Int,1}

    for s in fen
        # println(s)
        if s == '/'
            rank -= 1
            file =  1
        elseif s == '+'
            promote = MJNARI
        elseif s >= '1' && s <= '9'
            file += int(s-'0')
        elseif s == 'P'
            sq[BOARDINDEX[file,rank]]=MJFU+promote
            file += 1
            promote = 0
        elseif s == 'L'
            sq[BOARDINDEX[file,rank]]=MJKY+promote
            file += 1
            promote = 0
        elseif s == 'N'
            sq[BOARDINDEX[file,rank]]=MJKE+promote
            file += 1
            promote = 0
        elseif s == 'S'
            sq[BOARDINDEX[file,rank]]=MJGI+promote
            file += 1
            promote = 0
        elseif s == 'G'
            sq[BOARDINDEX[file,rank]]=MJKI
            file += 1
            promote = 0
        elseif s == 'B'
            sq[BOARDINDEX[file,rank]]=MJKA+promote
            file += 1
            promote = 0
        elseif s == 'R'
            sq[BOARDINDEX[file,rank]]=MJHI+promote
            file += 1
            promote = 0
        elseif s == 'K'
            sq[BOARDINDEX[file,rank]]=MJOU
            file += 1
            promote = 0

            # ここから後手

        elseif s == 'p'
            sq[BOARDINDEX[file,rank]]=MJGOFU+promote
            file += 1
            promote = 0
        elseif s == 'l'
            sq[BOARDINDEX[file,rank]]=MJGOKY+promote
            file += 1
            promote = 0
        elseif s == 'n'
            sq[BOARDINDEX[file,rank]]=MJGOKE+promote
            file += 1
            promote = 0
        elseif s == 's'
            sq[BOARDINDEX[file,rank]]=MJGOGI+promote
            file += 1
            promote = 0
        elseif s == 'g'
            sq[BOARDINDEX[file,rank]]=MJGOKI
            file += 1
            promote = 0
        elseif s == 'b'
            sq[BOARDINDEX[file,rank]]=MJGOKA+promote
            file += 1
            promote = 0
        elseif s == 'r'
            sq[BOARDINDEX[file,rank]]=MJGOHI+promote
            file += 1
            promote = 0
        elseif s == 'k'
            sq[BOARDINDEX[file,rank]]=MJGOOU
            file += 1
            promote = 0
        end
    end

    if bw == "w"
        sengo = SENTE
    else # bw == "b"
        sengo = GOTE
    end

    mo_sente::Array{Int,1} = [0 for x in MJFU:MJOU]
    mo_gote::Array{Int,1}  = [0 for x in MJFU:MJOU]

    numberOfMochi::Int = 0
    for s in mochi
        if s == '-'
            break # 持ち駒なし
        elseif s == '1'
            if numberOfMochi == 1
                numberOfMochi = 11
            else
                numberOfMochi = 1
            end
        elseif s == '0'
            if numberOfMochi == 1
                numberOfMochi = 10
            end
        elseif '2' <= s <= '9'
            if numberOfMochi == 1
                numberOfMochi = 10 + int(s - '0')
            else
                numberOfMochi = int(s - '0')
            end
        elseif s == 'P'
            mo_sente[MJFU] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'L'
            mo_sente[MJKY] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'N'
            mo_sente[MJKE] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'S'
            mo_sente[MJGI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'G'
            mo_sente[MJKI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'B'
            mo_sente[MJKA] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'R'
            mo_sente[MJHI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'K' # 普通はない
            mo_sente[MJOU] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0

            # ここから後手

        elseif s == 'p'
            mo_gote[MJFU] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'l'
            mo_gote[MJKY] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'n'
            mo_gote[MJKE] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 's'
            mo_gote[MJGI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'g' 
            mo_gote[MJKI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'b'
            mo_gote[MJKA] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'r'
            mo_gote[MJHI] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        elseif s == 'k' # 普通はない
            mo_gote[MJOU] = numberOfMochi == 0 ? 1: numberOfMochi
            numberOfMochi = 0
        end
    end

    bo = SquareInit(sq,mo_sente,mo_gote,sengo,bo)
    bo
end

function DisplayMochiGoma( bo::Board, sengo::Int)
    senteNum::Int = 0
    goteNum::Int = 0
    if sengo == SENTE
        print("\e[34m", TEBANSTR[1], "\e[30m 持駒　")
        for i = MJOU:-1:MJFU
            mochi = bo.WhitePiecesInHands[i]
            if mochi > 0
                senteNum += 1

                print(MOCHISTR[i])
                if mochi > 1
                    print(mochi)
                end
            end
        end
        if senteNum == 0
            print("なし")
        end
        println()
    elseif sengo == GOTE
        print(TEBANSTR[2], " 持駒　")
        for i = MJOU:-1:MJFU
            mochi = bo.BlackPiecesInHands[i]
            if mochi > 0
                senteNum += 1

                print(MOCHISTR[i])
                if mochi > 1
                    print(mochi)
                end
            end
        end
        if senteNum == 0
            print("なし")
        end
        println()
    else
        println("Illegal Mochi Goma!")
    end
end

function DisplayBoard(bo::Board)
    println()
    DisplayMochiGoma(bo,GOTE)
    println(" ９　  ８　  ７　  ６　  ５　  ４　  ３　  ２　  １　 ")
    sq::Int = 0

    for i = 1:NumRank
        for j = 1:NumFile
            sq += 1
            koma = bo.square[sq]
            komamoji::UTF8String = doubleZenkakuSpace
            if koma == MJNONE
	        print("\e[36m ..  \e[30m ")
            else
                komamoji = KOMASTR[koma&0x0f]
                if koma < MJGOTE
                    print("\e[34m+")
                    print(KOMASTR[koma&0x0f],"\e[30m ")
                elseif koma > MJGOTE
                    print("\e[30m-")
                    print(KOMASTR[koma&0x0f],"\e[30m ")
                end
            end
        end
        println(DANSTR[i])
    end
    DisplayMochiGoma(bo,SENTE)
    println("Material = ", bo.Material)
    println()
end

function BBTest()
    #InitTables()
    bb::BitBoard = uint128(0)
    #println(bb)
    bb2 = setAttack( 5, 5, bb)
    #println(bb2)
    bo = Board()
    #DisplayBitBoard(bb2,false)
    for x=A9:I1
        b = BitSet[x]
        sqname = SQUARENAME[x]
        #println("SQ[$sqname] BitSet\[$x\] = ", b, " count one = ", count_ones(b),
        #        " leading_zeros = ", leading_zeros(b), " trailing_zeros = ", trailing_zeros(b))
        #DisplayBitBoard(b,false)
    end
    for ra = 1:NumRank, fi = 1:NumFile
        #println("BOARDINDEX[$fi,$ra] = $(BOARDINDEX[fi,ra])")
    end
    #board = SquareInit(HIRATE,[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],SENTE,bo)
    sfenHirate = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1"
    board = InitSFEN(sfenHirate, bo)
    #DisplayBoard(board)
    #sfen = "8l/1l+R2P3/p2pBG1pp/kps1p4/Nn1P2G2/P1P1P2PP/1PS6/1KSG3+r1/LN2+p3L w Sbgn3p 124"::String
    #bo2 = Board()
    #board2 = InitSFEN(sfen, bo2)
    #DisplayBoard(board2)
end

#BBTest()
