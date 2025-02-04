



const startingpos = 

replace(
"""
rnbqkbnr
pppppppp
________
________
________
________
pppppppp
RNBQKBNR
""",
"\n"=>""
)

const char2bits = Dict{Char,NTuple{5,Bool}}((
'p' => (1,0,0,0,0),
'P' => (1,0,0,0,0),
'n' => (0,1,0,0,0),
'N' => (0,1,0,0,0),
'b' => (0,0,1,0,0),
'B' => (0,0,1,0,0),
'r' => (0,0,0,1,0),
'R' => (0,0,0,1,0),
'q' => (0,0,0,0,1),
'Q' => (0,0,0,0,1),
'k' => (0,0,0,0,0),
'K' => (0,0,0,0,0)

)
)

const bits2char = Dict{NTuple{6,Bool},Char}([((j...,isuppercase(i)),i) for (i,j) in char2bits])