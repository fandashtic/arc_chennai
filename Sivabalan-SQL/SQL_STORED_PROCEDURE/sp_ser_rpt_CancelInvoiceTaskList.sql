CREATE procedure [dbo].[sp_ser_rpt_CancelInvoiceTaskList](@Item nvarchar(255))                          
as                          
                          
Declare @ParamSep nVarchar(10)                              
Declare @EID int                          
Declare @ServiceInvoiceID int                              
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
Declare @Prefix as nvarchar(5)        
        
        
Set @tempString = @Item                          
Set @ParamSep = Char(2)                              
                          
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                              
set @ServiceInvoiceID = substring(@tempString, 1, @ParamSepcounter-1)                           
          
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                           
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                          
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                        
                        
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                           
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                          
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)                           
                          
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                           
set @Type = @tempString            
                        
if  @Type = '2'                          
begin                          
	select ServiceInvoicedetail.TaskID, 'TaskID' = ServiceInvoicedetail.TaskID,            
	'Task Description' =  Taskmaster.[Description],                  
	(case Isnull(TaskType,'') when 0 then 'New' when 1 then 'Bounds Case'else '' end) as 'Type',            
	'Estimated Rate' = isnull(EstimatedPrice,0),            
	'Task Rate' = isnull(serviceinvoicedetail.price,0),    
	'Service Tax(%)' = serviceTax_Percentage,            
	'Tax Amount' = isnull(ServiceInvoicedetail.serviceTax,0),            
	'Amount' = isnull(Amount,0),            
	'Net Value' = Isnull(sum(Netvalue),0), 'ColumnKey' = 2
	from ServiceInvoicedetail,Taskmaster                           
	where type = @Type             
	and ServiceInvoicedetail.product_Code = @Itemcode            
	and serviceInvoiceID = @ServiceInvoiceID            
	and Product_specification1 = @Itemspec1            
	and  ServiceInvoicedetail.Taskid = Taskmaster.Taskid                                       
	and isnull(serviceinvoicedetail.taskid,'')  <> '' and isnull(sparecode,'') = ''                        
	group by ServiceInvoicedetail.TaskID,Taskmaster.[Description],ServiceInvoicedetail.TaskType,            
	ServiceInvoicedetail.EstimatedPrice,serviceinvoicedetail.price,ServiceInvoicedetail.ServiceTax_Percentage,ServiceInvoicedetail.ServiceTax,            
	ServiceInvoicedetail.Amount,ServiceInvoicedetail.Netvalue            
End                     
Else if  @Type = '3'                          
begin                                  
	select @Prefix = Prefix from VoucherPrefix where TranID = 'ISSUESPARES'                            
	select serviceinvoicedetail.IssueID,        
	'IssueID' =  @Prefix + cast(Issueabstract.DocumentID as nvarchar(15)),                                  
	'Issue Date' = issueabstract.issuedate,            
	'Spare Code' = serviceinvoicedetail.sparecode,            
	'Spare Name ' = productname,            
	'Batch' = Serviceinvoicedetail.batch_number,            
	'UOM' = UOM.Description, 
	'Qty' = Serviceinvoicedetail.UomQty,                        
	'Date of Sale ' = Serviceinvoicedetail.DateofSale,                    
	(case Isnull(Serviceinvoicedetail.Warranty,'') when 1 then 'Yes' when 2 then 'No'else '' end) as 'Warranty',                           
	'Warranty No' = Serviceinvoicedetail.WarrantyNo,                  
	--'Sale Price' = isnull(ServiceInvoiceDetail.price,0),            
	'Sale Price' = isnull(ServiceInvoiceDetail.UOMPrice,0),
	'Amount' = isnull(Serviceinvoicedetail.amount,0),            
	'Discount(%)' = isnull(ItemDiscountPercentage,0),            
	'SalesTax(%)'  = isnull(ServiceInvoiceDetail.Saletax,0),            
	'Tax Amount' = Isnull(Lstpayable,0) + Isnull(CSTpayable,0),            
	'ST Credit' = Case When IsNull(Flag,0)= 1 then 0 Else ((ServiceInvoiceDetail.Amount + ServiceInvoiceDetail.TaxSuffered - ServiceInvoiceDetail.ItemDiscountValue)* ServiceInvoiceDetail.SaleTax/100)  * 
	 ((ServiceInvoiceAbstract.TradeDiscountPercentage + ServiceInvoiceAbstract.AdditionalDiscountPercentage)/100)
	 End,
	'TaxSuffered(%)' = ServiceInvoiceDetail.Tax_sufferedPercentage,            
	'TaxSuffered' = ServiceInvoiceDetail.TaxSuffered,            
	(case Isnull(ServiceInvoiceDetail.SaleID,'') when 1 then 'First Sale' when 2 then 'Second Sale'else '' end) as 'Type',    
	'Net Value' = Isnull((Serviceinvoicedetail.Netvalue),0), 'ColumnKey' = 3
	from Serviceinvoicedetail,items,issueabstract,ServiceInvoiceAbstract,UOM
	where serviceinvoicedetail.issueid = issueabstract.issueid  
	and serviceinvoicedetail.ServiceInvoiceID = @ServiceinvoiceID            
	and ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID
	and Serviceinvoicedetail.product_Code = @Itemcode            
	and Serviceinvoicedetail.Product_specification1 = @ItemSpec1            
	and Serviceinvoicedetail.SpareCode = items.product_Code                          
	and isnull(sparecode,'')  <> ''  
	and ServiceInvoiceDetail.UOM *= UOM.UOM
	order by serialno                        
End
