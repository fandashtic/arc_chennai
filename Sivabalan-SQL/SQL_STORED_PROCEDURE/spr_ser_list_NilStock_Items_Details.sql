CREATE Procedure spr_ser_list_NilStock_Items_Details (@ItemCode VarChar(50))  
As  
Declare @VouPrefix VarChar(20)  

Create Table #NilStockTemp(InvType nvarchar(100) collate SQL_Latin1_General_Cp1_CI_AS,
[Invoice Type] nvarchar(100) collate SQL_Latin1_General_Cp1_CI_AS,
[Invoice ID] nvarchar(25) collate SQL_Latin1_General_Cp1_CI_AS,
[Doc Ref] varchar(255) collate SQL_Latin1_General_Cp1_CI_AS,
--[Date] nvarchar(50) collate SQL_Latin1_General_Cp1_CI_AS,
[Date] DateTime,
[Customer Name] nvarchar(150)collate SQL_Latin1_General_Cp1_CI_AS,
Quantity Decimal(18,6),
Rate Decimal(18,6),
[Item Gross Value] Decimal(18,6))
  
--Select @VouPrefix = Prefix From Voucherprefix Where TranID = 'INVOICE'  

Insert into #NilStockTemp
  
Select InvoiceType, "Invoice Type" = Case IsNull(InvoiceType, 0)  
 When 1 Then 'Invoice' When 2 Then 'Retail Invoice'
 When 5 Then 'Retail Sales Return Salable'
 When 6 Then 'Retail Sales Return Damages'
 When 3 Then 'Amend Invoice' When 4 Then Case When Status & 32 = 0 Then 'Sales Return Salable'  
 Else 'Sales Return Damages' End
 Else '' End,   
 "Invoice ID" = VoucherPrefix.Prefix +  Cast(ia.InvoiceID As VarChar),   
 "Doc Ref" = DocReference,   
--  "Date" = cast(Datepart(dd,InvoiceDate) As VarChar)+'/'+  
--  cast(Datepart(mm,InvoiceDate) As VarChar)+'/'+cast(Datepart(yy,InvoiceDate) As VarChar),  
 "Date" = dbo.stripdatefromtime(InvoiceDate),
 "Customer Name" = Company_Name, "Quantity" = Sum(Quantity),   
 "Rate" = Sum(SalePrice),    
 "Item Gross Value" = Sum(Quantity * SalePrice)  From   
 InvoiceAbstract ia, InvoiceDetail ide, Customer cu, Items it,Voucherprefix  
 Where ia.InvoiceID = ide.InvoiceID And ia.CustomerID = cu.CustomerID  
 And ide.Product_Code = it.Product_Code And ide.Product_Code = @ItemCode  
 And Status & 192 = 0
And Voucherprefix.TranID = 'INVOICE'
 Group By ide.Product_Code, InvoiceType, ia.InvoiceID, Company_Name,  
 DocReference, InvoiceDate, Status,Voucherprefix.Prefix  

Insert into #NilStockTemp
 Select ServiceInvoiceType, "Invoice Type" = Case IsNull(ServiceInvoiceType, 0)  
 When 1 Then 'Service Invoice' 
 Else '' End,   
 "Invoice ID" = VoucherPrefix.Prefix +  Cast(ia.ServiceInvoiceID As VarChar),   
 "Doc Ref" = DocReference,   
--  "Date" = cast(Datepart(dd,ServiceInvoiceDate) As VarChar)+'/'+  
--  cast(Datepart(mm,ServiceInvoiceDate) As VarChar)+'/'+cast(Datepart(yy,ServiceInvoiceDate) As VarChar),  
 "Date" = dbo.stripdatefromtime(ServiceInvoiceDate),
 "Customer Name" = Company_Name, "Quantity" = Sum(Isnull(ide.Quantity,0)),   
 "Rate" = Sum(Isnull(ide.Price,0)),    
 "Item Gross Value" = Sum(Isnull(ide.Quantity,0) * Isnull(ide.Price,0)) 
	From ServiceInvoiceAbstract ia, ServiceInvoiceDetail ide, Customer cu, Items it,Voucherprefix   
	Where ia.ServiceInvoiceID = ide.ServiceInvoiceID And ia.CustomerID = cu.CustomerID  
	And ide.SpareCode = it.Product_Code And ide.SpareCode = @ItemCode  
	And Isnull(Status,0) & 192 = 0
	And Isnull(ide.Sparecode,'') <> ''
	And Voucherprefix.TranID = 'SERVICEINVOICE'
	Group By ide.SpareCode, ServiceInvoiceType, ia.ServiceInvoiceID, Company_Name,  
	DocReference, ServiceInvoiceDate, Status ,Voucherprefix.Prefix 

select * from #NilStockTemp order by [Date]

Drop table  #NilStockTemp









