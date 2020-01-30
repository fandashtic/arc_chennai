CREATE procedure sp_ser_rpt_CancelJObCardTaskList(@Item nvarchar(255))                
as                
                
Declare @ParamSep nVarchar(10)                    
Declare @EID int                
Declare @JobcardID int                    
Declare @ItemCode nvarchar(255)                
Declare @Productcode int                
Declare @Itemspec1 nvarchar(255)                  
Declare @Type nvarchar(50)                    
Declare @TaskID1 nvarchar(255)                  
Declare @JobID nvarchar(255)                  
Declare @serviceid nvarchar(255)                
Declare @tempString nVarchar(510)                
Declare @ParamSepcounter int                
Declare @TID nvarchar(4000)                
Set @tempString = @Item                
Set @ParamSep = Char(2)                    
                
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                    
set @JobcardID = substring(@tempString, 1, @ParamSepcounter-1)                 
              
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                 
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                
set @Type = substring(@tempString, 1, @ParamSepcounter-1)                 
                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                 
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                 
                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                 
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)                 
              
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                 
set @serviceid =  @tempString                
              
              
if  @Type = '1'                
begin                
              
 select 'TID' = cast(cast(JobcardID as nvarchar(10))+ @paramsep + '1' + @paramsep + @ItemCode + @paramsep +               
  @Itemspec1  + @paramsep + @serviceid + @paramsep + jobcarddetail.Taskid as nvarchar(4000)),                
 'TaskID' = jobcarddetail.Taskid,Taskmaster.[Description], 'ColumnKey' = 2                
 from jobcarddetail,Taskmaster                 
 where  jobcardDetail.Taskid = Taskmaster.Taskid                
 and jobcarddetail.product_Code = @Itemcode                
 and JobcardID = @jobcardID                
 and Product_specification1 = @Itemspec1                
 and type = @Type                
 and jobid = @serviceid                
 and isnull(sparecode,'') = ''              
 order by serialno              
               
End            
else if  @Type = '2'                
begin                
	select jobcarddetail.SpareCode,'Spare Code'  = jobcarddetail.SpareCode,           
	'Spare Name' = productname,                
	'UOM'= UOM.[Description],               
	'Qty' = Isnull(UomQty,0),              
	'Date of Sale' = DateofSale,          
	(case Isnull(Warranty,'') when 1 then 'Yes' when 2 then 'No'else '' end) as 'Warranty',                 
	'Warranty No' = WarrantyNo, 'ColumnKey' = 3
	from jobcarddetail,items,UOM                 
	where jobcardDetail.SpareCode = items.product_Code                
	and jobcardDetail.UOM = UOM.UOM              
	and jobcardID = @jobcardID                
	and jobcarddetail.product_Code = @Itemcode                
	and Product_specification1 = @Itemspec1                
	and type = @Type                
	and Taskid = @Serviceid                
	and isnull(sparecode,'')  <> ''                
	order by serialno              
end         
else if  @Type = '3'                
begin                
	select jobcarddetail.SpareCode,'Spare Code'  = jobcarddetail.SpareCode,           
	'Spare Name' = productname,                
	'UOM'= UOM.[Description],               
	'Qty' = Isnull(UomQty,0),              
	'Date of Sale ' = DateofSale,          
	(case Isnull(Warranty,'') when 1 then 'Yes' when 2 then 'No'else '' end) as 'Warranty',                 
	'Warranty No' = WarrantyNo, 'ColumnKey' = 3
	from jobcarddetail,items,UOM                 
	where jobcardDetail.SpareCode = items.product_Code                
	and jobcardDetail.UOM = UOM.UOM              
	and jobcardID = @jobcardID                
	and jobcarddetail.product_Code = @Itemcode                
	and Product_specification1 = @Itemspec1                
	and type = @Type                
	and Sparecode = @Serviceid                
	and isnull(sparecode,'')  <> ''                
	order by serialno              
End 

