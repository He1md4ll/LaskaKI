% ===== MOVES =====
% Bewertung der aktuellen Spielsituation

% Sucht erst nach Schritten (steps) und Spruengen (jumps)
% wenn ein Sprung gefunden wurde, dann nur noch nach Spruengen
% in diesem Fall wird die StepList zu einer leeren Liste
%
% Mehrfachspruenge werden hier erkannt!
%
% StepList -> [Zugkoor, Zugkoor, ...]
% JumpList -> [[Sprungkoor, Sprungkoor, ...], [Sprungkoor], [Sprungkoor], ...]
getMoves(Board,CurrentColor,StepList,JumpList) :-
        %Reduziere das Brett auf eine Farbe
        getReduceBoard(Board,CurrentColor,ReduceBoard),

        %Durchlaufen des Brettes, um fuer jeden Figur Sprungmoeglichkeiten zu pruefen
        getJumps(ReduceBoard,Board,JumpList),
        (
                ( JumpList = [])
                ->
                ( getSteps(ReduceBoard,Board,StepList) )
                ;
                ( StepList = [] )
        ),!.

% ===== STEP =====
% Uebergabeparameter: Brett reduziert auf aktuelle Farbe, komplettes Brett
% Durchlaeuft die Figuren einer Farbe rekursiv, um fuer jede Figur die Zugmoeglichkeiten zu pruefen
% Rueckgabeparameter: Liste mit ZeileA,SpalteA,ZeileE,SpalteE
% ZeileA,SpalteA Koordinaten Ursprungsfeld
% ZeileE,SpalteE Koordianten Zielfeld
getSteps([[(Column, Row),[HeadToken|_]]|Tail],Board,Targets):-
        getSteps(Tail,Board,Targets4Token),

        %Pruefen auf Zugmoeglichkeit
        getSteps4Token(Board,(Column,Row),HeadToken,NewTargets),
        append(Targets4Token,NewTargets,Targets).

getSteps([],_,[]).
% Liefert die moeglichen Zuege zu einer bestimmten Figur
getSteps4Token(Board,(Column,Row),Token,Targets):-

        % regeltechnisch besuchbare Nachbarfelder zusammensuchen
        (
                % Offizier auf Feld?
                ( Token == g ; Token == r )
                ->
                % dann : alle Richtungen in Betracht ziehen
                findall((ColumnTarget,RowTarget),neighbour((Column,Row),(ColumnTarget,RowTarget),_,_),Moves)
                ;
                % sonst: nur Frontrichtung nehmen
                findall((ColumnTarget,RowTarget),neighbour((Column,Row),(ColumnTarget,RowTarget),Token,_),Moves)
        ),

        % moegliche Ziel-Felder ueberpruefen, ob leer
        checkIfFieldFree(Board,Moves,(Column,Row),Targets).


% Prueft ob die moeglichen Felder frei sind
checkIfFieldFree(Board,[(ColumnTarget,RowTarget)|Tail],(ColumnStart,RowStart),Targets):-

        % rekursiver Aufruf, um Liste mit moeglichen Zielen zu durchlaufen
        checkIfFieldFree(Board,Tail,(ColumnStart,RowStart),OtherTargets),
        (
                % Ziel-Feld leer?
                (member([(ColumnTarget,RowTarget),[l]],Board))
                ->
                % dann: Zug-Moeglichkeit in Ergebnisliste aufnehmen
                (append(OtherTargets,[(ColumnStart,RowStart,ColumnTarget,RowTarget)],Targets))
                ;
                % sonst: Ergebnisliste nur uebernehmen
                (Targets = OtherTargets)
        ).

% Abbruch-Fakt fuer Rekursion
checkIfFieldFree(_,[],_,[]).


% ===== JUMP =====
% Uebergabeparameter: Brett reduziert auf aktuelle Farbe, komplettes Brett
% Durchlaeuft die Figuren einer Farbe rekursiv, um fuer jede Figur die Sprungmoeglichkeiten zu pruefen
% Rueckgabeparameter: Liste mit ZeileA,SpalteA,ZeileE,SpalteE
% ZeileA,SpalteA Koordinaten Ursprungsfeld
% ZeileE,SpalteE Koordianten Zielfeld
getJumps([[(Column, Row),[HeadToken|_]]|Tail],Board,Targets):-
        getJumps(Tail,Board,Targets4Token),

        %Pruefen auf Sprungmoeglichkeit
        getJumps4Token(Board,(Column,Row),HeadToken,[],NewTargets),
        append(Targets4Token,NewTargets,Targets).

getJumps([],_,[]).


% Uebergabeparameter: Zeile, Spalte, Farbe des zu ueberpruefenden Feldes
% Nachbarfelder ueberpruefen ob in Zugrichtung Gegner stehen
% Wenn Gegner in Zugrichtung vorhanden sind,
% schauen ob deren Nachbarfelder in Zugrichtung frei sind
% Rueckgabeparameter: Liste mit ZeileA,SpalteA,ZeileE,SpalteE
% ZeileA,SpalteA Koordinaten Ursprungsfeld
% ZeileE,SpalteE Koordianten Zielfeld
getJumps4Token(Board,StartCoordinates,Token,ForbiddenNeighbours,Targets) :-

        % regeltechnisch besuchbare Nachbarfelder zusammensuchen
        (
                % Offizier auf Feld?
                ( Token == g ; Token == r )
                ->
                % dann : alle Richtungen in Betracht ziehen
                findall((ColumnNeighbour,RowNeighbour,NSDirection,EWDirection),neighbour(StartCoordinates,(ColumnNeighbour,RowNeighbour),NSDirection,EWDirection),Neighbours)
                ;
                % sonst: nur Frontrichtung nehmen
                NSDirection = Token,
                findall((ColumnNeighbour,RowNeighbour,NSDirection,EWDirection),neighbour(StartCoordinates,(ColumnNeighbour,RowNeighbour),NSDirection,EWDirection),Neighbours)
        ),

        % Sprung-Moeglichkeit ueberpruefen
        checkIfJumpIsPossible(Board,StartCoordinates,Token,ForbiddenNeighbours,Neighbours,NewTargets),
        reverse(NewTargets,Targets).

% In Zugrichtung liegende Nachbarfelder pruefen, ob diese vom Gegner besetzt sind
% und ob dieser geschlagen werden kann
checkIfJumpIsPossible(Board,(ColumnStart,RowStart),Token,ForbiddenNeighbours,[(ColumnNeighbour,RowNeighbour,NSDirection, EWDirection)|Tail],Targets):-

        % rekursiver Aufruf
        checkIfJumpIsPossible(Board,(ColumnStart,RowStart),Token,ForbiddenNeighbours,Tail,OtherTargets),

        (
                (
                % kein verbotener Nachbar?
                \+ member((ColumnNeighbour,RowNeighbour), ForbiddenNeighbours),

                % Gegner-Figuren anhand von eigener Figur bestimmen
                enemy(Token,EnemyToken),

                % Gegner auf Nachbarfeld?
                member([(ColumnNeighbour,RowNeighbour),[EnemyToken|_]],Board),

                % Nachbarfeld von Nachbarfeld in Sprungrichtung bestimmen
                neighbour((ColumnNeighbour,RowNeighbour),(ColumnTarget,RowTarget),NSDirection,EWDirection),

                % Sprung-Ziel-Feld leer?
                member([(ColumnTarget,RowTarget),[l]],Board)
                )
                ->
                % dann: Zug-Moeglichkeit in Ergebnisliste aufnehmen
                (
                % Nachbarfeld in Verbot-Liste aufnehmen
                append(ForbiddenNeighbours, [(ColumnNeighbour, RowNeighbour)], NewForbiddenNeighbours),

                % Sprung virtuell durchfuehren
                vjump(Board,(ColumnStart,RowStart,ColumnTarget,RowTarget),NewBoard),

                        getJumps4Token(NewBoard,(ColumnTarget,RowTarget),Token,NewForbiddenNeighbours,NewTargets),
                        (
                                NewTargets \= []
                                ->
                                createJumpJump(NewTargets,[(ColumnStart,RowStart,ColumnTarget,RowTarget)],Targets)
                                ;
                                append(OtherTargets,[[(ColumnStart,RowStart,ColumnTarget,RowTarget)]],Targets)
                        )
                )
                ;
                % sonst: Ergebnisliste nur uebernehmen
                (
                (Targets = OtherTargets)
                )
        ).

% Abbruch-Fakt fuer Rekursion
checkIfJumpIsPossible(_Board,_Startcoordinates,_Token,_ForbiddenNeighbours,[],[]).

createJumpJump([NextMove|Tail], PreviousMove, Targets):-

        % rekursiver Aufruf
        createJumpJump(Tail, PreviousMove, OtherTargets),

        % Sprung zusammenfuegen
        append(PreviousMove, NextMove, TempTarget),

        % Sprungliste zusammenfuegen
        append(OtherTargets,[TempTarget],Targets).
createJumpJump([],_,[]).