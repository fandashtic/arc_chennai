CREATE Procedure sp_list_RecItems_FMCG (@ForumCode nvarchar(20))
As
Select ItemsReceivedDetail.ID, ItemsReceivedDetail.PartyID,
ItemsReceivedDetail.ForumCode, ItemsReceivedDetail.Product_Code,
ItemsReceivedDetail.ProductName, ItemsReceivedDetail.CategoryName,
ItemsReceivedDetail.ManufacturerName, ItemsReceivedDetail.BrandName,
ItemsReceivedDetail.PurchasePrice, ItemsReceivedDetail.SalePrice,
dbo.StripDateFromTime(ItemsReceivedDetail.CreationDate),
dbo.StripDateFromTime(ItemsReceivedDetail.ModifiedDate)
From ItemsReceivedDetail
Where IsNull(ItemsReceivedDetail.Flag, 0) & 32  = 0 And
ItemsReceivedDetail.PartyID In (Select ID From ItemsReceivedAbstract Where
ForumCode = @ForumCode And IsNull(Flag, 0) & 32  = 0)
Order By ItemsReceivedDetail.ID
