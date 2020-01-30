Create Procedure sp_List_GroupName  
As  
Select GroupId, GroupName  
From ProductCategoryGroupAbstract  
Where Active = 1  
