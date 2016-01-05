displayPossibleDrafts :-
        (current_predicate(possibleJump/3), possibleJump(X,_,Y)
        ;
        current_predicate(possibleMove/2), possibleMove(X,Y)),
        write(X),write(Y),nl, fail.
displayPossibleDrafts.
        
applyTurn(Field, TargetField) :-
		board(Field, [Color, _]),
        (isJump(Field, TargetField) ->
        possibleJump(Field,M,TargetField),
        board(M,[Oppo|Jailed]),
        opponent(Color,Oppo),
        doJump(Field,M,Oppo,Jailed,TargetField),!
        ;
        isMove(Field,TargetField),
        possibleMove(Field,TargetField),
        doMove(Field,TargetField) ,!
        ).
        
isJump(Field, TargetField) :-
        current_predicate(possibleJump/3), 
        possibleJump(Field, _, TargetField), !.
        
isMove(Field, TargetField) :-
        current_predicate(possibleMove/2),
        possibleMove(Field, TargetField), !.
        
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
        abolish(possibleJump/3),
        abolish(possibleMove/2).
        
hasPossibleJumps():-
        current_predicate(possibleJump/3),
        possibleJump(_,_,_).

hasPossibleMoves():-
        current_predicate(possibleMove/2),
        possibleMove(_,_).