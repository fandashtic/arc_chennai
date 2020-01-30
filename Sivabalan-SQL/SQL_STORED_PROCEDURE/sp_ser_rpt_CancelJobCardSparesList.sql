CREATE procedure sp_ser_rpt_CancelJobCardSparesList(@Item nvarchar(255))              
as              
              
Declare @ParamSep nVarchar(10)                  
Declare @JID int              
Declare @JobcardID int                  
Declare @ItemCode nvarchar(255)              
Declare @Productcode int              
Declare @Itemspec1 nvarchar(255)                
Declare @Type nvarchar(255)                  
Declare @TaskID nvarchar(255)                
Declare @JobID nvarchar(255)                
Declare @serviceid nvarchar(255)              
Declare @tempString nVarchar(510)              
Declare @ParamSepcounter int              
            
Set @tempString = @Item              
Set @ParamSep = Char(2)                  
            
/* ID */            
               
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                  
set @jobcardID = substring(@tempString, 1, @ParamSepcounter-1)               
            
/* JObType */            
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)              
set @Type = substring(@tempString, 1, @ParamSepcounter-1)               
            
/* Productcode */            
              
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)              
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)               
            
/* ItemSpecification */              
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)              
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)               
            
/* jobid,taskid,sparecode */            
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)              
set @Serviceid = substring(@tempString, 1, @ParamSepcounter-1)            
            
/* taskid */            
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
set @Taskid =  @tempString              
            
            
if  @Type = '1'              
            
Begin              
	select jobcarddetail.SpareCode, 'Spare Code'  = jobcarddetail.SpareCode,         
	'Spare Name ' = productname,              
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
	and TaskID = @Taskid              
	and isnull(sparecode,'')  <> ''              
	order by serialno            
End              

