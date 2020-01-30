CREATE procedure spr_get_SalesmanSalesSummary_Abstract (@SalesMan nvarchar(2550), @FromDate DateTime, @ToDate DateTime)
as
begin
Declare @OTHERS NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpCus(Salesman_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @Salesman='%'  
	Insert into #tmpCus select Salesman_Name from Salesman 
Else  
 	Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter)  

select 
	isnull(IA.SalesManID,0), "Salesman" = isnull(SM.SalesMan_Name, @OTHERS), "Value" = Sum(
	case IA.InvoiceType when 4 then -IDt.Amount else  IDt.Amount end)
from InvoiceAbstract IA 
Inner Join InvoiceDetail IDt On
	IA.InvoiceID = IDt.InvoiceID 
Left Outer Join SalesMan SM on
	IA.SalesmanID = SM.SalesmanID
where 	
	(@Salesman = '%' or	SM.Salesman_Name in (Select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus))
	and IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0
--	and IA.InvoiceType <> 2
	and IA.InvoiceType not in (2,5,6)
group by IA.SalesManID, SM.SalesMan_Name
end





