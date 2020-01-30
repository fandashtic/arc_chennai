CREATE PROCEDURE [dbo].[sp_print_BillItems_MultiUOM](@BillNo INT)  
  
AS  
  
SELECT "Item Code" = BillDetail.Product_Code,   
"Item Name" = Items.ProductName, 
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(BillDetail.Product_Code, Sum(BillDetail.Quantity)),
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  BillDetail.Product_Code )),
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(BillDetail.Product_Code, Sum(BillDetail.Quantity)),
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  BillDetail.Product_Code )),
"UOMQuantity" = dbo.GetLastLevelUOMQty(BillDetail.Product_Code, Sum(BillDetail.Quantity)),
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  BillDetail.Product_Code )),    
"Description" = Items.description,
"Purchase Price" = PurchasePrice,   
"Amount" = Sum(Isnull(Amount, 0)), "Tax Suffered" = BillDetail.TaxSuffered,   
"Tax Amount" = Sum(Isnull(BillDetail.TaxAmount,0 )),  
"Batch" = BillDetail.Batch, "Expiry" = BillDetail.Expiry,   
"PKD" = BillDetail.PKD, "PTS" = BillDetail.PTS, "PTR" = BillDetail.PTR,  
"ECP" = BillDetail.ECP, 
"PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount, 0), 
"Excise Duty" = IsNull(BillDetail.ExciseDuty, 0), 
"Discount %" =  Case (Select isnull(DiscountOption,1) from BillAbstract where BillID=@BillNo) When 2 Then
		IsNull(BillDetail.Discount,0)/(IsNull(BillDetail.Quantity,0)*IsNull(BillDetail.PurchasePrice,0))*100
		Else
		isnull(Billdetail.Discount,0)
		End,
"Item Disc Amount" = Case (Select isnull(DiscountOption,1) from BillAbstract where BillID=@BillNo) When 2 Then
		        ((IsNull(BillDetail.Discount,0)/(IsNull(BillDetail.Quantity,0)*IsNull(BillDetail.PurchasePrice,0))*100)/100)*(IsNull(BillDetail.Quantity,0)*IsNull(BillDetail.PurchasePrice,0))
		        Else
		       isnull((Billdetail.Discount/100)*(BillDetail.Quantity*BillDetail.PurchasePrice),0)
		       End

FROM BillDetail
Inner Join Items ON BillDetail.Product_Code = Items.Product_Code
Left Outer Join UOM ON Items.UOM = UOM.UOM
WHERE BillDetail.BillID = @BillNo 
Group by BillDetail.Product_Code , Items.ProductName, PurchasePrice,  BillDetail.PKD, 
BillDetail.PTS, BillDetail.PTR, BillDetail.ECP , BillDetail.TaxSuffered, BillDetail.Batch,
BillDetail.Expiry, Items.description, BillDetail.Serial, 
BillDetail.PurchasePriceBeforeExciseAmount, BillDetail.ExciseDuty,BillDetail.Discount,BillDetail.Amount,Billdetail.Quantity
Order By BillDetail.Serial

