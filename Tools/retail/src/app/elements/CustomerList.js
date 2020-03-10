import React, { Component } from 'react'
import axios from './../api'


class CustomerList extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedCustomer: "",
            CustomerList: [],
        };
    }

    componentDidMount() {
        this.getCustomerList();
    }

    getCustomerList = () => {
        axios.get('parameters/getcustomerlist', { crossdomain: true }).then(result => {
            this.setState({
                CustomerList: result.data
            });
        });
    };

    setSelectedCustomer = (e) => {
        this.setState({
            selectedCustomer: e.target.value
        }, () => {
            this.props.onUpdate(this.state.selectedCustomer);
        });
    };

    render() {

        if (!this.state.CustomerList.length)
            return null;

        let options = this.state.CustomerList.map((Customer, i) => (
            <option key={Customer} value={Customer}>{Customer}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm"
                    onChange={this.setSelectedCustomer}
                >
                    <option value="">Select Customer</option>
                    {options}
                </select>
            </>
        )
    }
}

export default CustomerList
