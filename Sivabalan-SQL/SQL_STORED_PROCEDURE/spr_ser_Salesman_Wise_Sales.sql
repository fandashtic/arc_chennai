CREATE procedure [dbo].[spr_ser_Salesman_Wise_Sales](@Salesman VARCHAR(2550),           
@FromDATE DATETIME ,@TODATE DATETIME )           
AS           

Begin
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpSale(Salesman_Name varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @Salesman='%'
	Insert into #tmpSale Select Salesman_Name From Salesman
Else
	Insert into #tmpSale Select * From dbo.sp_SplitIn2Rows(@Salesman ,@Delimeter)

Create Table #Temp_Salesman(SaleId Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Salesman Varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustId Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustName varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
NetVal Decimal(18,6),TotQty Decimal(18,6))
    
If @Salesman = '%'
Begin
	-- Trade Invoice For all Salesman
	Insert into #Temp_Salesman
	Select  Cast (IsNull(Salesman.Salesmanid, 0 ) as varchar) +  ',' + (IsNull(InvoiceAbstract.CustomerID,0 )) ,       
	"Salesman" = Case IsNull(Salesman.Salesman_Name, '' ) when '' then 'Others' else Salesman.Salesman_Name end ,           
	"Customer ID" = IsNull(InvoiceAbstract.CustomerID, ''),     
	"Company Name" = IsNull(Customer.Company_Name, '') ,           
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) ELSE IsNull(InvoiceDetail.Amount,0) END),           
	"Total Quantity" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) ELSE IsNull(InvoiceDetail.Quantity,0) END)        
	From InvoiceAbstract, InvoiceDetail, Customer, Salesman
	Where InvoiceAbstract.Customerid *= Customer.Customerid    
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid           
	And InvoiceAbstract.InvoiceDate Between @FromDATE And @TODATE           
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanId           
	And Salesman.Salesman_Name in (Select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSale)     
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0           
	And InvoiceAbstract.InvoiceType in (1,3,4)           
	Group By  Salesman.SalesmanID, Salesman.Salesman_name,           
	InvoiceAbstract.CustomerID, Customer.Company_Name           
	Order By Salesman.Salesman_name        

	--Service Invoice For all Salesman          	
	Insert into #Temp_Salesman
	Select  '0,' + (IsNull(SerAbs.CustomerID,0 )),
	"Salesman" = 'Others',
	"Customer ID" = IsNull(SerAbs.CustomerID, ''),
	"Company Name" = IsNull(Customer.Company_Name, '') ,                 
	"Net Value (%c)" = Sum(IsNull(SerDet.NetValue,0)),                 
	"Total Quantity" = Sum(IsNull(SerDet.Quantity,0)) 
	From ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet, Customer
	Where SerAbs.ServiceInvoiceid = SerDet.ServiceInvoiceid                 
	And SerAbs.Customerid = Customer.Customerid                 
	And SerAbs.ServiceInvoiceDate Between @FromDATE And @TODATE
	And IsNull(SerAbs.Status,0) & 192  = 0                 
	And IsNull(SerAbs.ServiceInvoiceType,0) =1
	And IsNull(SerDet.SpareCode,'') <> ''
	Group By  SerAbs.CustomerID,Customer.Company_Name            

End
Else
Begin
	-- Trade Invoice For Particular Salesman
	Insert into #Temp_Salesman
	Select  Cast (IsNull(Salesman.Salesmanid, 0 ) as varchar) +  ',' + (IsNull(InvoiceAbstract.CustomerID,0 )) ,       
	"Salesman" = Case IsNull(Salesman.Salesman_Name, '' ) when '' then 'Others' else Salesman.Salesman_Name end ,           
	"Customer ID" = IsNull(InvoiceAbstract.CustomerID, ''),     
	"Company Name" = IsNull(Customer.Company_Name, '') ,           
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) ELSE IsNull(InvoiceDetail.Amount,0) END),           
	"Total Quantity" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) ELSE IsNull(InvoiceDetail.Quantity,0) END)        
	From InvoiceAbstract, InvoiceDetail, Customer, Salesman           
	Where InvoiceAbstract.Customerid *= Customer.Customerid           
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid           
	And InvoiceAbstract.InvoiceDate Between @FromDATE And @TODATE           
	And InvoiceAbstract.SalesmanID = Salesman.Salesmanid           
	And Salesman.Salesman_Name in (Select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSale)         
	And IsNull(InvoiceAbstract.Status,0) & 128 = 0           
	And InvoiceAbstract.InvoiceType in (1,3,4)           
	Group By  Salesman.Salesmanid , Salesman.Salesman_name,           
	InvoiceAbstract.CustomerID, Customer.Company_Name           
	Order By Salesman.Salesman_name 	
End 
Begin
	Select SaleId ,Salesman as "Salesman",CustId as "Customer ID",
	CustName as "Company Name",Sum(NetVal) as "Net Value (%c)",
	Sum(TotQty)  as "Total Quantity"  
	From #Temp_Salesman 
	Group By SaleId,Salesman,CustId,CustName
	Order By Salesman
	Drop Table #Temp_Salesman
End
End
