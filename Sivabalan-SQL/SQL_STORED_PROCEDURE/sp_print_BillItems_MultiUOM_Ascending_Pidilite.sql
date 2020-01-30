CREATE procedure [dbo].[sp_print_BillItems_MultiUOM_Ascending_Pidilite](@BILLNO INT)    
    
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
"Octroi Amount" = Sum(IsNull(OctroiAmount,0)),"Freight" = Sum(IsNull(Freight,0)),"1" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 17 And BD.ItemSerial = BillDetail.Serial ),"AA" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 7 And BD.ItemSerial = BillDetail.Serial ),"BB" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 9 And BD.ItemSerial = BillDetail.Serial ),"CC" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 19 And BD.ItemSerial = BillDetail.Serial ),"CD" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 20 And BD.ItemSerial = BillDetail.Serial ),"CD1" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 21 And BD.ItemSerial = BillDetail.Serial ),"CD2" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 22 And BD.ItemSerial = BillDetail.Serial ),"CD3" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 23 And BD.ItemSerial = BillDetail.Serial ),"CD4" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 24 And BD.ItemSerial = BillDetail.Serial ),"FF" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 16 And BD.ItemSerial = BillDetail.Serial ),"GG" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 12 And BD.ItemSerial = BillDetail.Serial ),"HH" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 11 And BD.ItemSerial = BillDetail.Serial ),"JK" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 13 And BD.ItemSerial = BillDetail.Serial ),"PD" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 8 And BD.ItemSerial = BillDetail.Serial ),"QD" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 5 And BD.ItemSerial = BillDetail.Serial ),"RR" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 15 And BD.ItemSerial = BillDetail.Serial ),"SD" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 6 And BD.ItemSerial = BillDetail.Serial ),"TT" = (Select Sum(BD.DiscountAmount) From BillDiscount BD Where BillID = @BILLNO And BD.DiscountID = 18 And BD.ItemSerial = BillDetail.Serial )      
FROM BillDetail, Items, UOM    
WHERE BillDetail.BillID = @BillNo     
AND BillDetail.Product_Code = Items.Product_Code    
AND Items.UOM *= UOM.UOM  
Group by BillDetail.Product_Code , Items.ProductName, PurchasePrice,  BillDetail.PKD,   
BillDetail.PTS, BillDetail.PTR, BillDetail.ECP , BillDetail.TaxSuffered, BillDetail.Batch,  
BillDetail.Expiry, Items.description, BillDetail.Serial,   
BillDetail.PurchasePriceBeforeExciseAmount, BillDetail.ExciseDuty  
Order By  BillDetail.Product_Code , Items.ProductName
