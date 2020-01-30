CREATE procedure [dbo].[sp_print_BillItems_MultiUOM_ComboPack](@BillNo INT)    
    
AS    
  
DECLARE @ItemCode nvarchar(500)  
DECLARE @BatchNumber nvarchar(500)  
DECLARE @SQL nvarchar(2000)  
  
SET @SQL = N''  
SET @ItemCode = N''  
SET @BatchNumber = N''  
    
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
"ECP" = BillDetail.ECP    
INTO #Temp1 FROM BillDetail, Items, UOM    
WHERE Items.Product_Code = BillDetail.Product_Code 
AND Items.UOM *= UOM.UOM  And BillDetail.BillID = @BillNo 
Group by BillDetail.Product_Code , Items.ProductName, PurchasePrice,  BillDetail.PKD,   
BillDetail.PTS, BillDetail.PTR, BillDetail.ECP , BillDetail.TaxSuffered, BillDetail.Batch,  
BillDetail.Expiry, Items.description  
  
SELECT "Pack" = BillDetail.Product_Code, "Item Code" = Bill_Combo_Components.Component_Item_Code,     
"Item Name" = Items.ProductName,   
"UOM2Quantity" = 0,  
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Bill_Combo_Components.Component_Item_Code )),  
"UOM1Quantity" = 0,  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Bill_Combo_Components.Component_Item_Code )),  
"UOMQuantity" = Sum(Bill_Combo_Components.Received_Quantity),  
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Bill_Combo_Components.Component_Item_Code )),      
"Description" = Items.description,  
"Purchase Price" = Bill_Combo_Components.PurchasePrice,     
"Amount" = Sum(Isnull(Bill_Combo_Components.Amount, 0)), "Tax Suffered" = Bill_Combo_Components.TaxSuffered,     
"Tax Amount" = Sum(Isnull(Bill_Combo_Components.TaxSufferedValue,0 )),    
"Batch" = BillDetail.Batch, "Expiry" = BillDetail.Expiry,     
"PKD" = BillDetail.PKD, "PTS" = Bill_Combo_Components.PTS, "PTR" = Bill_Combo_Components.PTR,    
"ECP" = Bill_Combo_Components.ECP    
INTO #Temp2 FROM Bill_Combo_Components, Items, UOM, BillDetail   
WHERE Items.Product_Code = Bill_Combo_Components.Component_Item_Code    
AND Items.UOM *= UOM.UOM And  
Bill_Combo_Components.ComboID = BillDetail.ComboID And  
Isnull(BillDetail.ComboID,0) <> 0 And BillDetail.BillID = @BillNo  
Group by Bill_Combo_Components.Component_Item_Code, Items.ProductName, Bill_Combo_Components.PurchasePrice,  BillDetail.PKD,   
Bill_Combo_Components.PTS, Bill_Combo_Components.PTR, Bill_Combo_Components.ECP , Bill_Combo_Components.TaxSuffered, BillDetail.Batch,  
BillDetail.Expiry, Items.description, BillDetail.Product_Code  
  
SELECT * INTO #Temp3 FROM #Temp1 WHERE 1 < 0   

 
DECLARE S1 CURSOR FOR Select [Item Code], [Batch] FROM #Temp1  
OPEN S1  
FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber  
 WHILE @@FETCH_STATUS = 0   
 BEGIN  
  INSERT INTO #Temp3 SELECT * FROM #Temp1 Where [Item Code] = @ItemCode And [Batch] = @BatchNumber   
  INSERT INTO #Temp3 SELECT N'   ' + [Item Code],N'   ' + [Item Name], [UOM2Quantity], [UOM2Description],   
  [UOM1Quantity], [UOM1Description], [UOMQuantity], [UOMDescription], [Description], [Purchase Price],  
  [Amount], [Tax Suffered], [Tax Amount], N'', [Expiry], [PKD], [PTS], [PTR], [ECP] FROM #Temp2   
  WHERE Pack = @ItemCode AND [Batch] = @BatchNumber  
 FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber  
 END  
CLOSE S1  
DEALLOCATE S1  
  
SELECT * FROM #TEMP3  
  
DROP TABLE #TEMP1  
DROP TABLE #TEMP2  
DROP TABLE #TEMP3
