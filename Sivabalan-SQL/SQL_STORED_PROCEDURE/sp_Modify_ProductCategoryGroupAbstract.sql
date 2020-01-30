Create Procedure sp_Modify_ProductCategoryGroupAbstract(@GroupId Int, @Active Int)  
As  
Update ProductCategoryGroupAbstract Set Active =  @Active Where GroupId = @GroupId  
