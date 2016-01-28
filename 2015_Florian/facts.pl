:- dynamic
        possibleMove/3.        
:- dynamic
        possibleJump/4.        
:- dynamic
        currentColor/1.
:- dynamic
        aiColor/1.
:- dynamic
        bestRating/2.
:- dynamic
                aiCalculationTime/1.
:- dynamic
                distanceCounter/1.      
:- dynamic
                debugCounter/1.
                
% Values for evaluation of rating                       
:- dynamic
                soldierValue/1. 
:- dynamic
                generalValue/1.
:- dynamic
                jailedSoldierValue/1.
:- dynamic
                jailedJailedSoldierValue/1.
:- dynamic
                moveValue/1.
:- dynamic
                jumpValue/1.    
:- dynamic
                distanceValue/1.                                                                                                                
                
debugCounter(0).

distanceCounter(0).                                                                                                
        
aiCalculationTime(0).        

currentColor(black).
currentColor(white).

uiNameColor(white, w).
uiNameColor(black, s).

relatedColor(white, green).
relatedColor(black, red).
relatedColor(red, black).
relatedColor(green, white).

opponent(white,black).
opponent(white,red).
opponent(black,white).
opponent(black,green).
opponent(green,black).
opponent(green,red).
opponent(red,white).
opponent(red,green).

enemy(white, black).
enemy(black, white).

degrade(green,white).
degrade(red,black).
degrade(X,X).     % degradiere nicht

% Felder, auf denen gewöhnliche Steine befördert werden
promote(a4,black,red).
promote(a6,black,red).
promote(g4,white,green).
promote(g6,white,green).
promote(_,X,X).    % befördere nicht

% Possible moves for white (from -- to)
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

move(Field,TargetField,white):-
     move(Field,TargetField).

move(Field,TargetField,black):-
     move(TargetField, Field).
     
move(Field,TargetField,green):-
     move(Field,TargetField, white).   
  
move(Field,TargetField,green):-
     move(Field,TargetField, black). 
 
move(Field,TargetField,red):-
     move(Field,TargetField, white).   
  
move(Field,TargetField,red):-
     move(Field,TargetField, black).             

% Possible jumps for white (from -- over -- to)
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

jump(Field, OverField, TargetField,white):-
     jump(Field, OverField,TargetField).

jump(Field, OverField, TargetField,black):-
     jump(TargetField, OverField, Field).
     
jump(Field, OverField, TargetField,green):-
     jump(Field, OverField, TargetField,white).
     
jump(Field, OverField, TargetField,green):-
     jump(Field, OverField, TargetField,black).     
     
jump(Field, OverField, TargetField,red):-
     jump(Field, OverField, TargetField,white).
  
jump(Field, OverField, TargetField,red):-
     jump(Field, OverField, TargetField,black).

distance(X,X,0).
distance(Field1,Field2,Distance):-
     sub_atom(Field1,0,1,_,Row1),
     sub_atom(Field2,0,1,_,Row2),
     sub_atom(Field1,1,1,_,Col1),
     sub_atom(Field2,1,1,_,Col2),
     getDistance(Row1,Row2,DistanceRow),
     getDistance(Col1,Col2,DistanceCol),
     Distance is DistanceRow + DistanceCol /2,!.

getDistance(X,X,0).
getDistance(F1,F2,Distance):-
     distanceBetween(F1,F2,Distance),!.
     
getDistance(F1,F2,Distance):-
     distanceBetween(F2,F1,Distance),!.

distanceBetween(a,b,1).
distanceBetween(a,c,2).
distanceBetween(a,d,3).
distanceBetween(a,e,4).
distanceBetween(a,f,5).
distanceBetween(a,g,6).

distanceBetween(b,c,1).
distanceBetween(b,d,2).
distanceBetween(b,e,3).
distanceBetween(b,f,4).
distanceBetween(b,g,5).

distanceBetween(c,d,1).
distanceBetween(c,e,2).
distanceBetween(c,f,3).
distanceBetween(c,g,4).

distanceBetween(d,e,1).
distanceBetween(d,f,2).
distanceBetween(d,g,3).

distanceBetween(e,f,1).
distanceBetween(e,g,2).

distanceBetween(f,g,1).

distanceBetween(A,B,Distance):-
 atomTonumber(A,AN),
 atomTonumber(B,BN),
 AN < BN,
 Distance = BN-AN  ,!.

distanceBetween(A,B,Distance):-
 atomTonumber(A,AN),
 atomTonumber(B,BN),
 AN > BN,
 Distance = AN-BN  ,!.
 
 
atomTonumber('1',1).
atomTonumber('2',2).
atomTonumber('3',3).
atomTonumber('4',4).
atomTonumber('5',5).
atomTonumber('6',6).
atomTonumber('7',7).
atomTonumber('8',8).
atomTonumber('9',9).

 




