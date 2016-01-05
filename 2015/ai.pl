getBestTurn(AiColor, Field, TargetField) :-
	isOnlyOneTurnPossible(Field, TargetField).
	
isOnlyOneTurnPossible(Field, TargetField) :-
	aggregate_all(count, possibleMove(_,_), 1),
	possibleMove(Field,TargetField), !.
	
isOnlyOneTurnPossible(Field, TargetField) :-
	aggregate_all(count, possibleJump(_,_,_), 1),
	possibleJump(Field,_,TargetField).	