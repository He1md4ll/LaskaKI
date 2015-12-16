getKiMove(Color, Move,Depth) :-

        % Brett in Liste verpacken
        board2list(BoardList),

        % mit der Berechnung beginnen
        time(abSearch(BoardList, Color, Color, true, Depth, -100000, 100000, Move, _)),

        % Cut, damit keine weiteren Ausgaben erfolgen
        !.

moveKi(Color,Depth) :-
        % Zug berechnen
        getKiMove(Color, Move, Depth),

        (
        % Zug gefunden?
        \+ var(Move)
        ->

        (
        % Sprungliste?
        is_list(Move),
        % Sprung ausfuehren
        jumplist(Move)
        ;
        % Zug durchfuehren
        move(Move)
        ),

        % Brett ausgeben
        schreibeBrett,

        % Zug ausgeben
        nl, write(Move), nl, nl

        ;

        nl, write('Leider kein Zug mehr moeglich!'), nl, nl

        ), !.

% Kurzbefehle
mbk(Depth) :-
        moveKi(s,Depth), !.
mwk(Depth) :-
        moveKi(w,Depth), !.

abSearch(Board, MyColor, CurrentColor, First, Depth, Alpha, Beta, Move, Rating) :-

        % alle moeglichen Zuege fuer Spieler berechnen
        getMoves(Board, CurrentColor, StepList, JumpList),

        % erster Zug und nur ein Sprung?
        (
        First == true, length(JumpList, 1)
        ->
        % einzigen Sprung zurueckgeben
        member(Move, JumpList),
        % imaginaeres Rating setzen
        Rating = 0

        ;

        (

        % keine Zuege mehr moeglich, deswegen absolut miserable Wertung
        ( StepList == [], JumpList == [] ),
        Rating = -10000

        ;

        % Suchtiefe erreicht und letzter Zug eigener gewesen?
        ( Depth =< 0, CurrentColor \== MyColor ),
        % Bewertung durchführen, da Suchtiefe erreicht
        getBoardValue(Board, Board, CurrentColor, Rating)

        ;

        % Suchtiefe verringern
        NewDepth is Depth - 1,

        % Vorzeichen wechseln und AlphaBeta drehen wegen NegaMax
        NegaBeta is Alpha * -1,
        NegaAlpha is Beta * -1,

        % IF : Spruenge vorhanden?
        (
        StepList == []
        ->
        % THEN : Spruenge verarbeiten
        jumpIt(JumpList, Board, MyColor, CurrentColor, NewDepth, NegaAlpha, NegaBeta, null, Move, Rating)
        ;
        % ELSE : Schritte verarbeiten
        moveIt(StepList, Board, MyColor, CurrentColor, NewDepth, NegaAlpha, NegaBeta, null, Move, Rating)
        )
        % ENDIF

        )

        ).

moveIt([Coordinates|Tail], Board, MyColor, CurrentColor, Depth, Alpha, Beta, MoveStorage, Move, Rating) :-

        % Zug virtuell druchfuehren
        vmove(Board, Coordinates, NewBoard),

        % Farbe wechseln
        followColor(CurrentColor, NextColor),


        % rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
        abSearch(NewBoard, MyColor, NextColor, false, Depth, Alpha, Beta, _, ThisRating),

        % Vorzeichen vom Rating drehen
        NegaThisRating is ThisRating * -1,

        % Alpha-Beta-Auswertung
        (
        NegaThisRating >= Beta,
        Rating = NegaThisRating,
        Move = Coordinates
        ;
        NegaThisRating =< Alpha,
        moveIt(Tail, Board, MyColor, CurrentColor, Depth, Alpha, Beta, MoveStorage, Move, Rating)
        ;
        moveIt(Tail, Board, MyColor, CurrentColor, Depth, NegaThisRating, Beta, Coordinates, Move, Rating)
        ).
moveIt([], _Board, _MyColor, _CurrentColor, _Depth, Alpha, _Beta, Move, Move, Alpha).


jumpIt([JumpList|Tail], Board, MyColor, CurrentColor, Depth, Alpha, Beta, MoveStorage, Move, Rating) :-

        % Sprung virtuell druchfuehren
        vjumplist(Board, JumpList, NewBoard),

        % Farbe wechseln
        followColor(CurrentColor, NextColor),

        % rekursiver Aufruf mit neuem Board, Farbe und Suchtiefe
        abSearch(NewBoard, MyColor, NextColor, false, Depth, Alpha, Beta, _, ThisRating),

        % Vorzeichen vom Rating drehen
        NegaThisRating is ThisRating * -1,

        % Alpha-Beta-Auswertung
        (
        % --- Folgezoge verwerfen ---
        % kein besserer Zug moeglich
        NegaThisRating >= Beta,
        Rating = NegaThisRating,
        Move = JumpList
        ;
        % --- aktuellen Zug verwerfen ---
        % diese Zug war nicht besser - daher verwerfen
        NegaThisRating =< Alpha,
        jumpIt(Tail, Board, MyColor, CurrentColor, Depth, Alpha, Beta, MoveStorage, Move, Rating)
        ;
        % --- regulaere Vergleichsanalyse ---
        jumpIt(Tail, Board, MyColor, CurrentColor, Depth, NegaThisRating, Beta, JumpList, Move, Rating)
        ).
jumpIt([], _Board, _MyColor, _CurrentColor, _Depth, Alpha, _Beta, Move, Move, Alpha).