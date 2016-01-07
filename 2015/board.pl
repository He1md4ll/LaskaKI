:- dynamic
	board/2.
	
:- dynamic
	backupBoard/2.	
        
board(a4,[white]).
board(a6,[white]).
board(b3,[white]).
board(b5,[white]).
board(b7,[white]).
board(c2,[white]).
board(c4,[white]).
board(c6,[white]).
board(c8,[white]).
board(d1,[]). %
board(d3,[]). % diese fuenf Felder
board(d5,[]). %
board(d7,[]). % sind anfangs unbesetzt
board(d9,[]). %
board(e2,[black]).
board(e4,[black]).
board(e6,[black]).
board(e8,[black]).
board(f3,[black]).
board(f5,[black]).
board(f7,[black]).
board(g4,[black]).
board(g6,[black]).
        
% Felder des Brettes waehrend eines Spiels
:- dynamic       % brett(Zeile+Spalte,Farbe)
        brett/2.
initBrett :-
        abolish(brett,2),
        board(ZS,F),
        asserta(brett(ZS,F)),
        fail.
initBrett.

% (Hauptprozedur)
schreibeBrett :-
        trennzeile(a),
    schreibeZeilen([g,f,e,d,c,b,a]).
% Trennzeile
trennzeile(a) :-
    write(' --                              +------------------------------+'),
    nl.
trennzeile(b) :-
    write(' --                    +--------------------------------------------------+'),
    nl.
trennzeile(c) :-
    write(' --          +----------------------------------------------------------------------+'),
    nl.
trennzeile(d) :-
    write('   +------------------------------------------------------------------------------------------+'),
    nl.
trennzeile(e) :-
        trennzeile(d).
trennzeile(f) :-
        trennzeile(c).
trennzeile(g) :-
        trennzeile(b).
% Ausgabe der Zeilen des Spielbretts
schreibeZeilen([]):- % Fusszeile unter dem Brett
    write('        1         2         3         4         5         6         7         8         9'),
    nl.
schreibeZeilen([Zeile|T]) :- % 2-Felder-Reihen
    member(Zeile,[g,a]),
    schreibeKb(Zeile),
    write('                               |'),
    schreibeZellen(Zeile,[4,x,6]),
    schreibeZeilen(T),!.
schreibeZeilen([Zeile|T]) :- % 3-Felder-Reihen
    member(Zeile,[f,b]),
    schreibeKb(Zeile),
    write('                     |'),
    schreibeZellen(Zeile,[3,x,5,x,7]),
    schreibeZeilen(T).
schreibeZeilen([Zeile|T]) :- % 4-Felder-Reihen
    member(Zeile,[e,c]),
    schreibeKb(Zeile),
    write('           |'),
    schreibeZellen(Zeile,[2,x,4,x,6,x,8]),
    schreibeZeilen(T).
schreibeZeilen([Zeile|T]) :- % 5-Felder-Reihe
    schreibeKb(Zeile),
    write(' |'),
    schreibeZellen(Zeile,[1,x,3,x,5,x,7,x,9]),
    schreibeZeilen(T),
    write('|').
% Kennbuchstabe der Reihe ausgeben
schreibeKb(B) :-
    write(' '),
    upcase_atom(B,Upper),
    write(Upper).
% Ausgabe der Felder (und horizontalen Trennzeilen)
schreibeZellen(d,[]) :-
    nl,
    trennzeile(d).
schreibeZellen(Zeile,[]) :-
    write('|'),nl,
    trennzeile(Zeile).
schreibeZellen(Zeile,[x|T]) :- % nicht genutztes "Zwischenfeld"
    write('    |     '), % (auf einem Schachbrett die Felder einer Farbe)
    schreibeZellen(Zeile,T).
schreibeZellen(Zeile,[Spalte|T]) :- % genutztes Spielfeld
        atom_concat(Zeile,Spalte,ZeileSpalte),
    board(ZeileSpalte,Stapel), % was liegt auf dem Feld?
    schreibeboard(Stapel),       % Säule ausgeben
    schreibeZellen(Zeile,T).
    
schreibeboard([]) :- % unbesetztes Feld (anfangs sind das die Felder der 5er-Reihe)
    write('          ').
schreibeboard([Kopf|Rest]) :-   % besetztes Feld
    kopfsymbol(Kopf,Symb),
    write(Symb),      % der Kopf wird als Großbuchstabe ausgegeben, s.u.
    colorToUiNames(Rest,UiRest),
    concat_atom(UiRest,Gefangene),
    write(Gefangene), % alle Steine unter dem Kopf
    atom_length(Gefangene,Len),
    Leer is 8 - Len,
    fuellen(Leer,Fueller),
    write(Fueller),   % Leerzeichen für alle Pos. < 9
    write(' ').       % Abgrenzung zum Nachbarfeld

% Umwandlung in Großbuchstaben per Fakten
kopfsymbol(white,'W').
kopfsymbol(black,'S').
kopfsymbol(green,'G').
kopfsymbol(red,'R').

   
uiSymbol(white,'w').
uiSymbol(black,'s').
uiSymbol(green,'g').
uiSymbol(red,'r').

colorToUiNames(Rest,UiRest):-
   colorToUiNames(Rest,[],UiRest).
   
colorToUiNames([Head|Tail],Li,UiRest):-
   uiSymbol(Head,UiHead),
   append(Li,[UiHead],LiBack),
   colorToUiNames(Tail,LiBack,UiRest).
   
colorToUiNames([],UiRest,UiRest).

% Leerzeichen zum Auffüllen in gleicher Weise
fuellen(1,' ').
fuellen(2,'  ').
fuellen(3,'   ').
fuellen(4,'    ').
fuellen(5,'     ').
fuellen(6,'      ').
fuellen(7,'       ').
fuellen(8,'        ').


