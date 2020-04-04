import React, { Component } from 'react';
import { Form } from 'react-bootstrap';
import DatePicker from "react-datepicker";
import JsonToTable from './../../../elements/JsonToTable'
import axios from "././../../../api";
import VanListCombo from './../../../elements/VanListCombo';
import VehicleTypeCombo from './../../../elements/VehicleTypeCombo';

class NewDelivery extends Component {

    constructor(props, context) {
        super(props, context);

        this.state = {
            dateofsale: new Date(),
            dateofdelivery: new Date(),
            selectedVan: "",
            selectedVehicleType: "",
            selectedInvoiceList: [],
            totalWeight: 0,
            totalValue: 0,
            isPlanned: false,
            invoiceList: [], loading: null, title: 'Fandashtic'
        };
    }

    componentDidUpdate(prevProps) {
        document.title = this.state.title;
    };

    dateofsaleChange = date => {
        this.setState({
            dateofsale: date
        });
    };

    dateofdeliveryChange = date => {
        this.setState({
            dateofdelivery: date
        });
    };

    getSelectedWeightValue = () => {
        var totalWeight = 0;
        var totalValue = 0;
        if (this.state.invoiceList.length > 0) {
            this.state.invoiceList.forEach(invoice => {
                if (document.getElementById(invoice.InvoiceID).checked) {
                    totalWeight = totalWeight + parseFloat(invoice.Weight);
                    totalValue = totalValue + parseFloat(invoice.NetValue);
                }
            });
        }

        this.setState({
            totalValue: totalValue,
            totalWeight: totalWeight
        }, () => {

        });
    };

    isChecked = (e) => {
        var arr = [];
        var curId = e.target.id;
        if (this.state.selectedInvoiceList.length > 0) {
            this.state.selectedInvoiceList.forEach(id => {
                if (id !== curId) {
                    arr.push(id);
                }
            });
            if (e.target.checked === true) {
                arr.push(curId);
            }
        }
        else {
            arr.push(curId);
        }

        this.setState({
            selectedInvoiceList: arr
        }, () => {
            this.getSelectedWeightValue();
        });
    }

    isCheckedAll = (e) => {        
        var checked = e.target.checked;
        this.UncheckAll(checked);        
    }

    VanChange = (val) => {
        this.setState({
            selectedVan: val
        })
    };

    VehicleTypeChange = (val) => {
        this.setState({
            selectedVehicleType: val
        })
    };

    getSalesByDateAndVan = () => {
        var van = this.state.selectedVan;
        var salesDate = this.state.dateofsale.toLocaleDateString().replace('/', '-').replace('/', '-');

        axios.get('delivery/GerSalesInvoiceByDateAndVan/' + van + '?Todate=' + salesDate).then(result => {
            this.setState({
                invoiceList: result.data, loading: false
            })
        });
    };

    renderSelectAll = () => {
        return (
            this.state.invoiceList.length ?
                <span className="form-check form-check-success" Style={"margin: 0px;"}>
                    <label className="form-check-label">
                        <input type="checkbox" className="form-check-input" onClick={this.isCheckedAll} />
                        <i className="input-helper"></i>
                    </label>
                </span>
                : null
        )
    }

    renderDeliveryDate = () => {
        return (
            this.state.invoiceList.length ?
                <div className="padding0">
                    <Form.Group>
                        <div className="col-sm-12 padding0">
                            <DatePicker className="form-control height40" id="dateofsale"
                                selected={this.state.dateofdelivery}
                                onChange={this.dateofdeliveryChange}
                            />
                        </div>
                    </Form.Group>
                </div>
                : null
        )
    }

    renderNewDelivery = () => {
        return (
            this.state.invoiceList.length && this.state.selectedInvoiceList.length > 0 ?                
                    <div className="col-md-2 padding0 pleft15">
                        <Form.Group>
                            <div>
                                <button type="button" className="btn btn-success height40" onClick={this.CreateNewDelivery} >
                                    Continue Delivery
                                    </button>
                            </div>
                        </Form.Group>
                    </div>
                : null
        )
    }

    CreateNewDelivery = () => {
        this.setState({
            isPlanned: true
        }, () => {
            
        });
    };    

    RevertNewDelivery = () => {
        this.setState({
            isPlanned: false
        }, () => {
            this.UncheckAll(false);  
        });
    };

    renderTable = (state) => {
        return (
            <div className="table table-hover">
                <JsonToTable jsonData={state.invoiceList} />
            </div>
        );
    }

    renderRows = (state) => {
        let rows = state.invoiceList.map((invoice, i) => (
            <tr key={i + 1}>
                <td>
                    <div className="form-check form-check-{invoice.DeliveryStatus !== 2 ? 'danger' : 'success'}">
                        <label className="form-check-label">
                            <input key={invoice.InvoiceID} id={invoice.InvoiceID} type="checkbox" className="form-check-input" onClick={this.isChecked} />
                            <i className="input-helper"></i>
                        </label>
                    </div>
                </td>
                <td className="padding0">{i + 1}</td>
                {/* <td>{invoice.SalesmanName}</td>
                <td>{invoice.Beat}</td> */}
                <td className="padding0">{invoice.CustomerName}</td>
                <td className="padding0">{invoice.GSTFullDocID}</td>
                <td className="padding0">{invoice.NetValue}</td>
                <td className="padding0">{invoice.Weight}</td>
                <td className="padding0">{invoice.DocSerialType}</td>
                <td className="padding0"><label className="badge badge-danger">{invoice.DeliveryStatus !== 2 ? 'Pending' : 'Completed'}</label></td>
            </tr>
        ))
        return rows;
    }

    currencyFormat = (num) => {
        return '' + num.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
     }

    renderTablePage = () => {
        if (this.state.loading === true) {
            return (
                <div className="main-spinner-wrapper">
                    Loader
                </div>
            );
        } else {
            //return this.renderTable(this.state);
            return (
                <div className="table-responsive">
                    <table className="table table-hover padding0">
                        <thead>
                            <tr>
                                <th Style={"padding: 10px;padding-left: 0px;"}>
                                    {this.renderSelectAll()}
                                </th>
                                <th Style={"padding-left: 0px;"}>S.No</th>
                                {/* <th>SalesMan</th>
                                <th>Beat</th> */}
                                <th Style={"padding-left: 0px;"}>Customer</th>
                                <th Style={"padding-left: 0px;"}>Invoice Id</th>
                                <th Style={"padding-left: 0px;"}>Value</th>
                                <th Style={"padding-left: 0px;"}>Weight</th>
                                <th Style={"padding-left: 0px;"}>Van</th>
                                <th Style={"padding-left: 0px;"}>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            {
                                this.renderRows(this.state)
                            }
                        </tbody>
                    </table>
                </div>
            )
        }
    }

    SaveDelivery = () => {
        var deliveryData = {};
        var dateOfDelivery = this.state.dateofdelivery.toLocaleDateString().replace('/', '-').replace('/', '-');
        deliveryData.InvoiceIds = this.state.selectedInvoiceList;
        deliveryData.dateOfDelivery = dateOfDelivery;
        axios.post('delivery/updateDelivery', deliveryData).then(result => {

        });
    };

    UncheckAll = (checked) => {
        var arr = [];
        if (this.state.invoiceList.length > 0) {
            this.state.invoiceList.forEach(invoice => {
                if (checked) {
                    arr.push(invoice.InvoiceID);
                }
                document.getElementById(invoice.InvoiceID).checked = checked;
            });
        }

        this.setState({
            selectedInvoiceList: arr
        }, () => {
            this.getSelectedWeightValue();
        });
    };

    render() {
        return (
            this.state.isPlanned ?
                <div>
                    <div className="row">
                        <div className="col-md-6 grid-margin stretch-card">
                            <div className="card">
                                <div className="card-body">
                                    <h4 className="card-title">New Delivery</h4>                                    
                                    <form className="forms-sample">
                                        <Form.Group>
                                            <label htmlFor="exampleInputUsername1">Delivery Date</label>
                                            {this.renderDeliveryDate()}   
                                        </Form.Group>
                                        <Form.Group>
                                            <label htmlFor="exampleInputEmail1">Vehicle Types</label>
                                            <VehicleTypeCombo onUpdate={this.VehicleTypeChange} />
                                        </Form.Group>
                                        <Form.Group>
                                            <label htmlFor="lblVehicleNumber">Vehicle Number</label>
                                            <Form.Control type="text" className="form-control" id="lblVehicleNumber" placeholder="Vehicle Number" />
                                        </Form.Group>
                                        <Form.Group>
                                            <label htmlFor="lblDriverName">Driver Name</label>
                                            <Form.Control type="text" className="form-control" id="lblDriverName" placeholder="Driver Name" />
                                        </Form.Group>
                                        <Form.Group>
                                            <label htmlFor="lblHelpers">Helpers</label>
                                            <Form.Control type="text" className="form-control" id="lblHelpers" placeholder="Helpers" />
                                        </Form.Group>                                        
                                        <button type="submit" className="btn btn-primary mr-2">Save Delivery</button>
                                        <button className="btn btn-light" onClick={this.RevertNewDelivery}>Back</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    {/* <div className="row">
                        <div class="row form-group">
                            <label class="col-sm-3 col-form-label">Delivery Date</label>
                            <div class="col-sm-9">
                                
                            </div>
                        </div>

                                             
                        <div className="col-md-2 padding0 pleft15" Style={'text-align: right;'}>
                            <Form.Group>
                                <div>
                                    <button type="button" className="btn btn-dark btn-rounded btn-icon height40" >{this.currencyFormat(Math.round(this.state.totalValue))}</button>
                                </div>
                            </Form.Group>
                        </div>
                        <div className="col-md-1 padding0 pleft15">
                            <Form.Group>
                                <div>
                                    <button type="button" className="btn btn-primary btn-rounded btn-icon height40" >{this.currencyFormat(Math.round(this.state.totalWeight))}</button>
                                </div>
                            </Form.Group>
                        </div>
                    </div> */}
                    <div className="row">
                    <div className="col-md-3 padding0">
                        <Form.Group>
                            <div className="col-sm-11 padding0 height40">
                                
                            </div>
                        </Form.Group>
                    </div>
                    </div>
                </div>
            :
            <div>
                <div className="row">
                    <div className="col-md-3 padding0">
                        <Form.Group>
                            <div className="col-sm-11 padding0 height40">
                                <VanListCombo onUpdate={this.VanChange} />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-1 padding0">
                        <Form.Group>
                            <div className="col-sm-12 padding0 width100">
                                <DatePicker className="form-control w-100 height40" id="dateofsale"
                                    selected={this.state.dateofsale}
                                    onChange={this.dateofsaleChange}
                                />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-2 padding0 pleft15">
                        <Form.Group>
                            <div>
                                <button type="button" className="btn btn-info height40" onClick={this.getSalesByDateAndVan} >Get Sales Invoices</button>
                            </div>
                        </Form.Group>
                    </div>
                    {this.renderNewDelivery()}
                    <div className="col-md-2 padding0 pleft15" Style={'text-align: right;'}>
                        <Form.Group>                           
                            <div>
                                <button type="button" className="btn btn-dark btn-rounded btn-icon height40" >{this.currencyFormat(Math.round(this.state.totalValue))}</button>
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-1 padding0 pleft15">
                        <Form.Group>
                            <div>
                                <button type="button" className="btn btn-primary btn-rounded btn-icon height40" >{this.currencyFormat(Math.round(this.state.totalWeight))}</button>
                            </div>
                        </Form.Group>
                    </div>
                </div>
                
                <div>
                    {this.renderTablePage()}
                </div>
            </div>
        );
    }
}

export default NewDelivery;