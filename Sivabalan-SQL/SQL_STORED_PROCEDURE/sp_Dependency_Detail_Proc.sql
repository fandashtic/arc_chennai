CREATE Procedure sp_Dependency_Detail_Proc(@Parent_Proc_Name nvarchar(250))  
As  
Create Table #patch_proc (Proc_Name nvarchar(250), Ref int)  
exec sp_Recursive_Dependency_Detail_Proc @Parent_Proc_Name   
Select Proc_Name, Ref from #patch_proc Where Isnull(Proc_Name,N'') <> N''  
Drop Table #patch_proc 
