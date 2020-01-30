create procedure spr_ser_get_CustomerSummary_Abstract(@Customer varchar(2550), @FromDate DateTime, @ToDate DateTime)
AS    
BEGIN    

DECLARE @Delimeter as Char(1)    
SET @Delimeter=Char(15)  
Declare @CustInfo nvarchar(4000)

Create table #tmpCustomer(Customer varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @Customer='%'     
	Insert into #tmpCustomer select Company_Name from Customer
Else    
	Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)    

--Temp Table To Dump the Fields from Invoice and Service Invoice

Create Table #Temp_Cust(CustId nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustName nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,Qty Decimal(18,6),SaleValue Decimal(18,6))

Insert into #Temp_Cust
--Invoice
Select Cus.CustomerID, "Customer" = Cus.Company_Name,     
"Total Qty" = Sum(IsNull(Invd.Quantity,0)),
"Total Sale Value" = sum(Distinct    
case IA.InvoiceType 
	when 4 then -IsNull(IA.NetValue,0) 
	when 5 then -IsNull(IA.NetValue,0)
	when 6 then -IsNull(IA.NetValue,0)
	else IsNull(IA.NetValue,0) end)    
From Customer Cus, InvoiceAbstract IA,InvoiceDetail Invd    
Where Cus.CustomerID = IA.CustomerID     
and IA.InvoiceId=Invd.InvoiceId
and Cus.Company_Name IN (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer)     
and IA.InvoiceDate between @FromDate and @ToDate    
and IsNull(IA.Status,0) & 192 = 0    
Group by Cus.CustomerID, Cus.Company_Name 

Insert into #Temp_Cust 
---Service Invoice
Select Cus.CustomerID, "Customer" = Cus.Company_Name,     
"Total Qty" = Sum(IsNull(SerDet.Quantity,0)),
"Total Sale Value" = Sum(IsNull(SerDet.NetValue,0)) 
From Customer Cus, ServiceInvoiceAbstract SerAbs,ServiceInvoiceDetail SerDet
Where Cus.CustomerID = SerAbs.CustomerID
and SerAbs.ServiceInvoiceId=SerDet.ServiceInvoiceId
and Cus.Company_Name IN (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer)     
and SerAbs.ServiceInvoiceDate between @FromDate and @ToDate    
and IsNull(SerAbs.Status,0) & 192 = 0    
and IsNull(SerDet.Quantity,0) <> 0
and IsNull(SerAbs.ServiceInvoiceType,0) = 1
Group by Cus.CustomerID, Cus.Company_Name 

Select CustId,Custname as "Customer Name",sum(Qty) as "Total Qty",
sum(Salevalue) as "Total Sale Value" 
from #Temp_Cust  group by CustId,Custname

Drop Table #Temp_cust
Drop Table #tmpCustomer

END    


