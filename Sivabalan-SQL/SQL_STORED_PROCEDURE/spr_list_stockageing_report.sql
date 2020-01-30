CREATE PROCEDURE spr_list_stockageing_report (@ItemCode nvarchar(2550))      
AS      
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
if @ItemCode = '%'      
 Insert InTo @tmpProd Select Product_code From Items      
Else      
 Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)      
      
--SELECT * INTO #TempOpen FROM OpeningDetails      
  
--This table is to display the categories in the Order  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Exec sp_CatLevelwise_ItemSorting   
      
SELECT  Items.Product_Code, "Item Code" = Items.Product_Code,       
"Item Name" = Items.ProductName,      
--"Opening Quantity" = (SELECT TOP 1 IsNull(Opening_Quantity,0) FROM #TempOpen WHERE #TempOpen.Product_Code = Items.Product_Code ORDER BY Opening_Date),      
"Opening Quantity" = (SELECT TOP 1 IsNull(Opening_Quantity,0) FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code ORDER BY Opening_Date),      
"Total On Hand Qty" = SUM(Batch_Products.Quantity),  
"Total SIT Qty" = (Select SUM(IDR.Pending) FROM InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR   
WHERE IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0)  
FROM Items, Batch_Products, #tempCategory1 T1  
WHERE   
Items.CategoryID = T1.CategoryID  
And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)   
And Items.Product_Code = Batch_Products.Product_Code   
GROUP BY T1.IDS, Items.Product_Code, Items.ProductName  
having SUM(Batch_Products.Quantity) > 0   
Order by T1.IDS   
    
