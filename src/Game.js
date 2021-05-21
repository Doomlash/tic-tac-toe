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
      rowClues: null,
      colClues: null,
      waiting: false
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
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
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
        });
      }
    });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }
    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[[3], [1,2], [4], [5], [5]], [[2], [5], [1,3], [5], [4]],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const squaresS = JSON.stringify(this.state.grid)//.replaceAll('"_"', "_"); // Remove quotes for variables.
    const rowClues = JSON.stringify(this.state.rowClues);
    const colClues = JSON.stringify(this.state.colClues);
    const queryS = 'put("#", [' + i + ',' + j + '], ' + rowClues + ', ' + colClues + ', ' + squaresS + ', GrillaRes, FilaSat, ColSat)';
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
          waiting: false
        });
      } else {
        this.setState({
          waiting: false
        });
      }
    });
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    const statusText = 'Keep playing!';
    return (
      <div className="game">
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
      </div>

    );
  }
}

export default Game;
