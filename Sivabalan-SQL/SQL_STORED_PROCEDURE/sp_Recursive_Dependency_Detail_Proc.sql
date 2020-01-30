CREATE Procedure sp_Recursive_Dependency_Detail_Proc (@Procedure_Name nvarchar(250))    
As  
Declare @Proc nvarchar(255)  
Declare @Detail_Proc nvarchar(255)  
Declare @rec_cnt integer  
  
insert into #patch_Proc values(@Procedure_Name, N'0')  
  
/* Inserting the Dependencies of the Parent Proc in the temp table*/  
insert into #patch_Proc   
select name,   
  
"Ref" = case xtype  
when N'P' then 1  
ELse 2  
End  
  
  from sysobjects where id in   
(select depid from sysdepends where id in (select id from sysobjects where name like @Procedure_Name))  
and xtype in (N'P',N'FN')  
  
  
/*Storing the contents in the temp table to a cursor */  
Declare Depend Cursor Keyset For  
Select Proc_name From #patch_Proc Where Ref = 1  
Open Depend  
Fetch Next From Depend Into @Proc  
  
  
/* Fetch one by one from the cursor and stoe its dependies to the same temp table*/   
While @@Fetch_Status = 0  
Begin  
 insert into #patch_Proc   
 select name, 1 from sysobjects where id in   
 (select depid from sysdepends where id in (select id from sysobjects where name like @Proc))  
 and xtype in (N'P',N'FN')  
 Fetch Next From Depend Into @Proc  
End  
Close Depend  
DeAllocate Depend  
  
Select @rec_cnt = count(*) from #patch_proc Where Ref = 0  
  
  
If @rec_cnt = 1  
begin  
 Select @Detail_Proc = ActionData from ReportData where Parent in   
 (Select [ID] from ReportData where ActionData = isnull(@Procedure_Name,N''))  
 If Isnull(@Detail_Proc,N'') = N''   
 begin   
  Return 0  
 end  
 exec sp_Recursive_Dependency_Detail_Proc @Detail_Proc  
end  
