displayPossibleDrafts :-
        (current_predicate(possibleJump/4), possibleJump([],X,_,Y)
        ;
        current_predicate(possibleMove/3), possibleMove([],X,Y)),
        write(X),write(Y),nl, fail.
displayPossibleDrafts.
        
applyTurn(Field, TargetField) :-
		board(Field, [Color| _]),
        (
	        isJump(Color, Field, OverField, TargetField),
	        board(OverField,[Oppo|Jailed]),
	        opponent(Color,Oppo),
	        doJump(Field,OverField,Oppo,Jailed,TargetField)
        ;
	        isMove(Color, Field,TargetField),
	        doMove(Field,TargetField)
        ), !.
        
isJump(Color, Field, OverField, TargetField) :-
        current_predicate(possibleJump/4), 
        jump(Field, OverField, TargetField, Color), !.
        
isMove(Color, Field, TargetField) :-
        current_predicate(possibleMove/3),
        move(Field, TargetField, Color), !.
        
doJump(X,M,O,J,Y) :-
        retract(board(X,[Kopf|S])),
        assertz(board(X,[])),
        retract(board(M,_)),
        assertz(board(M,J)),
        retract(board(Y,_)),
        promote(Y,Kopf,Offz),
        degrade(O,G),
        append([Offz|S],[G],New),
        assertz(board(Y,New)).
doMove(X,Y) :-
        retract(board(X,[Kopf|S])),
        assertz(board(X,[])),
        retract(board(Y,_)),
        promote(Y,Kopf,Offz),
        assertz(board(Y,[Offz|S])).

resetMovesAndJumps :-
        abolish(possibleJump/4),
        abolish(possibleMove/3).       
        
hasPossibleJumps(MoveOrder):-
        current_predicate(possibleJump/4),
        possibleJump(MoveOrder,_,_,_).

hasPossibleMoves(MoveOrder):-
        current_predicate(possibleMove/3),
        possibleMove(MoveOrder,_,_).