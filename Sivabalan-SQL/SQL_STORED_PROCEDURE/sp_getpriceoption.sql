
CREATE proc sp_getpriceoption(@category nvarchar(255))
as
SELECT Price_Option FROM ItemCategories WHERE Category_Name = @CATEGORY


