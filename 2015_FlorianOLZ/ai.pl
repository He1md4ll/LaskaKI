getDepth(Depth) :-
        aiCalculationTime(AiTime),
        AiTime > 280000, 
        Depth is 6, !.
        
getDepth(Depth) :-
        aiCalculationTime(AiTime),
        AiTime > 250000, 
        Depth is 7, !.
        
getDepth(Depth) :-
        aggregate_all(count, board(_,[red|_]), R),
        aggregate_all(count, board(_,[green|_]), G), 
        R + G > 3,
        Depth is 6, !.

getDepth(Depth):-
        aggregate_all(count, board(_,[]), E),
        (                                       
                E > 14, Depth is 6
        ;       
                E > 12, Depth is 6
        ;
                E > 8, Depth is 7
        ;
                Depth is 8
        ),!.

getBestTurn(Field, TargetField) :-
        abolish(bestRating/2),
        calculateTurn(Field, TargetField, Depth, Rating),
        write(Field),write(TargetField),nl,
        %debugCounter(Count),
        %write('Additional Moves: '),write(Count),nl,
        write('Rating: '),write(Rating),nl,
        write('Depth: '),write(Depth),nl
        %retract(debugCounter(Count)),
        %assertz(debugCounter(0))
        .
        
calculateTurn(Field, TargetField, _, 'Schlagzwang') :-
        isOnlyOneTurnPossible(Field, TargetField),
        atom_concat(Field,TargetField, Draft),
        removeFromChoosenMoverOrder(Draft),!.
        
calculateTurn(Field, TargetField, Depth, Rating) :-
        aiColor(AiColor),
        getDepth(Depth),
        saveBoardToBackup,
        %getBetterStartBeta(AiColor, Depth, Beta),
        %abolish(bestRating/2),
        abSearch(AiColor,[], Depth, Rating, -10000, 10000),
        getBest(Field, TargetField, Rating, Depth),
        %writeBestRating,
        saveBackupToBoard.

getBetterStartBeta2(AiColor, Depth, Beta):-
        current_predicate(choosenMoveOrder/1),
        choosenMoveOrder(ChoosenMoveOrder),
        length(ChoosenMoveOrder, Length),
        NewDepth is Depth - Length,
        NewDepth > 0,
        abSearch(AiColor,ChoosenMoveOrder, Depth, Beta, -10000, 10000),!.
getBetterStartBeta2(_, _, Beta) :- Beta is 10000.


abSearch(Color, MoveOrder,0,Rating,_,_) :-
        setupBoard(MoveOrder),
        calculateRating(Rating, Color, MoveOrder),
        assertz(bestRating(MoveOrder, Rating)), !.

abSearch(Color, MoveOrder,Depth,Rating,Alpha,Beta) :-
        setupBoard(MoveOrder),
        writeAllPossibleDraftsForIfNeeded(Color, MoveOrder),
        enemy(Color, EnemyColor),
        assertz(bestRating(MoveOrder, Alpha)),
        checkHasMovesOrJumps(MoveOrder),
        getNewMoveOrder(MoveOrder, Draft),
        append(MoveOrder,[Draft],NewMoveOrder),
        coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta).
        
abSearch(_, MoveOrder,_,Rating,_,_) :-
        bestRating(MoveOrder,Rating).
        
deleteAlphaMoveOrderRating(_, _).       
        
checkHasMovesOrJumps(MoveOrder) :-
        hasPossibleJumps(MoveOrder),!.
        
checkHasMovesOrJumps(MoveOrder) :-
        hasPossibleMoves(MoveOrder),!.
        
checkHasMovesOrJumps(MoveOrder) :-
        saveNewBestRating(MoveOrder, -5000).    
        
coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta) :-
        bestRating(MoveOrder,Best),
        nextLayer(EnemyColor, NewMoveOrder, V, Depth, Best, Beta),!,
        V > Best,
        saveNewBestRating(MoveOrder, V),
        V >= Beta,
        Rating is V.
        
nextLayer(EnemyColor, NewMoveOrder, V, Depth,Best,Beta) :-
        NewDepth is Depth - 1,
        NegaBeta is Best * -1,
        NegaAlpha is Beta * -1,
        % rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
        abSearch(EnemyColor, NewMoveOrder,NewDepth,ThisRating,NegaAlpha,NegaBeta),
        % Vorzeichen vom Rating drehen
        V is ThisRating * -1,!. 
        
saveNewBestRating(MoveOrder, Rating) :-
        retract(bestRating(MoveOrder,_)),
        assertz(bestRating(MoveOrder,Rating)), !.
        
%getNewMoveOrder([], Draft):-
        %getFirstTurnFromLastChoosenMoveOrder(Draft).
        
getNewMoveOrder(MoveOrder, Draft) :-
        current_predicate(possibleMove/3),
        possibleMove(MoveOrder, Field, TargetField),
        atom_concat(Field,TargetField, Draft).
        %\+getFirstTurnFromLastChoosenMoveOrder(Draft).
        
getNewMoveOrder(MoveOrder, Draft) :-
        current_predicate(possibleJump/4),
        possibleJump(MoveOrder, Field, _, TargetField),
        atom_concat(Field,TargetField, Draft).
        %\+getFirstTurnFromLastChoosenMoveOrder(Draft).

getFirstTurnFromLastChoosenMoveOrder(Draft) :-
        current_predicate(choosenMoveOrder/1),
        choosenMoveOrder(OldMoveOrder),
        getFirstTurnFromLastChoosenMoveOrder(Draft,OldMoveOrder).
getFirstTurnFromLastChoosenMoveOrder(Draft,[Draft|_]).


getBest(Field, TargetField, Rating, Depth) :-
        NegaRating is Rating * -1,
        findall(Draft, bestRating([Draft|[]], NegaRating),List),
        %length(List, Length),
        %Length2 is Length - 1,
        %getRandomTurn(Length2, Number, Rating),
        nth0(0, List, Draft),
        checkIfDraftIsRight(Rating, Depth -1, [Draft], ResultMoveOrder),
        %write(ResultMoveOrder),nl,
        abolish(choosenMoveOrder/1),
        asserta(choosenMoveOrder(ResultMoveOrder)),
        removeFromChoosenMoverOrder(Draft),
        translateDraft(Draft, Field, TargetField),
        !.
getRandomTurn(X, X,_).
getRandomTurn(_, 0,5000).  %Bei Sieg oder Niederlage kein Random
getRandomTurn(_, 0,-5000). %Sondern immer den ersten Zug.
getRandomTurn(Length2, Number,_):-
        random_between(0, Length2, Number).
getRandomTurn(Length2, Number,_) :-
        getRandomTurn(0, Length2, Number).

checkIfDraftIsRight(5000,_,_,[]).  %Bei Sieg oder Niederlage keine ueberpruefung
checkIfDraftIsRight(-5000,_,_,[]).
checkIfDraftIsRight(Raiting, Depth, MoveOrder, ResultMoveOrder)  :-
        NextDraft = [_],
        append(MoveOrder,NextDraft,NewMoveOrder),
        bestRating(NewMoveOrder,Raiting),
        NegaRaiting is Raiting * -1,
        NewDepth is Depth -1,
        checkIfDraftIsRight(NegaRaiting,NewDepth, NewMoveOrder, ResultMoveOrder).
checkIfDraftIsRight(_, 0, X, X).

        
setupBoard(MoveOrder) :- 
        saveBackupToBoard,
        applyMoves(MoveOrder),!.

applyMoves([]).
applyMoves([Head|Tail]) :-
        translateDraft(Head, Field, TargetField),
        applyTurn(Field, TargetField),
        applyMoves(Tail).               
        
isOnlyOneTurnPossible(Field, TargetField) :-
        current_predicate(possibleMove/3),
        aggregate_all(count, possibleMove([],_,_), 1),
        possibleMove([],Field,TargetField), !.
        
isOnlyOneTurnPossible(Field, TargetField) :-
        current_predicate(possibleJump/4),
        aggregate_all(count, possibleJump([],_,_,_), 1),
        possibleJump([],Field,_,TargetField), !.        
        
saveBoardToBackup :- 
        retract(backupBoard(_,_)),
        fail.
                                        
saveBoardToBackup :- 
        board(Field,Figures),
        asserta(backupBoard(Field,Figures)),
        fail.

saveBoardToBackup.      

saveBackupToBoard :- 
        retract(board(_,_)),
        fail.
                                        
saveBackupToBoard :- 
        backupBoard(Field,Figures),
        asserta(board(Field,Figures)),
        fail.

saveBackupToBoard.

writeBestRating :-
        bestRating(MoveOrder, Rating),
        checkMoveOrder(MoveOrder),
        write('MoveOrder: '), write(MoveOrder),write(' Rating: '),write(Rating),nl,fail.
writeBestRating.
checkMoveOrder(_).

