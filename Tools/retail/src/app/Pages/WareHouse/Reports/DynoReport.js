import React, { Component } from 'react';
import axios from "././../../../api";
//import { JsonToTable } from "react-json-to-table";
import JsonToTable from './../../../elements/JsonToTable'
import FromDate from './../../../elements/FromDate';
import ToDate from './../../../elements/ToDate';
import ExportCSV from './../../../elements/ExportCSV';
import DynamicCombo from './../../../elements/DynamicCombo';
import Spinner from './../../../shared/Spinner';

import { Document, Page, View } from '@react-pdf/renderer'

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
      isLoading: false,
      reportTitle: 'Reports',
      breadcrumbs: [],
      isBreadcrumbClick: false,
      fileName: ""
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
          var _breadcrumbs = [];
          _breadcrumbs = prevState.breadcrumbs;

          //remove _breadcrumb
          if(this.state.isBreadcrumbClick){
            var list = [];  
            
            _breadcrumbs.map((_breadcrumb) => {              
                if(_breadcrumb.id.toString() === report.id.toString()){
                  list.push(_breadcrumb);
                }
                return list;              
            })

            _breadcrumbs = list;
          }

          _breadcrumbs.map(function(_breadcrumb){
            return _breadcrumb.isActive = false;
          });
          if (report.node !== undefined) { _breadcrumbs.push({ "id": report.id, "action": report.action, "node": report.node, "isActive": true }); }
          return {
            allReports: result.data,
            isParameters: false,
            currentId: report.id,
            backId: prevState.currentId,
            action: prevState.action,
            isLoading: false,
            breadcrumbs : _breadcrumbs,
            isBreadcrumbClick: false            
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
            parameters: this.setValueParam(result.data.result),
            isParameters: true,
            currentId: report.id,
            actionData: report.actionData,
            backId: prevState.currentId,
            action: prevState.action,
            isLoading: false,
            reportTitle: 'Reports : '+ report.node,
            isBreadcrumbClick: false,
            fileName: report.node
          }
        }, () => {
          this.renderParameters();
        });
      });
    }
  }

  setValueParam = (parameters) => {
    JSON.parse(parameters).map((param, i) => (
      param.Value = null
    ))
    return JSON.parse(parameters);
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
    if (param.AutoComplete !== null && param.AutoComplete !== "" && param.AutoComplete !== undefined) {
      return <DynamicCombo id={param.ParameterName} autoComplete={param.AutoComplete} defaultValue={param.DefaultValue} value={param.Value} />;
    }
    else {
      switch (param.ParameterName) {
        case 'From Date':
          return <FromDate id={param.ParameterName} defaultValue={param.DefaultValue} value={param.Value} />;
        case 'To Date':
          return <ToDate id={param.ParameterName} defaultValue={param.DefaultValue} value={param.Value} />;       
        default:
          return null;
      }
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
    }
    // , () => {
    //   this.pDFdoc();
    // }
    );
  }
 

  goto = (e) => {
    this.setState(prevState => {
      return {
        isBreadcrumbClick: true
      }
    });
    this.getReportData({ id: e.target.id, action: 0 });
  }

  refreshReport = () => {
    var params = [];
    this.setState(prevState => {
      return {
        isLoading: true
      }
    });
    
    this.state.parameters.map((param, i) => (            
        params.push({ "ParameterName": param.ParameterName.replace(/ /g, ''), "ParameterValue": document.getElementById(param.ParameterName).value, "AutoComplete": param.AutoComplete })
    ))

    var reportRequest = { "ProcedureName": this.state.actionData, "Parameters": params };
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

  // pDFdoc = () => {
  //   let pdf = (
  //     this.state.dynoReportGrid !== null ?
  //   <Document>
  //     <Page wrap>
  //       <View wrap={false}>
  //         {this.state.dynoReportGrid}
  //       </View>
  //     </Page>
  //   </Document> : null
  //   )

  //   this.setState({
  //     pdfForm: pdf
  //   });
  // };
 
  render() {
    return (
      <div>
        
        <h2>{this.state.reportTitle}</h2>

        <nav aria-label="breadcrumb">
          <ol className="breadcrumb">
            <li className="breadcrumb-item" key="Reports">
              <a href="/WareHouse/DynoReport" className="removeHref">Reports</a>
            </li>
            {
              this.state.breadcrumbs
                .map((breadcrumb, i) => (                  
                  <li key={i} id={breadcrumb.id} onClick={this.goto} className={'breadcrumb-item '  + (breadcrumb.isActive ? 'active' : '')} aria-current="page">{breadcrumb.node}</li>
                ))
            }                   
          </ol>
        </nav>

        {this.state.pdfForm}

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
                   
                    <ExportCSV csvData={this.state.dynoReportData} fileName={this.state.fileName} />
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
