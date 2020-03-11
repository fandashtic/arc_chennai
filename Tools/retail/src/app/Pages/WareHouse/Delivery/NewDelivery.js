import React, { Component } from 'react';
import { Form } from 'react-bootstrap';
import DatePicker from "react-datepicker";
import { JsonToTable } from "react-json-to-table";
import axios from "././../../../api";
import VanListCombo from './../../../elements/VanListCombo';

class NewDelivery extends Component {

    constructor(props, context) {
        super(props, context);

        this.state = {
            dateofsale: new Date(),
            dateofdelivery: new Date(),
            selectedVan: "",
            selectedInvoiceList: [],
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

        });
    }

    isCheckedAll = (e) => {
        var arr = [];
        var checked = e.target.checked;
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

        });
    }

    onUpdate = (val) => {
        this.setState({
            selectedVan: val
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
                <span className="form-check form-check-success" Style={"margin: 0px; left: 5px;"}>
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
                <div className="col-md-2 padding0">
                    <Form.Group>
                        <div className="col-sm-12 padding0">
                            <DatePicker className="form-control w-100 height40" id="dateofsale"
                                selected={this.state.dateofdelivery}
                                onChange={this.dateofdeliveryChange}
                            />
                        </div>
                    </Form.Group>
                </div>
                : null
        )
    }

    renderSaveDelivery = () => {
        return (
            this.state.invoiceList.length && this.state.selectedInvoiceList.length > 0 ?
                <div className="col-md-2 padding0">
                    <Form.Group>
                        <div>
                            <button type="button" className="btn btn-success height40" onClick={this.CreateNewDelivery} >
                                Save Delivery
                                    </button>
                        </div>
                    </Form.Group>
                </div>
                : null
        )
    }

    CreateNewDelivery = () => {
        var deliveryData = {};
        var dateofdelivery = this.state.dateofdelivery.toLocaleDateString().replace('/', '-').replace('/', '-');
        deliveryData.InvoiceIds = this.state.selectedInvoiceList;
        deliveryData.deliveryDate = dateofdelivery;        
        axios.get('delivery/updateDelivery', deliveryData).then(result => {
            
        });
    };

    renderTable = (state) => {
        return (
            <div className="table table-hover">
                <JsonToTable json={state.invoiceList} />
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
                <td>{i + 1}</td>
                <td>{invoice.SalesmanName}</td>
                <td>{invoice.Beat}</td>
                <td>{invoice.CustomerName}</td>
                <td>{invoice.GSTFullDocID}</td>
                <td>{invoice.NetValue}</td>
                <td><label className="badge badge-danger">{invoice.DeliveryStatus !== 2 ? 'Pending' : 'Completed'}</label></td>
            </tr>
        ))
        return rows;
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
                    <table className="table table-hover">
                        <thead>
                            <tr>
                                <th Style={"padding: 10px;"}>
                                   {this.renderSelectAll()}
                                </th>
                                <th>S.No</th>
                                <th>SalesMan</th>
                                <th>Beat</th>
                                <th>Customer</th>
                                <th>Invoice Id</th>
                                <th>Value</th>
                                <th>Status</th>
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

    render() {
        return (
            <div>
                <div className="row">
                    <div className="col-md-4 padding0">
                        <Form.Group>
                            <div className="col-sm-11 padding0 height40">
                                <VanListCombo onUpdate={this.onUpdate} />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-2 padding0">
                        <Form.Group>
                            <div className="col-sm-12 padding0">
                                <DatePicker className="form-control w-100 height40" id="dateofsale"
                                    selected={this.state.dateofsale}
                                    onChange={this.dateofsaleChange}
                                />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-2 padding0">
                        <Form.Group>
                            <div>
                                <button type="button" className="btn btn-info height40" onClick={this.getSalesByDateAndVan} >Get Sales Invoices</button>
                            </div>
                        </Form.Group>
                    </div>
                    {this.renderDeliveryDate()}                    
                    {this.renderSaveDelivery()}
                </div>
                <div>                
                    {this.renderTablePage()}
                </div>
            </div>
        );
    }
}

export default NewDelivery;