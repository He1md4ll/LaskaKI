% link all files
:- ['ai.pl'].
:- ['board.pl'].
:- ['evaluate.pl'].
:- ['facts.pl'].
%:- ['gamelogic.pl'].
:- ['draftCalculator.pl'].
:- ['movement.pl'].

currentTurn(1).
currentTurn(X) :- currentTurn(Y), X is Y+1.

start(AiColor) :-
		asserta(aiColor(AiColor)),
        currentTurn(N),write('-> '),write(N),nl,
        currentColor(Color),
        schreibeBrett,
        writeAllPossibleDraftsFor(Color,[]),
        \+checkIsWinner(Color),
        displayPossibleDrafts,
        getTurnFor(Color, Field, TargetField),
        applyTurn(Field, TargetField),
        resetMovesAndJumps,
        changeCurrentColor(Color),
        fail.
        
checkIsWinner(white) :- \+hasPossibleJumps([]),\+hasPossibleMoves([]),write('Black wins.'),abort.
checkIsWinner(black) :- \+hasPossibleJumps([]),\+hasPossibleMoves([]),write('White wins.'),abort.

getTurnFor(Color, Field, TargetField) :-
		aiColor(AiColor),
        write(Color), write(' am Zug:'),
        (Color \= AiColor ->
        playerDraft(Field, TargetField)
        ;
        aiDraft(Field, TargetField)
        ).
        
checkPlayerDraft(Field,TargetField) :-
	hasPossibleMoves([]),
	possibleMove([],Field,TargetField),!
	;
	hasPossibleJumps([]),
	possibleJump([],Field,_,TargetField),!
	;
	write('Falsche Eingabe!'),nl,fail.       
        
aiDraft(Field, TargetField) :-
	getBestTurn(Field, TargetField).

playerDraft(Field, TargetField) :-    
    read(Draft),
    translateDraft(Draft, Field, TargetField),
    checkPlayerDraft(Field, TargetField),!.
    
playerDraft(Field, TargetField) :- 
	playerDraft(Field, TargetField).       
        
changeCurrentColor(Color) :-
        retract(currentColor(Color)),
        assertz(currentColor(Color)).
        
translateDraft(Draft, Field, TargetField) :-
		sub_atom(Draft,0,2,_,Field),
        sub_atom(Draft,2,2,_,TargetField).