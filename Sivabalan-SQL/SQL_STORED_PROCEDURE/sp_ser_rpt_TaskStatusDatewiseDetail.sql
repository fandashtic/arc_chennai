CREATE procedure sp_ser_rpt_TaskStatusDatewiseDetail(@Item nVarchar(255))                      
as                      

Declare @ParamSep nVarchar(2),@tmpStr nVarchar(255),@Pos as Int
Declare @JCPrefix nVarchar(10),@SIPrefix nVarchar(10)
Declare @JobCardID Int, @TaskID nVarChar(50),@Item_SpecValue nVarchar(50),@SerialNo as Int
Declare @Item_Spec1 nVarchar(50)
Declare @Qry nVarChar(2000)	

Set @ParamSep = Char(2)
Set @tmpStr = @Item

--JobCard ID Extraction
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)
Set @JobCardID = Cast(SubString(@tmpStr, 1, @Pos - 1) as Int)
--Task ID Extraction
Set @tmpStr = SubString(@tmpStr, @Pos + 1, len(@Item))
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)
Set @TaskID = SubString(@tmpStr, 1, @Pos-1)
--Prodcut Specification Extraction
Set @tmpStr = SubString(@tmpStr, @Pos + 1, len(@Item))
Set @Pos = CHARINDEX(@ParamSep,@tmpStr,1)
Set @Item_SpecValue = SubString(@tmpStr, 1, @Pos-1)
--Serial No Extraction
Set @SerialNo = Cast(SubString(@tmpStr, @Pos + 1, len(@Item)) as Int)

select @JCPrefix = Prefix from VoucherPrefix where Tranid='JOBCARD'
select @SIPrefix = Prefix from VoucherPrefix where Tranid='SERVICEINVOICE'
Select	@Item_Spec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'

Set @Qry = 
'Select TA.TaskID,TA.Product_Code as "Item Code",ITEM.ProductName as "Item Name", '+
'[' + @Item_Spec1 + '] = JCD.Product_Specification1,isNull(GM.Description,'''') "Color",''' +
@JCPrefix + '''+ Cast(JCA.DocumentID as nVarChar(20)) as  "Job Card ID", '+
'JCA.JobCardDate as "Job Card Date",''' +  @SIPrefix + ''' + Cast(SIA.DocumentID as nVarChar(20)) as "Service Invoice ID",'+
'SIA.ServiceInvoiceDate as "Service Invoice Date", JCA.CustomerID as "Customer ID",CU.Company_Name as "Customer", ' +
'isnull(dbo.sp_ser_StripTimeFromDate(JCD.TimeIn),'''') as "Time In", '+
'JCD.DeliveryDate as "Delivery Date",isnull(dbo.sp_ser_StripTimeFromDate(JCD.DeliveryTime),'''') as "Delivery Time" '+
'from JobCardTaskAllocation TA '+
'Inner Join JobCardDetail JCD On JCD.JobCardID = TA.JobCardID'+
' and JCD.Product_Specification1 = TA.Product_Specification1'+
' and JCD.Product_Code = TA.Product_Code and JCD.Type=0 '+
'Inner Join JobCardAbstract JCA On JCA.JobCardID = TA.JobCardID '+
'Inner Join Customer CU On CU.CustomerID = JCA.CustomerID '+
'Left Outer Join ServiceInvoiceAbstract SIA On SIA.ServiceInvoiceID= JCA.ServiceInvoiceID and isNull(TA.TaskStatus,'''') <> 3 '+
'Left Outer Join Items ITEM On TA.Product_Code = ITEM.Product_Code '+
'Left Outer Join ItemInformation_Transactions ITEMTRANS On ITEMTRANS.DocumentID=JCD.SerialNo and ITEMTRANS.DocumentType=2 '+
'Left Outer Join GeneralMaster GM On ITEMTRANS.Color=isNull(GM.Code,'''') '+
'Where TA.TaskID=''' + @TaskID + ''' and TA.JobCardID=' + Cast(@JobCardID as nVarchar) + ' and TA.Product_Specification1= ''' + @Item_SpecValue + ''' and TA.SerialNo=' + Cast(@SerialNo as nVarchar)

Exec SP_ExecuteSQL @Qry
	
