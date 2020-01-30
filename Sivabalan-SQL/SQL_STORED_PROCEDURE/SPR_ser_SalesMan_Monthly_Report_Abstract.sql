CREATE procedure [dbo].[SPR_ser_SalesMan_Monthly_Report_Abstract](
@SalesManName varchar(8000),          
@FromDate DateTime,          
@Todate DateTime,          
@Val_Volume Varchar(50))            
as          
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
Create table #TmpSalesMan(SalesManid integer)              
          
if @SalesManName='%'               
Begin      
	Insert into #TmpSalesMan select SalesManid from SalesMan          
	Insert into #TmpSalesman Values (0)    
end      
Else      
Begin      
Insert into #TmpSalesMan     
	Select salesmanid from Salesman where salesman_name in (select * from dbo.sp_SplitIn2Rows(@SalesManName,@Delimeter))
	if exists(select * from dbo.sp_SplitIn2Rows(@SalesManName,@Delimeter) 
			where ItemValue like 'Others')
	begin 
		Insert into #TmpSalesman Values (0)    
	end
end        

Select "Salesman ID" =[ID],"SalesMan Name" = SalesManName,"Total Qty" = Sum(isNull(Qty,0)),
"Total Value" = Sum(isNull(Value,0)) from 
(
	select "ID"=isnull(invoiceabstract.salesmanid,0),    
	"SalesManName" = case isnull(InvoiceAbstract.SalesmanID, 0) when 0 then 'Others'     
	else Salesman.Salesman_Name end      
	,"Qty"= sum(Case InvoiceType When 4 then 0-Quantity Else Quantity end)          
	,"Value"= sum(Case InvoiceType When 4 then 0-Amount Else Amount end)          
	from invoiceabstract,Invoicedetail,Salesman        
	WHERE Invoiceabstract.invoiceid = invoicedetail.invoiceid        
	And Invoicedate Between @FromDate And @Todate    
	And IsNull(Invoiceabstract.status,0) & 128 = 0       
	And Invoiceabstract.invoicetype in (1,3,4)     
	And Isnull(invoiceabstract.Salesmanid,0)*= Salesman.Salesmanid       
	--(Case @COUNT WHEN 1     
	And isnull(invoiceabstract.Salesmanid,0)IN    
	(select SalesManid  from #TmpSalesMan)        
	group by     
	isnull(invoiceabstract.Salesmanid,0)    
	,Salesman.Salesman_Name     

	--Begin: Service Module Impact
	UNION all
	select "ID"=0,"SalesManName" = 'Others',
	"Qty" = Sum(isNull(Quantity,0)),
	"Value " = Sum(isNull(SID.NetValue,0))
	from ServiceInvoiceAbstract SIA,ServiceInvoiceDetail SID
	where SIA.ServiceInvoiceID = SID.ServiceInvoiceID
	and isNull(SID.SpareCode,'')<>'' 
	and SIA.ServiceInvoiceDate Between @FromDate And @Todate
	and SIA.ServiceInvoiceType = 1 and isNull(SIA.Status,0) & 192 = 0
	and '0' in (select SalesManid  from #TmpSalesMan)
	having Sum(isNull(Quantity,0)) <> 0 or Sum(isNull(SID.NetValue,0)) <> 0
	--End:  Service Module Impact
) as ResultSet
group by ID,SalesManName
Drop table #tmpSalesman
