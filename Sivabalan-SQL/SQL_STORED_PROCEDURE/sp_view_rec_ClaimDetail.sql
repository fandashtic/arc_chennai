CREATE PROCEDURE sp_view_rec_ClaimDetail(@CLAIMID nvarchar(50))

AS

SELECT ClaimsDetailReceived.Product_Code, Items.ProductName, Quantity, Rate, 
Quantity * Rate, Remarks, Batch, Expiry, PurchasePrice, ClaimsDetailReceived.Batch 
FROM ClaimsNoteReceived, ClaimsDetailReceived, Items
WHERE ClaimsNoteReceived.ClaimID = @CLAIMID
AND ClaimsDetailReceived.ForumCode = Items.Alias
AND ClaimsNoteReceived.DocSerial = ClaimsDetailReceived.DocSerial
Group By ClaimsDetailReceived.Product_Code, ClaimsDetailReceived.Batch, ClaimsDetailReceived.Expiry, Quantity,
ClaimsDetailReceived.PurchasePrice, ClaimsDetailReceived.Rate, ClaimsDetailReceived.Remarks, Items.ProductName, ClaimsDetailReceived.Batch




