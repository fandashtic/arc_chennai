CREATE Procedure sp_ser_rpt_BouncecaseItemSpecwise(@FromDate datetime, @ToDate datetime,@Itemspec nvarchar(255))                                
As        
    
Declare @ParamSep nVarchar(10)                              
Set @ParamSep = Char(2)                              
Declare @Itemspec1 nvarchar(50)                                 
Declare @ItemInfo nvarchar(4000)              
Declare @Prefix nvarchar(15)                  
Declare @ItemInfo1 nvarchar(4000)              

select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                                

Create table #ItemSpec_Temp([_ID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                  
                  
set @Iteminfo ='Alter Table #ItemSpec_Temp Add     
[_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[_Item Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,                                
[' + @ItemSpec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,    
[_No Of Bounce Cases] int null'                        
                      
Exec sp_executesql @Iteminfo                                
Insert into #ItemSpec_Temp    
select 'ID' = jobcarddetail.product_specification1,                                 
jobcarddetail.Product_code,productname,                                
jobcarddetail.product_specification1,          
'No of Bounce Cases' = count(TaskType)        
from jobcarddetail,jobcardabstract,items    
where (IsNull(jobcarddetail.TaskType,0) = 1)        
and jobcarddetail.jobcardid = jobcardabstract.jobcardid        
and (IsNull(jobcardabstract.Status, 0) & 192) = 0                        
and jobcarddetail.product_code = items.product_code    
and jobcarddetail.Product_specification1 like @Itemspec    
and (jobcardabstract.jobcarddate) between @FromDate and @ToDate
and Isnull(JobcardDetail.Type,0) = 2 and 
IsNull(JobcardDetail.SpareCode, '') = '' and (IsNull(JobcardDetail.TaskType,0) = 1)
group by jobcarddetail.Product_Code,items.ProductName, jobcarddetail.Product_Specification1       

set @Iteminfo1 = 'Select  [_ID] as "ID",
[_Item Code] as "Item Code",
[_Item Name]  as "Item Name",
[' + @ItemSpec1 + '],
[_No Of Bounce Cases] as "No Of Bounce Cases"
from #ItemSpec_Temp'    

Exec sp_executesql @Iteminfo1

Drop Table #ItemSpec_Temp    

