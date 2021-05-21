:- module(proylcc,
	[
		put/8
	]).

:-use_module(library(lists)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%
put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, 1, 1):-
    putAux(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla),
    isRowCorrect(RowN,PistasFilas,NewGrilla),
    isColumnCorrect(ColN,PistasColumnas,NewGrilla).

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, 1, 0):-
    putAux(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla),
    isRowCorrect(RowN,PistasFilas,NewGrilla).

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, 0, 1):-
    putAux(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla),
    isColumnCorrect(ColN,PistasColumnas,NewGrilla).

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, 0, 0):-
    putAux(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla).

putAux(Contenido, [RowN, ColN], _PistasFilas, _PistasColumnas, Grilla, NewGrilla):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.

	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.

	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)).


getPos(0,[X|_],X).
getPos(N,[_|XL],X):-
    N > 0,
    NS is N - 1,
    getPos(NS,XL,X).


invertirAux([],L,L).
invertirAux([X|RL],LAux,LI):-
    invertirAux(RL,[X|LAux],LI).

invertirLista(Lista,ListaInvertida):-
    invertirAux(Lista,[],ListaInvertida).

countSequence(0,NewFila,NewFila).
countSequence(Pista,["#"|RFila],NewFila):-
    Pista > 0,
    PistaS is Pista - 1,
    countSequence(PistaS,RFila,NewFila).

countSquares([],[]).
countSquares([],["X",RCeldas]):-
    countSquares([],RCeldas).
countSquares([],["_",RCeldas]):-
    countSquares([],RCeldas).
countSquares(Pistas,["X"|RCeldas]):-
    countSquares(Pistas,RCeldas).
countSquares(Pistas,["_"|RCeldas]):-
    countSquares(Pistas,RCeldas).
countSquares([Pista|RPistas],["#"|RCeldas]):-
    countSequence(Pista,["#"|RCeldas],NewFila),
    countSquares(RPistas,NewFila).

isRowCorrect(RowN,PistasFilas,Grilla):-
    %obtengo la fila de la grilla y las pistas para esa fila
    getPos(RowN,PistasFilas,PistasN),
    getPos(RowN,Grilla,Fila),
    countSquares(PistasN,Fila).

getColAux(_,[],Col,Col).
getColAux(ColN,[Fila|RFilas],ColAux,Columna):-
    getPos(ColN,Fila,Celda),
    getColAux(ColN,RFilas,[Celda|ColAux],Columna).

getCol(ColN,Grilla,Columna):-
    getColAux(ColN,Grilla,[],ColInvertida),
    invertirLista(ColInvertida,Columna).

isColumnCorrect(ColN,PistasCol,Grilla):-
    getPos(ColN,PistasCol,PistasN),
    getCol(ColN,Grilla,Columna),
    countSquares(PistasN,Columna).












