abstract type AbstractBoard end #An abstract board type.
abstract type AbstractMove end #An abstract move type.
mutable struct Board<:AbstractBoard
    ourPiece::UInt64
    enemyPiece::UInt64
    pawn::UInt64
    knight::UInt64
    bishop::UInt64
    rook::UInt64
    queen::UInt64
    kings::UInt16
end




function Board(board::String, castling_rights = (true,true,true,true))
    if castling_rights[1]
        @assert board[61] == 'K' && board[57] == 'R'
    end
    if castling_rights[2]
        @assert board[61] == 'K' && board[64] == 'R'
    end
    if castling_rights[3]
        @assert board[5] == 'k' && board[1] == 'r'
    end
    if castling_rights[4]
        @assert board[5] == 'k' && board[8] == 'r'
    end
    


    ourPiece = UInt64(0)
    enemyPiece = UInt64(0)
    pawn = UInt64(0)
    knight = UInt64(0)
    bishop = UInt64(0)
    rook = UInt64(0)
    queen = UInt64(0)
    kings = UInt16(0)

    kings |= (castling_rights[1]<<15) | (castling_rights[2]<<14) | (castling_rights[3]<<13) | (castling_rights[4]<<12)
    for i in 1:64
        if board[i] == '_'
            continue
        end
        if board[i] == 'k'
            kings |= (i-1)
        end
        if board[i] == 'K'
            kings |= (i-1)<<6
        end
        
        if islowercase(board[i])
            enemyPiece |= (UInt64(1) << (i-1))
        end
        if isuppercase(board[i])
            ourPiece |= (UInt64(1)<<(i-1))
        end

        p,n,b,r,q = char2bits[board[i]]
        pawn |= (UInt64(p)<<(i-1))
        knight |= (UInt64(n)<<(i-1))
        bishop |= (UInt64(b)<<(i-1))
        rook |= (UInt64(r)<<(i-1))
        queen |= (UInt64(q)<<(i-1))
    end

    return Board(ourPiece,enemyPiece,pawn,knight,bishop,rook,queen,kings)
end

function get_our_king_pos(board::Board, onebasedindexing = true)
    return (board.kings>>6)&63 + onebasedindexing
end

function get_enemy_king_pos(board::Board,onebasedindexing = true)
    return (board.kings)&63 + onebasedindexing
end

function print_board(board::Board)

    for i in 1:64
        
        character = bits2char[(((board.pawn>>(i-1))&1) == 1,((board.knight>>(i-1))&1) == 1,((board.bishop>>(i-1))&1) == 1,((board.rook>>(i-1))&1) == 1,((board.queen>>(i-1))&1) == 1,((board.ourPiece>>(i-1))&1) == 1)]
        if i == get_our_king_pos(board)
            @assert character == 'K' "Invalid board representation."
        elseif i == get_enemy_king_pos(board)
            @assert character == 'k' "Invalid board representation."
        elseif character == 'k'
            character = '_'
        end

        print(character)
        if (i%8 == 0)
            println()
        end
    end
end

struct pieceMove<:AbstractMove 
    data::UInt32
end

#A piece move full of information.
#Used for debugging/etc purposes.
#A 16-bits Partial move will probably be used instead of this in the real engine.

Move(starting_square::Integer, ending_square::Integer, board::Board) = Move(UInt32(starting_square),UInt32(ending_square),board)

function pieceon(square,board::Board, onebasedindexing = true)
    square -= onebasedindexing
    
    if (square == get_our_king_pos(board,false)) | (square == get_enemy_king_pos(board,false)) 
        return KING
    end
    
    return (((board.pawn>>square)&1) * PAWN) | (((board.knight>>square)&1) * KNIGHT) | (((board.bishop>>square)&1) * BISHOP) | (((board.rook>>square)&1) * ROOK) | (((board.queen>>square)&1) * QUEEN)
end

function coloron(square, board::Board, onebasedindexing = true)
    square -= onebasedindexing
    return (board.enemyPiece>>square)&1
end

function pieceMove(starting_square::UInt32, ending_square::UInt32, board::Board, onebasedindexing = true)
    starting_square -= onebasedindexing
    ending_square -= onebasedindexing

    return pieceMove((starting_square<<26 )| (ending_square<<20) | (pieceon(starting_square,board)<<14) | (pieceon(ending_square,board))<<11)
    #Bits 32 to 27 is starting square.
    #Bits 26 to 21 is ending square.
    #Bits 20 to 18 is promoted piece type.
    #Bits 17 to 15 is the moving piece type.
    #Bits 14 to 12 is attacked type
    #Bits 13 to 10 one hots encode the four main castle.
    #Bits 9 for en passant marking.
    #The rest are reserved for future purposes.
end

function promote_Move(starting_square::UInt32, ending_square::UInt32, board::Board,promotedPiece = QUEEN, onebasedindexing = true)
    return pieceMove(pieceMove(starting_square,ending_square,board,onebasedindexing).data | (promotedPiece<<17))
end


function is_legal(move::chessMove, board::Board)
    #An expensive check whether or not the move is legal.
    #working in progress.
end

function is_not_suicide(move::chessMove, board::Board)
    #Assumes the move is otherwise legal. Doesn't put yourself in check.
    # Hmm
end

