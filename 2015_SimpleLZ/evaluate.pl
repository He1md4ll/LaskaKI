% Moegliche weitere Bewertungen:
%       Abstand zum Gegner: 1 Feld besser als 2 oder mehr
%       Bei Jump Tiefe nicht verringern, da Zugzwang
%       In Tiefe 0 auf Jump überprüfen, dann 1 weiter rechnen
%       BRANCH: ReuseMoveOrder, MoveOrder wiederverwenden -> gemachten Zug aus Order löschen, Rest wiederverwenden
%       Ersten Zug eintragen
%       Depth -1 geht nicht, da Ratings nicht mehr Vergleichbar
%       Alpha muss gelöscht werden (e8d9 immer noch drin)

calculateRating(Rating, Color, MoveOrder) :-
        enemy(Color, EnemyColor),   
        aggregate_all(count, board(_,[black|_]), S),
        aggregate_all(count, board(_,[white|_]), W),
        aggregate_all(count, board(_,[red|_]), R),
        aggregate_all(count, board(_,[green|_]), G),
        append(MoveOrder, [my], MyMoveOrder),
        writeAllPossibleDraftsWithoutZugzwangFor(Color,MyMoveOrder),
        countMovesFor(MyMoveOrder, M),
        countJumpsFor(MyMoveOrder, J),
        append(MoveOrder, [oppo], OppoMoveOrder),
        writeAllPossibleDraftsWithoutZugzwangFor(EnemyColor, OppoMoveOrder),
        countMovesFor(OppoMoveOrder, OM),
        countJumpsFor(OppoMoveOrder, OJ),
        not(opponentHasNoMovesNorJumps(OM,OJ)),                 
        soldierValue(SV),
        generalValue(GV),
        moveValue(MV),
        jumpValue(JV),
        FigureValue is SV*(S-W) + GV*(R-G),
        MoveValue is MV*(M-OM),
        JumpValue is JV*(J-OJ),
        accumulateRating(Color, Rating, FigureValue, MoveValue, JumpValue),
        !.
   
calculateRating(Rating, _, _) :-
   Rating is 5000,!.

countMovesFor(MoveOrder, M) :-
        hasPossibleMoves(MoveOrder),
        aggregate_all(count, possibleMove(MoveOrder,_,_), M).

countMovesFor(_, M) :-
        M is 0.
        
countJumpsFor(MoveOrder, J) :-
        hasPossibleJumps(MoveOrder),
        aggregate_all(count, possibleJump(MoveOrder,_,_,_), J).
        
countJumpsFor(_, J) :-
        J is 0.
        
accumulateRating(black, Rating, FigureValue, MoveValue, JumpValue) :-    
        Rating is FigureValue + MoveValue + JumpValue.
        
accumulateRating(white, Rating, FigureValue, MoveValue, JumpValue) :-
        Rating is (MoveValue + JumpValue) - FigureValue.
        
opponentHasNoMovesNorJumps(OM,OJ) :-
        OM == 0,
        OJ == 0.