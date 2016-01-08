writeAllPossibleDraftsFor(Color, MoveOrder) :-
        writeAllPossibleDraftsWithoutZugzwangFor(Color, MoveOrder),
        checkZugzwang(MoveOrder), !.
       
writeAllPossibleDraftsWithoutZugzwangFor(Color, MoveOrder) :-
        allSoldierDrafts(Color, MoveOrder),
        relatedColor(Color, GeneralColor),
        allSoldierDrafts(GeneralColor, MoveOrder), !.            
        
allSoldierDrafts(Color, MoveOrder) :-
        board(Field, [Color|_]),           % Get next figure position
        move(Field, TargetField, Color),       % Get next move
        \+testAndSaveMove(MoveOrder, Field, TargetField),
        jump(Field, TargetField, JumpTargetField, Color),
        testAndSaveJump(Color, MoveOrder, _, Field, TargetField, JumpTargetField),
        fail.
allSoldierDrafts(_, _).

testAndSaveMove(MoveOrder, Field, TargetField) :-
        isFieldEmpty(TargetField),
        assertz(possibleMove(MoveOrder, Field, TargetField)).
        
testAndSaveJump(Color, MoveOrder, GeneralColor, Field, TargetField, JumpTargetField) :-
        relatedColor(Color, GeneralColor),
        \+board(TargetField, [Color|_]),   % Not possible to jump over own figures
        \+board(TargetField, [GeneralColor|_]),
        isFieldEmpty(JumpTargetField),
        assertz(possibleJump(MoveOrder, Field, TargetField, JumpTargetField)).

isFieldEmpty(Field) :-
        board(Field, []).
        
checkZugzwang(MoveOrder) :-
        hasPossibleJumps(MoveOrder),
        retract(possibleMove(MoveOrder,_,_)),
        checkZugzwang(MoveOrder).
checkZugzwang(_).  