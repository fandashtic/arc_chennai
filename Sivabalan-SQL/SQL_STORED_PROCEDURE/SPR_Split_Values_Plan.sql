CREATE Procedure SPR_Split_Values_Plan (@Customerid nvarchar(200), @nIndex int, @Result NVarChar(200) output)        
as    
        
Declare @Delimeter as Char(1)                
declare @Salesman_tmp as nvarchar(30)                
Declare @WCPCode_tmp as nvarchar(30)                
Declare @Customerid_tmp as nvarchar(30)                      
declare @Order_tmp as nvarchar(30)      
declare @Detail nvarchar(30)        
Declare @SV_Count as nvarchar(30)
Declare @Cur_Date As nvarchar(30)
Set @Delimeter=Char(44)                  
create table #tmpCust (Salesman varchar(30))                  
insert into  #tmpCust select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)                  
    
Declare @nCount Int                
Set @NCount = 1                  
    
declare Split_Cursor cursor for select salesman from #tmpcust                
open  split_cursor                
fetch next from  Split_Cursor into @Detail    
while @@Fetch_Status=0                
 begin                
 If @nCount = 1                 
  begin                
  set @salesman_tmp =@Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
  End                
 If @nCount = 2                
  begin                
  set @WCPCode_tmp = @Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
  End                
 If @nCount = 3                
  begin                
  set @Customerid_tmp =@Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
 End                
 If @nCount = 4                
  begin                
  set @Order_tmp =@Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
  End       
 If @nCount = 5                
  begin                
  set @SV_Count =@Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
  End       
 If @nCount = 6                
  begin                
  set @Cur_Date = @Detail                
  Set @nCount = @nCount + 1                
  fetch next from  Split_Cursor into @Detail                
  End    
end                
if @nindex =1        
begin        
 select @Result =@salesman_tmp        
end        
if @nindex=2        
begin        
 select @Result =@WCPCode_tmp        
end        
if @nindex=3        
begin        
 select @Result =@Customerid_tmp        
end        
if @nindex=4      
begin        
 select @Result =@Order_tmp        
end          
if @nindex=5  
begin        
 select @Result =@SV_Count        
end      
if @nindex=6
begin        
 select @Result =@Cur_Date
end         
close split_cursor                
deallocate split_cursor         
drop table #tmpcust        
  


