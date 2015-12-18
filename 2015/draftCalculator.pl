writeAllPossibleDraftsFor(Color) :-
        allSoldierDrafts(Color),
        relatedColor(Color, GeneralColor),
        allSoldierDrafts(GeneralColor),
        allGeneralDrafts(GeneralColor),
        checkZugzwang, !.
        
allSoldierDrafts(Color) :-
        feld(Field, [Color]),           % Get next figure position
        move(Field, TargetField, Color),       % Get next move
        \+testAndSaveMove(Field, TargetField),
        jump(Field, TargetField, JumpTargetField, Color),
        testAndSaveJump(Color, _, Field, TargetField, JumpTargetField),
        fail.
allSoldierDrafts(_).

allGeneralDrafts(GeneralColor) :-
        feld(Field, [GeneralColor]),            % Get next figure position
        move(TargetField, Field, Color),                       % Get next move
        \+testAndSaveMove(Field, TargetField),
        jump(JumpTargetField, TargetField, Field, Color),
        testAndSaveJump(_, GeneralColor, Field, TargetField, JumpTargetField),
        fail.
allGeneralDrafts(_).

testAndSaveMove(Field, TargetField) :-
        isFieldEmpty(TargetField),
        assertz(possibleMove(Field, TargetField)).
        
testAndSaveJump(Color, GeneralColor, Field, TargetField, JumpTargetField) :-
        relatedColor(Color, GeneralColor),
        \+feld(TargetField, [Color]),   % Not possible to jump over own figures
        \+feld(TargetField, [GeneralColor]),
        isFieldEmpty(JumpTargetField),
        assertz(possibleJump(Field, TargetField, JumpTargetField)).

isFieldEmpty(Field) :-
        feld(Field, []).
        
checkZugzwang :-
        hasPossibleJumps,
        abolish(possibleMove/2).
checkZugzwang.  