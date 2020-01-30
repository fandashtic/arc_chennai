CREATE PROCEDURE sp_insert_category(@CATEGORY nvarchar(255),    
        @DESCRIPTION nvarchar(255),    
        @PARENTID int,    
        @TRACK_INVENTORY int,    
        @CAPTURE_PRICE int)    
AS    
    
INSERT INTO ItemCategories(Category_Name,    
      Description,    
      ParentID,    
      Track_Inventory,    
      Price_Option,
      ModifiedDate)    
VALUES (@CATEGORY,    
  @DESCRIPTION,    
  @PARENTID,    
  @TRACK_INVENTORY,    
  @CAPTURE_PRICE,
  GetDate())    
SELECT @@IDENTITY 
