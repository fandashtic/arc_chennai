CREATE procedure [dbo].[Spr_List_VATINPut_Register_Elf](@FromDate Datetime, @ToDate DateTime ) As    
Declare @Inv nVarchar(15)    
Select @Inv = Prefix From voucherprefix where tranid=N'Invoice'    
Create Table #TmpVat ( [IDate] DateTime,SlNo Int Identity(1,1), [Date] DateTime, [Cash MemoNo/ BillNo] NVarchar(100),    
 [Name & Address of Buyer] NVarchar(510), [Seller Vat No] NVarchar(20),    
 [Quantity] Decimal(18,6), [Item Name] NVarchar(255), [Price Per Unit (%c)] Decimal(18,6),    
 [Value (%c)] Decimal(18,6), [Vat Rate] Decimal(18,6), [Tax Amount (%c)] Decimal(18,6),    
 [Total Amount (%c)] Decimal(18,6)) --, [Remarks] NVarchar(255))    
Insert Into #TmpVat ([IDate], [Date], [Cash MemoNo/ BillNo],    
 [Name & Address of Buyer], [Seller Vat No],     
 [Quantity], [Item Name], [Price Per Unit (%c)],    
 [Value (%c)], [Vat Rate], [Tax Amount (%c)],    
 [Total Amount (%c)]--,    
--[Remarks]    
)    
Select  INAB.InvoiceDate, INAB.InvoiceDate, @Inv+ Cast(INAB.DocumentId as nVarchar),    
  CUS.Company_Name +' '+ CUS.BillingAddress, Cus.Tin_Number,    
  INDT.Quantity, ITM.ProductName, INDT.SalePrice,    
  (INDT.Quantity * INDT.SalePrice)as value, 
  Case When CUS.Locality = 1  Then INDT.TaxCode Else INDT.TaxCode2 End  , INDT.TaxAmount, INDT.Amount     
--  Case When INDT.TaxSuffAmount <> 0 Then INDT.TaxSuffAmount Else INDT.TaxAmount End, INDT.Amount     

    
From invoiceabstract INAB, Customer CUS,    
  InvoiceDetail INDT, Items ITM    
    
Where INAB.InvoiceID = INDT.InvoiceId  And    
  INAB.CustomerID = CUS.CustomerID And    
  INDT.Product_Code = ITM.Product_Code And    
  INAB.InvoiceDate Between  @FromDate And @ToDate And    
  (            
        (--Trade Invoice----------------            
         (INAB.Status & 192) = 0            
         and INAB.InvoiceType in (1, 3)            
        )-------------------------------            
   or             
        (--Sales Return-----------------            
      (INAB.Status & 192) = 0      
         and INAB.InvoiceType = 4            
        )-------------------------------     
   or    
        (--Retail Invoice----------------            
         (INAB.Status & 192) = 0            
         and INAB.InvoiceType in (2)            
        )-------------------------------               
      )    And    
  INDT.Vat = 1    
Order by InvoiceDate    
Select * from #TmpVat    
Drop Table #TmpVat
