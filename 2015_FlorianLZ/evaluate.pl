% Moegliche weitere Bewertungen:
%       Abstand zum Gegner: 1 Feld besser als 2 oder mehr
%       Bei Jump Tiefe nicht verringern, da Zugzwang
%       In Tiefe 0 auf Jump �berpr�fen, dann 1 weiter rechnen
%       BRANCH: ReuseMoveOrder, MoveOrder wiederverwenden -> gemachten Zug aus Order l�schen, Rest wiederverwenden
%       Ersten Zug eintragen
%       Depth -1 geht nicht, da Ratings nicht mehr Vergleichbar
%       Alpha muss gel�scht werden (e8d9 immer noch drin)

calculateRating(Rating, Color, MoveOrder) :-
        enemy(Color, EnemyColor),   
        aggregate_all(count, board(_,[black|_]), S),
        aggregate_all(count, board(_,[white|_]), W),
        aggregate_all(count, board(_,[red|_]), R),
        aggregate_all(count, board(_,[green|_]), G),
        aggregate_all(count, board(_,[_,black|_]), JS), % gefangene Schwarze an erster Position
        aggregate_all(count, board(_,[_,white|_]), JW), % gefangene Weisse an erster Position
        aggregate_all(count, board(_,[_,_,black|_]), JJS), % gefangene Schwarze an zweiter Position
        aggregate_all(count, board(_,[_,_,white|_]), JJW), % gefangene Weisse an zweiter Position
        countDistance(Color),
        distanceCounter(MyDistance),
        countDistance(EnemyColor),
        distanceCounter(EnemyDistance),
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
        jailedSoldierValue(JSV),
        jailedJailedSoldierValue(JJSV),
        moveValue(MV),
        jumpValue(JV),
        distanceValue(DV),
        FigureValue is SV*(S-W) + GV*(R-G) + JSV*(JS-JW) + JJSV*(JJS-JJW),
        MoveValue is MV*(M-OM),
        JumpValue is JV*(J-OJ),
        DistanceValue is DV * (MyDistance - EnemyDistance),
        accumulateRating(Color, Rating, FigureValue, MoveValue, JumpValue, DistanceValue),
        !.
   
calculateRating(Rating, _, _) :-
   Rating is 5000,!.
   
countDistance(Color) :-
        retract(distanceCounter(_)),
        asserta(distanceCounter(0)),
        getDistanceToEnemies(Color,Distance),
        addEnemyDistance(Distance),
        getDistanceToFriends(Color,Distance),
        addDistance(Distance),
        fail.
countDistance(_).

getDistanceToEnemies(Color,Distance):-
        relatedColor(Color, GeneralColor),
        enemy(Color, EnemyColor),
        relatedColor(EnemyColor, EnemyGeneralColor),
        board(Field,[GeneralColor|_]),
        board(FieldEnemy,[EnemyGeneralColor|_]),
        distance(Field,FieldEnemy,Distance).
        
getDistanceToEnemies(Color,Distance):-
        relatedColor(Color, GeneralColor),
        enemy(Color, EnemyColor),
        board(Field,[GeneralColor|_]),
        board(FieldEnemy,[EnemyColor|_]),
        distance(Field,FieldEnemy,Distance).
        
getDistanceToFriends(Color,Distance):-
        relatedColor(Color, GeneralColor),
        board(Field1,[GeneralColor|_]),
        move(Field1,Field2,GeneralColor),
        board(Field2,[GeneralColor|_]),
        Distance is 5,!.
getDistanceToFriends(_,0).

addEnemyDistance(0):- addDistance(0),!.
addEnemyDistance(1):- addDistance(-5),!.
addEnemyDistance(2):- addDistance(4),!.
addEnemyDistance(3):- addDistance(3),!.
addEnemyDistance(4):- addDistance(2),!.
addEnemyDistance(5):- addDistance(1),!.
addEnemyDistance(6):- addDistance(0),!.
addEnemyDistance(7):- addDistance(0),!.

addDistance(Value):-
        distanceCounter(Counter),
        retract(distanceCounter(Counter)),
        NewCounter is Counter + Value,
        asserta(distanceCounter(NewCounter)).

checkBoardForDistance(GeneralColor, Field) :-
        move(Field,TargetField,GeneralColor),
        board(TargetField,[GeneralColor|_]).

checkBoardForDistance2(GeneralColor, Field) :-
        relatedColor(Color, GeneralColor),
        enemy(Color, EnemyColor),
        jump(Field,OverField,TargetField,GeneralColor),
        board(OverField,[]),
        board(TargetField,[EnemyColor|_]).
        
checkBoardForDistance2(GeneralColor, Field) :-
        relatedColor(Color, GeneralColor),
        enemy(Color, EnemyColor),
        relatedColor(EnemyColor, EnemyGeneralColor),
        jump(Field,OverField,TargetField,GeneralColor),
        board(OverField,[]),
        board(TargetField,[EnemyGeneralColor|_]).

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
        
accumulateRating(black, Rating, FigureValue, MoveValue, JumpValue, DistanceValue) :-    
        Rating is FigureValue + MoveValue + JumpValue + DistanceValue.
        
accumulateRating(white, Rating, FigureValue, MoveValue, JumpValue, DistanceValue) :-
        Rating is (MoveValue + JumpValue + DistanceValue) - FigureValue.
        
opponentHasNoMovesNorJumps(OM,OJ) :-
        OM == 0,
        OJ == 0.