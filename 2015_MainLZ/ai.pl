% dynmaic determination of search depth for absearch
% if there are only 20 secounds left depth is 5
getDepth(Depth) :-
        aiCalculationTime(AiTime),
        AiTime > 280000, 
        Depth is 5, !.
% if there are only 50 secounds left depth is 6        
getDepth(Depth) :-
        aiCalculationTime(AiTime),
        AiTime > 250000, 
        Depth is 6, !.
% if there are more than 3 generals on the board depth is 6        
getDepth(Depth) :-
        aggregate_all(count, board(_,[red|_]), R),
        aggregate_all(count, board(_,[green|_]), G), 
        R + G > 3,
        Depth is 6, !.
% determine depth depending on empty fields on board
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

% discard old best ratings, call absearch to determine best turn and write results
getBestTurn(Field, TargetField) :-
        abolish(bestRating/2),
        calculateTurn(Field, TargetField, Depth, Rating),
        write(Field),write(TargetField),nl,
        write('Rating: '),write(Rating),nl,
        write('Depth: '),write(Depth),nl.

% check if there is only one possilbe turn to potentially skip absearch       
calculateTurn(Field, TargetField, 'Schlagzwang', 'Schlagzwang') :-
        isOnlyOneTurnPossible(Field, TargetField),
        atom_concat(Field,TargetField, Draft),
        removeFromChoosenMoverOrder(Draft),!.

% get search depth, backup current board, get best turn using absearch and load old board from backup        
calculateTurn(Field, TargetField, Depth, Rating) :-
        aiColor(AiColor),
        getDepth(Depth),
        saveBoardToBackup,
        abSearch(AiColor,[], Depth, Rating, -10000, 10000),
        getBest(Field, TargetField, Rating, Depth),
        saveBackupToBoard.

% reached depth 0 --> evaluate board and save rating as fact for this MoveOrder
abSearch(Color, MoveOrder,0,Rating,_,_) :-
        setupBoard(MoveOrder),
        calculateRating(Rating, Color, MoveOrder),
        assertz(bestRating(MoveOrder, Rating)), !.

% get next move or jump and continue absearch
abSearch(Color, MoveOrder,Depth,Rating,Alpha,Beta) :-
        setupBoard(MoveOrder),
        writeAllPossibleDraftsForIfNeeded(Color, MoveOrder),
        enemy(Color, EnemyColor),
        assertz(bestRating(MoveOrder, Alpha)),
        checkHasMovesOrJumps(MoveOrder),
        getNewMoveOrder(MoveOrder, Draft),
        append(MoveOrder,[Draft],NewMoveOrder),
        coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta).

% reached the end of absearch tree --> load best found rating and return        
abSearch(_, MoveOrder,_,Rating,_,_) :-
        bestRating(MoveOrder,Rating).       

% load current best rating and go to next layer (depth - 1)
% on retun from nextLayer check for new best rating and possible rating improvements (cutoff)     
coolStuff(EnemyColor, MoveOrder, Rating, NewMoveOrder, Depth, Beta) :-
        bestRating(MoveOrder,Best),
        nextLayer(EnemyColor, NewMoveOrder, V, Depth, Best, Beta),!,
        V > Best,
        saveNewBestRating(MoveOrder, V),
        V >= Beta,
        Rating is V.

% go to next layer in absearch        
nextLayer(EnemyColor, NewMoveOrder, V, Depth,Best,Beta) :-
        NewDepth is Depth - 1,
        NegaBeta is Best * -1,
        NegaAlpha is Beta * -1,
        % recursive  call with new board, color and depth
        abSearch(EnemyColor, NewMoveOrder,NewDepth,ThisRating,NegaAlpha,NegaBeta),
        % negate
        V is ThisRating * -1,!. 

checkHasMovesOrJumps(MoveOrder) :-
        hasPossibleJumps(MoveOrder),!.
        
checkHasMovesOrJumps(MoveOrder) :-
        hasPossibleMoves(MoveOrder),!.
        
checkHasMovesOrJumps(MoveOrder) :-
        saveNewBestRating(MoveOrder, -5000). 

% delete old best rating fact and write new one        
saveNewBestRating(MoveOrder, Rating) :-
        retract(bestRating(MoveOrder,_)),
        assertz(bestRating(MoveOrder,Rating)), !.
 
% Get next draft for absearch from MoveOrder of last turn        
getNewMoveOrder([], Draft):-
        getFirstTurnFromLastChoosenMoveOrder(Draft).
        
% Get next draft for absearch from next possible move fact    
getNewMoveOrder(MoveOrder, Draft) :-
        current_predicate(possibleMove/3),
        possibleMove(MoveOrder, Field, TargetField),
        atom_concat(Field,TargetField, Draft),
        checkIfItIsTheDraftFromTheChoosenMoveOrder(MoveOrder,Draft).
        
% Get next draft for absearch from next possible jump fact        
getNewMoveOrder(MoveOrder, Draft) :-
        current_predicate(possibleJump/4),
        possibleJump(MoveOrder, Field, _, TargetField),
        atom_concat(Field,TargetField, Draft),
        checkIfItIsTheDraftFromTheChoosenMoveOrder(MoveOrder,Draft).

% Check if draft equals predicted draft from MoveOrder of last turn
checkIfItIsTheDraftFromTheChoosenMoveOrder([],Draft):-
        \+getFirstTurnFromLastChoosenMoveOrder(Draft).
checkIfItIsTheDraftFromTheChoosenMoveOrder(MoverOrder,_):-
       MoverOrder \== [].

% read first move from MoveOrder of last turn
getFirstTurnFromLastChoosenMoveOrder(Draft) :-
        current_predicate(choosenMoveOrder/1),
        choosenMoveOrder(OldMoveOrder),
        getFirstTurnFromLastChoosenMoveOrder(Draft,OldMoveOrder).
getFirstTurnFromLastChoosenMoveOrder(Draft,[Draft|_]).

% Get Field and TargetField using best rating (determined by absearch)
% and write new choosen MoveOrder
getBest(Field, TargetField, Rating, Depth) :-
        NegaRating is Rating * -1,
        bestRating([Draft|[]], NegaRating),
        checkIfDraftIsRight(Rating, Depth -1, [Draft], ResultMoveOrder),
        abolish(choosenMoveOrder/1),
        asserta(choosenMoveOrder(ResultMoveOrder)),
        removeFromChoosenMoverOrder(Draft),
        translateDraft(Draft, Field, TargetField),!.

% Check if MoveOrder contains drafts for all depth
checkIfDraftIsRight(5000,_,_,[]).  % no check if won or lost (because depth might not be 0)
checkIfDraftIsRight(-5000,_,_,[]).
checkIfDraftIsRight(Raiting, Depth, MoveOrder, ResultMoveOrder)  :-
        NextDraft = [_],
        append(MoveOrder,NextDraft,NewMoveOrder),
        bestRating(NewMoveOrder,Raiting),
        NegaRaiting is Raiting * -1,
        NewDepth is Depth -1,
        checkIfDraftIsRight(NegaRaiting,NewDepth, NewMoveOrder, ResultMoveOrder).
checkIfDraftIsRight(_, 0, X, X).

% Apply whole MoveOrder to board (one draft after the other)        
setupBoard(MoveOrder) :- 
        saveBackupToBoard,
        applyMoves(MoveOrder),!.

% Apply draft to board (from MoveOrder)
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

% Use backupBoard facts to save current board as backup        
saveBoardToBackup :- 
        retract(backupBoard(_,_)),
        fail.                                      
saveBoardToBackup :- 
        board(Field,Figures),
        asserta(backupBoard(Field,Figures)),
        fail.
saveBoardToBackup.      

% Use backupBoard facts to load backup board as the current one
saveBackupToBoard :- 
        retract(board(_,_)),
        fail.                                      
saveBackupToBoard :- 
        backupBoard(Field,Figures),
        asserta(board(Field,Figures)),
        fail.
saveBackupToBoard.