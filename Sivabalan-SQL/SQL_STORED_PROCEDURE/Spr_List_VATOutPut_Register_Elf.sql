CREATE Procedure Spr_List_VATOutPut_Register_Elf(@FromDate Datetime, @ToDate DateTime ) As      
Declare @Bll nVarchar(15)      
Select @Bll = Prefix From voucherprefix where tranid=N'Bill'      
Create Table #TmpVat ( [BDate] DateTime, SlNo Int Identity(1,1), [Date] DateTime, [Cash MemoNo/ BillNo] NVarchar(100),      
 [Name & Address of Buyer] NVarchar(255), [Buyer Vat No] NVarchar(20),      
 [Quantity] Decimal(18,6), [Item Name] NVarchar(255), [Price Per Unit (%c)] Decimal(18,6),      
 [Value (%c)] Decimal(18,6), [Vat Rate] Decimal(18,6), [Tax Amount (%c)] Decimal(18,6),      
 [Total Amount (%c)] Decimal(18,6), [Remarks] NVarchar(255))      
Insert Into #TmpVat ([BDate], [Date], [Cash MemoNo/ BillNo],      
 [Name & Address of Buyer],  [Quantity], [Buyer Vat No],      
 [Item Name], [Price Per Unit (%c)], [Value (%c)],      
 [Vat Rate], [Tax Amount (%c)], [Total Amount (%c)],      
 [Remarks])      
Select  BLAB.BillDate, BLAB.BillDate, @Bll + Cast(BLAB.DocumentId as varchar),      
  VEN.Vendor_Name +' ' +VEN.Address, BLDT.Quantity, VEN.Tin_Number,      
  ITM.ProductName, BLDT.PurchasePrice, (BLDT.Quantity * BLDT.PurchasePrice),      
  BLDT.TaxSuffered , BLDT.TaxAmount, (BLDT.Amount + BLDT.TaxAmount),      
  BLAB.Remarks      
      
From BillAbstract BLAB, Vendors VEN,      
  BillDetail BLDT, Items ITM      
      
Where BLAB.BillID = BLDT.BillId      And      
  BLAB.VendorID = VEN.VendorID     And      
  BLDT.Product_Code = ITM.Product_Code   And      
  BLAB.BillDate Between  @FromDate And @ToDate  And      
  (ISnull(BLAB.Status,0) & 128) = 0      And      
  BLDT.Vat = 1      
Order by BLAB.BillDate      
Select * from #TmpVat       
Drop Table #TmpVat      
    
  


