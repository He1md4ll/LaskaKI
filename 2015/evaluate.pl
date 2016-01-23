% Moegliche weitere Bewertungen:
%	Abstand zum Gegner: 1 Feld besser als 2 oder mehr
%	Bei Jump Tiefe nicht verringern, da Zugzwang
%	In Tiefe 0 auf Jump überprüfen, dann 1 weiter rechnen
%	BRANCH: ReuseMoveOrder, MoveOrder wiederverwenden -> gemachten Zug aus Order löschen, Rest wiederverwenden
%	Ersten Zug eintragen
%	Depth -1 geht nicht, da Ratings nicht mehr Vergleichbar
%	Alpha muss gelöscht werden (e8d9 immer noch drin)

calculateRating(Rating, Color, MoveOrder) :-
	enemy(Color, EnemyColor),   
	aggregate_all(count, board(_,[black|_]), S),
	aggregate_all(count, board(_,[white|_]), W),
	aggregate_all(count, board(_,[red|_]), R),
	aggregate_all(count, board(_,[green|_]), G),
	
	aggregate_all(count, board(_,[black,black|_]), JailedBlackSoldier), %
	aggregate_all(count, board(_,[black,black,black|_]), JailedJailedBlackSoldier),
	aggregate_all(count, board(_,[red,black|_]), JailedBlackGeneral), %
	aggregate_all(count, board(_,[red,black,black|_]), JailedJailedBlackGeneral),
	
	aggregate_all(count, board(_,[white,white|_]), JailedWhiteSoldier),
	aggregate_all(count, board(_,[white,white,white|_]), JailedJailedWhiteSoldier),
	aggregate_all(count, board(_,[green,white|_]), JailedWhiteGeneral),
	aggregate_all(count, board(_,[green,white,white|_]), JailedJailedWhiteGeneral),
		
	JailedBlack is JailedBlackSoldier + JailedBlackGeneral,
	JailedJailedBlack is JailedJailedBlackSoldier + JailedJailedBlackGeneral,
	JailedWhite is JailedWhiteSoldier + JailedWhiteGeneral,
	JailedJailedWhite is JailedJailedWhiteSoldier + JailedJailedWhiteGeneral,
	
	aggregate_all(count, board(_,[white,black|_]), JailedOpponentsWhiteSoldier), %
	aggregate_all(count, board(_,[white,black,black|_]), JailedJailedOpponentsWhiteSoldier),
	aggregate_all(count, board(_,[green,black|_]), JailedOpponentsWhiteGeneral), %
	aggregate_all(count, board(_,[green,black,black|_]), JailedJailedOpponentsWhiteGeneral),
	
	aggregate_all(count, board(_,[black,white|_]), JailedOpponentsBlackSoldier),
	aggregate_all(count, board(_,[black,white,white|_]), JailedJailedOpponentsBlackSoldier),
	aggregate_all(count, board(_,[red,white|_]), JailedOpponentsBlackGeneral),
	aggregate_all(count, board(_,[red,white,white|_]), JailedJailedOpponentsBlackGeneral),
		
	JailedOpponentsBlack is JailedOpponentsBlackSoldier + JailedOpponentsBlackGeneral,
	JailedJailedOpponentsBlack is JailedJailedOpponentsBlackSoldier + JailedJailedOpponentsBlackGeneral,
	JailedOpponentsWhite is JailedOpponentsWhiteSoldier + JailedOpponentsWhiteGeneral,
	JailedJailedOpponentsWhite is JailedJailedOpponentsWhiteSoldier + JailedJailedOpponentsWhiteGeneral,
	
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
	jailedOpponents(JOV),
	jailedJailedOpponents(JJOV),
	FigureValue is SV*(S-W) + GV*(R-G) + JSV*((JailedBlack-JailedJailedBlack)-(JailedWhite-JailedJailedWhite)) + JJSV*(JailedJailedBlack-JailedJailedWhite) + JOV*((JailedOpponentsBlack-JailedJailedOpponentsBlack)-(JailedOpponentsWhite-JailedJailedOpponentsWhite)) + JJOV*(JailedJailedOpponentsBlack-JailedJailedOpponentsWhite),
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
	board(Field,[GeneralColor|_]),
	checkBoardForDistance(GeneralColor, Field),
	distanceCounter(Counter),
	retract(distanceCounter(Counter)),
	NewCounter is Counter + 1,
	asserta(distanceCounter(NewCounter)),
	fail.
countDistance(_).

checkBoardForDistance(GeneralColor, Field) :-
	relatedColor(Color, GeneralColor),
	enemy(Color, EnemyColor),
	jump(Field,OverField,TargetField,GeneralColor),
	board(OverField,[]),
	board(TargetField,[EnemyColor|_]).
	
checkBoardForDistance(GeneralColor, Field) :-
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