% Write all possible moves and jumps for player as facts and check for zugzwang
writeAllPossibleDraftsFor(Color, MoveOrder) :-
        writeAllPossibleDraftsWithoutZugzwangFor(Color, MoveOrder),
        checkZugzwang(MoveOrder), !.

% Write all possible moves and jumps for color and general color as facts       
writeAllPossibleDraftsWithoutZugzwangFor(Color, MoveOrder) :-
        allSoldierDrafts(Color, MoveOrder),
        relatedColor(Color, GeneralColor),
        allSoldierDrafts(GeneralColor, MoveOrder), !.

% Write only moves and jumps as facts that don't already exist        
writeAllPossibleDraftsForIfNeeded(Color,MoveOrder) :-
	not(hasPossibleMoves(MoveOrder)),
	not(hasPossibleJumps(MoveOrder)),  
	writeAllPossibleDraftsFor(Color, MoveOrder), !.
writeAllPossibleDraftsForIfNeeded(_,_).	                 

% Iterate over all player figures and check for possible moves and jumps       
allSoldierDrafts(Color, MoveOrder) :-
        board(Field, [Color|_]),           % Get next figure position
        move(Field, TargetField, Color),       % Get next move
        \+testAndSaveMove(MoveOrder, Field, TargetField),
        jump(Field, TargetField, JumpTargetField, Color),
        testAndSaveJump(Color, MoveOrder, _, Field, TargetField, JumpTargetField),
        fail.
allSoldierDrafts(_, _).

% If target is empty write possible move as fact
testAndSaveMove(MoveOrder, Field, TargetField) :-
        isFieldEmpty(TargetField),
        assertz(possibleMove(MoveOrder, Field, TargetField)).

% If jump target is empty and field between is enemy figure write possible jump as fact        
testAndSaveJump(Color, MoveOrder, GeneralColor, Field, TargetField, JumpTargetField) :-
        relatedColor(Color, GeneralColor),
        \+board(TargetField, [Color|_]),   % Not possible to jump over own figures
        \+board(TargetField, [GeneralColor|_]),
        isFieldEmpty(JumpTargetField),
        assertz(possibleJump(MoveOrder, Field, TargetField, JumpTargetField)).

isFieldEmpty(Field) :-
        board(Field, []).

% If there is one or more possible jumps we have zugzwang --> all possible moves deleted       
checkZugzwang(MoveOrder) :-
        hasPossibleJumps(MoveOrder),
        retract(possibleMove(MoveOrder,_,_)),
        checkZugzwang(MoveOrder).
checkZugzwang(_).  