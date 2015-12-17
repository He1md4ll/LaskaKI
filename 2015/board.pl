%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beispiel einer Ausgaberoutine für UM-L´
% -- das modifizierte Laska-Spiel
%
% U. Meyer, Okt. 2008, Feb. 2015
%
%
% Angenommen wird ein Spiel auf einem Schachbrett-ähnlichen,
% rautenartigen Spielfeld, jedoch mit 9 x 7 Feldern
%
% Wie im Laska-Spiel wird beim Schachbrett
% auf den Feldern einer Farbe gespielt, die
% Felder der anderen Farbe gehören nicht zum Spielfeld.
%
% Demonstriert werden auch verschiedene Programmiertechniken
% in Prolog.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fakten zur Repräsentation benutzter Felder in der
% Ausgangsstellung: feld(Zeile+Spalte,Farbe)
feld(a4,[white]).
feld(a6,[white]).
feld(b3,[white]).
feld(b5,[white]).
feld(b7,[white]).
feld(c2,[white]).
feld(c4,[white]).
feld(c6,[white]).
feld(c8,[white]).
feld(d1,[]). %
feld(d3,[]). % diese fünf Felder
feld(d5,[]). %
feld(d7,[]). % sind anfangs unbesetzt
feld(d9,[]). %
feld(e2,[black]).
feld(e4,[black]).
feld(e6,[black]).
feld(e8,[black]).
feld(f3,[black]).
feld(f5,[black]).
feld(f7,[black]).
feld(g4,[black]).
feld(g6,[black]).
        
% Felder des Brettes während eines Spiels
:- dynamic       % brett(Zeile+Spalte,Farbe)
        brett/2.
initBrett :-
        abolish(brett,2),
        feld(ZS,F),
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
    brett(ZeileSpalte,Stapel), % was liegt auf dem Feld?
    schreibeFeld(Stapel),       % Säule ausgeben
    schreibeZellen(Zeile,T).
    
schreibeFeld([]) :- % unbesetztes Feld (anfangs sind das die Felder der 5er-Reihe)
    write('          ').
schreibeFeld([Kopf|Rest]) :-   % besetztes Feld
    kopfsymbol(Kopf,Symb),
    write(Symb),      % der Kopf wird als Großbuchstabe ausgegeben, s.u.
    concat_atom(Rest,Gefangene),
    write(Gefangene), % alle Steine unter dem Kopf
    atom_length(Gefangene,Len),
    Leer is 8 - Len,
    fuellen(Leer,Fueller),
    write(Fueller),   % Leerzeichen für alle Pos. < 9
    write(' ').       % Abgrenzung zum Nachbarfeld

% Umwandlung in Großbuchstaben per Fakten
kopfsymbol(w,'W').
kopfsymbol(s,'S').
kopfsymbol(g,'G').
kopfsymbol(r,'R').

% Leerzeichen zum Auffüllen in gleicher Weise
fuellen(1,' ').
fuellen(2,'  ').
fuellen(3,'   ').
fuellen(4,'    ').
fuellen(5,'     ').
fuellen(6,'      ').
fuellen(7,'       ').
fuellen(8,'        ').


