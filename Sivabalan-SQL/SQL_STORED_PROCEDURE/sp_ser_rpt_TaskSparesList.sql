CREATE Procedure sp_ser_rpt_TaskSparesList(@Item nvarchar(255))                    
as                    
                    
Declare @ParamSep nVarchar(10)                        
Declare @EID int                    
Declare @EstimationID int                        
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
set @EstimationID = substring(@tempString, 1, @ParamSepcounter-1)                     
                  
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
	select 'TID' = cast(cast(EstimationID as nvarchar(10))+ @paramsep + '1' + @paramsep + @ItemCode + @paramsep +                   
	@Itemspec1  + @paramsep + @serviceid + @paramsep + Estimationdetail.Taskid as nvarchar(4000)),                    
	'TaskID' = Estimationdetail.Taskid, 'Description' = Taskmaster.[Description],                    
	'Rate'   = Isnull(Amount,0),                     
	'Service Tax' = Isnull(Estimationdetail.ServiceTax_Percentage,0),                     
	'Tax Amount' = Isnull(Estimationdetail.ServiceTax,0),                    
	'Net Value' = Isnull(NetValue,0), 'ColumnKey' = 2 from Estimationdetail,Taskmaster                     
	where  EstimationDetail.Taskid = Taskmaster.Taskid                    
	and Estimationdetail.product_Code = @Itemcode                    
	and EstimationID = @EstimationID                    
	and Product_specification1 = @Itemspec1                    
	and type = @Type                    
	and jobid = @serviceid                    
	and isnull(sparecode,'') = ''                  
	order by serialno                  
                   
End                    
Else if  @Type = '2'                    
Begin      
	
	select 'TID' = cast(cast(EstimationID as nvarchar(10))+ @paramsep + '2' + @paramsep + @ItemCode + @paramsep +                   
	@Itemspec1  + @paramsep + @serviceid + @paramsep + Estimationdetail.Taskid as nvarchar(4000)),                    
	'TaskID' = Estimationdetail.Taskid,
	'Description' = Taskmaster.[Description],                    
	'Rate'   = Isnull(Amount,0),                     
	'Service Tax' = Isnull(Estimationdetail.ServiceTax_Percentage,0),                     
	'Tax Amount' = Isnull(Estimationdetail.ServiceTax,0),                    
	'Net Value' = Isnull(NetValue,0), 'ColumnKey' = 2
	from Estimationdetail,Taskmaster                     
	where  EstimationDetail.Taskid = Taskmaster.Taskid                    
	and Estimationdetail.product_Code = @Itemcode                    
	and EstimationID = @EstimationID             
	and Product_specification1 = @Itemspec1                    
	and type = @Type                    
	and Estimationdetail.Taskid = @serviceid                    
	and isnull(sparecode,'') = ''                  
	order by serialno                  
End                
Else if  @Type = '3'                 
Begin            
	select '','Spare Code' = Estimationdetail.SpareCode, 
	'Spare Name' = productname,                    
	'UOM'= UOM.[Description],                   
	'Qty' = Isnull(UomQty,0),                  
	'Sale Price' = Isnull(Uomprice,0),
	'SalesTax' = ISnull(SalesTax,0),
	'Sales Tax Amount' = (Isnull(LSTPayable,0) + Isnull(CSTpayable,0)),                  
	'TaxSuffered Percentage' = Isnull(Taxsuffered_Percentage,0),                  
	'TaxSuffered' = Isnull(Estimationdetail.TaxSuffered,0),
	'Amount' = Isnull(Amount,0),                   
	'Net Value' = Isnull(Netvalue,0), 'ColumnKey' = 3
	from Estimationdetail,items,UOM                     
	where EstimationDetail.SpareCode = items.product_Code                    
	and EstimationDetail.UOM = UOM.UOM                  
	and EstimationID = @EstimationID                    
	and Estimationdetail.product_Code = @Itemcode                    
	and Product_specification1 = @Itemspec1                    
	and type = @Type                    
	and SpareCode = @Serviceid                    
	and isnull(sparecode,'')  <> ''                    
	order by serialno                  
End               




