%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beispiel einer Ausgaberoutine für das Laska-Spiel
%
% U. Meyer, Okt. 2008
%
%
% Angenommen wird ein Spiel auf einem Schachbrett,
% gespielt wird auf den Feldern einer Farbe, die
% Felder der anderen Farbe gehören nicht zum Spielfeld.
%
% Demonstriert werden auch verschiedene Programmiertechniken
% in Prolog.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fakten zur Repräsentation benutzter Felder in der
% Ausgangsstellung: brett(Zeile,Spalte,Farbe)


% Das Board wurde soweit übernommen. Lediglich der Farbwechsel
% wurde hier entfernt.

:- dynamic
	brett/2.
brett(a1,[w]).
brett(a3,[w]).
brett(a5,[w]).
brett(a7,[w]).
brett(b2,[w]).
brett(b4,[w]).
brett(b6,[w]).
brett(c1,[w]).
brett(c3,[w]).
brett(c5,[w]).
brett(c7,[w]).
brett(d2,[]). % diese drei Felder
brett(d4,[]). % (12, 13 und 14)
brett(d6,[]). % sind anfangs unbesetzt
brett(e1,[s]).
brett(e3,[s]).
brett(e5,[s]).
brett(e7,[s]).
brett(f2,[s]).
brett(f4,[s]).
brett(f6,[s]).
brett(g1,[s]).
brett(g3,[s]).
brett(g5,[s]).
brett(g7,[s]).
% Benachbarte Felder
nachbarn(a1,b2,c3).
nachbarn(a3,b2,c1).
nachbarn(a3,b4,c5).
nachbarn(a5,b4,c3).
nachbarn(a5,b6,c7).
nachbarn(a7,b6,c5).
nachbarn(b2,c1,x).
nachbarn(b2,c3,d4).
nachbarn(b4,c3,d2).
nachbarn(b4,c5,d6).
nachbarn(b6,c5,d4).
nachbarn(b6,c7,x).
nachbarn(c1,d2,e3).
nachbarn(c3,d2,e1).
nachbarn(c3,d4,e5).
nachbarn(c5,d4,e3).
nachbarn(c5,d6,e7).
nachbarn(c7,d6,e5).
nachbarn(d2,e1,x).
nachbarn(d2,e3,f4).
nachbarn(d4,e3,f2).
nachbarn(d4,e5,f6).
nachbarn(d6,e5,f4).
nachbarn(d6,e7,x).
nachbarn(e1,f2,g3).
nachbarn(e3,f2,g1).
nachbarn(e3,f4,g5).
nachbarn(e5,f4,g3).
nachbarn(e5,f6,g7).
nachbarn(e7,f6,g5).
nachbarn(f2,g1,x).
nachbarn(f2,g3,x).
nachbarn(f4,g3,x).
nachbarn(f4,g5,x).
nachbarn(f6,g5,x).
nachbarn(f6,g7,x).
% Hauptprozedur
schreibeBrett(Farbe) :-
	write('  -|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'),
	nl,
	schreibeZeilen([g,f,e,d,c,b,a],Farbe).
%	retract(fehler(_,_)),
%	asserta(fehler(nein,Farbe)).

% Ausgabe der Zeilen des Spielbretts
schreibeZeilen([],Farbe):- % Fusszeile unter dem Brett
	write('     1           2           3           4           5           6           7'),
	nl,
	write(Farbe),write(' am Zug.'),nl,write('Moegliche Zuege:'),nl.
schreibeZeilen([Zeile|T],Farbe) :- % 3-Felder-Reihen
	member(Zeile,[b,d,f]),
	write(' '),
	upcase_atom(Zeile,Upper),
	write(Upper),
	write(' |'),
	schreibeZellen(Zeile,[x,2,x,4,x,6,x]),
	schreibeZeilen(T,Farbe), !.
schreibeZeilen([Zeile|T],Farbe) :- % 4-Felder-Reihen
	write(' '),
	upcase_atom(Zeile,Upper),
	write(Upper),
	write(' |'),
	schreibeZellen(Zeile,[1,x,3,x,5,x,7]),
	schreibeZeilen(T,Farbe).
	
% Ausgabe der Felder (und horizontalen Trennzeilen)
schreibeZellen(_,[]) :- % Trennzeile
	nl,
	write('  -|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'),
	nl.
schreibeZellen(Zeile,[x|T]) :- % nicht genutztes "Zwischenfeld"
	write('-----------|'), % (auf einem Schachbrett die Felder einer Farbe)
	schreibeZellen(Zeile,T).
schreibeZellen(Zeile,[Spalte|T]) :-	% genutztes Spielfeld
	atom_concat(Zeile,Spalte,Feld),	% Feldbezeichner
	brett(Feld,Stapel),		% was liegt auf dem Feld?
	schreibeFeld(Stapel),		% Säule ausgeben
	schreibeZellen(Zeile,T).
	
schreibeFeld([]) :- % unbesetztes Feld (anfangs sind das 12, 13, 14)
	write('           |').
schreibeFeld([Kopf|Rest]) :-   % besetztes Feld
	kopfsymbol(Kopf,Symb),
	write(Symb),      % der Kopf wird als Großbuchstabe ausgegeben, s.u.
	concat_atom(Rest,Gefangene),
	write(Gefangene), % alle Steine unter dem Kopf
	atom_length(Gefangene,Len),
	Leer is 10 - Len,
	fuellen(Leer,Fueller),
	write(Fueller),   % Leerzeichen für alle Pos. < 11
	write('|').       % Abgrenzung zum Nachbarfeld

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
fuellen(9,'         ').
fuellen(10,'          ').
