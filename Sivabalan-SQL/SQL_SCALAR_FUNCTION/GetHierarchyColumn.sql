
CREATE FUNCTION GetHierarchyColumn(@Level nvarchar(500))
RETURNS nvarchar(100)
BEGIN
DECLARE @FirstLevel nvarchar(100)  
DECLARE @LastLevel nvarchar(100)  
DECLARE @Result nvarchar(100)
Declare @First nvarchar(100)
Declare @Last nvarchar(100)
set @First = dbo.LookupDictionaryItem('First Level',default)
set @Last = dbo.LookupDictionaryItem('Last Level',default)
  
SELECT @FirstLevel = IsNull(HierarchyName,@First) FROM ItemHierarchy WHERE HierarchyID = 1  
SELECT @LastLevel = IsNull(HierarchyName,@Last) FROM ItemHierarchy 
WHERE HierarchyID = (SELECT Max([Level]) FROM ItemCategories)  
  
IF IsNull(@FirstLevel, N'') = N''  
 SET @FirstLevel = @First
IF IsNull(@LastLevel, N'') = N''  
 SET @LastLevel = @Last

IF dbo.LookupDictionaryItem2(@Level,default) = N'FIRST'
   SET @Result = @FirstLevel
ELSE
   SET @Result = @LastLevel

RETURN(@Result)
END




