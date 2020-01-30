CREATE PROCEDURE [dbo].[sp_print_GRNitems_RespectiveUOM_ComboPack](@GRNID int)        
AS    
DECLARE @ItemCode nvarchar(500)
DECLARE @BatchNumber nvarchar(500)
DECLARE @SQL nvarchar(2000)
DECLARE @UOMDesc nvarchar(500)
DECLARE @RecQty Decimal(18,6)
Declare @FREE As NVarchar(50)
Declare @SALEABLE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)
Set @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)
SET @SQL = N''
SET @ItemCode = N''
SET @BatchNumber = N''
SET @UOMDesc = N''

CREATE TABLE #Temp3([Product Code] nvarchar(100), [Product Name] nvarchar(100), [Quantity] nvarchar(20), 
[Rejected] nvarchar(50), [UOM] nvarchar(50), [Sale Price] Decimal(18,6), [Batch Number] nvarchar(50), [Expiry] nvarchar(50), 
[PTS] Decimal(18,6), [PTR] Decimal(18,6), [ECP] Decimal(18,6), 
[Company Price] Decimal(18,6), [Free] nvarchar(20))

SELECT "Product Code" = Batch_Products.Product_Code,"Product Name" = Items.ProductName,         
"Quantity" = Batch_Products.UOMQty, 
"Rejected" =  NULL,"UOM" = UOM.Description, "Sale Price" = Batch_Products.UOMPrice,        
"Batch Number" = Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,        
"PTS" = isnull(Batch_Products.PTS, 0), "PTR" = ISNULL(Batch_Products.PTR, 0),         
"ECP" = ISNULL(Batch_Products.ECP, 0),         
"Company Price" = ISNULL(Batch_Products.Company_Price, 0),         
"Free" = Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End,
"ReceivedQty" = Batch_Products.QuantityReceived
INTO #temp1 FROM Batch_Products
Inner Join Items On Batch_Products.Product_Code = Items.Product_Code        
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID         
Left Outer Join UOM On Batch_Products.UOM = UOM.UOM            
WHERE Batch_Products.GRN_ID = @GRNID 
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)         
 AND Batch_Products.Free = 0        


INSERT INTO #Temp1 SELECT  Batch_Products.Product_Code, Items.ProductName,         
Batch_Products.UOMQty,NULL,UOM.Description, Batch_Products.UOMPrice,        
Batch_Products.Batch_Number, Batch_Products.Expiry,        
isnull(Batch_Products.PTS, 0), ISNULL(Batch_Products.PTR, 0),         
ISNULL(Batch_Products.ECP, 0),         
ISNULL(Batch_Products.Company_Price, 0),         
Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End,
"ReceivedQty" = Batch_Products.QuantityReceived
FROM Batch_Products
Inner Join  Items On Batch_Products.Product_Code = Items.Product_Code        
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID        
Left Outer Join UOM On Batch_Products.UOM = UOM.UOM           
WHERE Batch_Products.GRN_ID = @GRNID
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)         
 AND Batch_Products.Free = 1        
ORDER  BY Items.ProductName    

SELECT "Pack" = Batch_Products.Product_Code, "Product Code" = Combo_Components.Component_Item_Code,
"Product Name" = (SELECT Item.ProductName FROM Items Item WHERE Item.Product_Code = Combo_Components.Component_Item_Code),
"Quantity" = Combo_Components.Quantity,
"Rejected" =  NULL,"UOM" = UOM.Description, "Sale Price" = Combo_Components.ECP,
"Batch Number" = Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,        
"PTS" = Isnull(Combo_Components.PTS, 0), "PTR" = ISNULL(Combo_Components.PTR, 0),         
"ECP" = ISNULL(Combo_Components.ECP, 0),         
"Company Price" = Combo_Components.SpecialPrice,          
"Free" = Case IsNull(Combo_Components.PTS, 0) When 0 Then @FREE Else @SALEABLE End    
INTO #temp2 FROM batch_products
Inner Join Items On Items.Product_Code = Batch_Products.Product_Code
Left Outer Join UOM On UOM.UOM = Items.UOM
Inner Join  Combo_Components  On Combo_Components.ComboID = Batch_Products.ComboID
where Batch_Products.Grn_ID = @GRNID 
GROUP BY Combo_Components.Component_Item_Code, Items.ProductName, Combo_Components.ECP, Combo_Components.PTS, Combo_Components.ECP, Combo_Components.PTR, 
Batch_Products.Batch_Number, Combo_Components.Quantity, Combo_Components.SpecialPrice, 
Batch_Products.Product_Code,UOM.Description, Batch_Products.Expiry, Combo_Components.Quantity

DECLARE S1 CURSOR FOR Select [Product Code], [Batch Number], [UOM], [ReceivedQty] FROM #Temp1
OPEN S1
FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber, @UOMDesc, @RecQty
	WHILE @@FETCH_STATUS = 0 
	BEGIN

		INSERT INTO #Temp3 SELECT [Product Code],[Product Name], [Quantity],[Rejected], 
		[UOM], [Sale Price], [Batch Number], [Expiry], [PTS], [PTR], [ECP], [Company Price], [Free] FROM #Temp1 Where [Product Code] = @ItemCode And [Batch Number] = @BatchNumber And [UOM] = @UOMDesc
	
		INSERT INTO #Temp3 SELECT N'   ' + [Product Code],N'   ' + [Product Name],  @RecQty * [Quantity],[Rejected], 
		[UOM], [Sale Price], N'', [Expiry], [PTS], [PTR], [ECP], [Company Price], [Free] FROM #Temp2
		WHERE Pack = @ItemCode AND [Batch Number] = @BatchNumber
	FETCH NEXT FROM S1 INTO @ItemCode, @BatchNumber, @UOMDesc, @RecQty
	END
CLOSE S1
DEALLOCATE S1

SELECT * FROM #TEMP3

DROP TABLE #Temp1
DROP TABLE #Temp2
DROP TABLE #Temp3
