CREATE PROCEDURE spr_list_ClaimsDetail(@CLAIMID INT)  
  
AS  
Declare @nClaimType Integer
Declare @InvPrefix nvarchar(10)

Set @nClaimType = (Select Isnull(ClaimType, 0) from ClaimsNote where ClaimID = @CLAIMID)
Set @InvPrefix = (Select Prefix from VoucherPrefix WHere TranID = 'INVOICE')

if @nClaimType = 6 
Select "Invoice No" = ClaimsDetail.InvoiceID, "Document No" = @InvPrefix + Cast(DocumentID as nvarchar), 
"Invoice Date" = InvoiceDate, "Sales Value" = NetValue,  "Scheme Discount" = SchemeDiscountAmount, 
"Claimed Amount" = ClaimAmount
From InvoiceAbstract, ClaimsDetail
Where ClaimsDetail.InvoiceID = InvoiceAbstract.InvoiceID
And ClaimID = @CLAIMID And Isnull(ClaimAmount, 0) > 0
Else  if @nClaimType = 5
Begin
Select Reason, Reason, AdjustedAmount From ClaimsDetail cd, Adjustmentreason adj Where
adj.Adjreasonid = cd.AdjReasonID And cd.ClaimID = @CLAIMID
End
Else
SELECT ClaimsDetail.Product_Code, "Item Code" = ClaimsDetail.Product_Code,   
"Item Name" = Items.ProductName, ClaimsDetail.Batch, ClaimsDetail.Expiry,   
"Purchase Price" = ClaimsDetail.PurchasePrice,   
ClaimsDetail.Quantity, ClaimsDetail.Rate,   
Quantity * Rate AS "Value", Remarks FROM ClaimsDetail, Items  
WHERE ClaimsDetail.ClaimID = @CLAIMID  
AND ClaimsDetail.Product_Code = Items.Product_Code  
  




