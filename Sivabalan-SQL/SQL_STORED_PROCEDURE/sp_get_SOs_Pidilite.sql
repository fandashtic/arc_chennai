CREATE Procedure sp_get_SOs_Pidilite(@CustomerID nVarchar (15),@SOFromDate datetime,@SOToDate datetime)
 as 
Select SOAbstract.CustomerID,Customer.Company_Name,SOAbstract.SONumber,
SOAbstract.SODate, Value, DeliveryDate, PODocReference, DocumentID from SOAbstract,customer
where ((SOAbstract.Status & 192)=0) and  
Customer.CustomerID=SOAbstract.CustomerID 
and SOAbstract.CustomerID like @CustomerID
and (SOAbstract.SODate between @SOFromDate and @SOToDate) 
order by Customer.Company_Name, SOAbstract.SONumber
