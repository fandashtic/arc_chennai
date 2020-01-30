CREATE procedure sp_ser_dropSparesitems(@TaskID nvarchar(50),@ProductCode nvarchar(15),    
@SpareCode nvarchar(4000),@Mode int )      
as      
    
if @Mode = 2    
Begin      
Create Table #TempItems (SpareCode nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS null)
      
Insert #TempItems      
exec sp_ser_SqlSplit @SpareCode,','      
      
Delete Task_Items_spares      
Where TaskID = @TaskID     
and Product_code = @productCode   
and sparecode not in (Select SpareCode from #TempItems)    
      
Drop Table #TempItems      
End    
else    
Begin    
 Delete Task_Items_spares            
  Where TaskID = @TaskID and Product_code = @productCode     
End    

