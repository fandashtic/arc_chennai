CREATE Procedure spr_list_NilStock_Items_Details (@ItemCode nvarchar(50))  
As  
Declare @VouPrefix nvarchar(20)  
Declare @RETAILSALESRETURNSALEABLE As NVarchar(50)
Declare @RETAILSALESRETURNDAMAGES As NVarchar(50)
Declare @SALESRETURNSALEABLE As NVarchar(50)
Declare @SALESRETURNDAMAGES As NVarchar(50)
Declare @RETAILINVOICE As NVarchar(50)
Declare @INVOICE As NVarchar(50)
Declare @AMENDINVOICE As NVarchar(50)

Set @RETAILSALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Retail Sales Return Saleable', Default)
Set @RETAILSALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Retail Sales Return Damages', Default)
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice' , Default)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @AMENDINVOICE = dbo.LookupDictionaryItem(N'Amend Invoice', Default)

  
Select @VouPrefix = Prefix From Voucherprefix Where TranID = N'INVOICE'  
  
Select InvoiceType, "Invoice Type" = Case IsNull(InvoiceType, 0)  
 When 1 Then @INVOICE When 2 Then @RETAILINVOICE
 When 5 Then @RETAILSALESRETURNSALEABLE
 When 6 Then @RETAILSALESRETURNDAMAGES
 When 3 Then @AMENDINVOICE When 4 Then Case When Status & 32 = 0 Then @SALESRETURNSALEABLE
 Else @SALESRETURNDAMAGES End
 Else N'' End,   
 "Invoice ID" = Case ISNULL(ia.GSTFlag,0) When 0 Then @VouPrefix +  Cast(ia.InvoiceID As nvarchar) Else ISNULL(ia.GSTFullDocID,'') End,   
 "Doc Ref" = DocReference,   
 "Date" = cast(Datepart(dd,InvoiceDate) As nvarchar)+N'/'+  
 cast(Datepart(mm,InvoiceDate) As nvarchar)+N'/'+cast(Datepart(yy,InvoiceDate) As nvarchar),  
 "Customer Name" = Company_Name, "Quantity" = Sum(Quantity),   
 "Rate" = Sum(SalePrice),    
 "Item Gross Value" = Sum(Quantity * SalePrice)  From   
 InvoiceAbstract ia, InvoiceDetail ide, Customer cu, Items it   
 Where ia.InvoiceID = ide.InvoiceID And ia.CustomerID = cu.CustomerID  
 And ide.Product_Code = it.Product_Code And ide.Product_Code = @ItemCode  
 And Status & 192 = 0
 Group By ide.Product_Code, InvoiceType, ia.InvoiceID, Company_Name,  
 DocReference, InvoiceDate, Status  ,ia.GSTFlag,ia.GSTFullDocID
