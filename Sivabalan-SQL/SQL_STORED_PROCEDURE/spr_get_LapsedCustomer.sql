CREATE procedure spr_get_LapsedCustomer (@Customer nvarchar(2550), @FromDate1 DateTime, @ToDate1 DateTime, @FromDate2 DateTime, @ToDate2 DateTime)
as
begin 
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpCus(Company_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @Customer='%'  
	Insert into #tmpCus select Company_Name from Customer
Else  
 	Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)  

select 
	distinct Cus.CustomerID, "Customer" = Cus.Company_Name, 
	"Last Invoice Date" = max(DBO.StripDateFromTime(IA.InvoiceDate))
from Customer Cus, InvoiceAbstract IA
where 
	Cus.CustomerID = IA.CustomerID 
	and Cus.Company_Name in (select Company_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCus) 
	and IA.InvoiceDate between @FromDate1 and @ToDate1 
	and IA.InvoiceDate not between @FromDate2 and @ToDate2
	and IA.InvoiceType in (1,3)
	and (IA.Status & 192) = 0
group by  Cus.CustomerID, Cus.Company_Name
end

Drop table #tmpCus


