import React, { Component } from 'react'
import axios from './../api'


class BeatList extends Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedBeat: "",
            BeatList: [],
        };
    }

    componentDidMount() {
        this.getBeatList();
    }

    getBeatList = () => {
        axios.get('parameters/getbeatlist', { crossdomain: true }).then(result => {
            this.setState({
                BeatList: result.data
            });
        });
    };

    setSelectedBeat = (e) => {
        this.setState({
            selectedBeat: e.target.value
        }, () => {
            this.props.onUpdate(this.state.selectedBeat);
        });
    };

    render() {

        if (!this.state.BeatList.length)
            return null;

        let options = this.state.BeatList.map((Beat, i) => (
            <option key={Beat} value={Beat}>{Beat}</option>
        ))

        return (
            <>
                <select
                    className="form-control form-control-sm"
                    onChange={this.setSelectedBeat}
                >
                    <option value="">Select Beat</option>
                    {options}
                </select>
            </>
        )
    }
}

export default BeatList
