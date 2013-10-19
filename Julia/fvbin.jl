# いまのところ、読み込む必要ないので、
# コメントアウトしておく。。。

fi = open("../fv.bin", "r")
const pc_on_sq = read( fi, Int16, NumSQ, pos_n)
const kkp = read( fi, Int16, NumSQ, NumSQ, kkp_end)
#println("type of pc_on_sq = ", typeof(pc_on_sq))
#println("type of kkp = ", typeof(kkp))
close(fi)