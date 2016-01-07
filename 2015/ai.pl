getDepth(Tiefe):-   
	aggregate_all(count, board(_,[red|_]), R),
	aggregate_all(count, board(_,[green|_]), G), 
	R + G > 3,
	Tiefe is 4,!
	; 
	aggregate_all(count, board(_,[]), E),
	(                                       
		E > 12, Tiefe is 4
	;	
		E > 10, Tiefe is 4
	;
		E > 8, Tiefe is 6
	;
		Tiefe is 8
	),!.

getBestTurn(Field, TargetField) :-
	isOnlyOneTurnPossible(Field, TargetField), 
	write(Field),write(TargetField),nl,!.
	
getBestTurn(Field, TargetField) :-
	aiColor(AiColor),
	getDepth(Depth),
	saveBoardToBackup,
	resetMovesAndJumps,
	abolish(bestRating/2),
	abSearch(AiColor,[], Depth, Rating, -10000, 10000),
	getBest(Field, TargetField, Rating),
	write(Field),write(TargetField),nl,
	saveBackupToBoard.

abSearch(Color, MoveOrder,Depth,Rating,Alpha,Beta) :-
	aiColor(AiColor),
	enemy(Color, EnemyColor),
	assertz(bestRating(MoveOrder, Alpha)),
	setupBoard(MoveOrder),
	writeAllPossibleDraftsFor(Color,MoveOrder),
	(
		\+hasPossibleJumps(MoveOrder),
		\+hasPossibleMoves(MoveOrder),
		Rating = -10000
	;	
		(
			getNewMoveOrder(MoveOrder, NewMoveOrder),
			(
				(Depth =< 0, Color == AiColor ),
			    calculateRating(Rating, AiColor, MoveOrder),
			    retract(bestRating(MoveOrder,_)),
			    assertz(bestRating(MoveOrder, Rating))
			;
				bestRating(MoveOrder,Best),
				NewDepth is Depth - 1,
				NegaBeta is Best * -1,
			    NegaAlpha is Beta * -1,
			    
			    % rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
			    abSearch(EnemyColor, NewMoveOrder,NewDepth,ThisRating,NegaAlpha,NegaBeta),
			
			    % Vorzeichen vom Rating drehen
			    V is ThisRating * -1,
				(
					V >= Beta
				->	
					(
						V > Best
					->  	
						retract(bestRating(MoveOrder,_)),
						asserta(bestRating(MoveOrder,V))
					;
						true
					),
					Rating is V
				;	
					(
						V > Best
					->	
						retract(bestRating(MoveOrder,_)),
						asserta(bestRating(MoveOrder,V))
					;
						true
					)
					,fail
				)
			)
		;
			bestRating(MoveOrder,Rating)	
		)
	), !.
	
getNewMoveOrder(MoveOrder, NewMoveOrder) :-
	(
		current_predicate(possibleMove/3),
		possibleMove(MoveOrder, Field, TargetField)
	;
		current_predicate(possibleJump/4),
		possibleJump(MoveOrder, Field, _, TargetField)
	),
	atom_concat(Field,TargetField, Draft),
	append(MoveOrder,[Draft],NewMoveOrder).

getBest(Field, TargetFiled, Rating) :-
	bestRating([Draft|_], Rating),
	translateDraft(Draft, Field, TargetFiled), !.
	
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