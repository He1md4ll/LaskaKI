% link all files
:- ['ai.pl'].
:- ['board.pl'].
:- ['evaluate.pl'].
:- ['facts.pl'].
:- ['draftCalculator.pl'].
:- ['movement.pl'].

% Turn counter
currentTurn(1).
currentTurn(X) :- currentTurn(Y), X is Y+1.

start(AiColor) :-
        start(AiColor, 35, 100, 10, 2, 0, 0, 50).

start(AiColor, SV, GV, JSV, JJSV, MV, JV, DV) :-
                writeAiValues(SV, GV, JSV, JJSV, MV, JV, DV),
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

% write evaluation paramters as facts for global access
writeAiValues(SV, GV, JSV, JJSV, MV, JV, DV) :-
        asserta(soldierValue(SV)),
        asserta(generalValue(GV)),
        asserta(jailedSoldierValue(JSV)),
        asserta(jailedJailedSoldierValue(JJSV)),
        asserta(moveValue(MV)),
        asserta(jumpValue(JV)),
        asserta(distanceValue(DV)). 
        
checkIsWinner(white) :- \+hasPossibleJumps([]),\+hasPossibleMoves([]),write('Black wins.'),sleep(10),halt.
checkIsWinner(black) :- \+hasPossibleJumps([]),\+hasPossibleMoves([]),write('White wins.'),sleep(10),halt.

% Determine AI turn or wait for player input
getTurnFor(Color, Field, TargetField) :-
                aiColor(AiColor),
        write(Color), write(' am Zug:'),
        (Color \= AiColor ->
        playerDraft(Field, TargetField)
        ;
        aiDraft(Field, TargetField)
        ).      
        
% Check if determined turn is possible to avoid impossible turn input      
checkPlayerDraft(Field,TargetField) :-
        hasPossibleMoves([]),
        possibleMove([],Field,TargetField),!
        ;
        hasPossibleJumps([]),
        possibleJump([],Field,_,TargetField),!
        ;
        write('Falsche Eingabe!'),nl,fail.       
 
% Determine best turn using AI (absearch) and increase calculation time counter        
aiDraft(Field, TargetField) :-
        statistics(runtime,_),
        getBestTurn(Field, TargetField),
        statistics(runtime,[_,NewTime]),
        aiCalculationTime(UsedTime),
        NewUsedTime is NewTime + UsedTime,
        asserta(aiCalculationTime(NewUsedTime)),retract(aiCalculationTime(UsedTime)),
        write('Zeit in MilliSekunden:'),write(NewUsedTime),nl,!.
        
% Read turn from player input and check if turn possible
playerDraft(Field, TargetField) :-    
    read(Draft),
    translateDraft(Draft, Field, TargetField),
    checkPlayerDraft(Field, TargetField),
    removeFromChoosenMoverOrder(Draft),!.
    
playerDraft(Field, TargetField) :- 
        playerDraft(Field, TargetField).       

% Swap color        
changeCurrentColor(Color) :-
        retract(currentColor(Color)),
        assertz(currentColor(Color)).

% Substring Draft (a4b5) to Field (a4) and TarbetField (b5)        
translateDraft(Draft, Field, TargetField) :-
        sub_atom(Draft,0,2,_,Field),
        sub_atom(Draft,2,2,_,TargetField).
        
% Remove Draft from predicted MoveOrder to sort absearch of AI for next turn
% (start with probably best value in absearch to get fast cutoffs)
removeFromChoosenMoverOrder(Draft):-
    choosenMoveOrder(OldMoveOrder),
    removeFromChoosenMoverOrder(Draft,OldMoveOrder).

removeFromChoosenMoverOrder(_).
    
removeFromChoosenMoverOrder(Draft,[Draft|NewMoveOrder]):-
    retract(choosenMoveOrder(_)),
    asserta(choosenMoveOrder(NewMoveOrder)),!.
    
removeFromChoosenMoverOrder(_,_):-
    retract(choosenMoveOrder(_)).
