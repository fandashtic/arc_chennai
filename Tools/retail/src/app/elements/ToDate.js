import React, { useState } from 'react';
import DatePicker from "react-datepicker";

const ToDate = () => {
    const [toDate, setToDate] = useState(new Date());
    return (      
      <DatePicker className="form-control w-100 height40"
        showPopperArrow={false}
        selected={toDate}
        onChange={date => setToDate(date)}
      />
    );
}

export default ToDate;

