Create Procedure spr_list_ReceivedClaimsDetail_pidilite (@CLAIMID INT)
as
Select ClaimsDetailReceived.Product_Code,"Item Code"=ClaimsDetailReceived.Product_Code,
"Item Name" = Items.ProductName,"Batch"=ClaimsDetailReceived.Batch,
"Expiry"=ClaimsDetailReceived.Expiry, 
"Purchase Price" = ClaimsDetailReceived.PurchasePrice, 
"Quantity" = Isnull(ClaimsDetailReceived.Quantity,0),
"Reporting UOM" = Isnull(ClaimsDetailReceived.Quantity,0) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End,  
"Conversion Factor" = Isnull(ClaimsDetailReceived.Quantity,0) * IsNull(ConversionFactor, 0),  
"Rate"=Isnull(ClaimsDetailReceived.Rate,0), 
"Value"=Isnull(ClaimsDetailReceived.Quantity,0) * Isnull(ClaimsDetailReceived.Rate,0),
"Adjusted Amount"=Isnull(ClaimsDetailReceived.AdjustedAmount,0),
"Adjustment Reason"=ClaimsDetailReceived.AdjustmentReason,
"Remarks"=ClaimsDetailReceived.Remarks FROM ClaimsDetailReceived, Items
where ClaimsDetailReceived.DocSerial=@CLAIMID
and ClaimsDetailReceived.Product_Code=Items.Product_Code

