import React, { Component } from 'react'

class JsonToTable extends Component {
    constructor(props) {
        super(props)

        this.state = {

        }
    }

    generateRows = () => 
        if (this.props.jsonData.length > 0) {
            var cols = Object.keys(this.props.jsonData[0]), data = this.props.jsonData;
            var rows = data.map(function (item, k) {
                var cells = cols.map(function (colData, j) {
                    return j > 0 ? <td key={j}> {item[colData]} </td> : null;
                });
                return k > 0 && cells !== null && cells !== "" ? <tr key={k}> {cells} </tr> : null;
            });
            return rows;
        } else {
            return [];
        }
    }

    renderTable = () => {
        if (this.props.jsonData.length > 0) {
            let rowComponents = this.generateRows();
            var cols = Object.keys(this.props.jsonData[0]);
            let headers = [];
            cols.map(function (h, i) {
                return i > 0 ? headers.push(<th key={i}>{h}</th>) : null
            });

            return (
                this.props.jsonData.length > 0 ?
                    <div>
                        <br />
                        <table className="table table-bordered">
                            <thead><tr key={'a0'}>{headers}</tr></thead>
                            <tbody>{rowComponents}</tbody>
                        </table>
                    </div> : null
            );
        }
        else {
            return (
                <div className="alert alert-warning pad10 m-top10">No Data Found!</div>
            )
        }
    }

    render() {
        return (
            <div>
                {this.renderTable()}
            </div>
        )
    }
}

export default JsonToTable
