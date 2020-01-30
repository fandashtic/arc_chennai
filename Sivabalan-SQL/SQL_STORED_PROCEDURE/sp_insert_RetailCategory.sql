CREATE PROCEDURE sp_insert_RetailCategory(@CATEGORY nvarchar(255))  
AS      
      
INSERT INTO RetailCustomerCategory(CategoryName, Active, CreationDate )  
      
VALUES (@CATEGORY, 1, Getdate())  
SELECT @@IDENTITY   
  


