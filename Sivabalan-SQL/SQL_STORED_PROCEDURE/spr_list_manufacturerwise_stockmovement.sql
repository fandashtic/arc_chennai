CREATE PROCEDURE [dbo].[spr_list_manufacturerwise_stockmovement]            
              ( @Mfr nvarchar(2550),                
                @FROMDATE datetime,                
                @TODATE datetime,        
			    @StockVal nvarchar(100),
				@ItemCode nvarchar(2550))                
As   

--Declare @Mfr nvarchar(2550)                
--Declare @FROMDATE datetime                
--Declare @TODATE datetime       
--Declare @StockVal nvarchar(100)
--Declare @ItemCode nvarchar(2550)

--set dateformat dmy
--Set @Mfr = '%'            
--Set @FROMDATE = '15-05-2018 00:00:00'           
--Set @TODATE =  '15-05-2018 23:59:59' 
--Set @StockVal = 'PTS'
--Set @ItemCode = '%'
				           
   
	  
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @Mfr='%'         
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer        
Else        
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)        
      
If @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)
        
declare @NEXT_DATE datetime                
DECLARE @CORRECTED_DATE datetime                
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/'                 
+ CAST(DATEPART(mm, @TODATE) as nvarchar) + '/'                 
+ cast(DATEPART(yyyy, @TODATE) AS nvarchar)                
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/'                 
+ CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/'                 
+ cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)                
            
Create Table #temp             
(Manu_Code Int,            
Manu_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,            
Opening_Qty Decimal(18,6) ,            
Free_Opening_Qty Decimal(18,6),            
Damage_Opening_Qty Decimal(18,6),            
Total_Opeing_Val Decimal(18,6),            
Opening_Val Decimal(18,6),            
Damage_Opening_Val Decimal(18,6),            
Total_Opening_Val Decimal(18,6),            
Purchase Decimal(18,6),            
Free_Purchase Decimal(18,6),              
Purchase_Value Decimal(18,6),              
Sales_Return_Sale Decimal(18,6),            
Sales_Return_Damages Decimal(18,6),            
Total_Issues Decimal(18,6),            
Free_Issues Decimal(18,6),            
Sales_Val Decimal(18,6),            
Purchase_Return Decimal(18,6),            
Adjust Decimal(18,6),            
Stk_Out Decimal(18,6),            
Stk_In Decimal(18,6),         
Stk_Destruction Decimal(18,6),           
On_Hand_Qty Decimal(18,6),            
On_Hand_Free_Qty Decimal(18,6),            
On_Hand_Dam_Qty Decimal(18,6),            
Tot_On_Hand_Qty Decimal(18,6),            
On_Hand_Val Decimal(18,6),            
On_Hand_Dam Decimal(18,6),            
Tot_On_Hand Decimal(18,6))            
            
            
Insert Into #temp             
SELECT                  
"Manufacturer Code" = Manufacturer.ManufacturerID,      
            
"Manufacturer Name" = Manufacturer.Manufacturer_Name,            
                
"Opening Quantity" = ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0),                 
                
"Free Opening Quantity" = ISNULL(Free_Saleable_Quantity, 0),                 
                
"Damage Opening Quantity" =ISNULL(Damage_Opening_Quantity, 0),                
                
"Total Opening Quantity" = ISNULL(Opening_Quantity, 0),                
      
"Opening Value (%c)" =      
case @StockVal        
When 'PTS' Then           
((ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.PTS, 0))  - (ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0))      
When 'PTR' Then      
((ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.PTR, 0))  - (ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0))      
When 'ECP' Then      
((ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.ECP, 0))  - (ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0))      
Else      
ISNULL(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0)      
End,       
      
"Damage Opening Value (%c)" =       
case @StockVal        
When 'PTS' Then       
(ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0))       
When 'PTR' Then       
(ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0))      
When 'ECP' Then       
(ISNULL(Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0))      
Else      
IsNull(Damage_Opening_Value, 0)      
End,      
      
"Total Opening Value (%c)" =       
case @StockVal        
When 'PTS' Then                  
(ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.PTS, 0)        
When 'PTR' Then      
(ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.PTR, 0)        
When 'ECP' Then      
(ISNULL(Opening_Quantity, 0) - ISNULL(Free_Saleable_Quantity, 0)) * Isnull(Items.ECP, 0)        
Else      
ISNULL(Opening_Value, 0)                
End,      
                
"Purchase" = ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                 
FROM GRNAbstract, GRNDetail                 
WHERE GRNAbstract.GRNID = GRNDetail.GRNID                 
AND GRNDetail.Product_Code = Items.Product_Code                 
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE         
And (GRNAbstract.GRNStatus & 64) = 0        
And (GRNAbstract.GRNStatus & 32) = 0), 0),                
                
"Free Purchase" = ISNULL((SELECT SUM(IsNull(FreeQty, 0))                 
FROM GRNAbstract, GRNDetail           
WHERE GRNAbstract.GRNID = GRNDetail.GRNID                 
AND GRNDetail.Product_Code = Items.Product_Code                 
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE         
And (GRNAbstract.GRNStatus & 64) = 0         
And (GRNAbstract.GRNStatus & 32) = 0), 0),                
      
"Purchase Value (%c)" =       
ISNULL((SELECT SUM((GRNDetail.QuantityReceived - GRNDetail.QuantityRejected) * Isnull(Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else PurchasePrice End, 0))        
FROM GRNAbstract, GRNDetail, Items a, Batch_products
WHERE GRNDetail.GRNID = GRNAbstract.GRNID        
AND Items.Product_Code = GRNDetail.Product_Code        
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE         
And (GRNAbstract.GRNStatus & 64) = 0        
And (GRNAbstract.GRNStatus & 32) = 0       
And Batch_products.GRN_ID = GRNAbstract.GRNID
And Batch_products.Product_Code = Items.Product_Code
AND a.Product_Code = Items.Product_Code), 0),      
                
"Sales Return Saleable" = ISNULL((SELECT SUM(Quantity)                 
FROM InvoiceDetail, InvoiceAbstract                 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                 
AND (InvoiceAbstract.InvoiceType = 4)                 
AND (InvoiceAbstract.Status & 128) = 0                 
AND InvoiceDetail.Product_Code = Items.Product_Code                 
AND (InvoiceAbstract.Status & 32) = 0                
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),                
                
"Sales Return Damages" = ISNULL((SELECT SUM(Quantity)                 
FROM InvoiceDetail, InvoiceAbstract                 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                 
AND (InvoiceAbstract.InvoiceType = 4)     
AND (InvoiceAbstract.Status & 128) = 0                 
AND InvoiceDetail.Product_Code = Items.Product_Code                 
AND (InvoiceAbstract.Status & 32) <> 0                
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),                
                
"Total Issues" = (ISNULL((SELECT SUM(Quantity)                 
FROM InvoiceDetail, InvoiceAbstract                 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                 
AND (InvoiceAbstract.InvoiceType = 2)                 
AND (InvoiceAbstract.Status & 128) = 0                 
AND InvoiceDetail.Product_Code = Items.Product_Code                 
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)                 
+ ISNULL((SELECT SUM(Quantity)                 
FROM DispatchDetail, DispatchAbstract                 
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                 
AND (DispatchAbstract.Status & 320) = 0                 
AND DispatchDetail.Product_Code = Items.Product_Code                 
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)),                
                
"Free Issues" = (ISNULL((SELECT SUM(Quantity)                 
FROM InvoiceDetail, InvoiceAbstract                 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                 
AND (InvoiceAbstract.InvoiceType = 2)                 
AND (InvoiceAbstract.Status & 128) = 0                 
AND InvoiceDetail.Product_Code = Items.Product_Code                 
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE         
And InvoiceDetail.SalePrice = 0), 0)                 
+ ISNULL((SELECT SUM(Quantity)                 
FROM DispatchDetail, DispatchAbstract                 
WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID                 
AND (DispatchAbstract.Status & 320) = 0                 
AND DispatchDetail.Product_Code = Items.Product_Code                 
AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE                
And (DispatchDetail.SalePrice = 0
OR DispatchDetail.FlagWord = 1)), 0)),                

                
"Sales Value (%c)" = ISNULL((SELECT SUM(case invoicetype when 4 then 0 - Amount else Amount end)                 
FROM InvoiceDetail, InvoiceAbstract                 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                 
AND (InvoiceAbstract.Status & 128) = 0                 
And (Invoiceabstract.InvoiceType Not In(4))        
AND InvoiceDetail.Product_Code = Items.Product_Code                 
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),                
                
"Purchase Return" = ISNULL((SELECT SUM(Quantity)                 
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                 
WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                 
AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                 
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE         
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0        
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),                
                
"Adjustments" = ISNULL((SELECT SUM(Quantity - OldQty)                 
FROM StockAdjustment, StockAdjustmentAbstract                 
WHERE ISNULL(AdjustmentType,0) in (1, 3)                 
And Product_Code = Items.Product_Code                 
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0),                
                
"Stock Transfer Out" = IsNull((Select Sum(Quantity)                 
From StockTransferOutAbstract, StockTransferOutDetail                
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                 
And StockTransferOutAbstract.Status & 192 = 0                
And StockTransferOutDetail.Product_Code = Items.Product_Code), 0),                
                
"Stock Transfer In" = IsNull((Select Sum(Quantity)                 
From StockTransferInAbstract, StockTransferInDetail                 
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                 
And StockTransferInAbstract.Status & 192 = 0                 
And StockTransferInDetail.Product_Code = Items.Product_Code), 0),                
        
"Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                       
From StockDestructionAbstract, StockDestructionDetail,ClaimsNote           
Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                      
And StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID          
And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                       
And ClaimsNote.Status & 1 <> 0              
And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),         
                
"On Hand Qty" = CASE                 
when (@TODATE < @NEXT_DATE) THEN                 
ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)                
FROM OpeningDetails                 
WHERE OpeningDetails.Product_Code = Items.Product_Code                 
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                
ELSE                 
(ISNULL((SELECT SUM(Quantity)                 
FROM Batch_Products                 
WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +                
(SELECT ISNULL(SUM(Pending), 0)                 
FROM VanStatementDetail, VanStatementAbstract                 
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
AND (VanStatementAbstract.Status & 128) = 0                 
And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice <> 0))                
end,                
                
"On Hand Free Qty" = CASE                 
when (@TODATE < @NEXT_DATE) THEN                 
ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                
FROM OpeningDetails                 
WHERE OpeningDetails.Product_Code = Items.Product_Code                 
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                
ELSE                 
(ISNULL((SELECT SUM(Quantity)                 
FROM Batch_Products                 
WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                
(SELECT ISNULL(SUM(Pending), 0)                 
FROM VanStatementDetail, VanStatementAbstract           
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
AND (VanStatementAbstract.Status & 128) = 0                 
And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))                
end,                
                
"On Hand Damage Qty" = CASE                 
when (@TODATE < @NEXT_DATE) THEN       
ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                
FROM OpeningDetails                 
WHERE OpeningDetails.Product_Code = Items.Product_Code                 
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                
ELSE                 
(ISNULL((SELECT SUM(Quantity)                 
FROM Batch_Products                 
WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))                
end,                
                
"Total On Hand Qty" = CASE               
when (@TODATE < @NEXT_DATE) THEN                 
ISNULL((Select Opening_Quantity                
FROM OpeningDetails                 
WHERE OpeningDetails.Product_Code = Items.Product_Code                 
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                
ELSE                 
(ISNULL((SELECT SUM(Quantity)                 
FROM Batch_Products                 
WHERE Product_Code = Items.Product_Code), 0) +                
(SELECT ISNULL(SUM(Pending), 0)                 
FROM VanStatementDetail, VanStatementAbstract                 
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                 
AND (VanStatementAbstract.Status & 128) = 0                 
And VanStatementDetail.Product_Code = Items.Product_Code))   
end,                
        
"On Hand Value (%c)" =         
CASE               
when (@TODATE < @NEXT_DATE) THEN               
ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)              
FROM OpeningDetails  
WHERE OpeningDetails.Product_Code = Items.Product_Code               
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)              
ELSE               
((SELECT ISNULL(SUM(Quantity * Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else PurchasePrice End), 0)                 
FROM Batch_Products, Items a               
WHERE Batch_Products.Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 and a.Product_Code = Items.Product_Code)      
 + (SELECT ISNULL(SUM(Pending * Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else Purchase_Price End), 0)             
FROM VanStatementDetail, VanStatementAbstract, Items a                  
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial               
AND (VanStatementAbstract.Status & 128) = 0               
And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0 and a.Product_Code = Items.Product_Code))              
end,                
      
"On Hand Damages Value (%c)" =         
CASE               
when (@TODATE < @NEXT_DATE) THEN               
ISNULL((Select IsNull(Damage_Opening_Value, 0)              
FROM OpeningDetails               
WHERE OpeningDetails.Product_Code = Items.Product_Code               
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)              
ELSE               
(SELECT ISNULL(SUM(Quantity * Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else PurchasePrice End), 0)               
FROM Batch_Products, Items a      
WHERE Batch_Products.Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0 and a.Product_Code = Items.Product_Code)              
end,                 
                
"Total On Hand Value (%c)" =         
CASE               
when (@TODATE < @NEXT_DATE) THEN               
ISNULL((Select Opening_Value              
FROM OpeningDetails             
WHERE OpeningDetails.Product_Code = Items.Product_Code               
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)              
ELSE               
((SELECT ISNULL(SUM(Quantity * Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else PurchasePrice End), 0)               
FROM Batch_Products, Items a      
WHERE Batch_Products.Product_Code = Items.Product_Code and a.Product_Code = Items.Product_Code And IsNull(Free, 0) = 0)      
 + (SELECT ISNULL(SUM(Pending * Case @StockVal       
    When 'PTS' Then a.PTS      
    When 'PTR' Then a.PTR      
    When 'ECP' Then a.ECP      
    Else Purchase_Price End), 0)               
FROM VanStatementDetail, VanStatementAbstract, Items a      
WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial               
AND (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.SalePrice <> 0       
And VanStatementDetail.Product_Code = Items.Product_Code and a.Product_Code = Items.Product_Code)      
)              
end                 
                
FROM Items
left Outer Join OpeningDetails on Items.Product_Code = OpeningDetails.Product_Code
left Outer Join UOM on Items.UOM = UOM.UOM
Inner Join Manufacturer on Items.ManufacturerID = Manufacturer.ManufacturerID
WHERE   
--Items.Product_Code *= OpeningDetails.Product_Code AND                
 OpeningDetails.Opening_Date = @FROMDATE And               
 --AND Items.UOM *= UOM.UOM And                
 --Items.ManufacturerID = Manufacturer.ManufacturerID And                
 Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
 And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
            
Select "Manufacturer Code" = Manu_Code ,            
"Manufacturer Name" = Manu_Name ,            
"Opening Quantity" = Sum(Opening_Qty),            
"Free Opening Quantity" = Sum(Free_Opening_Qty),             
"Damage Opening Quantity" = Sum(Damage_Opening_Qty),            
"Total Opening Quantity" = Sum(Total_Opeing_Val),             
"Opening Value (%c)" = Sum(Opening_Val),             
"Damage Opening Value (%c)" = Sum(Damage_Opening_Val),            
"Total Opening Value (%c)" = Sum(Total_Opening_Val),             
"Purchase" = Sum(Purchase),             
"Free Purchase" = Sum(Free_Purchase),             
"Purchase Value (%c)" = Sum(Purchase_Value),             
"Sales Return Saleable" = Sum(Sales_Return_Sale ),            
"Sales Return Damages" = Sum(Sales_Return_Damages),             
"Total Issues" = Sum(Total_Issues ),            
"Free Issues" = Sum(Free_Issues ),            
"Sales Value (%c)" = Sum(Sales_Val ),            
"Purchase Return" = Sum(Purchase_Return ),            
"Adjustments" = Sum(Adjust ),            
"Stock Transfer Out" = Sum(Stk_Out ),            
"Stock Transfer In" = Sum(Stk_In ),           
"Stock Destruction Movement" = Sum(Stk_Destruction),         
"On Hand Qty" = Sum(On_Hand_Qty ),            
"On Hand Free Qty" = Sum(On_Hand_Free_Qty ),            
"On Hand Damage Qty" = Sum(On_Hand_Dam_Qty),            
"Total On Hand Qty" = Sum(Tot_On_Hand_Qty),            
"On Hand Value (%c)" = Sum(On_Hand_Val ),            
"On Hand Damages Value (%c)" = Sum(On_Hand_Dam ),            
"Total On Hand Value (%c)" = Sum(Tot_On_Hand )            
            
from #temp             
Group By #temp.Manu_Code, #temp.Manu_Name             
            
drop table #temp         
Drop table #tmpMfr      
