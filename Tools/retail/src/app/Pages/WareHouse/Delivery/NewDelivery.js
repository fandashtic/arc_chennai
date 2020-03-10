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
            selectedVan: "",
            invoiceList: [], loading: true, title: 'Fandashtic'
        };
    }

    componentDidUpdate(prevProps) {
        document.title = this.state.title;
    };

    handleChange = date => {
        this.setState({
            dateofsale: date
        });
    };

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

    renderTable = (state) => {
        return (
            <div className="table table-hover">
                <JsonToTable json={state.invoiceList} />
            </div>
        );
    }

    renderRows = (state) => {
        debugger;
        let rows = state.invoiceList.map((invoice, i) => (
            <tr key={i+1}>
                <td>{i+1}</td>
                <td>{invoice.SalesmanName}</td>
                <td>{invoice.Beat}</td>
                <td>{invoice.CustomerName}</td>
                <td>{invoice.GSTFullDocID}</td>
                <td>{invoice.NetValue}</td>                
                <td><label className="badge badge-danger">{invoice.DeliveryStatus === 1 ? 'Pending' : 'Completed'}</label></td>
            </tr>
        ))
        return rows;
        
    }

    renderTablePage = () => {
        if (this.state.loading) {
            return (
                <div>
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
                    <div className="col-md-4">
                        <Form.Group>                            
                            <div className="col-sm-9">
                                <VanListCombo onUpdate={this.onUpdate} />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-4">
                        <Form.Group>                            
                            <div className="col-sm-9">
                                <DatePicker className="form-control w-100" id="dateofsale"
                                    selected={this.state.dateofsale}
                                    onChange={this.handleChange}
                                />
                            </div>
                        </Form.Group>
                    </div>
                    <div className="col-md-4">
                        <Form.Group>
                            <div>
                                <button type="button" className="btn btn-info" onClick={this.getSalesByDateAndVan} >Get Sales Invoices</button>
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