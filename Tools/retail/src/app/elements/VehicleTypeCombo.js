import React, { Component } from 'react'
import axios from '../api'


class VehicleTypeCombo extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedVehicleType: "",
            vehicleTypes: [],
        };
    }

    componentDidMount() {
        this.getVehicleTypes();
    }

    getVehicleTypes = () => {
        axios.get('parameters/getvehicletype', { crossdomain: true }).then(result => {
            this.setState({
                vehicleTypes: result.data
            });
        });
    };

    setSelectedVehicleType = (e) => {
        this.setState({
            selectedVehicleType: e.target.value
        }, () => {
            this.props.onUpdate(this.state.selectedVehicleType);
            //console.log(this.state.selectedVehicleType);
        });
    };

    render() {

        if (!this.state.vehicleTypes.length)
            return null;

        let options = this.state.vehicleTypes.map((van, i) => (
            <option key={van} value={van}>{van}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm btn40"
                    onChange={this.selectedVehicleType}
                >
                    <option value="">Select Vehicle Type</option>
                    {options}
                </select>
            </>
        )
    }
}

export default VehicleTypeCombo
