
CREATE Procedure sp_get_AllDispatchAbstract (@DispatchFromDate Datetime,@DispatchToDate datetime)
 as 
Select Customer.CustomerID, Customer.Company_Name, DispatchAbstract.DispatchID,
DispatchAbstract.DispatchDate, DispatchAbstract.DocumentID from 
DispatchAbstract,Customer
where ((DispatchAbstract.Status & 128) = 0) and  
Customer.CustomerID=DispatchAbstract.CustomerID 
and (DispatchAbstract.DispatchDate between @DispatchFromDate and @DispatchToDate)
order by Customer.Company_Name, DispatchAbstract.DispatchID

