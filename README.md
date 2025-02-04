# Tesla
 An experimental chess engine

Plan: This engine is not expected to be very strong. Its purpose is to find something original and vastly different from A/B and MCTS engines out there.

First step, we have the desired depth D.

While not satisfied:
	search the tree.
end while

We will use the negamax system so that each node is always maximizing its value.

To search a tree:
initial evaluation of each child node is set using the policy value.
The desired depth of the child node is set to the maximum of d-1. The depth of these nodes are theoretically 0, but might be set to -1, -2, or other values for error calculation purpose.
For each node, realize that the error of evaluation is probably within the range of [eval-missingdepth \* errorconstant, eval+missingdepth \* errorconstant] (Maybe dynamic error constant or something better? Need to tune).
Realize that the cost of searching deeper by 1 is dependent on the effective branching factor (EBF) with the formula (EBF-1)*(EBF)^(olddepth). The EBF has to be empirically derived.
For the current best child and the root node, you promote in an attempt to disprove its status. For other nodes, you search in an attempt to promote its status to the best node. This requires a Cumulative mass function, which itself must be tuned. The nodes must be compared to the current best.
So, in promoting a node, one needs to rank by the benefit/cost ratio, the probability of promotion to the cost of increasing depth by 1. For each node whose depth has been promoted from 0, evaluate the node using static evaluation. Repeat the process. However, for the sake of efficiency, we will not immediately promote depth-0 nodes until we can evaluate depth-0 nodes in batch, so we will promote other nodes first until depth-0 nodes are the only nodes we can promote or depth-0 nodes fill up the (batch size) most promising candidates first. Also, since the GPU is busy evaluating, we will use this time to do bookkeeping and promote non-leaf nodes to fetch the next batch of leaf nodes to evaluate.

End

To calculate satisfaction:
	Take the benefit/cost ratio. Once the benefit/cost ratio drops below the point it is worthy of time, stop the search. The exact formula needs to be tuned. 

Static evaluation: Efficiently Updatable transformer neural network.

Move represenation: 12 bits move, 3 bits moved type, 3 bits target type.
Board representation: our piece, enemy piece, pawn, knight, bishop, rook, queen, king position.
Transposition table: 64-bits key, 32-bits eval, 18-bits bestmove,  1 bit principal variation tag. 8 bits depth. 5 bits age. Total 128 bits. 4 entries in a single cache line.

Handling key collision: if the transposition table gets a PV node, must look down the tree to see if the key doesn’t collide. Key collision should be extremely rare nonetheless.

Handling threefold repetition and 50-moves rule: every update, you propagate up the update anyway. Use that to check for threefold repetition and 50-moves and replace the value with a draw if either happens.

Handling race condition: It is sufficient to use 1-thread search since the bottleneck is in the evaluation. Scale up to larger neural network if you have more cores. Not even GPUs have enough core to keep up with search anyway.


History: Cache compute KV of the PV and other relevant nodes. Replace the KV least attended to. 