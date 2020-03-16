--exec ARC_DailyStockMovement '2020-01-21 23:59:59'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_DailyStockMovement')
BEGIN
    DROP PROC ARC_DailyStockMovement
END
GO
Create Proc ARC_DailyStockMovement (@FromDate DATETIME)  
AS  
BEGIN   
 --DECLARE @FromDate AS DATETIME  
 SET @FromDate =Convert(Date, Cast(@FromDate as DateTime), 105)  
  
 IF OBJECT_ID('tempdb..#V_ARC_Purchase_ItemDetails') IS NOT NULL DROP TABLE #V_ARC_Purchase_ItemDetails  
 IF OBJECT_ID('tempdb..#V_ARC_SaleReturn_ItemDetails') IS NOT NULL DROP TABLE #V_ARC_SaleReturn_ItemDetails  
 IF OBJECT_ID('tempdb..#V_ARC_Sale_ItemDetails') IS NOT NULL DROP TABLE #V_ARC_Sale_ItemDetails  
 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp  
  
 Select * into #V_ARC_Purchase_ItemDetails from V_ARC_Purchase_ItemDetails Where dbo.StripTimeFromDate(BillDate) = @FromDate  
 Select * into #V_ARC_SaleReturn_ItemDetails from V_ARC_SaleReturn_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) = @FromDate  
 Select * into #V_ARC_Sale_ItemDetails from V_ARC_Sale_ItemDetails Where dbo.StripTimeFromDate(InvoiceDate) = @FromDate  
  
 select   
   @FromDate [StockDate],  
   I.Product_Code  
  ,I.ProductName  
  ,I.Batch_Code  
  ,(SELECT TOP 1 SUM(P.Quantity) FROM #V_ARC_Purchase_ItemDetails P  WITH (NOLOCK) WHERE P.Product_Code = I.Product_Code AND P.Batch_Number = I.Batch_Number AND P.GRNID = I.GRN_ID) [PurchaseQuantity]  
  ,(SELECT TOP 1 SUM(P.PurchasePrice) FROM #V_ARC_Purchase_ItemDetails P  WITH (NOLOCK) WHERE P.Product_Code = I.Product_Code AND P.Batch_Number = I.Batch_Number AND P.GRNID = I.GRN_ID) PurchasePrice  
  ,(SELECT TOP 1 SUM(S.Quantity) FROM #V_ARC_Sale_ItemDetails S  WITH (NOLOCK) WHERE S.Product_Code = I.Product_Code AND S.Batch_Code = I.Batch_Code) [SalesQuantity]  
  ,(SELECT TOP 1 SUM(S.PurchasePrice) FROM #V_ARC_Sale_ItemDetails S  WITH (NOLOCK) WHERE S.Product_Code = I.Product_Code AND S.Batch_Code = I.Batch_Code) [SalesPurchasePrice]  
  ,(SELECT TOP 1 SUM(S.SalePrice) FROM #V_ARC_Sale_ItemDetails S  WITH (NOLOCK) WHERE S.Product_Code = I.Product_Code AND S.Batch_Code = I.Batch_Code) [SalePrice]  
  ,(SELECT TOP 1 SUM(SA.Quantity) FROM #V_ARC_SaleReturn_ItemDetails SA  WITH (NOLOCK) WHERE SA.Product_Code = I.Product_Code AND SA.Batch_Code = I.Batch_Code) [SalesReturnQuantity]  
  ,(SELECT TOP 1 SUM(SA.PurchasePrice) FROM #V_ARC_SaleReturn_ItemDetails SA  WITH (NOLOCK) WHERE SA.Product_Code = I.Product_Code AND SA.Batch_Code = I.Batch_Code) [SalesReturnPurchasePrice]  
  ,(SELECT TOP 1 SUM(SA.SalePrice) FROM #V_ARC_SaleReturn_ItemDetails SA  WITH (NOLOCK) WHERE SA.Product_Code = I.Product_Code AND SA.Batch_Code = I.Batch_Code) [SalesReturnPrice]  
  
 INTO #Temp  
 from V_ARC_Items_BatchDetails I WITH (NOLOCK)   
 
 SELECT 1, * FROM #Temp  WITH (NOLOCK)   WHERE   ISNULL(PurchaseQuantity, 0) > 0 OR  
 ISNULL(PurchasePrice, 0) > 0 OR   
 ISNULL(SalesQuantity, 0) > 0 OR  
 ISNULL(SalesPurchasePrice, 0) > 0 OR   
 ISNULL(SalePrice, 0) > 0 OR   
 ISNULL(SalesReturnQuantity, 0) > 0 OR  
 ISNULL(SalesReturnPurchasePrice, 0) > 0 OR   
 ISNULL(SalesReturnPrice, 0) > 0   Drop Table #V_ARC_Purchase_ItemDetails  Drop Table #V_ARC_SaleReturn_ItemDetails  Drop Table #V_ARC_Sale_ItemDetails  Drop Table #Temp END 