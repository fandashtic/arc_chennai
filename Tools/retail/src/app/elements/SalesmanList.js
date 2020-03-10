import React, { Component } from 'react'
import axios from './../api'


class SalesManList extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedSalesMan: "",
            SalesManList: [],
        };
    }

    componentDidMount() {
        this.getSalesManList();
    }

    getSalesManList = () => {
        axios.get('parameters/getsalesmanlist', { crossdomain: true }).then(result => {
            this.setState({
                SalesManList: result.data
            });
        });
    };

    setSelectedSalesMan = (e) => {
        this.setState({
            selectedSalesMan: e.target.value
        }, () => {
            this.props.onUpdate(this.state.selectedSalesMan);
        });
    };

    render() {

        if (!this.state.SalesManList.length)
            return null;

        let options = this.state.SalesManList.map((SalesMan, i) => (
            <option key={SalesMan} value={SalesMan}>{SalesMan}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm"
                    onChange={this.setSelectedSalesMan}
                >
                    <option value="">Select SalesMan</option>
                    {options}
                </select>
            </>
        )
    }
}

export default SalesManList
