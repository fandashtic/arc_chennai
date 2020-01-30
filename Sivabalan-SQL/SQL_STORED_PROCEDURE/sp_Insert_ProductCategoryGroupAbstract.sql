Create Procedure sp_Insert_ProductCategoryGroupAbstract(@GroupName nVarchar(50))  
As  
Insert Into ProductCategoryGroupAbstract(GroupName) values (@GroupName)   
Select @@Identity    
