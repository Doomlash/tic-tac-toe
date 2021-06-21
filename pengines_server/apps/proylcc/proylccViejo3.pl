:- module(proylcc,
	[
		put/8,
	        resolverGrilla/3
	]).


:-use_module(library(lists)).
:-use_module(library(dif)).




replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

putAux(Contenido,[RowN,ColN],Grilla,NewGrilla):-
	replace(Row, RowN, NewRow, Grilla, NewGrilla),
    replace(_Cell, ColN, Contenido, Row, NewRow).

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, RowSat, ColSat):-   
    % NewGrilla es el resultado de reemplazar la fila Row en la posici�n RowN de Grilla
	% (RowN-�sima fila de Grilla), por una fila nueva NewRow.

	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posici�n ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posici�n ColN de Row por Conenido.

	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),
        isRowCorrect(RowN,PistasFilas,NewGrilla,RowSat),
        isColumnCorrect(ColN,PistasColumnas,NewGrilla,ColSat).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%getPos(?Pos,+List,?Element)

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




countSequence(0,[X|XL],[X|XL]):-
    X\=="#".

countSequence(0,[],[]).

countSequence(Pista,[X|RFila],NewFila):-
    X == "#",
    Pista > 0,
    PistaS is Pista - 1,
    countSequence(PistaS,RFila,NewFila).



countSquares([],[]).
countSquares([],[C|RCeldas]):-
    C\=="#",
    countSquares([],RCeldas).
countSquares([0],RCeldas):-
    countSquares([],RCeldas).
countSquares(Pistas,[C|RCeldas]):-
    C\=="#",
    countSquares(Pistas,RCeldas).
countSquares([Pista|RPistas],[X|RCeldas]):-
    X == "#",
    countSequence(Pista,[X|RCeldas],NewFila),
    countSquares(RPistas,NewFila).

isRowCorrect(RowN,PistasFilas,Grilla,RowSat):-
    %obtengo la fila de la grilla y las pistas para esa fila
    getPos(RowN,PistasFilas,PistasN),
    getPos(RowN,Grilla,Fila),
    (countSquares(PistasN,Fila),
    RowSat is 1
        ;
    RowSat is 0
    ).

getColAux(_,[],Col,Col).
getColAux(ColN,[Fila|RFilas],ColAux,Columna):-
    getPos(ColN,Fila,Celda),
    getColAux(ColN,RFilas,[Celda|ColAux],Columna).

getCol(ColN,Grilla,Columna):-
    getColAux(ColN,Grilla,[],ColInvertida),
    invertirLista(ColInvertida,Columna).

isColumnCorrect(ColN,PistasCol,Grilla,ColSat):-
    getPos(ColN,PistasCol,PistasN),
    getCol(ColN,Grilla,Columna),
    (countSquares(PistasN,Columna),
    ColSat is 1
        ;
    ColSat is 0
    ).

generarFila(0,[]).
generarFila(CantCol,[_|F]):-
	CantCol > 0,
    CantCol1 is CantCol - 1,
    generarFila(CantCol1,F).

generarGrilla(0,_,[]).
generarGrilla(CantFil,CantCol,[Fila|G]):-
    CantFil > 0,
    CantFil1 is CantFil - 1,
    generarGrilla(CantFil1,CantCol,G),
    generarFila(CantCol,Fila).

cantidadColumnas([A|_],Cant):-
    length(A,Cant).

cantidadFilas(Grilla,Cant):-
    length(Grilla,Cant).

listaintersectada([],[],[]).
listaintersectada([A|L1],[B|L2],L3):- not(A==B), listaintersectada(L1,L2,Aux), append([_],Aux,L3).
listaintersectada([A|L1],[A|L2],L3):- listaintersectada(L1,L2,Aux), append([A],Aux,L3).

jugadaContenida([],[]).
jugadaContenida([A|J],[B|L]):-
    A==B,
    jugadaContenida(J,L).
jugadaContenida([_|J],[B|L]):-
    not(B=="#"),
    not(B=="X"),
    jugadaContenida(J,L).

jugadaCauta([A],A).
jugadaCauta([A|L],J):-
    jugadaCauta(L,Aux),
    listaintersectada(Aux,A,J).

generarPosibleJugada(0,[]).
generarPosibleJugada(Longitud,["#"|J]):-
    Longitud>0,
    Longitud1 is Longitud - 1,
    generarPosibleJugada(Longitud1,J).
generarPosibleJugada(Longitud,["X"|J]):-
    Longitud>0,
    Longitud1 is Longitud - 1,
    generarPosibleJugada(Longitud1,J).

generarJugada(Pistas,Linea,Jugada):-
    length(Linea,L),
    findall(X,(generarPosibleJugada(L,X),countSquares(Pistas,X),jugadaContenida(X,Linea)),ListaJugadas),
    not(ListaJugadas==[]),
    jugadaCauta(ListaJugadas,Jugada).
generarJugada(_,Linea,Linea).


jugarColumna(ColN,Jugada,Grilla,NewGrilla):-
     jugarColumnaAux(0,ColN,Jugada,Grilla,NewGrilla).

jugarColumnaAux(RowN,_,_,Grilla,NewGrilla):-
     cantidadFilas(Grilla,RowN),
     NewGrilla=Grilla.
jugarColumnaAux(RowN,ColN,Jugada,Grilla,NewGrilla):-
     getPos(RowN,Jugada,A),
     not(A=="#"),
     not(A=="X"),
     cantidadFilas(Grilla,Cant),
     RowN < Cant,
     RowN1 is RowN + 1,
     jugarColumnaAux(RowN1,ColN,Jugada,Grilla,NewGrilla).
jugarColumnaAux(RowN,ColN,Jugada,Grilla,NewGrilla):-
     getPos(RowN,Jugada,A),
     cantidadFilas(Grilla,Cant),
     RowN < Cant,
     putAux(A,[RowN,ColN],Grilla,Aux),
     RowN1 is RowN + 1,
     jugarColumnaAux(RowN1,ColN,Jugada,Aux,NewGrilla).



jugarFila(RowN,Jugada,Grilla,NewGrilla):-
     jugarFilaAux(RowN,0,Jugada,Grilla,NewGrilla).

jugarFilaAux(_,ColN,_,Grilla,NewGrilla):-
     cantidadColumnas(Grilla,ColN),
     NewGrilla=Grilla.
jugarFilaAux(RowN,ColN,Jugada,Grilla,NewGrilla):-
     getPos(ColN,Jugada,A),
     not(A=="#"),
     not(A=="X"),
     cantidadColumnas(Grilla,Cant),
     ColN < Cant,
     ColN1 is ColN + 1,
     jugarFilaAux(RowN,ColN1,Jugada,Grilla,NewGrilla).
jugarFilaAux(RowN,ColN,Jugada,Grilla,NewGrilla):-
     getPos(ColN,Jugada,A),
     cantidadColumnas(Grilla,Cant),
     ColN < Cant,
     putAux(A,[RowN,ColN],Grilla,Aux),
     ColN1 is ColN + 1,
     jugarFilaAux(RowN,ColN1,Jugada,Aux,NewGrilla).



resolverGrilla(PistasFilas,PistasColumnas,Grilla):-
     length(PistasFilas,CantFilas),
     length(PistasColumnas,CantColumnas),
     generarGrilla(CantFilas,CantColumnas,GrillaVacia),
     resolverGrillaAux(PistasFilas,PistasColumnas,0,GrillaVacia,Grilla).


resolverGrillaAux(_,_,1,Grilla,NewGrilla):-
     NewGrilla=Grilla.
resolverGrillaAux(PistasFilas,PistasColumnas,Resuelta,Grilla,NewGrilla):-
     not(Resuelta is 1),
     resolverFilas(0,PistasFilas,FilasResueltas,Grilla,Aux1),
     resolverColumnas(0,PistasColumnas,ColumnasResueltas,Aux1,Aux2),
     Resuelta1 is FilasResueltas*ColumnasResueltas,
     resolverGrillaAux(PistasFilas,PistasColumnas,Resuelta1,Aux2,NewGrilla).             

resolverFilas(RowN,_,Resuelta,Grilla,NewGrilla):-
     cantidadFilas(Grilla,RowN),
     NewGrilla=Grilla,
     Resuelta is 1.

resolverFilas(RowN,PistasFilas,Resuelta,Grilla,NewGrilla):-
     cantidadFilas(Grilla,Cant),
     RowN < Cant,
     getPos(RowN,PistasFilas,PistasN),
     getPos(RowN,Grilla,Fila),
     generarJugada(PistasN,Fila,Jugada),
     jugarFila(RowN,Jugada,Grilla,Aux),
     getPos(RowN,Grilla,NewFila),
     RowN1 is RowN + 1,
     resolverFilas(RowN1,PistasFilas,Resuelta1,Aux,NewGrilla),
     (countSquares(PistasN,NewFila),
      Resuelta is 1 * Resuelta1
          ;
      Resuelta is 0).
     
resolverColumnas(ColN,_,Resuelta,Grilla,NewGrilla):-
     cantidadColumnas(Grilla,ColN),
     NewGrilla=Grilla,
     Resuelta is 1.

resolverColumnas(ColN,PistasColumnas,Resuelta,Grilla,NewGrilla):-
     cantidadColumnas(Grilla,Cant),
     ColN < Cant,
     getPos(ColN,PistasColumnas,PistasN),
     getCol(ColN,Grilla,Columna),
     generarJugada(PistasN,Columna,Jugada),
     jugarColumna(ColN,Jugada,Grilla,Aux),
     getCol(ColN,Grilla,NewCol),
     ColN1 is ColN + 1,
     resolverColumnas(ColN1,PistasColumnas,Resuelta1,Aux,NewGrilla),
     (countSquares(PistasN,NewCol),
      Resuelta is 1 * Resuelta1
          ;
      Resuelta is 0).