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