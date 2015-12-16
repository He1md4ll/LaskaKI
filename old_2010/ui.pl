%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beispiel einer Ausgaberoutine fuer das Laska-Spiel
%
% U. Meyer, Okt. 2008
%
%
% Angenommen wird ein Spiel auf einem Schachbrett,
% gespielt wird auf den Feldern einer Farbe, die
% Felder der anderen Farbe gehoeren nicht zum Spielfeld.
%
% Demonstriert werden auch verschiedene Programmiertechniken
% in Prolog.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hauptprozedur
schreibeBrett :-
        writeSeparator,
        nl,
        schreibeZeilen([g,f,e,d,c,b,a]),
        !.

% Ausgabe der Zeilen des Spielbretts
schreibeZeilen([]):- % Fusszeile unter dem Brett
        write('     1           2           3           4           5           6           7'),
        nl.
schreibeZeilen([Zeile|T]) :- % 3-Felder-Reihen
        member(Zeile,[b,d,f]),
        write(' '),
        upcase_atom(Zeile,Upper),
        write(Upper),
        write(' |'),
        schreibeZellen(Zeile,[x,2,x,4,x,6,x]),
        schreibeZeilen(T).
schreibeZeilen([Zeile|T]) :- % 4-Felder-Reihen
        write(' '),
        upcase_atom(Zeile,Upper),
        write(Upper),
        write(' |'),
        schreibeZellen(Zeile,[1,x,3,x,5,x,7]),
        schreibeZeilen(T).

% Ausgabe der Felder (und horizontalen Trennzeilen)
schreibeZellen(_,[]) :- % Trennzeile
        nl,
        writeSeparator,
        nl.
schreibeZellen(Zeile,[x|T]) :- % nicht genutztes "Zwischenfeld"
        write('-----------|'), % (auf einem Schachbrett die Felder einer Farbe)
        schreibeZellen(Zeile,T).
schreibeZellen(Zeile,[Spalte|T]) :- % genutztes Spielfeld
        board(Spalte,Zeile,Stapel), % was liegt auf dem Feld?
        schreibeFeld(Stapel),       % Saeule ausgeben
        schreibeZellen(Zeile,T).

schreibeFeld(l) :- % unbesetztes Feld (anfangs sind das 12, 13, 14)
        write('           |').
schreibeFeld(Stapel) :-   % besetztes Feld
        sub_atom(Stapel,0,1,Rest,Kopf),
        kopfsymbol(Kopf,Symb),
        write(Symb),      % der Kopf wird als Grossbuchstabe ausgegeben, s.u.
        sub_atom(Stapel,1,Rest,_,Gefangene),
        write(Gefangene), % alle Steine unter dem Kopf
        Leer is 10 - Rest,
        fuellen(Leer,Fueller),
        write(Fueller),   % Leerzeichen fuer alle Pos. < 11
        write('|').       % Abgrenzung zum Nachbarfeld


% ===================================================================
% ============================ BoardList ============================
% ===================================================================

% Brett zu Liste konvertieren
board2list(BoardList) :-
        findall([(Column,Row),Members],board(Column,Row,Members),NewList),
        members2list(NewList, BoardList).

% Praedikat zum aufbereiten der Spielsteine in eine Liste
members2list([[Coordinate, Members]|Tail], ListOutput) :-
        members2list(Tail, NewList),
        atom_chars(Members, MemberList),
        append([[Coordinate, MemberList]], NewList, ListOutput).
members2list([], []).

% Brett-Liste ausgeben
writeBoardList(BoardList) :-
        % oberer Spielfeld-Rand
        writeSeparator, nl,

        % Zeilen ausgeben
        writeRow(BoardList, [g,f,e,d,c,b,a]),

        % untere Spielfeld-Rand
        writeSeparator, nl,

        % untere Spielfeld-Beschriftung
        write('     1           2           3           4           5           6           7'), nl, nl, !.

writeSeparator :-
        write('  -|-----------|-----------|-----------|-----------|-----------|-----------|-----------|').


%Ausgabe der Zeilen des Spielbretts
writeRow(BoardList, [Row|Tail]) :- % 3-Felder-Reihen
        % Zeilen-Name ausgeben
        member(Row, [b,d,f]),
        write(' '),
        upcase_atom(Row, Upper),
        write(Upper),
        write(' |'),

        % Zellen schreiben
        writeCell(BoardList, Row, [x,2,x,4,x,6,x]),

        % naechste Zeile
        writeRow(BoardList, Tail).

writeRow(BoardList, [Row|Tail]) :- % 4-Felder-Reihen
        % Zeilen-Name ausgeben
        write(' '),
        upcase_atom(Row, Upper),
        write(Upper),
        write(' |'),

        % Zellen schreiben
        writeCell(BoardList, Row, [1,x,3,x,5,x,7]),

        % naechste Zeile
        writeRow(BoardList, Tail).

writeRow(_, []) :-
        true.

% Ausgabe der Felder (und horizontalen Trennzeilen)
writeCell(_,_,[]) :- % Trennzeile
        nl.

writeCell(BoardList, Row, [x|ColumnTail]) :- % nicht genutztes "Zwischenfeld"
        write('-----------|'), % (auf einem Schachbrett die Felder einer Farbe)

        % naechste Zelle
        writeCell(BoardList, Row, ColumnTail).

writeCell(BoardList, Row, [Column|ColumnTail]) :- % genutztes Spielfeld
        member([(Column, Row), Tokens], BoardList),

        atomic_list_concat(Tokens, AtomTokens),

        writeTokens(AtomTokens),       % Saeule ausgeben

        % naechste Zelle
        writeCell(BoardList, Row, ColumnTail).

writeTokens(l) :-
        write('leer       |').

writeTokens(Stapel) :-   % besetztes Feld
        sub_atom(Stapel,0,1,Rest,Kopf),
        kopfsymbol(Kopf,Symb),
        write(Symb),      % der Kopf wird als Großbuchstabe ausgegeben, s.u.
        sub_atom(Stapel,1,Rest,_,Gefangene),
        write(Gefangene), % alle Steine unter dem Kopf
        Leer is 10 - Rest,
        fuellen(Leer,Fueller),
        write(Fueller),   % Leerzeichen fuer alle Pos. < 11
        write('|').       % Abgrenzung zum Nachbarfeld