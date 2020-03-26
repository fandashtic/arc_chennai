import React, { Component } from 'react';
import axios from "././../../../api";
import FromDate from './../../../elements/FromDate';
import ToDate from './../../../elements/ToDate';

export default class DynoReport extends Component {

  constructor(props) {
    super(props)

    this.state = {
      allReports: [],
      reportGrid: null,
      paramGrid: null,
      title: "Reports",
      parameters: [],
      isParameters: false,
      backId: 0,
      currentId: 0,
      action: 0
    };
  };

  componentDidMount(prevProps) {
    document.title = this.state.title;
    this.getReportData({ id: 151, action: 0 });
  };

  getReportData = (report, e) => {
    if (report.action === 0) {
      axios.get('report/getreportsbyid/' + report.id, { crossdomain: true }).then(result => {
        this.setState(prevState => {
          return {
            allReports: result.data,
            isParameters: false,
            currentId: report.id,
            backId: prevState.currentId,
            action: prevState.action
          }
        }, () => {
          this.renderGrid();
        });
      });
    }
    else {
      axios.get('/parameters/getparametersbyid/' + report.parameters, { crossdomain: true }).then(result => {
        this.setState(prevState => {
          return {
            parameters: result.data,
            isParameters: true,
            currentId: report.id,
            backId: prevState.currentId,
            action: prevState.action
          }
        }, () => {
          this.renderParameters();
        });
      });
    }
  }

  renderParameters = () => {

    let param = (
      this.state.parameters
        .sort((a, b) => a.OrderBy > b.OrderBy)
        .map((param, i) => (

          <div className="row col-sm-6 form-group paramrow" key={i} >
            <label className="col-sm-3 col-form-label">{param.ParameterName}</label>
            <div className="col-sm-9">
              {this.renderParamControl(param.ParameterName)}
            </div>
          </div>

        ))
    )

    this.setState({
      paramGrid: param,
      isParameters: true
    });
  }

  renderParamControl(param) {
    switch (param) {
      case 'From Date':
        return <FromDate />;
      case 'To Date':
        return <ToDate />;
      default:
        return null;
    }
  }

  renderGrid = () => {
    let grid = (
      <div className="row">
        {
          this.state.allReports
            .sort((a, b) => a.id > b.id)
            .map((report, i) => (
              <label className="col-md-4 grid-margin stretch-card" key={report.id} onClick={() => this.getReportData(report)}>
                <div className="card">
                  <div className="card-body">
                    <h4 className="card-title">{report.node}</h4>
                    <div className="media">
                      <i className="mdi mdi-earth icon-md text-info d-flex align-self-start mr-3"></i>
                      <div className="media-body">
                        <p className="card-text">{report.description}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </label>
            ))
        }
      </div>
    )

    this.setState({
      reportGrid: grid,
      isParameters: false
    });
  }

  goBack = () => {
    this.getReportData({ id: this.state.backId, action: this.state.action });
  }

  refreshReport = () => {
debugger;
//this.state
  }

  render() {
    return (
      <div>
        <h2>Reports</h2>
        <div className="card-body">
          {
            this.state.isParameters ? this.state.paramGrid : this.state.reportGrid
          }
          {
            this.state.isParameters ?
              <>
                <br />
                <button type="button" className="btn btn-success" onClick={this.refreshReport} >Refresh</button>
              </>
              : null
          }
        </div>
      </div>
    );
  }
}
