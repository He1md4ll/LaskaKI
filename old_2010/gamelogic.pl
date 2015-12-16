% Ueberpruefung ob ein Offizier erstellt werden muss
offizier(Spalte,Zeile) :-

        % weissen Offizier erstellen
        Zeile == g,
        board(Spalte,Zeile,Stapel),
        sub_atom(Stapel,0,1,_,Kopf),
        Kopf == w,
        atom_length(Stapel,Len),
        SubLen is Len - 1,
        sub_atom(Stapel,1,SubLen,_,Gefangene),
        retract(board(Spalte,Zeile,Stapel)),
        concat_atom([g,Gefangene],Offizier),
        assertz(board(Spalte,Zeile,Offizier))

        ;

        % schwarzen Offizier erstellen
        Zeile == a,
        board(Spalte,Zeile,Stapel),
        sub_atom(Stapel,0,1,_,Kopf),
        Kopf == s,
        atom_length(Stapel,Len),
        SubLen is Len - 1,
        sub_atom(Stapel,1,SubLen,_,Gefangene),
        retract(board(Spalte,Zeile,Stapel)),
        concat_atom([r,Gefangene],Offizier),
        assertz(board(Spalte,Zeile,Offizier))

        ;

        % keinen Offizier erstellen
        true.
        
% Zug des Gegners in das Spielbrett eingeben
mw(StartColumn,StartRow,TargetColumn,TargetRow) :-
        move((StartColumn,StartRow,TargetColumn,TargetRow)),
        schreibeBrett,!.

% Zug auf den Fakten durchfuehren       
move((SpalteA,ZeileA,SpalteE,ZeileE)) :-
        retract(board(SpalteA,ZeileA,Stapel)),
        assertz(board(SpalteA,ZeileA,l)),
        retract(board(SpalteE,ZeileE,l)),
        assertz(board(SpalteE,ZeileE,Stapel)),
        offizier(SpalteE,ZeileE),!.

% Sprung des Gegners ins Spielbrett eingeben
jw(StartColumn,StartRow,TargetColumn,TargetRow) :-
        jump((StartColumn,StartRow,TargetColumn,TargetRow)),
        schreibeBrett,!.

% Sprung auf den Fakten durchfuehren    
jump((SpalteA,ZeileA,SpalteE,ZeileE)) :-
        retract(board(SpalteA,ZeileA,Stapel)),
        assertz(board(SpalteA,ZeileA,l)),
        atom_codes(ZeileA,[A|_]),
        atom_codes(ZeileE,[E|_]),
        M is (A + E) / 2,
        atom_codes(ZeileM,[M]),
        SpalteM is (SpalteA + SpalteE) / 2,
        retract(board(SpalteM,ZeileM,Mstapel)),
        divide(Mstapel,Mkopf,Mrest),
        assertz(board(SpalteM,ZeileM,Mrest)),
        retract(board(SpalteE,ZeileE,l)),
        concat_atom([Stapel,Mkopf],Estapel),
        assertz(board(SpalteE,ZeileE,Estapel)),
        offizier(SpalteE,ZeileE),!.


% ===== Hilfspraedikate =====

jumplist([Coordinates|JumpListTail]) :-

        % ersten Sprung aus Liste ausfuehren
        jump(Coordinates),

        % rekusriver Aufruf fuer weitere Spruenge
        jumplist(JumpListTail),!.
jumplist([]).

divide(Stapel,Kopf,Rest) :-
        sub_atom(Stapel,0,1,_,Kopf),
        atom_length(Stapel,Len),
        SubLen is Len - 1,
        sub_atom(Stapel,1,SubLen,_,Gefangene),
        restStapel(SubLen,Gefangene,Rest).

restStapel(0,_,l).
restStapel(_,G,G).


% ===== virtuelle Praedikate =====

% Ueberpruefung, ob ein Offizier erstellt werden muss
voffizier(Board,Column,Row,BoardOut) :-

        % weissen Offizier erstellen
        Row == g,
        select([(Column,Row),[HeadToken|Tail]],Board,BoardTemp),
        HeadToken == w,
        append([[(Column,Row),[g|Tail]]],BoardTemp,BoardOut)

        ;

        % schwarzen Offizier erstellen
        Row == a,
        select([(Column,Row),[HeadToken|Tail]],Board,BoardTemp),
        HeadToken == s,
        append([[(Column,Row),[r|Tail]]],BoardTemp,BoardOut)

        ;

        % keinen Offizier erstellen
        BoardOut = Board.

% Virtuellen Zug durchfuehren
vmove(BoardIn,(ColumnIn,RowIn,ColumnOut,RowOut),BoardOut) :-

        % Figuren von Start-Koordinate auslesen und leeres Feld hinterlassen
        select([(ColumnIn,RowIn),Tokens],BoardIn,Board2),
        append([[(ColumnIn,RowIn),[l]]],Board2,Board3),

        % Ziel-Koordinate freiraeumen
        delete(Board3,[(ColumnOut,RowOut),_],Board4),

        % Figuren auf Ziel-Feld ablegen
        append([[(ColumnOut,RowOut),Tokens]],Board4,Board5),

        % Offiziers-Pruefung
        voffizier(Board5,ColumnOut,RowOut,BoardOut).

% Virtuellen Sprung durchfuehren
vjump(BoardIn,(ColumnIn,RowIn,ColumnOut,RowOut),BoardOut) :-

        % Figuren von Start-Koordinate auslesen und leeres Feld hinterlassen
        select([(ColumnIn,RowIn),Tokens],BoardIn,Board2),
        append([[(ColumnIn,RowIn),[l]]],Board2,Board3),

        % Mathematisch das Zielfeld bestimmen (Sollten wir vielleicht ueber Nachbarn realisieren)
        atom_codes(RowIn,[A|_]),
        atom_codes(RowOut,[E|_]),
        M is (A + E) / 2,
        atom_codes(RowCenter,[M]),
        ColumnCenter is (ColumnIn + ColumnOut) / 2,

        % obersten Spielstein gefangen nehmen
        select([(ColumnCenter,RowCenter),[TokenHead|Tail]],Board3,Board4),
        emptyField(Tail, NewTail),
        append([[(ColumnCenter,RowCenter),NewTail]],Board4,Board5),

        % Ziel-Feld aus Liste entfernen und Spielsteine ablegen
        delete(Board5,[(ColumnOut,RowOut),_],Board6),
        append(Tokens,[TokenHead],NewTokens),
        append([[(ColumnOut,RowOut),NewTokens]],Board6,Board7),

        % Offiziers-Pruefung
        voffizier(Board7,ColumnOut,RowOut,BoardOut).

vjumplist(BoardIn,[Coordinates|JumpListTail],BoardOut) :-

        % ersten Sprung aus Liste ausführen
        vjump(BoardIn,Coordinates,TempBoard),

        % rekusriver Aufruf für weitere Sprünge
        vjumplist(TempBoard,JumpListTail,BoardOut).
vjumplist(Board,[],Board).

emptyField([], [l]).
emptyField(A, A).