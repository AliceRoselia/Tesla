module Tesla

include("Globals.jl") #Global immutable states such as magic BB and such.
include("Board.jl")

export Game, set_board!, set_time!, play!

end # module Tesla
