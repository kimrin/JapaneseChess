# -*- coding: utf-8 -*-

const MaxPly   = 80      # とりあえず大きめに取る。実際はこの半分もいかない。。。
const MaxMoves = 8000000 # 少ないかも。。。でもこんなに読まない。。。

const SENTE = 0 # ▲先手
const GOTE  = 1 # △後手

const ALPHALINE = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" }

#fi = open("table.jl","w")
#
#idx = 1
#
#for dan = 9:-1:1
#    for suji = 1:9
#        write( fi, "const $(ALPHALINE[suji])$(dan) = $(idx)\n")
#        idx+=1
#    end
#end
#close(fi)

const MaskOfBoard = parseint(Uint128,"000000000001ffffffffffffffffffff",16)::Uint128

const A9 = 1
const B9 = 2
const C9 = 3
const D9 = 4
const E9 = 5
const F9 = 6
const G9 = 7
const H9 = 8
const I9 = 9
const A8 = 10
const B8 = 11
const C8 = 12
const D8 = 13
const E8 = 14
const F8 = 15
const G8 = 16
const H8 = 17
const I8 = 18
const A7 = 19
const B7 = 20
const C7 = 21
const D7 = 22
const E7 = 23
const F7 = 24
const G7 = 25
const H7 = 26
const I7 = 27
const A6 = 28
const B6 = 29
const C6 = 30
const D6 = 31
const E6 = 32
const F6 = 33
const G6 = 34
const H6 = 35
const I6 = 36
const A5 = 37
const B5 = 38
const C5 = 39
const D5 = 40
const E5 = 41
const F5 = 42
const G5 = 43
const H5 = 44
const I5 = 45
const A4 = 46
const B4 = 47
const C4 = 48
const D4 = 49
const E4 = 50
const F4 = 51
const G4 = 52
const H4 = 53
const I4 = 54
const A3 = 55
const B3 = 56
const C3 = 57
const D3 = 58
const E3 = 59
const F3 = 60
const G3 = 61
const H3 = 62
const I3 = 63
const A2 = 64
const B2 = 65
const C2 = 66
const D2 = 67
const E2 = 68
const F2 = 69
const G2 = 70
const H2 = 71
const I2 = 72
const A1 = 73
const B1 = 74
const C1 = 75
const D1 = 76
const E1 = 77
const F1 = 78
const G1 = 79
const H1 = 80
const I1 = 81

# const RL90 = [A1, A2, A3, A4, A5, A6, A7, A8, A9,
# 	      B1, B2, B3, B4, B5, B6, B7, B8, B9,
# 	      C1, C2, C3, C4, C5, C6, C7, C8, C9,
# 	      D1, D2, D3, D4, D5, D6, D7, D8, D9,
# 	      E1, E2, E3, E4, E5, E6, E7, E8, E9,
# 	      F1, F2, F3, F4, F5, F6, F7, F8, F9,
# 	      G1, G2, G3, G4, G5, G6, G7, G8, G9,
# 	      H1, H2, H3, H4, H5, H6, H7, H8, H9,
# 	      I1, I2, I3, I4, I5, I6, I7, I8, I9]::Array{Int,1}
              
# const RL45 = [A9, B1, C2, D3, E4, F5, G6, H7, I8,
# 	      A8, B9, C1, D2, E3, F4, G5, H6, I7,
# 	      A7, B8, C9, D1, E2, F3, G4, H5, I6,
# 	      A6, B7, C8, D9, E1, F2, G3, H4, I5,
# 	      A5, B6, C7, D8, E9, F1, G2, H3, I4,
# 	      A4, B5, C6, D7, E8, F9, G1, H2, I3,
# 	      A3, B4, C5, D6, E7, F8, G9, H1, I2,
# 	      A2, B3, C4, D5, E6, F7, G8, H9, I1,
# 	      A1, B2, C3, D4, E5, F6, G7, H8, I9]::Array{Int,1}
  
# const RR45 = [I8, I7, I6, I5, I4, I3, I2, I1, I9,
# 	      H7, H6, H5, H4, H3, H2, H1, H9, H8,
# 	      G6, G5, G4, G3, G2, G1, G9, G8, G7,
# 	      F5, F4, F3, F2, F1, F9, F8, F7, F6,
# 	      E4, E3, E2, E1, E9, E8, E7, E6, E5,
# 	      D3, D2, D1, D9, D8, D7, D6, D5, D4,
# 	      C2, C1, C9, C8, C7, C6, C5, C4, C3,
# 	      B1, B9, B8, B7, B6, B5, B4, B3, B2,
# 	      A9, A8, A7, A6, A5, A4, A3, A2, A1]::Array{Int,1}

const MJNONE = 0 # 駒なし
const MJFU   = 1 # 歩兵
const MJKY   = 2 # 香車
const MJKE   = 3 # 桂馬
const MJGI   = 4 # 銀将
const MJKI   = 5 # 金将
const MJKA   = 6 # 角行
const MJHI   = 7 # 飛車
const MJOU   = 8 # 玉将／王将
const MJNARI = 8 #
const MJTO   = 9 # と
const MJNY   = 10 #成香
const MJNK   = 11 #成桂
const MJNG   = 12 #成銀
const MJPKIN = 13 #金は成らない
const MJUM   = 14 #馬
const MJRY   = 15 #龍
const MJNUM  = 16 #正規の駒は16種類
const MJGOTE = 16 # 後手の駒は16を足す

const MJGOFU   = 17 # 歩兵
const MJGOKY   = 18 # 香車
const MJGOKE   = 19 # 桂馬
const MJGOGI   = 20 # 銀将
const MJGOKI   = 21 # 金将
const MJGOKA   = 22 # 角行
const MJGOHI   = 23 # 飛車
const MJGOOU   = 24 # 玉将／王将
const MJGONARI = 24
const MJGOTO   = 25 # と
const MJGONY   = 26 #成香
const MJGONK   = 27 #成桂
const MJGONG   = 28 #成銀
const MJGOPKIN = 29 #金は成らない
const MJGOUM   = 30 #馬
const MJGORY   = 31 #龍
const MJGONUM  = 32 #正規の駒は16種類

const mjfu_max = 18
const mfky_max = 4
const mjke_max = 4
const mjgi_max = 4
const mjki_max = 4
const mjka_max = 2
const mjhi_max = 2
const mjou_max = 2

const rank1 = 1
const rank2 = 2
const rank3 = 3
const rank4 = 4
const rank5 = 5
const rank6 = 6
const rank7 = 7
const rank8 = 8
const rank9 = 9

const file1 = 1
const file2 = 2
const file3 = 3
const file4 = 4
const file5 = 5
const file6 = 6
const file7 = 7
const file8 = 8
const file9 = 9

const FILES = [1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9,
               1,2,3,4,5,6,7,8,9]::Array{Int,1}

const RANKS = [9,9,9,9,9,9,9,9,9,
	       8,8,8,8,8,8,8,8,8,
	       7,7,7,7,7,7,7,7,7,
	       6,6,6,6,6,6,6,6,6,
	       5,5,5,5,5,5,5,5,5,
	       4,4,4,4,4,4,4,4,4,
	       3,3,3,3,3,3,3,3,3,
	       2,2,2,2,2,2,2,2,2,
	       1,1,1,1,1,1,1,1,1]::Array{Int,1}

const SQUARENAME = ["a9","b9","c9","d9","e9","f9","g9","h9","i9",
                    "a8","b8","c8","d8","e8","f8","g8","h8","i8",
                    "a7","b7","c7","d7","e7","f7","g7","h7","i7",
                    "a6","b6","c6","d6","e6","f6","g6","h6","i6",
                    "a5","b5","c5","d5","e5","f5","g5","h5","i5",
                    "a4","b4","c4","d4","e4","f4","g4","h4","i4",
                    "a3","b3","c3","d3","e3","f3","g3","h3","i3",
                    "a2","b2","c2","d2","e2","f2","g2","h2","i2",
                    "a1","b1","c1","d1","e1","f1","g1","h1","i1"]::Array{ASCIIString,1}

const USISQNAME = ["9a","8a","7a","6a","5a","4a","3a","2a","1a",
		   "9b","8b","7b","6b","5b","4b","3b","2b","1b",
		   "9c","8c","7c","6c","5c","4c","3c","2c","1c",
		   "9d","8d","7d","6d","5d","4d","3d","2d","1d",
		   "9e","8e","7e","6e","5e","4e","3e","2e","1e",
		   "9f","8f","7f","6f","5f","4f","3f","2f","1f",
		   "9g","8g","7g","6g","5g","4g","3g","2g","1g",
		   "9h","8h","7h","6h","5h","4h","3h","2h","1h",
		   "9i","8i","7i","6i","5i","4i","3i","2i","1i"]::Array{ASCIIString,1}

const HIRATE = [ MJGOKY, MJGOKE, MJGOGI, MJGOKI, MJGOOU, MJGOKI, MJGOGI, MJGOKE, MJGOKY,
                 MJNONE, MJGOHI, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJGOKA, MJNONE,
                 MJGOFU, MJGOFU, MJGOFU, MJGOFU, MJGOFU, MJGOFU, MJGOFU, MJGOFU, MJGOFU,
                 MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE,
                 MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE,
                 MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJNONE,
                 MJFU,   MJFU,   MJFU,   MJFU,   MJFU,   MJFU,   MJFU,   MJFU,   MJFU,
                 MJNONE, MJKA,   MJNONE, MJNONE, MJNONE, MJNONE, MJNONE, MJHI,   MJNONE,
                 MJKY,   MJKE,   MJGI,   MJKI,   MJOU,   MJKI,   MJGI,   MJKE,   MJKY
                ]::Array{Int,1}

const PIECENAMES = ["  ", "P ", "L ", "N ", "S ", "G ", "B ", "R ",
		    "K ", "+P", "+L", "+N", "+S", "  ", "+B", "+R",
		    "  ", "p ", "l ", "n ", "s ", "g ", "b ", "r ",
		    "k ", "+p", "+l", "+n", "+s", "  ", "+b", "+r"]::Array{ASCIIString,1}
const usiDict = {"P"=>MJFU,"L"=>MJKY,"N"=>MJKE,"S"=>MJGI,
                 "G"=>MJKI,"B"=>MJKA,"R"=>MJHI,
                 "p"=>MJFU,"l"=>MJKY,"n"=>MJKE,"s"=>MJGI,
                 "g"=>MJKI,"b"=>MJKA,"r"=>MJHI}::Dict{Any,Any}

const num2usiDict = {MJFU=>"P",MJKY=>"L",MJKE=>"N",MJGI=>"S",
                     MJKI=>"G",MJKA=>"B",MJHI=>"R",
                     MJGOFU=>"P",MJGOKY=>"L",MJGOKE=>"N",MJGOGI=>"S",
                     MJGOKI=>"G",MJGOKA=>"B",MJGOHI=>"R"}::Dict{Any,Any}

const NumHand = 7
const NumFile = 9
const NumRank = 9
const NumSQ   = 81

const doubleZenkakuSpace = "　　"::UTF8String

const KOMASTR = ["歩　",
                 "香　",
                 "桂　",
                 "銀　",
                 "金　",
                 "角　",
                 "飛　",
                 "王　",
                 "と　",
                 "成香",
                 "成桂",
                 "成銀",
                 "成金",
                 "馬　",
                 "龍　"]::Array{UTF8String,1}

const MOCHISTR = ["歩",
                  "香",
                  "桂",
                  "銀",
                  "金",
                  "角",
                  "飛",
                  "王"]::Array{UTF8String,1}

const TEBANSTR = ["▲ ", "△ "]::Array{UTF8String,1}

const SUJISTR  = ["１",
                  "２",
                  "３",
                  "４",
                  "５",
                  "６",
                  "７",
                  "８",
                  "９"]::Array{UTF8String,1}

const DANSTR = ["一",
                "二",
                "三",
                "四",
                "五",
                "六",
                "七",
                "八",
                "九"]::Array{UTF8String,1}

const MATERIAL = [87, # FU
                  232,# KY
                  257,# KE
                  369,# GI
                  444,# KI
                  569,# KA
                  642,# HI
                  15000, # OU
                  534,# TO
                  489,# NY
                  510,# NK
                  495,# NG
                  0,  # Nari Kin
                  827,# UM
                  945,# RY
                  ]::Array{Int,1}

const MATERIAL_CAPTURE = [174,   # FU
                          464,   # KY
                          514,   # KE
                          738,   # GI
                          888,   # KI
                          1138,  # KA
                          1284,  # HI
                          15000, # OU
                          621,   # TO
                          721,   # NY
                          767,   # NK
                          864,   # NG
                          0,     # Nari Kin
                          1396,  # UM
                          1587,  # RY
                          ]::Array{Int,1}

FR2IDX(file,rank) = ((9-(rank))*NumFile + ((file)))

typealias BitBoard Uint128

const BOARDINDEX = [FR2IDX(f,r) for f = 1:9, r=1:9]::Array{Int,2}

const f_hand_pawn   =    0
const e_hand_pawn   =   19
const f_hand_lance  =   38
const e_hand_lance  =   43
const f_hand_knight =   48
const e_hand_knight =   53
const f_hand_silver =   58
const e_hand_silver =   63
const f_hand_gold   =   68
const e_hand_gold   =   73
const f_hand_bishop =   78
const e_hand_bishop =   81
const f_hand_rook   =   84
const e_hand_rook   =   87
const fe_hand_end   =   90
const f_pawn        =   81
const e_pawn        =  162
const f_lance       =  225
const e_lance       =  306
const f_knight      =  360
const e_knight      =  441
const f_silver      =  504
const e_silver      =  585
const f_gold        =  666
const e_gold        =  747
const f_bishop      =  828
const e_bishop      =  909
const f_horse       =  990
const e_horse       = 1071
const f_rook        = 1152
const e_rook        = 1233
const f_dragon      = 1314
const e_dragon      = 1395
const fe_end        = 1476

const kkp_hand_pawn   =   0
const kkp_hand_lance  =  19
const kkp_hand_knight =  24
const kkp_hand_silver =  29
const kkp_hand_gold   =  34
const kkp_hand_bishop =  39
const kkp_hand_rook   =  42
const kkp_hand_end    =  45
const kkp_pawn        =  36
const kkp_lance       = 108
const kkp_knight      = 171
const kkp_silver      = 252
const kkp_gold        = 333
const kkp_bishop      = 414
const kkp_horse       = 495
const kkp_rook        = 576
const kkp_dragon      = 657
const kkp_end         = 738

const pos_n = int((fe_end) * ( fe_end + 1) / 2)

