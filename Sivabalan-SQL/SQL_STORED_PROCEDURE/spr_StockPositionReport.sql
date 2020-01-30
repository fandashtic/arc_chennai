Create Procedure spr_StockPositionReport (@FromDate DateTime, @ToDate DateTime)
As

Declare @RegOwner nVarchar(255)
Declare @RepUploadDate DateTime
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      

Create Table #tempcategory (CategoryID Int, Status Int)
Exec GetLeafCategories N'%', N'%'

Select Top 1 @RegOwner = RegisteredOwner, @RepUploadDate = ReportUploadDate From Setup

--select getdate()
Set @RepUploadDate = IsNull(@RepUploadDate, GetDate() - 7)
--select @RepUploadDate
declare @NEXT_DATE datetime          
DECLARE @CORRECTED_DATE datetime          
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/'           
+ CAST(DATEPART(mm, @TODATE) as varchar) + '/'           
+ cast(DATEPART(yyyy, @TODATE) AS varchar)          
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/'           
+ CAST(DATEPART(mm, GETDATE()) as varchar) + '/'           
+ cast(DATEPART(yyyy, GETDATE()) AS varchar)          

Create Table #temp1 (CategoryID Int, MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OpeningSaleableStock Decimal(18, 6), OpeningDamageStock Decimal(18, 6), OpeningFreeStock Decimal(18, 6), Purchase Decimal(18, 6), 
PurchaseReturn Decimal(18, 6), TRIN Decimal(18, 6), Sales Decimal(18, 6), 
SalesReturn Decimal(18, 6), [D&D] Decimal(18, 6), ClosingSaleableStock Decimal(18, 6), 
ClosingDamageStock Decimal(18, 6), ClosingFreeStock Decimal(18, 6)) 

Create Table #temp2 (IDS Int IDENTITY(1, 1), CategoryID Int, 
CategoryName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
BrchID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18, 6))

Insert InTo #temp1 (CategoryID, MarketSKU, 
OpeningSaleableStock, OpeningDamageStock, OpeningFreeStock, Purchase, PurchaseReturn, TRIN, Sales, 
SalesReturn, [D&D], ClosingSaleableStock, ClosingDamageStock, ClosingFreeStock )

Select "CategoryID" = itc.CategoryID,
"Market SKU" = itc.Category_Name, 

"Opening Saleable Stock" = IsNull((Select Sum(IsNull(Opening_Quantity,0) - IsNull(Free_Saleable_Quantity,0) - IsNull(Damage_Opening_Quantity,0)) From 
OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code And 
Items.CategoryID = itc.CategoryID And Opening_Date = @FromDate), 0), 

"Opening Damages Stock" = 
IsNull((Select IsNull(sum(Damage_Opening_Quantity),0) From OpeningDetails , Items Where OpeningDetails.Product_Code = Items.Product_Code And 
Items.CategoryID = itc.CategoryID And Opening_Date = @FromDate), 0),

"Opening Free Stock" = 
IsNull((Select sum(Free_Saleable_Quantity) From OpeningDetails, Items Where 
OpeningDetails.Product_Code = Items.Product_Code And 
Items.CategoryID = itc.CategoryID And Opening_Date = @FromDate), 0), 

"Purchase" = 
ISNULL((SELECT SUM((QuantityReceived - QuantityRejected) + FreeQty)
                      FROM GRNAbstract, GRNDetail, Items 
                      WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
                      AND GRNDetail.Product_Code = Items.Product_Code
                      AND Items.CategoryID = itc.CategoryID 
		      And GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And
                      (GRNAbstract.GRNStatus & 64) = 0 And          
                      (GRNAbstract.GRNStatus & 32) = 0 ), 0), 

"Purchase Return" = ISNULL((SELECT SUM(Quantity)           
         FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, Items 
         WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID  
                      AND AdjustmentReturnDetail.Product_Code = Items.Product_Code
		      AND Items.CategoryID = itc.CategoryID
                      AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
                      And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),

"TRIN" = IsNull((Select Sum(Quantity) 
                      From StockTransferInAbstract, StockTransferInDetail, Items         
                      Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
                      And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
                      And StockTransferInAbstract.Status & 192 = 0          
                      And StockTransferInDetail.Product_Code = Items.Product_Code 
		      And Items.CategoryID = itc.CategoryID), 0), 

"Sales" = ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract, Items
                      WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
                      AND (InvoiceAbstract.InvoiceType = 2) AND   
                      (InvoiceAbstract.Status & 128) = 0 AND   
                      InvoiceDetail.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID 
                      AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)           
                      + ISNULL((SELECT SUM(Quantity)           
                      FROM DispatchDetail, DispatchAbstract, Items 
                      WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
                      AND Isnull(DispatchAbstract.Status, 0) & 64 = 0        
                      AND DispatchDetail.Product_Code = Items.Product_Code 
		      And Items.CategoryID = itc.CategoryID
                      AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0), 

 "Sales Return Salable" = ISNULL((SELECT SUM(Quantity) FROM   
                                              InvoiceDetail, InvoiceAbstract, Items
                                              WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
                                              AND (InvoiceAbstract.InvoiceType = 4)           
                                              AND (InvoiceAbstract.Status & 128) = 0           
                                              AND InvoiceDetail.Product_Code = Items.Product_Code 
					      And Items.CategoryID = itc.CategoryID
                                              AND (InvoiceAbstract.Status & 32) = 0          
                                              AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) + 
                          ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract, Items 
				             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
                                             AND (InvoiceAbstract.InvoiceType = 6)           
                                             AND (InvoiceAbstract.Status & 128) = 0           
                                             AND InvoiceDetail.Product_Code = Items.Product_Code 
					     And Items.CategoryID = itc.CategoryID 
                                             --AND (InvoiceAbstract.Status & 32) <> 0          
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),

"D&D" = ISNULL((SELECT SUM(Quantity) FROM   
                                             InvoiceDetail, InvoiceAbstract, Items  
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
                                             AND (InvoiceAbstract.InvoiceType = 4)           
                                             AND (InvoiceAbstract.Status & 128) = 0           
                                             AND InvoiceDetail.Product_Code = Items.Product_Code 
					     And Items.CategoryID = itc.CategoryID
                                             AND (InvoiceAbstract.Status & 32) <> 0          
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +   
        ISNULL((SELECT SUM(Quantity) FROM   
			  InvoiceDetail, InvoiceAbstract, Items
                                             WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
                                             AND (InvoiceAbstract.InvoiceType = 6)           
                                             AND (InvoiceAbstract.Status & 128) = 0           
                                             AND InvoiceDetail.Product_Code = Items.Product_Code 
					     And Items.CategoryID = itc.CategoryID 
                                             --AND (InvoiceAbstract.Status & 32) <> 0          
                                             AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0), 

"Closing Saleable Stock" = 
CASE When (@TODATE < @NEXT_DATE) THEN 
		      ISNULL((Select Sum(IsNull(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)  
                      - IsNull(Damage_Opening_Quantity, 0)) FROM OpeningDetails, Items 
                      WHERE OpeningDetails.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
Else
		      ISNULL((SELECT SUM(Quantity) FROM Batch_Products, Items 
                      WHERE Batch_Products.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +          

                      (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract, Items 
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial 
                      AND (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID And VanStatementDetail.PurchasePrice <> 0) 
End, 

"Closing Damages Stock" = 
CASE When (@TODATE < @NEXT_DATE) THEN
		      ISNULL((Select Sum(IsNull(Damage_Opening_Quantity, 0))
                      FROM OpeningDetails, Items WHERE OpeningDetails.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
Else
                      ISNULL((SELECT SUM(Quantity) FROM Batch_Products, Items 
                      WHERE Batch_Products.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID And IsNull(Damage, 0) > 0), 0)

End, 

"Closing Free Stock" = 
CASE when (@TODATE < @NEXT_DATE) THEN 
		      ISNULL((Select Sum(IsNull(Free_Saleable_Quantity, 0)) 
                      FROM OpeningDetails, Items WHERE OpeningDetails.Product_Code = Items.Product_Code           
		      And Items.CategoryID = itc.CategoryID AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
Else
                      ISNULL((SELECT SUM(Quantity) FROM Batch_Products, Items 
                      WHERE Batch_Products.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +    
        
                     (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract, Items 
                      WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
                      AND (VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code And 
		      Items.CategoryID = itc.CategoryID And VanStatementDetail.PurchasePrice = 0)
End

From ItemCategories itc  Where 
itc.CategoryID In (Select CategoryID From #tempcategory) 

Insert InTo #temp2
Select "CategoryID" = itc.CategoryID, "CategoryName" = itc.Category_Name, 
"BrchID" = 'TROUT - ' + WareHouse.ForumID, "Quantity" = Sum(stod.Quantity) From 
StockTransferOutAbstract stoa, StockTransferOutDetail stod, ItemCategories itc, 
Items, WareHouse Where stoa.WareHouseID = WareHouse.WareHouseID And 
stoa.DocSerial = stod.DocSerial And stod.Product_Code = Items.Product_Code And 
Items.CategoryID = itc.CategoryID And stoa.DocumentDate Between @FromDate And @ToDate And 
stoa.Status & 192 = 0 And itc.CategoryID In (Select CategoryID From #tempcategory) 
Group By itc.CategoryID, itc.Category_Name, WareHouse.ForumID


Declare @Inc Int
Declare @Count Int
Declare @CategoryID Int
Declare @BrchID nVarchar(255)
Declare @Quantity Decimal(18, 6)
Declare @Query nVarchar(4000)
Declare @TabID Int

Set @Inc = 1
Select @Count = Count(*) From #temp2

While @Inc <= @Count 
Begin
Select @CategoryID = CategoryID, @BrchID = BrchID, @Quantity = Quantity From #temp2
Where IDS = @Inc

If IsNull((Select Count(*) From #temp2 Where BrchID = @BrchID and ids < @Inc), 0) < 1
Begin
SET @Query = 'ALTER TABLE #temp1 Add [' + @BrchID +  '] Decimal(18, 6) Default 0'
EXEC sp_executesql @Query
End

Set @Query = 'Update #temp1 Set [' + @BrchID + '] = ' + Cast(@Quantity As nVarchar) + ' Where CategoryID  = ' + Cast(@CategoryID As nVarchar) + ''
EXEC sp_executesql @Query
Set @Inc = @Inc + 1
End 

-- "CategoryID" = CategoryID , "Market SKU" = MarketSKU, 
-- "Opening Salable Stock" = OSS, "Opening Damages Stock" = ODS, 
-- "Opening Free Stock" = OFS, "Purchase" = Puchase, "Purchase Return" = PurchaseReturn, 
-- "TRIN" = TRIN, "Sales" = Sales, "Sales Return Salable" = SalesReturn, "D&D" = DD, 
-- "Closing Salable Stock" = CSS, "Closing Damages Stock" = CDS, 
-- "Closing Free Stock" = CFS, 

Select * From #temp1

Drop Table #tempcategory
Drop Table #temp1
Drop Table #temp2

