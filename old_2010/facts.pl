% Faktensammlung

% Fakten zur Repraesentation benutzter Felder in der
% Ausgangsstellung: board(Spalte, Zeile, Farbe)
:- dynamic
        board/3.
board(1,a,w).
board(3,a,w).
board(5,a,w).
board(7,a,w).
board(2,b,w).
board(4,b,w).
board(6,b,w).
board(1,c,w).
board(3,c,w).
board(5,c,w).
board(7,c,w).
board(2,d,l). % leer
board(4,d,l). % leer
board(6,d,l). % leer
board(1,e,s).
board(3,e,s).
board(5,e,s).
board(7,e,s).
board(2,f,s).
board(4,f,s).
board(6,f,s).
board(1,g,s).
board(3,g,s).
board(5,g,s).
board(7,g,s).

% Umwandlung der Farben in Grossbuchstaben per Fakten
kopfsymbol(w,'W').
kopfsymbol(s,'S').
kopfsymbol(g,'G').
kopfsymbol(r,'R').

% Leerzeichen zum Auffuellen in gleicher Weise
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

% Buchstabe in Zahl Konvertierungsfakten
conv(a,1).
conv(b,2).
conv(c,3).
conv(d,4).
conv(e,5).
conv(f,6).
conv(g,7).

% Wertigkeit fuer eine Figur, wenn sie Zugmoeglichkeiten besitzt
value_free(s,2).
value_free(w,2).
value_free(r,5).
value_free(g,5).

% Wertigkeit fuer eine Figur, wenn sie blockiert ist / keine Zugmoeglichkeit bestitzt
value_blocked(s,1).
value_blocked(w,1).
value_blocked(r,4).
value_blocked(g,4).

% Farb-Konvertierung der Soldaten zu Offizieren
officer(s,r).
officer(w,g).

% Folge-Farbe
followColor(w,s).
followColor(s,w).

% Gegner-Mapping
enemy(s,w).
enemy(s,g).
enemy(r,w).
enemy(r,g).
enemy(w,s).
enemy(w,r).
enemy(g,s).
enemy(g,r).

% Startfeld(Spalte, Zeile), Zielfeld(Spalte, Zeile), Farbe(Weiss=w, Schwarz=s), Richtung(Westen=w, Osten=o)
neighbour((1,a),(2,b),w,o).
neighbour((3,a),(2,b),w,w).
neighbour((3,a),(4,b),w,o).
neighbour((5,a),(4,b),w,w).
neighbour((5,a),(6,b),w,o).
neighbour((7,a),(6,b),w,w).
neighbour((2,b),(1,a),s,w).
neighbour((2,b),(3,a),s,o).
neighbour((2,b),(1,c),w,w).
neighbour((2,b),(3,c),w,o).
neighbour((4,b),(3,a),s,w).
neighbour((4,b),(5,a),s,o).
neighbour((4,b),(3,c),w,w).
neighbour((4,b),(5,c),w,o).
neighbour((6,b),(5,a),s,w).
neighbour((6,b),(7,a),s,o).
neighbour((6,b),(5,c),w,w).
neighbour((6,b),(7,c),w,o).
neighbour((1,c),(2,b),s,o).
neighbour((1,c),(2,d),w,o).
neighbour((3,c),(2,b),s,w).
neighbour((3,c),(4,b),s,o).
neighbour((3,c),(2,d),w,w).
neighbour((3,c),(4,d),w,o).
neighbour((5,c),(4,b),s,w).
neighbour((5,c),(6,b),s,o).
neighbour((5,c),(4,d),w,w).
neighbour((5,c),(6,d),w,o).
neighbour((7,c),(6,b),s,w).
neighbour((7,c),(6,d),w,w).
neighbour((2,d),(1,c),s,w).
neighbour((2,d),(3,c),s,o).
neighbour((2,d),(1,e),w,w).
neighbour((2,d),(3,e),w,o).
neighbour((4,d),(3,c),s,w).
neighbour((4,d),(5,c),s,o).
neighbour((4,d),(3,e),w,w).
neighbour((4,d),(5,e),w,o).
neighbour((6,d),(5,c),s,w).
neighbour((6,d),(7,c),s,o).
neighbour((6,d),(5,e),w,w).
neighbour((6,d),(7,e),w,o).
neighbour((1,e),(2,d),s,o).
neighbour((1,e),(2,f),w,o).
neighbour((3,e),(2,d),s,w).
neighbour((3,e),(4,d),s,o).
neighbour((3,e),(2,f),w,w).
neighbour((3,e),(4,f),w,o).
neighbour((5,e),(4,d),s,w).
neighbour((5,e),(6,d),s,o).
neighbour((5,e),(4,f),w,w).
neighbour((5,e),(6,f),w,o).
neighbour((7,e),(6,d),s,w).
neighbour((7,e),(6,f),w,w).
neighbour((2,f),(1,e),s,w).
neighbour((2,f),(3,e),s,o).
neighbour((2,f),(1,g),w,w).
neighbour((2,f),(3,g),w,o).
neighbour((4,f),(3,e),s,w).
neighbour((4,f),(5,e),s,o).
neighbour((4,f),(3,g),w,w).
neighbour((4,f),(5,g),w,o).
neighbour((6,f),(5,e),s,w).
neighbour((6,f),(7,e),s,o).
neighbour((6,f),(5,g),w,w).
neighbour((6,f),(7,g),w,o).
neighbour((1,g),(2,f),s,o).
neighbour((3,g),(2,f),s,w).
neighbour((3,g),(4,f),s,o).
neighbour((5,g),(4,f),s,w).
neighbour((5,g),(6,f),s,o).
neighbour((7,g),(6,f),s,w).