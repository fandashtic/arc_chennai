CREATE procedure spr_list_property(@PropertyName nvarchar(2550))    
as    
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpProperty(PropName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @PropertyName='%'       
   Insert into #tmpProperty select Property_Name from properties      
Else      
   Insert into #tmpProperty select * from dbo.sp_SplitIn2Rows(@PropertyName,@Delimeter)    
    
    
select PropertyID, "Property" = Property_Name     
from properties     
where Property_Name In (Select PropName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProperty)    
    
Drop table #tmpProperty    
    
  
  
  






