getReduceBoard([[Coordinates, [Board_Color|Color_Rest]]|Board_Tail], Color, NewBoard):-
        getReduceBoard(Board_Tail,Color,Board),
        officer(Color,Officer_Color),
        (               
                ((Board_Color == Color);(Board_Color == Officer_Color))
                ->
                (append(Board,[[Coordinates,[Board_Color|Color_Rest]]],NewBoard))
                ;
                (NewBoard = Board)
        ).
getReduceBoard([],_,[]).