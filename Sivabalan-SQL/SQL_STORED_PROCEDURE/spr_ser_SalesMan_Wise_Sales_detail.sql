CREATE procedure [dbo].[spr_ser_SalesMan_Wise_Sales_detail](@SALES_CUST NVARCHAR(100),       
      @FromDATE DATETIME ,       
      @TODATE DATETIME )      
AS      
Begin

Declare @SALE int
Declare @CUST NVARCHAR(50)    
Declare @LENSTR INT    
Set @LENSTR = (CHARINDEX(',', @SALES_CUST) )     
Select @SALE = Cast (SUBSTRING(@SALES_CUST,  1 , (@lENSTR - 1 ))   as int)
Select @CUST = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )    

--If SaleId > 0 it takes details From Invoice

If @SALE > 0
	Select 	InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName,       
	"Quantity" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) ELSE IsNull(InvoiceDetail.Quantity,0) END),      
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) ELSE IsNull(InvoiceDetail.Amount,0) END)      
	From InvoiceAbstract, InvoiceDetail, Items, Salesman  , Customer    
	Where InvoiceDetail.Product_Code = Items.Product_Code      
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid      
	And InvoiceAbstract.InvoiceDate Between @FromDATE And @TODATE      
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID      
	And InvoiceAbstract.InvoiceType in (1,3,4)      
	And Invoiceabstract.customerid = customer.customerid    
	And Invoiceabstract.customerid like @CUST    
	And IsNull(invoiceabstract.Salesmanid, 0)  =  @SALE    
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0      
	Group By InvoiceDetail.Product_Code, Items.ProductName 
	order by Items.ProductName
Else
--If SaleId = 0 it takes details From Invoice And Service Invoice
	Create Table #Temp(ProductCode Varchar(30)  COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProductName Varchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Qty Decimal(18,6),NetVal Decimal(18,6))
	--Invoice
	Insert into #Temp
	Select 	InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName,       
	"Quantity" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) ELSE IsNull(InvoiceDetail.Quantity,0) END),      
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) ELSE IsNull(InvoiceDetail.Amount,0) END)      
	From InvoiceAbstract, InvoiceDetail, Items, Salesman  , Customer    
	Where InvoiceDetail.Product_Code = Items.Product_Code      
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid      
	And InvoiceAbstract.InvoiceDate Between @FromDATE And @TODATE      
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID      
	And InvoiceAbstract.InvoiceType in (1,3,4)      
	And Invoiceabstract.customerid = customer.customerid    
	And Invoiceabstract.customerid like @CUST    
	And IsNull(invoiceabstract.Salesmanid, 0)  =  @SALE    
	And IsNull(InvoiceAbstract.Status,0) & 128 = 0      
	Group By InvoiceDetail.Product_Code, Items.ProductName 
	--Service
	Insert into #Temp	
	Select 	SerDet.SpareCode,
	"Item Name" = Items.ProductName,       
	"Quantity" = Sum(IsNull(SerDet.Quantity,0)),      
	"Net Value (%c)" = Sum(IsNull(SerDet.NetValue,0))      
	From ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet, Items, Customer      
	Where SerDet.Sparecode = Items.Product_Code        
	And SerAbs.ServiceInvoiceid = SerDet.ServiceInvoiceid        
	And SerAbs.ServiceInvoiceDate Between @FromDATE And @TODATE        
	And SerAbs.customerid = customer.customerid      
	And SerAbs.customerid like @CUST      
	And IsNull(SerAbs.Status,0) & 192 = 0        
	And IsNull(SerDet.SpareCode,'') <> ''
	And IsNull(SerAbs.ServiceInvoiceType,0) = 1
	Group By SerDet.SpareCode, Items.ProductName   

	Select ProductCode,ProductName as "Item Name" ,
	Sum(Qty) as "Quantity",Sum(NetVal) as "Net Value (%c)"
	From #Temp
	Group by ProductCode,ProductName
	Order By ProductName

	Drop Table #Temp
End
