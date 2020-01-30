CREATE PROCEDURE sp_print_GRNitems_MultiUOM_ComboPack(@GRNID int)        
AS        

DECLARE @ItemCode nvarchar(500)
DECLARE @BatchNumber nvarchar(500)
DECLARE @SQL nvarchar(2000)
Declare @FREE As NVarchar(50)
Declare @SALEABLE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)
Set @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)
SET @SQL = N''
SET @ItemCode = N''
SET @BatchNumber = N''

CREATE TABLE #Temp3([Item Code] nvarchar(100), [Item Name] nvarchar(100), [UOM2Quantity] nvarchar(20), 
[UOM2Description] nvarchar(50), [UOM1Quantity] nvarchar(20), [UOM1Description] nvarchar(50),
[UOMQuantity] nvarchar(20), [UOMDescription] nvarchar(50), [Sale Price] nvarchar(100),
[Batch Number] nvarchar(50), [Expiry] nvarchar(50), [PTS] Decimal(18,6), [PTR] Decimal(18,6), [ECP] Decimal(18,6), 
[Company_Price] Decimal(18,6), [Free] nvarchar(200))
    
SELECT  "Item Code" = Batch_Products.Product_Code,"Item Name" = Items.ProductName,         
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
"UOMQuantity" = dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),        
"Sale Price" = Batch_Products.SalePrice,        
"Batch Number"= Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,        
"PTS" = isnull(Batch_Products.PTS, 0), "PTR" = ISNULL(Batch_Products.PTR, 0),         
"ECP" = ISNULL(Batch_Products.ECP, 0),         
"Company_Price" = ISNULL(Batch_Products.Company_Price, 0),          
"Free" = Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End    
INTO #temp1 FROM Batch_Products, Items, ItemCategories        
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code        
 AND ItemCategories.CategoryID = Items.CategoryID         
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)         
 AND Batch_Products.Free = 0        
Group by Batch_Products.Product_Code, Items.ProductName,      
Batch_Products.SalePrice,  Batch_Products.Batch_Number, Batch_Products.Expiry ,      
Batch_Products.PTS,Batch_Products.PTR, Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.Free      

INSERT INTO #temp1 SELECT  Batch_Products.Product_Code, Items.ProductName,        
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOM1Description" =(Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
"UOMQuantity" =dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),      
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),        
"Sale Price" = Batch_Products.SalePrice,        
"Batch Number" = Batch_Products.Batch_Number, "Expiry" = Batch_Products.Expiry,        
"PTS" = isnull(Batch_Products.PTS, 0), "PTR" =ISNULL(Batch_Products.PTR, 0),         
"ECP" = ISNULL(Batch_Products.ECP, 0),         
"Company Price" = IsNULL(Batch_Products.Company_Price, 0),         
"Free" = Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End    
FROM Batch_Products, Items, ItemCategories        
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code        
 AND ItemCategories.CategoryID = Items.CategoryID         
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)         
 AND Batch_Products.Free = 1        
Group by Batch_Products.Product_Code, Items.ProductName,      
Batch_Products.SalePrice,  Batch_Products.Batch_Number, Batch_Products.Expiry ,      
Batch_Products.PTS,Batch_Products.PTR, Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.Free      

SELECT "Pack" = Batch_Products.Product_Code, "Item Code" = Combo_Components.Component_Item_Code,
"Item Name" = Items.ProductName,
"UOM2Quantity" = 0,      
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Combo_Components.Component_Item_Code)),      
"UOM1Quantity" = 0,
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Combo_Components.Component_Item_Code)),      
"UOMQuantity"  = Sum(Batch_Products.QuantityReceived) * Combo_Components.Quantity,
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Combo_Components.Component_Item_Code )),
"Sale Price" = Combo_Components.ECP,
"Batch Number" = Batch_Products.Batch_Number, "Expiry" = NULL,        
"PTS" = isnull(Combo_Components.PTS, 0), "PTR" = ISNULL(Combo_Components.PTR, 0),         
"ECP" = ISNULL(Combo_Components.ECP, 0),
"Company_Price" = Combo_Components.SpecialPrice,          
"Free" = Case IsNull(Combo_Components.PTS, 0) When 0 Then @FREE Else @SALEABLE End    
INTO #temp2 FROM batch_products, Items, Combo_Components where 
Batch_Products.Grn_ID = @GRNID And
Combo_Components.ComboID = Batch_Products.ComboID
AND Items.Product_Code = Batch_Products.Product_Code
GROUP BY Combo_Components.Component_Item_Code, Items.ProductName, Combo_Components.ECP, 
Combo_Components.PTS, Combo_Components.ECP, Combo_Components.PTR, Batch_Products.Batch_Number, 
Combo_Components.Quantity, Batch_Products.Product_Code, Combo_Components.SpecialPrice, 
Items.UOM1_Conversion, Items.UOM2_Conversion, Combo_Components.Quantity

DECLARE S1 CURSOR FOR Select [Item Code], [Batch Number] FROM #Temp1
OPEN S1
FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO #Temp3 SELECT * FROM #Temp1 Where [Item Code] = @ItemCode And [Batch Number] = @BatchNumber 
		INSERT INTO #Temp3 SELECT N'   ' + [Item Code],N'   ' + [Item Name], [UOM2Quantity], [UOM2Description],
		[UOM1Quantity], [UOM1Description], [UOMQuantity], [UOMDescription], [Sale Price],
		N'', [Expiry], [PTS], [PTR], [ECP], [Company_Price], [Free] FROM #Temp2 
		WHERE Pack = @ItemCode AND [Batch Number] = @BatchNumber
	FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber
	END
CLOSE S1
DEALLOCATE S1

SELECT * FROM #TEMP3

DROP TABLE #Temp1
DROP TABLE #Temp2
DROP TABLE #Temp3
