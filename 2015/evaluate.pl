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
	countDistance(Color),
	distanceCounter(Distance),
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
	DistanceValue is DV*Distance,
	accumulateRating(Color, Rating, FigureValue, MoveValue, JumpValue, DistanceValue),
	!.
   
calculateRating(Rating, _, _) :-
   Rating is 5000,!.
   
countDistance(Color) :-
	retract(distanceCounter(_)),
	asserta(distanceCounter(0)),
	relatedColor(Color, GeneralColor),
	jump(Field,OverField,TargetField,GeneralColor),
	checkBoardForDistance(GeneralColor, Field, OverField, TargetField),
	distanceCounter(Counter),
	retract(distanceCounter(Counter)),
	NewCounter is Counter + 1,
	asserta(distanceCounter(NewCounter)),
	fail.
countDistance(_).

checkBoardForDistance(GeneralColor, Field, OverField, TargetField) :-
	relatedColor(Color, GeneralColor),
	enemy(Color, EnemyColor),
	board(Field,[GeneralColor|_]),
	board(OverField,[]),
	board(TargetField,[EnemyColor|_]),!.
	
checkBoardForDistance(GeneralColor, Field, OverField, TargetField) :-
	relatedColor(Color, GeneralColor),
	enemy(Color, EnemyColor),
	relatedColor(EnemyColor, EnemyGeneralColor),
	board(Field,[GeneralColor|_]),
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