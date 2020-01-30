CREATE procedure sp_ser_rpt_OpenTaskRelateSparesList(@Item nvarchar(255))                
as                
                
Declare @ParamSep nVarchar(10)                    
Declare @EID int                
Declare @EstimationID int                    
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
              
/* EstimationID */              
                 
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                    
set @EstimationID = substring(@tempString, 1, @ParamSepcounter-1)                 
              
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
	select Estimationdetail.SpareCode,'Spare Code' = Estimationdetail.SpareCode,        
	'Spare Name' = productname,                
	'UOM'= UOM.[Description],                   
	'Qty' = Isnull(UomQty,0),                  
	'Sale Price' = Isnull(Uomprice,0),  
	'SalesTax' = Isnull(SalesTax,0),  
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
	and TaskID = @Taskid                
	and isnull(sparecode,'')  <> ''                
	order by serialno              
End                
else if @Type = '2'    
	select Estimationdetail.SpareCode,'Spare Code' = Estimationdetail.SpareCode,  
	'Spare Name ' = productname,                    
	'UOM'= UOM.[Description],                   
	'Qty' = Isnull(UomQty,0),  
	'Sale Price ' = Isnull(Uomprice,0),  
	'SalesTax' = Isnull(SalesTax,0),  
	'Sales Tax Amount ' = (Isnull(LSTPayable,0) + Isnull(CSTpayable,0)),                    
	'TaxSuffered Percentage' = Isnull(Taxsuffered_Percentage,0),                    
	'TaxSuffered' = Isnull(Estimationdetail.TaxSuffered,0),  
	'Amount' = Isnull(Amount,0),                     
	'Net Value ' = Isnull(Netvalue,0),'ColumnKey' = 3 
	 from Estimationdetail,items,UOM                     
	 where EstimationDetail.SpareCode = items.product_Code                    
	 and EstimationDetail.UOM = UOM.UOM                  
	 and EstimationID = @EstimationID                    
	 and Estimationdetail.product_Code = @Itemcode                    
	 and Product_specification1 = @Itemspec1                    
	 and type = @Type                    
	 and TaskID = @Serviceid                    
	 and isnull(sparecode,'')  <> ''                    
	 order by serialno             



