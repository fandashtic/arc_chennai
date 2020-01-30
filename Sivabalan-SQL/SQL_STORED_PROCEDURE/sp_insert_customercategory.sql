
CREATE proc sp_insert_customercategory
	(	 @CategoryName_2 NVARCHAR(50))

AS INSERT INTO [CustomerCategory] 
	 ( 	 [CategoryName]) 
 
VALUES 
	(@CategoryName_2 
)

select @@identity




