CREATE PROCEDURE sp_print_ClaimItems(@CLAIMID INT)    
AS    
--Test  
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
Else  
SELECT "Item Code" = ClaimsDetail.Product_Code,     
"Item Name" = Items.ProductName, "Quantity" = Quantity, "Rate" = Rate,     
"Remarks" = Remarks, "UOM" = UOM.Description, "Batch" = Batch,     
"Expiry" = Expiry,     
"Purchase Price" = PurchasePrice,
"Tax Amount" = IsNull(TaxAmount,0),
"Tax Percent" = IsNull(TaxSuffPercent,0) ,
"Total Value" = ((Quantity * Rate) + IsNull(TaxAmount,0))
FROM ClaimsDetail, Items
Left Outer Join  UOM  On   Items.UOM = UOM.UOM   
WHERE ClaimID = @CLAIMID AND ClaimsDetail.Product_Code = Items.Product_Code    
order by claimsdetail.product_Code  
