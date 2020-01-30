CREATE PROCEDURE sp_list_ProductHierarchies  
AS  
BEGIN  

Declare @LEVEL As NVarchar(50)
Set @LEVEL = dbo.LookupDictionaryItem(N'Level', Default)

SELECT Level, Isnull(HierarchyName,LevelDesc) as LevelDesc  
FROM  
(SELECT Level, @LEVEL + Cast(level as nvarchar(5)) as LevelDesc  
FROM ItemCategories
Where level is not null and ItemCategories.Active=1
GROUP BY level) TBL1  
LEFT JOIN (SELECT HierarchyId, HierarchyName FROM Itemhierarchy) TBL2   
ON TBL1.Level=TBL2.HierarchyId  

END  

