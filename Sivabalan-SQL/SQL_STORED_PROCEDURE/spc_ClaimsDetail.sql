CREATE procedure spc_ClaimsDetail (@ClaimID int)
as
select Items.Alias, ClaimsDetail.Quantity, ClaimsDetail.Rate,
ClaimsDetail.Remarks, ClaimsDetail.Batch, ClaimsDetail.Expiry, ClaimsDetail.PurchasePrice,
ClaimsDetail.SchemeType
From ClaimsDetail, Items
Where ClaimsDetail.ClaimID = @ClaimID and
ClaimsDetail.Product_Code = Items.Product_Code
