% Moegliche weitere Bewertungen:
%	Abstand zum Gegner: 1 Feld besser als 2 oder mehr
%	Zweiter und Dritter Gefangener 
%	Erster und zweiter gefangener vom Gegner --> also gleiche Farbe
calculateRating(Rating, AiColor, MoveOrder) :-
   enemy(AiColor, EnemyColor),   
   aggregate_all(count, board(_,[black|_]), S),
   aggregate_all(count, board(_,[white|_]), W),
   aggregate_all(count, board(_,[red|_]), R),
   aggregate_all(count, board(_,[green|_]), G),
   aggregate_all(count, board(_,[_,black|_]), JS), % gefangene Schwarze an erster Position
   aggregate_all(count, board(_,[_,white|_]), JW), % gefangene Weisse an erster Position
   append(MoveOrder, [my], MyMoveOrder),
   writeAllPossibleDraftsWithoutZugzwangFor(AiColor,MyMoveOrder),
   (
	   hasPossibleMoves(MyMoveOrder),
	   aggregate_all(count, possibleMove(MyMoveOrder,_,_), M)
   ;
	   M is 0
   ),
   (
   	   hasPossibleJumps(MyMoveOrder),
	   aggregate_all(count, possibleJump(MyMoveOrder,_,_,_), J)
   ;
   	   J is 0
   ),
   append(MoveOrder, [oppo], OppoMoveOrder),
   writeAllPossibleDraftsWithoutZugzwangFor(EnemyColor, OppoMoveOrder),
   (
	   hasPossibleMoves(OppoMoveOrder),
	   aggregate_all(count, possibleMove(OppoMoveOrder,_,_), OM)
   ;
       OM is 0
   ),
   (
	   hasPossibleJumps(OppoMoveOrder),
	   aggregate_all(count, possibleJump(OppoMoveOrder,_,_,_), OJ)
   ;
       OJ is 0
   ),				
   (
	   M == 0, 
	   J == 0, 
	   Rating is -10000
   ;
	   OM == 0, 
	   OJ == 0, 
	   Rating is 10000
   ;
   	   FigureValue is 20*(S-W) + 65*(R-G) + 5*(JS-JW),
   	   MoveValue is 3*(M+J-OM-OJ),
   	   (
   	       AiColor == black,
   	       Rating is FigureValue + MoveValue
   	   ;
   	   	  Rating is MoveValue - FigureValue
   	   )
   ),
   !.	