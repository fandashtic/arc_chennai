CREATE Procedure sp_print_BillItems_RespectiveUOM_Ascending(@Bill_ID Int)
As
Begin
Declare @GRNLIST nVarchar(510)
Declare @RecInvID Int
Declare @LastGRNID Int
Select @GRNLIST = GRNID From BillAbstract Where BillID = @Bill_ID
Select Top 1 @RecInvID = RecdInvoiceID From GRNAbstract Where GRNID in (Select * from dbo.sp_SplitIn2Rows(@GRNLIST,','))
Select @LastGRNID = (Select Top 1 * from dbo.sp_SplitIn2Rows(@GRNLIST,',') Order by 1 Desc)

Create Table #TmpBillDetails([Item Code] nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     [Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     [Description] nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     [UOM] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     [Quantity] Decimal(18,6),
     [Free Qty] Decimal(18,6),
     [UOMPrice] Decimal(18,6),
     [PTS] Decimal(18,6), 
     [PTR] Decimal(18,6),
     [ECP] Decimal(18,6),
     [Spl Price] Decimal(18,6),
     [Invoice Qty] Decimal(18,6),
     [Invoice Free] Decimal(18,6),
     [Pending Qty] Decimal(18,6),
     [Pending Free] Decimal(18,6),
     [Received Qty] Decimal(18,6),
     [Received Free] Decimal(18,6),
     [Processed Qty] Decimal(18,6),
     [Processed Free] Decimal(18,6),
     [Purchase Price] Decimal(18,6),
     [Amount] Decimal(18,6),
     [Tax Rate] Decimal(18,6),
     [TaxAmount] Decimal(18,6),
     [TaxSuffered] Decimal(18,6),
     [Discount] Decimal(18,6),
     [Batch] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     [Expiry] datetime,
     [PKD] datetime,
     [Excise Duty] Decimal(18,6),
     [PPBED] Decimal(18,6),
     [DiscPerUnit] Decimal(18,6))

IF @RecInvID <> 0 
Begin 
 Insert Into #TmpBillDetails
 Select BillDetail.Product_Code,
 Items.ProductName,
 Items.Description,
 UOM.Description,
 Case When Sum(BillDetail.PurchasePrice) = 0 then 0 Else Sum(BillDetail.UOMQty) End, 
 Case When Sum(BillDetail.PurchasePrice) = 0 then Sum(BillDetail.UOMQty) Else 0 End , 
 Sum(BillDetail.UOMPrice), 
 (Sum(BillDetail.PTS) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),   
 (Sum(BillDetail.PTR) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
 (Sum(BillDetail.ECP) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
 (Sum(BillDetail.SpecialPrice) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
 Sum(Case when IRDet.SalePrice = 0 Then 0 Else (Case when IsNull(IRDet.UOM,0) = 0 then IRDet.Quantity Else IRDet.UOMQty End) End),
 Sum(Case When IRDet.SalePrice = 0 then IRDet.Quantity Else 0 End),
 Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Pending End),
 Sum(Case When IRDet.SalePrice = 0 Then IRDet.Pending Else 0 End),
 Sum(GRNDet.QuantityReceived),
 Sum(GRNDet.FreeQty),
 Sum(Case when IRDet.SalePrice = 0 Then 0 Else IRDet.Quantity End)-Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Pending End),
 Sum(Case When IRDet.SalePrice = 0 then IRDet.Quantity Else 0 End)-Sum(Case When IRDet.SalePrice = 0 Then IRDet.Pending Else 0 End),
 Sum(BillDetail.PurchasePrice), 
 Sum(BillDetail.Amount), 
 Max(Tax.Percentage),
 Sum(BillDetail.TaxAmount), 
 Sum(BillDetail.TaxSuffered), 
 Max(Discount),  
 BillDetail.Batch, 
 BillDetail.Expiry, 
 BillDetail.PKD,   
 Sum(IsNull(BillDetail.ExciseDuty,0)),
 Sum(IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0)),
 Sum(BillDetail.DiscPerUnit)
From BillDetail
Inner Join InvoiceDetailReceived IRDet On IRDet.Batch_Number = BillDetail.Batch
Inner Join Items On IRDet.Product_Code = Items.Product_Code And BillDetail.Product_Code = Items.Product_Code
Inner Join GRNDetail GRNDet On GRNDet.Product_Code = Items.Product_Code And GRNDet.Serial = BillDetail.Serial 
Left Outer Join UOM On  BillDetail.UOM = UOM.UOM And IRDet.UOM = UOM.UOM And GRNDet.UOM = UOM.UOM
Left Outer Join TAX On BillDetail.TaxCode = TAX.Tax_Code
Where IRDet.InvoiceID = @RecInvID
 And BillDetail.BillID = @Bill_ID
 And GRNDet.GRNID in (Select * from dbo.sp_SplitIn2Rows(@GRNLIST,','))
Group by BillDetail.Batch, BillDetail.Expiry,
 BillDetail.PKD, BillDetail.Serial,
 UOM.Description, BillDetail.Product_Code,
 Items.ProductName, Items.Description
End
Else 
Begin
  Insert Into #TmpBillDetails
  Select 
  BillDetail.Product_Code,
  Items.ProductName,
  Items.Description,
  UOM.Description,
  Case When Sum(BillDetail.PurchasePrice) = 0 then 0 Else Sum(BillDetail.UOMQty) End, 
  Case When Sum(BillDetail.PurchasePrice) = 0 then Sum(BillDetail.UOMQty) Else 0 End , 
  Sum(BillDetail.UOMPrice), 
  (Sum(BillDetail.PTS) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),   
  (Sum(BillDetail.PTR) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
  (Sum(BillDetail.ECP) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
  (Sum(BillDetail.SpecialPrice) * (Sum(BillDetail.UOMPrice) / (Case When Sum(IsNull(BillDetail.PurchasePrice, 0)) = 0 Then 1 Else Sum(BillDetail.PurchasePrice) End))),  
  Sum(GRNDet.QuantityReceived),
  Sum(GRNDet.FreeQty),
   0,0,
  Sum(GRNDet.QuantityReceived),
  Sum(GRNDet.FreeQty),
  Sum(GRNDet.QuantityReceived),
  Sum(GRNDet.FreeQty),
  Sum(BillDetail.PurchasePrice), 
  Sum(BillDetail.Amount), 
  Max(Tax.Percentage),
  Sum(BillDetail.TaxAmount), 
  Sum(BillDetail.TaxSuffered), 
  Max(Discount),  
  BillDetail.Batch, 
  BillDetail.Expiry, 
  BillDetail.PKD,   
  Sum(IsNull(BillDetail.ExciseDuty,0)),
  Sum(IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0)),
  Sum(BillDetail.DiscPerUnit)
From BillDetail
Inner Join Items On BillDetail.Product_Code = Items.Product_Code
Inner Join GRNDetail GRNDet On GRNDet.Product_Code = Items.Product_Code And GRNDet.Serial = BillDetail.Serial
Left Outer Join UOM On BillDetail.UOM = UOM.UOM And GRNDet.UOM = UOM.UOM
Left Outer Join TAX On BillDetail.TaxCode = TAX.Tax_Code 
Where BillDetail.BillID = @Bill_ID
 And GRNDet.GRNID in (Select * from dbo.sp_SplitIn2Rows(@GRNLIST,','))
Group by BillDetail.Batch, BillDetail.Expiry,
 BillDetail.PKD, BillDetail.Serial,
 UOM.Description, BillDetail.Product_Code,
 Items.ProductName, Items.Description
End 

select "Item Code" = [Item code],
 "Item Name" = [Item Name],
 "Description" = [Description],
 "UOM" = [UOM],
 "Quantity" = [Quantity], 
 "Free Qty" = [Free Qty], 
 "UOMPrice" = [UOMPrice], 
 "PTS" = [PTS],   
 "PTR" = [PTR],  
 "ECP" = [ECP],  
 "Spl Price" = [Spl Price],  
 "Invoice Qty" = [Invoice Qty],
 "Invoice Free" = [Invoice Free],
 "Pending Qty" = [Pending Qty],
 "Pending Free" = [Pending Free],
 "Received Qty" = [Received Qty],
 "Received Free" = [Received Free],
 "Processed Qty" = [Processed Qty],
 "Processed Free" = [Processed Free],
 "Purchase Price" = [Purchase Price], 
 "Amount" = [Amount], 
 "Tax Rate" = [Tax Rate],
 "TaxAmount" = [TaxAmount], 
 "TaxSuffered" = [TaxSuffered], 
 "Discount %" = [Discount],  
 "Batch" = [Batch], 
 "Expiry" = [Expiry], 
 "PKD" = [PKD],   
 "Excise Duty" = [Excise Duty],
 "PPBED" = [PPBED],
 "DiscPerUnit" = [DiscPerUnit]
 From #TmpBillDetails
 Order by [Item code]

 Drop Table #TmpBillDetails
End
