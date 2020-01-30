CREATE procedure sp_ser_droptaskitems(@TaskID nvarchar(50),@ItemCodes nvarchar(4000))  
as  
  
Create Table #TempItems (ItemCode nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS null)
  
Insert #TempItems
exec sp_ser_SqlSplit @ItemCodes,','
  
Delete Task_Items  
Where TaskID = @TaskID  
and Product_Code not in (Select ItemCode from #TempItems)  

Delete task_items_spares  
Where TaskID = @TaskID  
and Product_Code not in (Select ItemCode from #TempItems)  
  
Drop Table #TempItems  

