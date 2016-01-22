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
        statistics(runtime,_),
        getBestTurn(Field, TargetField),
        statistics(runtime,[_,NewTime]),
        aiCalculationTime(UsedTime),
        NewUsedTime is NewTime + UsedTime,
        asserta(aiCalculationTime(NewUsedTime)),retract(aiCalculationTime(UsedTime)),
        write('Zeit in MilliSekunden:'),write(NewUsedTime),nl,!.
        

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