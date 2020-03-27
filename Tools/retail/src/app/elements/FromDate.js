import React, { useState } from 'react';
import DatePicker from "react-datepicker";

const FromDate = (param) => {
    var date = new Date();
    date = param.defaultValue === '$MFDate' ? new Date(date.getFullYear(), date.getMonth(), 1) : date;
    const [fromDate, setFromDate] = useState(date);
    
    return (      
      <DatePicker className="form-control w-100 height40"
        dateFormat="dd-MMM-yyyy"
        showPopperArrow={false}
        selected={fromDate}
        value= {fromDate}
        id={param.id}
        onChange={date => setFromDate(date)}
      />
    );
}

export default FromDate;
