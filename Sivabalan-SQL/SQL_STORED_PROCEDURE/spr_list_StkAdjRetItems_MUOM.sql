CREATE PROCEDURE [dbo].[spr_list_StkAdjRetItems_MUOM](@ADJUSTMENTID INT, @UOMDesc nVarchar(50))  
AS  
DECLARE @BillID int  
  
SELECT Top 1 @BillID = BillAbstract.BillID FROM AdjustmentReturnDetail, BillAbstract WHERE AdjustmentReturnDetail.BillID = BillAbstract.DocumentID AND AdjustmentID = @ADJUSTMENTID  
  
SELECT   
"Product_Code"=Max(AdjustmentReturnDetail.Product_Code),   
"Item Code" = Max(AdjustmentReturnDetail.Product_Code),  
"Item Name" = Max(Items.ProductName),   
--"Quantity" = Sum(AdjustmentReturnDetail.Quantity),   
"Quantity" =    
     Case When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty(Sum(AdjustmentReturnDetail.Quantity), Case When Max(IsNull(Items.UOM1_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM1_Conversion) End)      
       When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty(Sum(AdjustmentReturnDetail.Quantity), Case When Max(IsNull(Items.UOM2_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM2_Conversion) End)      
     Else dbo.sp_Get_ReportingQty(Sum(AdjustmentReturnDetail.Quantity),1)      
      End,  
--"Purchase Price" = ISNULL(Rate, 0),  
"Purchase Price" =   
     Case When @UOMdesc = N'UOM1' then Max(ISNULL(Rate, 0)) * Case When Max(IsNull(Items.UOM1_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM1_Conversion) End  
       When @UOMdesc = N'UOM2' then Max(ISNULL(Rate, 0)) * Case When Max(IsNull(Items.UOM2_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM2_Conversion) End  
     Else Max(ISNULL(Rate, 0))      
      End,  
"Value" = isnull(Sum(AdjustmentReturnDetail.Quantity*Rate), 0),   
"Reason" = Max(ISNULL(StockAdjustmentReason.Message, N'')),  
"Bill No" = (Select case Max(ISNULL(BillAbstract.BillReference , N''))  
 When N'' then   
  Max(Bill.Prefix)  
 else  
  Max(BillAmend.Prefix)  
 end  
 + cast(Max(DocumentID) as nvarchar) From BillAbstract, VoucherPrefix Bill,   
 VoucherPrefix BillAmend  
 Where BillID = @BillID AND  
 --Max(AdjustmentReturnDetail.BillID) AND  
 Bill.TranID = N'BILL' AND  
 BillAmend.TranID = N'BILL AMENDMENT'),  
"Bill Date" = (Select Max(BillDate) From BillAbstract Where BillID = @BillID),  
-- "Orig Qty" = (Select SUM(Quantity) From BillDetail  
--   Where BillID = @BillID AND  
--  Product_Code = AdjustmentReturnDetail.Product_Code),  
"Orig Qty" =   
  Case When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty((Select SUM(Quantity) From BillDetail  
    Where BillID = @BillID AND Product_Code = Max(AdjustmentReturnDetail.Product_Code)), Case When Max(IsNull(Items.UOM1_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM1_Conversion) End)      
       When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty((Select SUM(Quantity) From BillDetail  
    Where BillID = @BillID AND Product_Code = Max(AdjustmentReturnDetail.Product_Code)), Case When Max(IsNull(Items.UOM2_Conversion, 0)) = 0 Then 1 Else Max(Items.UOM2_Conversion) End)      
     Else dbo.sp_Get_ReportingQty((Select SUM(Quantity) From BillDetail  
    Where BillID = @BillID AND Product_Code = Max(AdjustmentReturnDetail.Product_Code)),1)      
      End,  
"Orig Value" = (Select SUM(Value) From BillAbstract Where BillID = @BillID)  
FROM AdjustmentReturnDetail
Left Outer Join Items ON AdjustmentReturnDetail.Product_Code = Items.Product_Code
Left Outer Join StockAdjustmentReason ON AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID  
WHERE  AdjustmentID = @ADJUSTMENTID 
GROUP BY AdjustmentReturnDetail.SerialNo  
Order By AdjustmentReturnDetail.SerialNo  
 
