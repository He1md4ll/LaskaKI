writeAllPossibleDraftsFor(Color) :-
        allSoldierDrafts(Color),
        relatedColor(Color, GeneralColor),
        allSoldierDrafts(GeneralColor),
        checkZugzwang, !.
        
allSoldierDrafts(Color) :-
        board(Field, [Color|_]),           % Get next figure position
        move(Field, TargetField, Color),       % Get next move
        \+testAndSaveMove(Field, TargetField),
        jump(Field, TargetField, JumpTargetField, Color),
        testAndSaveJump(Color, _, Field, TargetField, JumpTargetField),
        fail.
allSoldierDrafts(_).

testAndSaveMove(Field, TargetField) :-
        isFieldEmpty(TargetField),
        assertz(possibleMove(Field, TargetField)).
        
testAndSaveJump(Color, GeneralColor, Field, TargetField, JumpTargetField) :-
        relatedColor(Color, GeneralColor),
        \+board(TargetField, [Color|_]),   % Not possible to jump over own figures
        \+board(TargetField, [GeneralColor|_]),
        isFieldEmpty(JumpTargetField),
        assertz(possibleJump(Field, TargetField, JumpTargetField)).

isFieldEmpty(Field) :-
        board(Field, []).
        
checkZugzwang :-
        hasPossibleJumps,
        abolish(possibleMove/2).
checkZugzwang.  