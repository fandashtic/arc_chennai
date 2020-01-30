Create Procedure sp_Insert_ProductCategoryGroupDetail  
(@GroupId Int, @CatId Int)  
AS  
Insert Into ProductCategoryGroupDetail values (@GroupId, @CatId)  
