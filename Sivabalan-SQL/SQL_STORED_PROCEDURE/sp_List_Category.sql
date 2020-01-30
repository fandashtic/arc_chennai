CREATE Procedure sp_List_Category  
As  

Select I.CategoryId, Category_Name, 
(select Max(GroupID) from productcategorygroupabstract Where GroupName = TCD.CategoryGroup) As GroupID,  
(SELECT distinct (GROUPNAME) FROM PRODUCTCATEGORYGROUPABSTRACT WHERE GroupName = TCD.CategoryGroup) AS GROUPNAME  
FROM ITEMCATEGORIES I
Left Outer Join tblcgdivmapping TCD  On I.Category_Name = TCD.Division 
WHERE ACTIVE = 1 AND ISNULL(LEVEL,0) = 2  
