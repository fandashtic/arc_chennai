CREATE procedure [dbo].[sp_print_BillItems_ComboPack](@BillNo INT)    
    
AS    

DECLARE @ItemCode nvarchar(500)
DECLARE @BatchNumber nvarchar(500)
DECLARE @UOM nvarchar(50)
DECLARE @SQL nvarchar(2000)
DECLARE @ComboID INT

SET @SQL = N''
SET @ItemCode = N''
SET @BatchNumber = N''
SET @UOM = N''
    
SELECT "Item Code" = BillDetail.Product_Code,     
"Item Name" = Items.ProductName, 
"Description" = Items.description,  
"Quantity" = BillDetail.UOMQty,  
"UOM" = UOM.Description,   
"Purchase Price" =UOMPrice,     
"Amount" = Isnull(Amount, 0), "Tax Suffered" = isnull(BillDetail.TaxSuffered, 0),
"Tax Amount" = Isnull(BillDetail.TaxAmount,0),    
"Batch" = BillDetail.Batch, "Expiry" = BillDetail.Expiry,     
"PKD" = BillDetail.PKD, "PTS" = BillDetail.PTS, "PTR" = BillDetail.PTR,    
"ECP" = BillDetail.ECP,
"ComboID" = BillDetail.ComboID    
INTO #Temp1 FROM BillDetail, Items, UOM    
WHERE BillDetail.BillID = @BillNo     
AND BillDetail.Product_Code = Items.Product_Code    
AND BillDetail.UOM *= UOM.UOM  

SELECT "Pack" = BillDetail.Product_Code, "Item Code" = Bill_Combo_Components.Component_Item_Code,   
"Item Name" = Items.ProductName, 
"Description" = Items.description,
"Quantity" = Bill_Combo_Components.Received_Quantity,
"UOM" = UOM.Description,
"Purchase Price" = Bill_Combo_Components.PurchasePrice,   
"Amount" = Sum(Isnull(Bill_Combo_Components.Amount, 0)), 
"Tax Suffered" = Bill_Combo_Components.TaxSuffered,   
"Tax Amount" = Sum(Isnull(Bill_Combo_Components.TaxSufferedValue,0 )),  
"Batch" = BillDetail.Batch, "Expiry" = BillDetail.Expiry,   
"PKD" = BillDetail.PKD, "PTS" = Bill_Combo_Components.PTS, "PTR" = Bill_Combo_Components.PTR,  
"ECP" = Bill_Combo_Components.ECP,
"ComboID" = BillDetail.ComboID      
INTO #Temp2 FROM Bill_Combo_Components, Items, UOM, BillDetail 
WHERE Items.Product_Code = Bill_Combo_Components.Component_Item_Code  
AND Items.UOM *= UOM.UOM And 
Bill_Combo_Components.ComboID = BillDetail.ComboID And
Isnull(BillDetail.ComboID,0) <> 0 And BillDetail.BillID = @BillNo
Group by Bill_Combo_Components.Component_Item_Code, Items.ProductName, Bill_Combo_Components.PurchasePrice,  BillDetail.PKD, 
Bill_Combo_Components.PTS, Bill_Combo_Components.PTR, Bill_Combo_Components.ECP , Bill_Combo_Components.TaxSuffered, BillDetail.Batch,
BillDetail.Expiry, Items.description, Bill_Combo_Components.Received_Quantity, BillDetail.Product_Code, UOM.Description, BillDetail.ComboID

  
SELECT * INTO #Temp3 FROM #Temp1 WHERE 1 < 0 

DECLARE S1 CURSOR FOR Select [Item Code], [Batch], [UOM], [ComboID] FROM #Temp1
OPEN S1
FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber, @UOM, @ComboID
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO #Temp3 SELECT [Item Code],[Item Name], [Description], [Quantity], 
		[UOM], [Purchase Price], [Amount], [Tax Suffered], [Tax Amount], [Batch],
		[Expiry], [PKD], [PTS], [PTR], [ECP], [ComboID] FROM #Temp1 Where [Item Code] = @ItemCode 
		And [Batch] = @BatchNumber And [UOM] = @UOM 

		INSERT INTO #Temp3 SELECT N'   ' + [Item Code],N'   ' + [Item Name], [Description], [Quantity], 
		[UOM], [Purchase Price], [Amount], [Tax Suffered], [Tax Amount], [Batch],
		[Expiry], [PKD], [PTS], [PTR], [ECP], [ComboID] FROM #Temp2 
		WHERE Pack = @ItemCode AND [Batch] = @BatchNumber And [ComboID] = @ComboID
	FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber, @UOM, @ComboID
	END
CLOSE S1
DEALLOCATE S1

SELECT [Item Code],[Item Name], [Description], [Quantity], 
[UOM], [Purchase Price], [Amount], [Tax Suffered], [Tax Amount], [Batch],
[Expiry], [PKD], [PTS], [PTR], [ECP] FROM #TEMP3

DROP TABLE #TEMP1
DROP TABLE #TEMP2
DROP TABLE #TEMP3
