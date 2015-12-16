% Jeden Spieler wird entsprechend seiner Farbe bewertet
% eigener Soldat   =  +30 Punkte
% fremder Soldat   =  -30 Punkte
% eigener Offizier = +100 Punkte
% fremder Offizier = -100 Punkte
% jede Zugmoeglichkeit einer eigenen Figur gibt +5
% jede Zugmoeglichkeit einer fremden Figur gibt -5
getBoardValue([[Coordinates,[HeadToken|_]]|BoardTail],Board,MyColor,Result) :-

        % reukursiver Aufruf
        getBoardValue(BoardTail, Board, MyColor, OtherResult),

        (
        % Leerfeld
        HeadToken = l,
        TokenResult is 0,
        Neighbours = []
        ;
        % Offizier
        ( HeadToken = g ; HeadToken = r ),
        TokenResult is 100,
        findall((ColumnNeighbour,RowNeighbour),neighbour(Coordinates,(ColumnNeighbour,RowNeighbour),_,_),Neighbours)
        ;
        % Soldat
        TokenResult is 30,
        findall((ColumnNeighbour,RowNeighbour),neighbour(Coordinates,(ColumnNeighbour,RowNeighbour),HeadToken,_),Neighbours)
        ),

        % Bewegungsfreiheit fuer Figur bewerten
        addTokenFreedomValue(Neighbours, Board, TokenResult, TokenFreedomResult),

        (
        % Gegner?
        enemy(MyColor, HeadToken)
        ->
        % Gegner! -> Werte subtrahieren
        Result is OtherResult - TokenFreedomResult
        ;
        % Freund! -> Werte addieren
        Result is OtherResult + TokenFreedomResult
        ),!.
getBoardValue([],_Board,_MyColor,0).

addTokenFreedomValue([Coordinates|Tail], Board, ResultIn, ResultOut) :-

        % rekursiver Aufruf
        addTokenFreedomValue(Tail, Board, ResultIn, ResultOther),

        % Feld leer?
        (
        member([Coordinates,[l]], Board)
        ->
        ResultOut is ResultOther + 5
        ;
        ResultOut is ResultOther
        ).
addTokenFreedomValue([], _Board, Result, Result).