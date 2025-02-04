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

function get_our_king_pos(board::Board)
    return (board.kings>>6)&63 + 1
end

function get_enemy_king_pos(board::Board)
    return (board.kings)&63 + 1
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
