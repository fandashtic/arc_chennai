import React, { useState } from 'react';
import DatePicker from "react-datepicker";

const FromDate = () => {
    const [fromDate, setFromDate] = useState(new Date());
    return (      
      <DatePicker className="form-control w-100 height40"
        showPopperArrow={false}
        selected={fromDate}
        onChange={date => setFromDate(date)}
      />
    );
}

export default FromDate;
