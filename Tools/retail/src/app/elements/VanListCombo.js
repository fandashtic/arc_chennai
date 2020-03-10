import React, { Component } from 'react'
import axios from './../api'


class VanListCombo extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedVan: "",
            vanList: [],
        };
    }

    componentDidMount() {
        this.getVanList();
    }

    getVanList = () => {
        axios.get('parameters/getvanlist', { crossdomain: true }).then(result => {
            this.setState({
                vanList: result.data
            });
        });
    };

    setSelectedVan = (e) => {
        this.setState({
            selectedVan: e.target.value
        }, () => {
            this.props.onUpdate(this.state.selectedVan);
            //console.log(this.state.selectedVan);
        });
    };

    render() {

        if (!this.state.vanList.length)
            return null;

        let options = this.state.vanList.map((van, i) => (
            <option key={van} value={van}>{van}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm"
                    onChange={this.setSelectedVan}
                >
                    <option value="">Select Van</option>
                    {options}
                </select>
            </>
        )
    }
}

export default VanListCombo
