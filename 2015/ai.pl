getDepth(6).

getBestTurn(Field, TargetField) :-
	isOnlyOneTurnPossible(Field, TargetField), !.
	
getBestTurn(Field, TargetField) :-
	getDepth(Depth),
	abSearch([], Depth, Rating, -10000, 10000),
	getBest(Field, TargetFiled, Rating),
	saveBackupToBoard.

abSearch(Color, MoveOrder,Depth,Rating,Alpha,Beta) :-
	aiColor(AiColor),
	enemy(Color, EnemyColor),
	setupBoard(MoveOrder),
	resetMovesAndJumps,
	writeAllPossibleDraftsFor(Color),
	(
	\+getNewMoveOrder(MoveOrder, NewMoveOrder, Field, TargetField)
	-> 
	Rating = -10000 % Keine Züge --> Spieler haette verloren --> Schlechte Bewertung
	;
	((Depth =< 0, CurrentColor \== AiColor ),
    getBoardValue(Rating)
    ;
	NewDepth is Depth - 1,
	NegaBeta is Alpha * -1,
    NegaAlpha is Beta * -1,
    
    applyTurn(Field, TargetField),
    
    % rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
    abSearch(EnemyColor, NewMoveOrder,NewDepth,ThisRating,NegaAlpha,NegaBeta),

    % Vorzeichen vom Rating drehen
    NegaThisRating is ThisRating * -1,

    % Alpha-Beta-Auswertung
    (
    NegaThisRating >= Beta,
    Rating = NegaThisRating,
    % Hier müssen schlaue sachen gemacht werden
    ;
    NegaThisRating =< Alpha
    % Hier muss tiefer in die den Suchbaum vorgedrungen werden
	)).
	
getNewMoveOrder(MoveOrder, NewMoveOrder, Field, TargetField) :-
	(hasPossibleMoves,possibleMove(Field, TargetField)
	;
	hasPossibleJumps,possibleJump(Field, TargetField)),
	atom_concat(Field,TargetField, Draft),
	append(MoveOrder,[Draft],NewMoveOrder).

getBest(Field, TargetFiled, Rating).
	
setupBoard(MoveOrder) :- 
	saveBackupToBoard,
	applyMoves(MoveOrder),!.

applyMoves([]).
applyMoves([Head|Tail]) :-
	translateDraft(Head, Field, TargetField),
	applyTurn(Field, TargetField),
	applyMoves(Tail).		
	
isOnlyOneTurnPossible(Field, TargetField) :-
	current_predicate(possibleMove/2),
	aggregate_all(count, possibleMove(_,_), 1),
	possibleMove(Field,TargetField), !.
	
isOnlyOneTurnPossible(Field, TargetField) :-
	current_predicate(possibleJump/3),
	aggregate_all(count, possibleJump(_,_,_), 1),
	possibleJump(Field,_,TargetField).	
	
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