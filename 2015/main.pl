% link all files
%:- ['ai.pl'].
:- ['board.pl'].
%:- ['evaluate.pl'].
:- ['facts.pl'].
%:- ['gamelogic.pl'].
:- ['draftCalculator.pl'].
:- ['movement.pl'].

currentTurn(1).
currentTurn(X) :- currentTurn(Y), X is Y+1.

start :-
        currentTurn(N),write('-> '),write(N),nl,
        currentColor(Color),
        schreibeBrett,
        writeAllPossibleDraftsFor(Color),
        \+checkIsWinner(Color),
        displayPossibleDrafts,
        getTurnFor(Color, Field, TargetField),
        applyTurnFor(Color, Field, TargetField),
        resetMovesAndJumps,
        changeCurrentColor(Color),
        fail.
        
checkIsWinner(white) :- \+hasPossibleJumps,\+hasPossibleMoves,write('Black wins.'),abort.
checkIsWinner(black) :- \+hasPossibleJumps,\+hasPossibleMoves,write('White wins.'),abort.
% checkIsWinner(_).
        
changeCurrentColor(Color) :-
        retract(currentColor(Color)),
        assertz(currentColor(Color)).