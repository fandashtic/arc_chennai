CREATE procedure [dbo].[spr_salesmanwise_packing_list_abstract_pidilite](@Category nVarchar(2550),
							@SALESMAN nvarchar(2550),
							@FROMNO nvarchar(50),
							@TONO nvarchar(50),
							@FROMDATE datetime,
							@TODATE datetime)
AS

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpSalesMan(SalesManName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @SALESMAN = N'%'   
   Insert into #tmpSalesMan select Salesman_Name from Salesman  
Else  
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SALESMAN,@Delimeter)  

Create Table #tempCategory(CategoryID int, Status int)                      
exec GetLeafCategories N'%', @Category                    

IF @FROMNO = N'%' SET @FROMNO = N'0'
IF @TONO = N'%' SET @TONO = N'2147483647'

IF @SALESMAN = N'%'
BEGIN
Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + N';' + Cast(@FROMNO as nvarchar) + N';' 
	+ Cast(@TONO as nvarchar), "Salesman Name" = IsNull(Salesman.Salesman_Name, N'Others'),
	"Sales Value (%c)" = Sum(NetValue - IsNull(Freight, 0)), 
	"Total Invoices" = Count(InvoiceAbstract.InvoiceID), 
	"Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)
From	InvoiceAbstract, invoicedetail, items, Salesman
Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
	(InvoiceAbstract.Status & 128) = 0 And 
	InvoiceAbstract.InvoiceType in (1, 3) And
    InvoiceAbstract.invoiceid = invoicedetail.invoiceid And
    invoicedetail.Product_code = Items.Product_code And
    Items.CategoryID In (Select CategoryID From #tempCategory) And
	InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And
	Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And
	InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name
end
ELSE
BEGIN
Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + N';' + Cast(@FROMNO as nvarchar) + N';' 
	+ Cast(@TONO as nvarchar), "Salesman Name" = IsNull(Salesman.Salesman_Name, N'Others'),
	"Sales Value (%c)" = Sum(NetValue - IsNull(Freight, 0)), 
	"Total Invoices" = Count(InvoiceAbstract.InvoiceID), 
	"Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)
From	InvoiceAbstract, invoicedetail, items, Salesman
Where	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And
	(InvoiceAbstract.Status & 128) = 0 And 
	InvoiceAbstract.InvoiceType in (1, 3) And
    InvoiceAbstract.invoiceid = invoicedetail.invoiceid And
    invoicedetail.Product_code = Items.Product_code And
    Items.CategoryID In (Select CategoryID From #tempCategory) And
	InvoiceAbstract.SalesmanID = Salesman.SalesmanID And
	Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And
	InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name
END
Drop table #tmpSalesMan
