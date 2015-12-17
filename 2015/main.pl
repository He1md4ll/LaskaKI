% link all files
%:- ['ai.pl'].
:- ['board.pl'].
%:- ['evaluate.pl'].
:- ['facts.pl'].
%:- ['gamelogic.pl'].

start :-
	currentColor(Color),
	writeAllPossibleDraftsFor(Color),
	checkIsWinner(Color),
	writeTurnFor(Color),
	applyTurn,
	resetMovesAndJumps,
	changeCurrentColor(Color),
	fail.
	



writeAllPossibleDraftsFor(Color) :-
	allSoldierDrafts(Color),
	checkZugzwang.
	
	
allSoldierDrafts(Color) :-
	feld(Field, [Color]),		% Get next figure position
	move(Field, TargetField),		% Get next move
	% IF
	(testMove(TargetField) ->
	% Then
	assertz(possibleMove(Field, TargetField))
	;
	% Else If
	\+feld(TargetField, [Color]),	% Not possible to jump over own figures
	testJump(Field, TargetField, JumpTargetField) ->
	% Then
	assertz(possibleJump(Field, TargetField, JumpTargetField))
	),
	fail.
allSoldierDrafts(_).

allGeneralDrafts(Color).
		

testMove(TargetField) :-
	feld(TargetField, []).
	
testJump(Field, TargetField, JumpTargetField) :-
	jump(Field, TargetField, JumpTargetField),
	isFieldEmpty(JumpTargetField).
	
checkZugzwang :-
	\+possibleJump(_,_,_);
	abolish(possibleMove/2).
	
	
checkIsWinner(white) :- \+possibleJump(_,[]),\+possibleMove(_,[]),write('Black wins.'),abort.
checkIsWinner(black) :- \+possibleJump(_,[]),\+possibleMove(_,[]),write('White wins.'),abort.
% checkIsWinner(_).	

changeCurrentColor(Color) :-
	retract(currentColor(Color)),
	assertz(currentColor(Color)).