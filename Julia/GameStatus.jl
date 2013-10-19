# game status

immutable type TransP
    hs::Uint64
    best::Move
    depth::Float64
    flags::Int
    val::Int
end

type GameStatus
    bookfile::String
    usebook::Bool
    canponder::Bool
    hashsize::Uint32
    board::Board
    lastPV::Array{Move,1}
    lastPVLength::Int
    whiteHeuristics::Array{Int,2}
    blackHeuristics::Array{Int,2}
    inodes::Int32
    nsStart::Int
    moveBufLen::Array{Int,1}
    moveBuf::Array{Move,1}
    triangularLength::Array{Int,1}
    triangularArray::Array{Move,2}
    side::Int
    timedout::Bool
    followpv::Bool
    allownull::Bool
    pvmovesfound::Int
    depth::Float64
    AttackTableNonSlide::Array{BitBoard,2}
    FillRank::Array{BitBoard,1}
    FillFile::Array{BitBoard,1}
    fukyBitsW::BitBoard
    fukyBitsB::BitBoard
    keBitsW::BitBoard
    keBitsB::BitBoard
    MovableKoma::Array{BitBoard,2}
    SenteJin::BitBoard
    GoteJin::BitBoard
    SenteOthers::BitBoard
    GoteOthers::BitBoard
    MoveBeginIndex::Int
    tt::Dict{Uint64,TransP}
    GameStatus() = new()
end

function InitGS()
    gs = GameStatus()
    gs.bookfile = "./Joseki.db"
    gs.usebook  = true
    gs.canponder= true
    gs.hashsize = uint32(256 * 1024 * 1024)
    gs.board = Board()
    gs.lastPV = [Move(0,0,0,0,0,0) for x = 1:MaxPly]::Array{Move,1}
    gs.lastPVLength = 0
    gs.whiteHeuristics = [0 for x = 1:NumSQ, y = 1:NumSQ]::Array{Int,2}
    gs.blackHeuristics = [0 for x = 1:NumSQ, y = 1:NumSQ]::Array{Int,2}
    gs.inodes = 0
    gs.nsStart = 0
    gs.moveBufLen = [0 for x = 1:MaxPly]::Array{Int,1}
    gs.moveBuf = [Move(0,0,0,0,0,0) for x = 1:MaxMoves]
    gs.triangularLength = [0 for x = 1:MaxPly]::Array{Int,1}
    gs.triangularArray  = [Move(0,0,0,0,0,0) for x = 1:MaxPly, y = 1:MaxPly]::Array{Move,2}
    gs.side = SENTE # 仮に先手として、後で書き換える
    gs.timedout = false
    gs.followpv = true
    gs.allownull = true
    gs.pvmovesfound = 0
    gs.depth = 0.0
    gs.AttackTableNonSlide = [uint128(0) for piece=MJFU:MJGORY, sq=A9:I1]::Array{BitBoard,2}
    gs.FillRank = [uint128(0) for r=1:9]::Array{BitBoard,1}
    gs.FillFile = [uint128(0) for f=1:9]::Array{BitBoard,1}
    gs.fukyBitsW = uint128(0)::BitBoard
    gs.fukyBitsB = uint128(0)::BitBoard
    gs.keBitsW   = uint128(0)::BitBoard
    gs.keBitsB   = uint128(0)::BitBoard
    gs.MovableKoma = [uint128(0) uint128(0) uint128(0);
                      uint128(0) uint128(0) uint128(0)]::Array{BitBoard,2}
    gs.SenteJin    = uint128(0)::BitBoard
    gs.GoteJin     = uint128(0)::BitBoard
    gs.SenteOthers = uint128(0)::BitBoard
    gs.GoteOthers  = uint128(0)::BitBoard

    gs.MoveBeginIndex = 0
    gs.tt = Dict{Uint64,TransP}()

    #println("$gs")
    gs
end

