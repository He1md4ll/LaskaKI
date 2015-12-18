% link all files
%:- ['ai.pl'].
:- ['board.pl'].
%:- ['evaluate.pl'].
:- ['facts.pl'].
%:- ['gamelogic.pl'].
:- ['draftCalculator.pl'].

start :-
	currentColor(Color),
	writeAllPossibleDraftsFor(Color),
	\+checkIsWinner(Color),
	displayPossibleDrafts,
	getTurnFor(Color, Field, TargetField),
	applyTurn(Field, TargetField),
	resetMovesAndJumps,
	changeCurrentColor(Color)
	%fail
	,!.
	
checkIsWinner(white) :- \+current_predicate(possibleJump/3),\+current_predicate(possibleMove/2),write('Black wins.'),abort.
checkIsWinner(black) :- \+current_predicate(possibleJump/3),\+current_predicate(possibleMove/2),write('White wins.'),abort.
% checkIsWinner(_).

displayPossibleDrafts :-
	(current_predicate(possibleJump/3), possibleJump(X,_,Y)
	;
	current_predicate(possibleMove/2), possibleMove(X,Y)),
	write(X),write(Y),nl, fail.
displayPossibleDrafts.

getTurnFor(Color, Field, TargetField) :-
	write(Color), write(' am Zug:'),
	read(Draft),
	sub_atom(Draft,0,2,_,Field),
	sub_atom(Draft,2,2,_,TargetField).
	
applyTurnFor(Color, Field, TargetField) :-
	(isJump ->
	possibleJump(Field,M,TargetField),
    brett(M,[Oppo|Jailed]),
    opponent(Color,Oppo),
    doJump(Field,M,Oppo,Jailed,TargetField)
    ;
    isMove(Field,TargetField),
    possibleMove(Field,TargetField),
    doMove(Field,TargetField)
    ).
	
isJump(Field, TargetField) :-
	current_predicate(possibleJump/3), 
	possibleJump(Field, _, TargetField), !.
	
isMove(Field, TargetField) :-
	current_predicate(possibleMove/2),
	possibleMove(Field, TargetField), !.
	
doJump(X,M,O,J,Y) :-
        retract(brett(X,[Kopf|S])),
        assertz(brett(X,[])),
        retract(brett(M,_)),
        assertz(brett(M,J)),
        retract(brett(Y,_)),
        promote(Y,Kopf,Offz),
        degrade(O,G),
        append([Offz|S],[G],New),
        assertz(brett(Y,New)).
doMove(X,Y) :-
        retract(brett(X,[Kopf|S])),
        assertz(brett(X,[])),
        retract(brett(Y,_)),
        promote(Y,Kopf,Offz),
        assertz(brett(Y,[Offz|S])).	

resetMovesAndJumps :-
	abolish(possibleJump/3),
	abolish(possibleMove/2).

changeCurrentColor(Color) :-
	retract(currentColor(Color)),
	assertz(currentColor(Color)).