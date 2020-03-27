import React, { Component } from 'react';
import axios from "././../../../api";
//import { JsonToTable } from "react-json-to-table";
import JsonToTable from './../../../elements/JsonToTable'
import FromDate from './../../../elements/FromDate';
import ToDate from './../../../elements/ToDate';
import Spinner from './../../../shared/Spinner';

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
      action: 0,
      actionData: null,
      dynoReportData: null,
      isReportView: false,
      isLoading: false
    };
  };

  componentDidMount(prevProps) {
    document.title = this.state.title;
    this.getReportData({ id: 151, action: 0 });
  };

  getReportData = (report, e) => {
    this.setState(prevState => {
      return {
        isLoading: true
      }
    });

    if (report.action === 0) {
      axios.get('report/getreportsbyid/' + report.id, { crossdomain: true }).then(result => {
        this.setState(prevState => {
          return {
            allReports: result.data,
            isParameters: false,
            currentId: report.id,
            backId: prevState.currentId,
            action: prevState.action,
            isLoading: false
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
            parameters: this.setValueParam(result.data),
            isParameters: true,
            currentId: report.id,
            actionData: report.actionData,
            backId: prevState.currentId,
            action: prevState.action,
            isLoading: false
          }
        }, () => {
          this.renderParameters();
        });
      });
    }
  }

  setValueParam = (parameters) => {
    parameters.map((param, i) => (
      param.Value = null
    ))
    return parameters;
  }

  renderParameters = () => {

    let param = (
      this.state.parameters
        .sort((a, b) => a.OrderBy > b.OrderBy)
        .map((param, i) => (
          <div className="row col-sm-6 form-group paramrow" key={i} >
            <label className="col-sm-3 col-form-label">{param.ParameterName}</label>
            <div className="col-sm-9">
              {this.renderParamControl(param)}
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
    switch (param.ParameterName) {
      case 'From Date':
        return <FromDate id={param.ParameterName} defaultValue={param.DefaultValue} value={param.Value} />;
      case 'To Date':
        return <ToDate id={param.ParameterName} defaultValue={param.DefaultValue} value={param.Value} />;
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

  renderDynoReportGrid = () => {
    let dynoReportGrid = (
      <>
        <div className="table-responsive">
          <JsonToTable jsonData={this.state.dynoReportData} />
        </div>
      </>
    );

    this.setState({
      dynoReportGrid: dynoReportGrid,
      isParameters: false,
      isReportView: true
    });
  }

  goBack = () => {
    this.getReportData({ id: this.state.backId, action: this.state.action });
  }

  refreshReport = () => {
    var params = [];
    this.setState(prevState => {
      return {
        isLoading: true
      }
    });

    this.state.parameters.map((param, i) => (
      params.push({ "ParameterName": param.ParameterName.replace(/ /g, ''), "ParameterValue": document.getElementById(param.ParameterName).value })
    ))

    var reportRequest = { "ProcedureName": this.state.actionData, "Parameters": params };
    console.log(JSON.stringify(reportRequest));
    axios.post('report/getreportsdata', reportRequest, { crossdomain: true }).then(result => {
      this.setState(prevState => {
        return {
          dynoReportData: result.data,
          isParameters: false,
          isReportView: true,
          isLoading: false
        }
      }, () => {
        this.renderDynoReportGrid();
      });

    });
  }

  render() {
    return (
      <div>
        <h2>Reports</h2>
        {
          this.state.isLoading ? <Spinner /> :

            <div className="card-body">
              {
                !this.state.isParameters && !this.state.isReportView ? this.state.reportGrid : this.state.paramGrid
              }
              {
                this.state.isParameters || this.state.isReportView ?
                  <>
                    <br />
                    <button type="button" className="btn btn-success App-logo" onClick={this.refreshReport} >Refresh</button>
                    <br />
                  </>
                  : null
              }
              {
                !this.state.isParameters && this.state.isReportView ? this.state.dynoReportGrid : null
              }
            </div>
        }

      </div>
    );
  }
}
