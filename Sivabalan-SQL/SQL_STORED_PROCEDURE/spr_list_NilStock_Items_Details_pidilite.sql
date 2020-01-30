CREATE Procedure spr_list_NilStock_Items_Details_pidilite (@ItemCode nvarchar(50))  
As  
Declare @VouPrefix nvarchar(20)  
  
Select @VouPrefix = Prefix From Voucherprefix Where TranID = N'INVOICE'  
  
Select InvoiceType, "Invoice Type" = Case IsNull(InvoiceType, 0)  
 When 1 Then N'Invoice' When 2 Then N'Retail Invoice'
 When 5 Then N'Retail Sales Return Salable'
 When 6 Then N'Retail Sales Return Damages'
 When 3 Then N'Amend Invoice' When 4 Then Case When Status & 32 = 0 Then N'Sales Return Salable'  
 Else N'Sales Return Damages' End
 Else N'' End,   
 "Invoice ID" = @VouPrefix +  Cast(ia.InvoiceID As nvarchar),   
 "Doc Ref" = DocReference,   
 "Date" = cast(Datepart(dd,InvoiceDate) As nvarchar)+N'/'+  
 cast(Datepart(mm,InvoiceDate) As nvarchar)+N'/'+cast(Datepart(yy,InvoiceDate) As nvarchar),  
 "Customer Name" = Company_Name, 
 "Quantity" = Sum(Quantity),
 "Reporting UOM" = Sum(Quantity / (Case IsNull(it.ReportingUnit, 1) When 0 Then 1 Else IsNull(it.ReportingUnit, 1) End)),
 "Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
 "Rate" = Sum(SalePrice),    
 "Item Gross Value" = Sum(Quantity * SalePrice)  From   
 InvoiceAbstract ia, InvoiceDetail ide, Customer cu, Items it   
 Where ia.InvoiceID = ide.InvoiceID And ia.CustomerID = cu.CustomerID  
 And ide.Product_Code = it.Product_Code And ide.Product_Code = @ItemCode  
 And Status & 192 = 0
 Group By ide.Product_Code, InvoiceType, ia.InvoiceID, Company_Name,  
 DocReference, InvoiceDate, Status  



