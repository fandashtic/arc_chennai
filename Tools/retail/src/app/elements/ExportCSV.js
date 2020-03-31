import React from 'react'
import Button from 'react-bootstrap/Button';
import * as FileSaver from 'file-saver';
import * as XLSX from 'xlsx';

const ExportCSV = ({csvData, fileName}) => {
    const fileType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8';
    const fileExtension = '.xlsx';

    const exportToCSV = (csvData, fileName) => {
        const ws = XLSX.utils.json_to_sheet(csvData);
        const wb = { Sheets: { 'data': ws }, SheetNames: ['data'] };
        const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
        const data = new Blob([excelBuffer], {type: fileType});
        FileSaver.saveAs(data, fileName + fileExtension);
    }

    const isHasValue = (data) => {
        return data === null ? false : true;
      }

    return (
        isHasValue(csvData) ?
        <button type="button" class="btn btn-info btn-icon-text" onClick={(e) => exportToCSV(csvData, fileName)}> 
        Export 
        <i class="fa-file-excel-o"></i>
        </button>        
        : null
    )
}

export default ExportCSV;
