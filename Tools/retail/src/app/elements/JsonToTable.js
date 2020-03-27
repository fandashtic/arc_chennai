import React, { Component } from 'react'

class JsonToTable extends Component {
    constructor(props) {
        super(props)

        this.state = {

        }
    }

    generateRows = () => {
        var cols = Object.keys(this.props.jsonData[0]), data = this.props.jsonData;
        var rows = data.map(function (item, i) {
            var cells = cols.map(function (colData, j) {
                return j > 0 ? <td> {item[colData]} </td> : null;
            });
            return i > 0 ? <tr key={i}> {cells} </tr> : null;
        });
        return rows;
    }

    renderTable = () => {
        let rowComponents = this.generateRows();
        var cols = Object.keys(this.props.jsonData[0]);
        let headers = [];
        cols.map(function (h, i) {
             return i > 0 ?  headers.push(<th key={i}>{h}</th>) : null
        });

        return (
            <div className="table-responsive">
                <table className="table">
                    <thead><tr>{headers}</tr></thead>
                    <tbody> {rowComponents} </tbody>
                </table>
            </div>
        );
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
