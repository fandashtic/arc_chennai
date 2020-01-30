CREATE PROCEDURE sp_insert_SplCatDetails    
( @CATEGORYCODE INT,      
       @PRODUCTCODE NVARCHAR(15),      
       @CATEGORYID INT,    
 @LEAFNODES INT=0    
)      
AS     
BEGIN      
 DECLARE @CatID Int    
 IF @LEAFNODES=0    
  INSERT INTO Special_Cat_Product(Special_Cat_Code, Product_Code,CategoryID)      
  VALUES(@CATEGORYCODE, @PRODUCTCODE, @CATEGORYID)      
 ELSE    
 BEGIN    
  DECLARE Leaf_Nodes CURSOR FOR    
  SELECT CategoryID FROM dbo.sp_get_LeafNodes(@CATEGORYID)
  WHERE CategoryID IN (SELECT DISTINCT CategoryID FROM Items WHERE Active = 1)    
  OPEN Leaf_Nodes    
  FETCH NEXT FROM Leaf_Nodes INTO @CatID    
  WHILE @@FETCH_STATUS = 0    
  BEGIN    
   INSERT INTO Special_Cat_Product(Special_Cat_Code, Product_Code, CategoryID, HierarchyID)      
   VALUES(@CATEGORYCODE, @PRODUCTCODE, @CatID, @CATEGORYID)      
   FETCH NEXT FROM Leaf_Nodes INTO @CatID    
  END    
  CLOSE Leaf_Nodes    
  DEALLOCATE Leaf_Nodes    
 END    
END  

