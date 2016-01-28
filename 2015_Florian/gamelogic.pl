fuckt(-1).
fuckt(-2).
fuckt(-3).
fuckt(-4).
fuckt(-5).

testA(Best) :-
(
	fuckt(V),
	(
		V >= 10000 
	->
		(
			V > -10000 
		->
			Best = V
		;
			true
		)
	;	
		(
			V > -10000 
		->
			Best = V
		;
			true
		)
		,fail
	)
;
	Best = 3	
).

testB :-
	checkAB(12,-10000,10000,_,[]);
	checkAB(18,12,10000,_,[]).
	