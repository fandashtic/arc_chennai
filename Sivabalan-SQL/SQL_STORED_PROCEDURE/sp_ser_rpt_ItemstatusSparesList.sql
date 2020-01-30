CREATE procedure [dbo].[sp_ser_rpt_ItemstatusSparesList](@Item nvarchar(255))                                                  
as                                                  
                                                  
Declare @ParamSep nVarchar(10)                                                      
Declare @EID int                                                  
Declare @jobcardID int                                                      
Declare @ItemCode nvarchar(255)                                                  
Declare @Productcode int                                                  
Declare @Itemspec1 nvarchar(255)                                                    
Declare @Type nvarchar(50)                                                      
Declare @JobID nvarchar(255)                                                    
Declare @serviceid nvarchar(255)                                                  
Declare @tempString nVarchar(510)                                                  
Declare @ParamSepcounter int                                                  
Declare @TID nvarchar(4000)                                                  
Set @tempString = @Item                                                  
Set @ParamSep = Char(2)                                                      
                                                  
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                                                      
set @jobcardID = substring(@tempString, 1, @ParamSepcounter-1)                                                   
                                                
                                                  
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                                                  
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                                                   
                                                  
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                                                  
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)                                                   
                                                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                                   
set @Type =  @tempString                                                  
                                             
                                        
if  @Type = '1'                                                  
begin                                                  
	Select 'TaskID'= jobcardtaskallocation.Taskid, 
	'TaskID'= jobcardtaskallocation.Taskid,                                        
	'Description' = Taskmaster.[Description],                                                  
	'Personnel Name' = personnelname,                                        
	(Case                                     
		when  TaskStatus = 0 then  'Open'                                       
		when  TaskStatus = 1 then 'Assigned'                                       
		when  TaskStatus = 2 then 'Closed'                                        
		else '' end) as 'Status',                                                                 
	(Case Isnull(StartWork, -1) when 0 then 'No' when 1 then 'Yes' else '' end) as 'Start Work',
	'Start Date' = Startdate,
	'Start Time' = isnull(dbo.sp_ser_StripTimeFromDate(Starttime),''),                                        
	'End Date'   = Enddate,                                        
	'End Time'   = isnull(dbo.sp_ser_StripTimeFromDate(Endtime),''), 2 'ColumnKey'
	from jobcardtaskallocation,Taskmaster,personnelmaster                                                   
	where  jobcardtaskallocation.Taskid = Taskmaster.Taskid                                                  
	and Isnull(Taskstatus,0) <> 5       
	and Isnull(Taskstatus,0) <> 4                                     
	and Isnull(Taskstatus,0) <> 3                                     
	and jobcardtaskallocation.product_Code = @Itemcode                                                  
	and jobcardtaskallocation.personnelID *= personnelmaster.personnelid                                        
	and jobcardid = @jobcardID                  
	and Product_specification1 = @Itemspec1                                                  
	order by Taskid                                                
End                                                                       
if  @Type = '2'                                        
Begin                                                  
	Select JS.spareCode,                            
	'Spare Code' = JS.SpareCode, 'Spare Name ' = productname,                                                 
	'UOM'= UOM.[Description],                                                 
	'Issued Qty' = Isnull(JS.qty,0)-isnull(JS.pendingqty,0),  
	'Pending Qty' = Isnull(JS.pendingqty,0),   
	(case when Isnull(JS.pendingqty,0) = 0 and Isnull(sparestatus,0) = 1 then                                            
	'Issued' when Isnull(JS.pendingqty,0) > 0 and Isnull(sparestatus,0) = 2  then 'Pending'                                 
	when Isnull(JS.pendingqty,0) > 0  and Isnull(JS.sparestatus,0) = 0 then 'Pending'                                           
	else '' end) as 'Status', 3 'ColumnKey'
	from Jobcardspares JS, items, UOM, issueabstract  
	where JS.SpareCode = items.product_Code                                                  
	and JS.UOM = UOM.UOM                                                
	and JS.jobcardID =  @Jobcardid  
	and JS.product_Code = @itemcode  
	and JS.Product_specification1 = @Itemspec1  
	and Isnull(JS.sparestatus,0) <> 2  
	group by JS.sparecode, items.productname, uom.[Description],  
	JS.qty, JS.pendingqty, JS.sparestatus  
End
