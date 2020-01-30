Create Procedure mERP_SP_LoadQuoCatInfo(@CatName as nvarchar(200)) 
As 
Begin 
	select CategoryID,description,Level from Itemcategories where Category_name=@CatName 
End 
