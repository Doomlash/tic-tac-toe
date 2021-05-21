import React from 'react';

class Clue extends React.Component {
    render() {
        const isSolved = this.props.isSolved;
        const clue = this.props.clue;
        return (
            <div className={"clue"} style={{background: isSolved ? 'green' : 'lightgray'}}>
                {clue.map((num, i) =>
                    <div key={i}>
                        {num}
                    </div>
                )}
            </div>
        );
    }
}

export default Clue;