% calculate rating for current board
% all ratings got its own weighting from facts
% 1:	Count normal figures
% 2:	Count generals
% 3:	Count jailed figures at first position in stack
% 4:	Count jailed figures at secound position in stack
% 5:	Evaluate distance to other figures: best if one field between two figures --> only for generals
% 6:	Count possible moves
% 7:	Count possible jumps
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

% Counts all generals where one field is between itself and another figure
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

% Checks if distance from general to next figure is one (one field between)
checkBoardForDistance(GeneralColor, Field) :-
	relatedColor(Color, GeneralColor),
	enemy(Color, EnemyColor),
	jump(Field,OverField,TargetField,GeneralColor),
	board(OverField,[]),
	board(TargetField,[EnemyColor|_]).
% Check for other direction	
checkBoardForDistance(GeneralColor, Field) :-
	relatedColor(Color, GeneralColor),
	enemy(Color, EnemyColor),
	relatedColor(EnemyColor, EnemyGeneralColor),
	jump(Field,OverField,TargetField,GeneralColor),
	board(OverField,[]),
	board(TargetField,[EnemyGeneralColor|_]).	

% Count all possible moves
countMovesFor(MoveOrder, M) :-
	hasPossibleMoves(MoveOrder),
	aggregate_all(count, possibleMove(MoveOrder,_,_), M).
countMovesFor(_, M) :-
	M is 0.

% Count all possible jumps	
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