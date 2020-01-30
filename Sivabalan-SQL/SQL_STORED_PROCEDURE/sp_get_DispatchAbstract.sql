
CREATE Procedure sp_get_DispatchAbstract (@CustomerID nVarchar (15),@DispatchFromDate datetime,@DispatchToDate datetime)
 as 
Select DispatchAbstract.CustomerID,Customer.Company_Name,DispatchAbstract.DispatchID,
DispatchAbstract.DispatchDate, DispatchAbstract.DocumentID from DispatchAbstract,customer
where ((DispatchAbstract.Status & 128)=0) and  
Customer.CustomerID=DispatchAbstract.CustomerID 
and DispatchAbstract.CustomerID = @CustomerID
and (DispatchAbstract.DispatchDate between @DispatchFromDate and @DispatchToDate) 
order by DispatchAbstract.DispatchDate 



