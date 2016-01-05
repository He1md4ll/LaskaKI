% link all files
:- ['ai.pl'].
:- ['board.pl'].
%:- ['evaluate.pl'].
:- ['facts.pl'].
%:- ['gamelogic.pl'].
:- ['draftCalculator.pl'].
:- ['movement.pl'].

currentTurn(1).
currentTurn(X) :- currentTurn(Y), X is Y+1.

start(AiColor) :-
        currentTurn(N),write('-> '),write(N),nl,
        currentColor(Color),
        schreibeBrett,
        writeAllPossibleDraftsFor(Color),
        \+checkIsWinner(Color),
        displayPossibleDrafts,
        getTurnFor(Color, AiColor, Field, TargetField),
        applyTurnFor(Color, Field, TargetField),
        resetMovesAndJumps,
        changeCurrentColor(Color),
        fail.
        
checkIsWinner(white) :- \+hasPossibleJumps,\+hasPossibleMoves,write('Black wins.'),abort.
checkIsWinner(black) :- \+hasPossibleJumps,\+hasPossibleMoves,write('White wins.'),abort.

getTurnFor(Color, AiColor, Field, TargetField) :-
        write(Color), write(' am Zug:'),
        (Color \= AiColor ->
        playerDraft(Field, TargetField)
        ;
        aiDraft(AiColor, Field, TargetField)
        ).
        
aiDraft(AiColor, Field, TargetField) :-
	getBestTurn(AiColor, Field, TargetField).

playerDraft(Field, TargetField) :-       
        read(Draft),
        sub_atom(Draft,0,2,_,Field),
        sub_atom(Draft,2,2,_,TargetField).
        
changeCurrentColor(Color) :-
        retract(currentColor(Color)),
        assertz(currentColor(Color)).