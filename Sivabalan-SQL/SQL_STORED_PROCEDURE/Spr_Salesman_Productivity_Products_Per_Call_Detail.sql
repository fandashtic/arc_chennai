CREATE procedure [dbo].[Spr_Salesman_Productivity_Products_Per_Call_Detail]
                                                             (@SalesmanID Int,
							      @ProHier nvarchar(255),
                                                              @FromDate DateTime,
		                			      @ToDate DateTime)
As
Declare @MLOthers NVarchar(50)
Declare @MLSalesReturnInvoice NVarchar(50)
Declare @MLInvoice NVarchar(50)
Set @MLOthers=dbo.LookupDictionaryItem(N'Others', Default)
Set @MLSalesReturnInvoice=dbo.LookupDictionaryItem(N'Sales Return Invoice', Default)
Set @MLInvoice=dbo.LookupDictionaryItem(N'Invoice', Default)

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @ProHier, N'%'
Select Distinct CategoryID InTo #temp From #tempCategory

Declare @Prefix nvarchar(50)
Select @Prefix = Prefix From VoucherPrefix Where TranID Like N'INVOICE'

Select IsNull(ia.DocumentID, 0), "Invoice Number" = @Prefix + Cast(IsNull(ia.DocumentID, 0) As nvarchar),
"Invoice Date" = ia.InvoiceDate, 
"Customer Name" = Case ia.InvoiceType When 2 Then @MLOthers Else IsNull(c.Company_Name, @MLOthers) End,
"No of Products Sold" = Count(Distinct IsNull(ids.Product_Code, N'')),
"Invoice Type" = Case IsNull(ia.InvoiceType, 0) When 4 Then @MLSalesReturnInvoice Else @MLInvoice End
From InvoiceAbstract ia, InvoiceDetail ids, Customer c, Items it, #temp
Where ia.InvoiceID = ids.InvoiceID And ia.CustomerID *= c.CustomerID And 
it.Product_Code = ids.Product_Code And it.CategoryID = #temp.CategoryID And
(Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) = @SalesmanID And 
ia.InvoiceDate Between @FromDate And @ToDate And
IsNull(ia.Status, 0) & 192 = 0 Group By ia.DocumentID, ia.InvoiceDate, c.Company_Name,
ia.InvoiceType
Order By ia.DocumentID

Drop Table #tempCategory
Drop Table #temp
