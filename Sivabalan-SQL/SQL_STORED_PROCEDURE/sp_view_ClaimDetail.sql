CREATE PROCEDURE sp_view_ClaimDetail(@CLAIMID INT)    
    
AS    
  
Declare @nClaimType Integer    
Declare @InvPrefix nvarchar(10)    
    
Set @nClaimType = (Select Isnull(ClaimType, 0) from ClaimsNote where ClaimID = @CLAIMID)    
Set @InvPrefix = (Select Prefix from VoucherPrefix WHere TranID = 'INVOICE')    
    
If @nClaimType = 6     
Select "Invoice No" = ClaimsDetail.InvoiceID, "Document No" = @InvPrefix + Cast(invoiceAbstract.DocumentID as nVarchar),     
"Invoice Date" = InvoiceDate, "Sales Value" = NetValue,  "Scheme Discount" = SchemeDiscountAmount,     
"Claimed Amount" = ClaimAmount    
From InvoiceAbstract, ClaimsDetail--, ClaimsNote   
Where ClaimsDetail.InvoiceID = InvoiceAbstract.InvoiceID    
--And ClaimsNote.ClaimID = ClaimsDetail.ClaimID
And ClaimID = @CLAIMID And Isnull(ClaimAmount, 0) > 0    
Else       
SELECT ClaimsDetail.Product_Code, Items.ProductName, Sum(Quantity), Rate,     
Sum(Quantity) * Rate, Remarks, Batch, Expiry, PurchasePrice, ClaimsDetail.Batch_Code FROM ClaimsDetail, Items    
WHERE ClaimsDetail.ClaimID = @CLAIMID    
AND ClaimsDetail.Product_Code = Items.Product_Code    
Group By ClaimsDetail.Product_Code, ClaimsDetail.Batch, ClaimsDetail.Expiry,    
ClaimsDetail.PurchasePrice, ClaimsDetail.Rate, ClaimsDetail.Remarks, Items.ProductName, ClaimsDetail.Batch_Code    

