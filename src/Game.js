import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';


class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      currentPut: "#",
      solvedRowCol: null,
      grid: null,
      currentGrid: null,
      solvedGrid: null,
      solvedGridShow: false,
      solveNext: false,
      rowClues: null,
      colClues: null,
      win: false,
      statusText:'Keep playing!',
      solvedGridButton: 'Show Solved Grid',
      waiting: false
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.changePut = this.changePut.bind(this);
    this.showSolution = this.showSolution.bind(this);
    this.solveCell = this.solveCell.bind(this);
    this.handlePengineSolve = this.handlePengineSolve.bind(this)
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = 'init(PistasFilas, PistasColumns, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        const aux = [Array(response['Grilla'].length).fill(0),Array(response['Grilla'][0].length).fill(0)];
        this.setState({
          grid: response['Grilla'],
          solvedRowCol:aux,
          waiting: true,
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
        });
        this.handlePengineSolve();
      }
    });
   
  }

  handlePengineSolve(){
      const rowClues = JSON.stringify(this.state.rowClues);
      const colClues = JSON.stringify(this.state.colClues);
      const queryS = 'resolverGrilla('+ rowClues +', '+ colClues +', GrillaRes)';
      this.pengine.query(queryS, (success, response) => {
        if (success) {
          this.setState({
            solvedGrid: response['GrillaRes'],
            waiting: false,
          });
        } else{
          this.setState({
            waiting: false,
          });
        }
      });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting||this.state.win||this.state.solvedGridShow) {
      return;
    }
    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[[3], [1,2], [4], [5], [5]], [[2], [5], [1,3], [5], [4]],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    let auxPut = this.state.currentPut;
    if(this.state.solveNext){
      auxPut = this.state.solvedGrid[i][j]
    }
    const currentPut = auxPut;
    if (!(this.state.solveNext && currentPut === this.state.grid[i][j])){
      const queryS = 'put("'+ currentPut +'", [' + i + ',' + j + '], ' + rowClues + ', ' + colClues + ', ' + squaresS + ', GrillaRes, FilaSat, ColSat)';
      this.setState({
        waiting: true
      });
      this.pengine.query(queryS, (success, response) => {
        if (success) {
          let aux = this.state.solvedRowCol;
          aux[0][i] = response['FilaSat'];
          aux[1][j] = response['ColSat'];
          this.setState({
            grid: response['GrillaRes'],
            solvedRowCol: aux,
            waiting: false,
            solveNext: false
          });
          let win = true;
          let rows = this.state.solvedRowCol[0];
          let columns = this.state.solvedRowCol[1];
          for (let x in rows) {
            if(rows[x]===0){
              win = false;
              break;
            }
          };
          if(win){
            for (let x in columns){
              if(columns[x]===0){
                win=false;
                break;
              }
            }
          }
          if(win){
            let grilla = this.state.grid
            for (let x in rows){
              for (let y in columns){
                if(grilla[x][y]=== '_'){
                  grilla[x][y]="X"
                }
              }
            }
            this.setState({
              win:true,
              statusText:'You Win!!!',
              grid:grilla
            });
          }
          
        } else {
          this.setState({
            waiting: false
          });
        }
      });}
    else{
      this.setState({
        solveNext: false
      });
    }

  }

  changePut(){
    let aux = this.state.currentPut;
    if (aux === "#"){
      aux = "X";
    }
    else{
      aux = "#";
    }
    this.setState({
      currentPut:aux
    });
  }

  showSolution(){
    if(this.state.solvedGridShow){
      this.setState({
        grid:this.state.currentGrid,
        solvedGridShow: false,
        solvedGridButton:'Show Solved Grid'
      })
    }
    else{
      let auxGrid = this.state.grid;
      this.setState({
        grid:this.state.solvedGrid,
        currentGrid:auxGrid,
        solvedGridShow: true,
        solvedGridButton:'Hide Solved Grid'
    });}
  }

  solveCell(){
    this.setState({
      solveNext:true
    })
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    const statusText = this.state.statusText;
    return (
      <div className="game">
        <div>
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          solvedRowCol={this.state.solvedRowCol}
          onClick={(i, j) => this.handleClick(i,j)}
        />
        <div className="gameInfo">
          {statusText}
        </div>
        <div>
          <button onClick={this.changePut}>{this.state.currentPut}</button>
        </div>
        </div>
        <div>
          <button onClick={this.showSolution}>{this.state.solvedGridButton}</button>
          <button onClick={this.solveCell} disabled={this.state.solveNext}>Solve Cell</button>
        </div>
      </div>
    );
  }
}

export default Game;
