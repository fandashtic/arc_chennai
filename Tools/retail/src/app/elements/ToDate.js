import React, { useState } from 'react';
import DatePicker from "react-datepicker";

const ToDate = (param) => {
    var date = new Date();
    date = param.defaultValue === '$MLDate' ? new Date(date.getFullYear(), date.getMonth() + 1, 0) : date;
    const [toDate, setToDate] = useState(date);
    return (      
      <DatePicker className="form-control w-100 height40"
        dateFormat="dd-MMM-yyyy"
        showPopperArrow={false}
        selected={toDate}
        value= {toDate}
        id={param.id}
        onChange={date => setToDate(date)}
      />
    );
}

export default ToDate;

