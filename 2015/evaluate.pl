% Moegliche weitere Bewertungen:
%	Abstand zum Gegner: 1 Feld besser als 2 oder mehr
%	Bei Jump Tiefe nicht verringern, da Zugzwang
%	In Tiefe 0 auf Jump überprüfen, dann 1 weiter rechnen
%	BRANCH: ReuseMoveOrder, MoveOrder wiederverwenden -> gemachten Zug aus Order löschen, Rest wiederverwenden
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
   append(MoveOrder, [my], MyMoveOrder),
   writeAllPossibleDraftsWithoutZugzwangFor(Color,MyMoveOrder),
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
	   OM == 0, 
	   OJ == 0, 
	   Rating is 5000
   ;
   	   aiColor(AiColor),
   	   soldierValue(AiColor,SV),
   	   generalValue(AiColor,GV),
   	   jailedSoldierValue(AiColor,JSV),
   	   jailedJailedSoldierValue(AiColor,JJSV),
   	   moveValue(AiColor,MV),
   	   jumpValue(AiColor,JV),
   	   FigureValue is SV*(S-W) + GV*(R-G) + JSV*(JS-JW) + JJSV*(JJS-JJW),
   	   MoveValue is MV*(M-OM),
   	   JumpValue is JV*(J-OJ),
   	   (
   	       Color == black,
   	       Rating is FigureValue + MoveValue + JumpValue
   	   ;
   	   	  Rating is (MoveValue + JumpValue) - FigureValue
   	   )
   ),
   !.	