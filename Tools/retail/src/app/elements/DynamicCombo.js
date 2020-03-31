import React, { Component } from 'react'
import axios from './../api'


class DynamicCombo extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedValue: "",
            list: [],
            defaultValue: null
        };
    }

    componentDidMount() {
        this.getVanList();
        this.getDefaultValue();
    }

    getVanList = () => {
        axios.post('parameters/getqueryparams', {"data" : this.props.autoComplete}, { crossdomain: true }).then(result => {
            this.setState({
                list: result.data
            });
        });
    };

    setSelectedValue= (e) => {
        this.setState({
            selectedValue: e.target.value
        }, () => {
            //this.props.onUpdate(this.state.selectedVan);
            //console.log(this.state.selectedVan);
        });
    };

    getDefaultValue = () => {
        if (this.props.autoComplete !== null && this.props.autoComplete !== "" && this.props.autoComplete !== undefined) {
            this.setState({
                defaultValue: this.props.defaultValue.replace('$', '')
            });

        }
    }

    render() {

        if (!this.state.list.length)
            return null;

        let options = this.state.list.map((value, i) => (
            <option key={i} value={value["value"]}>{value["value"]}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm height40 w163"
                    onChange={this.setSelectedValue}
                    value= {this.selectedValue}
                    id={this.props.id}
                >
                    <option value="%">{this.state.defaultValue}</option>
                    {options}
                </select>
            </>
        )
    }
}

export default DynamicCombo
