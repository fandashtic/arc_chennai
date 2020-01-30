Create Procedure spr_list_ReceivedClaimsDetail(@CLAIMID INT)
as
Select ClaimsDetailReceived.Product_Code,"Item Code"=ClaimsDetailReceived.Product_Code,
"Item Name" = Items.ProductName,"Batch"=ClaimsDetailReceived.Batch,
"Expiry"=ClaimsDetailReceived.Expiry, 
"Purchase Price" = ClaimsDetailReceived.PurchasePrice, 
"Quantity"=Isnull(ClaimsDetailReceived.Quantity,0),
"Rate"=Isnull(ClaimsDetailReceived.Rate,0), 
"Value"=Isnull(ClaimsDetailReceived.Quantity,0) * Isnull(ClaimsDetailReceived.Rate,0),
"Adjusted Amount"=Isnull(ClaimsDetailReceived.AdjustedAmount,0),
"Adjustment Reason"=ClaimsDetailReceived.AdjustmentReason,
"Remarks"=ClaimsDetailReceived.Remarks FROM ClaimsDetailReceived, Items
where ClaimsDetailReceived.DocSerial=@CLAIMID
and ClaimsDetailReceived.Product_Code=Items.Product_Code

