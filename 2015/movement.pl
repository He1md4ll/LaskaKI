%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beispiel der Zugbewegungen-Routinen für UM-L´
%
% U. Meyer, Okt. 2008, Feb. 2015
%
%
% Benötigt board.pl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
:- dynamic
	fehler/2.
fehler(nein,weiss).	% Schwarz beginnt das Spiel, s.u.!!

:- [board].

% Mögliche Züge aus der Sicht von Weiss (von -- nach)
move(a4,b3).
move(a4,b5).
move(a6,b5).
move(a6,b7).
move(b3,c2).
move(b3,c4).
move(b5,c4).
move(b5,c6).
move(b7,c6).
move(b7,c8).
move(c2,d1).
move(c2,d3).
move(c4,d3).
move(c4,d5).
move(c6,d5).
move(c6,d7).
move(c8,d7).
move(c8,d9).
move(d1,e2).
move(d3,e2).
move(d3,e4).
move(d5,e4).
move(d5,e6).
move(d7,e6).
move(d7,e8).
move(d9,e8).
move(e2,f3).
move(e4,f3).
move(e4,f5).
move(e6,f5).
move(e6,f7).
move(e8,f7).
move(f3,g4).
move(f5,g4).
move(f5,g6).
move(f7,g6).

% Mögliche Sprünge aus der Sicht von Weiss (von -- über -- nach)
jump(a4,b3,c2).
jump(a4,b5,c6).
jump(a6,b5,c4).
jump(a6,b7,c8).
jump(b3,c2,d1).
jump(b3,c4,d5).
jump(b5,c4,d3).
jump(b5,c6,d7).
jump(b7,c6,d5).
jump(b7,c8,d9).
jump(c2,d3,e4).
jump(c4,d3,e2).
jump(c4,d5,e6).
jump(c6,d5,e4).
jump(c6,d7,e8).
jump(c8,d7,e6).
jump(d1,e2,f3).
jump(d3,e4,f5).
jump(d5,e4,f3).
jump(d5,e6,f7).
jump(d7,e6,f5).
jump(d9,e8,f7).
jump(e2,f3,g4).
jump(e4,f5,g6).
jump(e6,f5,g4).
jump(e8,f7,g6).

start :-
	retract(fehler(_,_)),
	assertz(fehler(nein,weiss)),
	initBrett,
        dialog.
        
dialog :-
	farbe(Farbe),
	schreibeBrett,
	write(Farbe),
	write(' am Zug  ==> '),
	read(Zugfolge),
	ziehen(Farbe,Zugfolge).
farbe(F) :- fehler(ja,F).
farbe(schwarz) :- fehler(nein,weiss).
farbe(weiss) :- fehler(nein,schwarz).
farbe(F) :- farbe(F).

ziehen(_,halt) :-
        write('Spiel beendet.'),nl,
        halt.
ziehen(_,init) :-
        write('Alles auf Anfang!'),nl,
        start.
ziehen(Farbe,Zug) :-
	atom_length(Zug,4),
	zug(Farbe,Zug),
	retract(fehler(_,_)),asserta(fehler(nein,Farbe)),
	!,fail.
ziehen(Farbe,_) :-
	nl,write('Ungültige Eingabe!'),nl,nl,
	retract(fehler(_,_)),asserta(fehler(ja,Farbe)),
	fail.
zug(Farbe,Zug) :-
	sub_atom(Zug,0,2,_,FeldA),
	sub_atom(Zug,2,2,_,FeldZ),
	FeldA \== FeldZ,
	selbst(Farbe,FeldA,Kopf),  % ist das Ausgangsfeld mit einer eigenen Farbe besetzt?
	brett(FeldZ,[]),           % ist das Zielfeld leer?
	test(Kopf,FeldA,FeldZ),
	!.

selbst(schwarz,Feld,s) :-
	brett(Feld,[s|_]).
selbst(schwarz,Feld,r) :-
	brett(Feld,[r|_]).
selbst(weiss,Feld,w) :-
	brett(Feld,[w|_]).
selbst(weiss,Feld,g) :-
	brett(Feld,[g|_]).

test(s,A,Z) :-
        jump(Z,M,A),
        brett(M,[Oppo|Jailed]),
        opponent(s,Oppo),
        doJump(A,M,Oppo,Jailed,Z).
test(s,A,Z) :-
        move(Z,A),
        doMove(A,Z).
test(w,A,Z) :-
        jump(A,M,Z),
        brett(M,[Oppo|Jailed]),
        opponent(w,Oppo),
        doJump(A,M,Oppo,Jailed,Z).
test(w,A,Z) :-        
        move(A,Z),
        doMove(A,Z).

opponent(w,s).
opponent(w,r).
opponent(s,w).
opponent(s,g).

degradiere(g,w).
degradiere(r,s).
degradiere(X,X).     % degradiere nicht

% Felder, auf denen gewöhnliche Steine befördert werden
promotion(a4,s,r).
promotion(a6,s,r).
promotion(g4,w,g).
promotion(g6,w,g).
promotion(_,X,X).    % befördere nicht

doJump(X,M,O,J,Y) :-
        retract(brett(X,[Kopf|S])),
        assertz(brett(X,[])),
        retract(brett(M,_)),
        assertz(brett(M,J)),
        retract(brett(Y,_)),
        promotion(Y,Kopf,Offz),
        degradiere(O,G),
        append([Offz|S],[G],New),
        assertz(brett(Y,New)).
doMove(X,Y) :-
        retract(brett(X,[Kopf|S])),
        assertz(brett(X,[])),
        retract(brett(Y,_)),
        promotion(Y,Kopf,Offz),
        assertz(brett(Y,[Offz|S])).
        
demo :-
	schreibeBrett(schwarz),write(e3d4),nl,
	selbst(schwarz,e3,KopfS1),
	e3 \== d4,
	testMove(schwarz,KopfS1,e3,d4),
	move(e3,d4),
	schreibeBrett(weiss),write(c5e3),nl,
	selbst(weiss,c5,KopfW),
	c5 \== e3,
	testJump(weiss,KopfW,c5,e3,M1),
	jump(c5,M1,e3),
	schreibeBrett(schwarz),write(f2d4),nl,
	selbst(schwarz,f2,KopfS2),
	f2 \== d4,
	testJump(schwarz,KopfS2,f2,d4,M2),
	jump(f2,M2,d4),
	schreibeBrett(weiss),!.
