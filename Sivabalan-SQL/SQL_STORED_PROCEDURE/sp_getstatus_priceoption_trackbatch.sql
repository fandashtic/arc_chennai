CREATE	Procedure sp_getstatus_priceoption_trackbatch ( @ItemCode nvarchar(15))
as
SELECT Track_Batches, Price_Option,ISNULL(TrackPKD, 0)
From Items left outer join ItemCategories on  Items.CategoryID = ItemCategories.CategoryID
WHERE Product_Code = @ItemCode  
