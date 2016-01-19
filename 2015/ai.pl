getDepth(Depth):-   
	aggregate_all(count, board(_,[red|_]), R),
	aggregate_all(count, board(_,[green|_]), G), 
	R + G > 3,
	Depth is 6,!
	; 
	aggregate_all(count, board(_,[]), E),
	(                                       
		E > 12, Depth is 5
	;	
		E > 10, Depth is 6
	;
		E > 8, Depth is 7
	;
		Depth is 8
	),!.

getBestTurn(Field, TargetField) :-
	abolish(bestRating/2),
	calculateTurn(Field, TargetField),
	write(Field),write(TargetField),nl,
	debugCounter(Count),
	write('Additional Moves: '),write(Count),
	retract(debugCounter(Count)),
	assertz(debugCounter(0)).
	
calculateTurn(Field, TargetField) :-
	isOnlyOneTurnPossible(Field, TargetField),!.
	
calculateTurn(Field, TargetField) :-
	aiColor(AiColor),
	getDepth(Depth),
	saveBoardToBackup,
	abSearch(AiColor,[], Depth, Rating, -10000, 10000),
	getBest(Field, TargetField, Rating),
	%writeBestRating,
	saveBackupToBoard.	

abSearch(Color, MoveOrder,-1,Rating,_,_) :-
	debugCounter(Count),
	retract(debugCounter(Count)),
	NewCount is Count + 1,
	assertz(debugCounter(NewCount)), 
	setupBoard(MoveOrder),
	calculateRating(Rating, Color, MoveOrder),
	asserta(bestRating(MoveOrder, Rating)), !.

abSearch(Color, MoveOrder,0,Rating,_,_) :-
	setupBoard(MoveOrder),
	writeAllPossibleDraftsFor(Color, MoveOrder),
	not(hasPossibleJumps(MoveOrder)),
	calculateRating(Rating, Color, MoveOrder),
	asserta(bestRating(MoveOrder, Rating)), !.

abSearch(Color, MoveOrder,Depth,Rating,Alpha,Beta) :-
	setupBoard(MoveOrder),
	writeAllPossibleDraftsForIfNeeded(Color, MoveOrder),
	enemy(Color, EnemyColor),
	assertz(bestRating(MoveOrder, Alpha)),
	checkHasMovesOrJumps(MoveOrder),
	getNewMoveOrder(MoveOrder, Draft),
	append(MoveOrder,[Draft],NewMoveOrder),
	coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta).
	
abSearch(_, MoveOrder,_,Rating,Alpha,_) :-
	bestRating(MoveOrder,Rating),
	deleteAlphaMoveOrderRating(MoveOrder, Alpha).
	
deleteAlphaMoveOrderRating(MoveOrder, Alpha) :-
	retract(bestRating(MoveOrder,Alpha)).
	
deleteAlphaMoveOrderRating(_, _).	
	
checkHasMovesOrJumps(MoveOrder) :-
	hasPossibleJumps(MoveOrder),!.
	
checkHasMovesOrJumps(MoveOrder) :-
	hasPossibleMoves(MoveOrder),!.
	
checkHasMovesOrJumps(MoveOrder) :-
	saveNewBestRating(MoveOrder, -5000).	
	
coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta) :-
	bestRating(MoveOrder,Best),
	nextLayer(EnemyColor, NewMoveOrder, V, Depth,Best,Beta),!,
	V > Best,
	saveNewBestRating(MoveOrder, V),
	V >= Beta,
	Rating is V.	
	
nextLayer(EnemyColor, NewMoveOrder, V, Depth,Best,Beta) :-
	NewDepth is Depth - 1,
	NegaBeta is Best * -1,
	NegaAlpha is Beta * -1,
	% rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
	abSearch(EnemyColor, NewMoveOrder,NewDepth,ThisRating,NegaAlpha,NegaBeta),
	% Vorzeichen vom Rating drehen
	V is ThisRating * -1,!.	
	
saveNewBestRating(MoveOrder, Rating) :-
	retract(bestRating(MoveOrder,_)),
	assertz(bestRating(MoveOrder,Rating)), !.
	
getNewMoveOrder(MoveOrder, Draft) :-
	current_predicate(possibleMove/3),
	possibleMove(MoveOrder, Field, TargetField),
	atom_concat(Field,TargetField, Draft).
	
getNewMoveOrder(MoveOrder, Draft) :-
	current_predicate(possibleJump/4),
	possibleJump(MoveOrder, Field, _, TargetField),
	atom_concat(Field,TargetField, Draft).

getBest(Field, TargetField, Rating) :-
	NegaRating is Rating * -1,
	bestRating([Draft|[]], NegaRating),
	translateDraft(Draft, Field, TargetField),
	write('Rating: '),write(NegaRating),nl,!.
	
setupBoard(MoveOrder) :- 
	saveBackupToBoard,
	applyMoves(MoveOrder),!.

applyMoves([]).
applyMoves([Head|Tail]) :-
	translateDraft(Head, Field, TargetField),
	applyTurn(Field, TargetField),
	applyMoves(Tail).		
	
isOnlyOneTurnPossible(Field, TargetField) :-
	current_predicate(possibleMove/3),
	aggregate_all(count, possibleMove([],_,_), 1),
	possibleMove([],Field,TargetField), !.
	
isOnlyOneTurnPossible(Field, TargetField) :-
	current_predicate(possibleJump/4),
	aggregate_all(count, possibleJump([],_,_,_), 1),
	possibleJump([],Field,_,TargetField), !.	
	
saveBoardToBackup :- 
	retract(backupBoard(_,_)),
	fail.
					
saveBoardToBackup :- 
	board(Field,Figures),
	asserta(backupBoard(Field,Figures)),
	fail.

saveBoardToBackup.	

saveBackupToBoard :- 
	retract(board(_,_)),
	fail.
					
saveBackupToBoard :- 
	backupBoard(Field,Figures),
	asserta(board(Field,Figures)),
	fail.

saveBackupToBoard.

writeBestRating :-
	bestRating(MoveOrder, Rating),
	checkMoveOrder(MoveOrder),
	write('MoveOrder: '), write(MoveOrder),write(' Rating: '),write(Rating),nl,fail.
writeBestRating.
checkMoveOrder([e8d9 | _]).

