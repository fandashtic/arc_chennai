Create Procedure sp_ser_print_JobCardAbstract_FMCG(@JobCardID as int)  
As       
Declare @JEPrefix nVarchar(15),@JCPrefix nVarchar(15),@SIPrefix nVarchar(15)
Declare @Locality Int,@CustomerType Int

/*********** Prefix of Transactions ***************/
select @JEPrefix = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'
select @JCPrefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'
select @SIPrefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'

/************
@Locality = 1 is Local 2 is Outstation
***********/
Select @Locality =IsNull(locality ,1),@CustomerType = CustomerCategory
from JobCardAbstract JCA Inner Join Customer CUST On JCA.CustomerID = CUST.CustomerID 
and JCA.JobCardID = @JobCardID

/******** Create Temporary Tables ************/
Create Table #EstDetail(JobCardID Int,SpareAmount Decimal(18,6)
	,TaskAmount Decimal(18,6),TotalAmount Decimal(18,6))

/********* Fetch JobCard details and find estimation details ***********/
Insert Into #EstDetail
 Select 
  Min(JobCardID),Sum(SpareAmount)
  ,Sum(TaskAmount),Sum(TotalAmount)
 from (Select 
	JCA.JobCardID 'JobCardID'
	,Case 
	when IsNull(JCD.SpareCode,'') <> '' then
		Case IsNull(JED.SerialNO,0)
		when 0 then (ITEMSPARE.MRP * JCD.Quantity) *
		/************* Sale Tax *************/
		(1+ (Case @Locality	
			when 1 then IsNull(SALETAX.Percentage,0)
			when 2 then IsNull(SALETAX.CST_Percentage,0) 
			else 0 end /100
			*
			(1 +  
				Case 
				when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 then (
					Case @Locality	
					when 1 then IsNull(TAXSUFF.Percentage,0)
					when 2 then IsNull(TAXSUFF.CST_Percentage,0) 
					else 0 end /100)
				else 0 end)
			)
		+
		/************* Tax Suffered *************/
			(Case 
			when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 then (
				Case @Locality	
				when 1 then IsNull(TAXSUFF.Percentage,0)
				when 2 then IsNull(TAXSUFF.CST_Percentage,0) 
				else 0 end /100)
			else 0 end)
			)
		else isNull(JED.NetValue,0)/IsNull(JED.Quantity,0) * IsNull(JCD.Quantity,0) end
	else 0 end 'SpareAmount'
	, 
	Case 
	when IsNull(JCD.TaskID,'') <> '' and IsNull(JCD.SpareCode,'') = '' then
		Case IsNull(JED.SerialNO,0)
		when 0 then IsNull(TASKITMS.Rate,0) * ( 1 + (IsNull(STM.Percentage,0)/100))
		else isNull(JED.NetValue,0) end
	else 0 end 'TaskAmount'
	,
	Case IsNull(JED.SerialNO,0)
	when 0 then 
		Case 
		when IsNull(JCD.SpareCode,'') <> '' then
		(ITEMSPARE.MRP * IsNull(JCD.Quantity,0)) *
		/************* Sale Tax *************/
		(1+ (Case @Locality	
			when 1 then IsNull(SALETAX.Percentage,0)
			when 2 then IsNull(SALETAX.CST_Percentage,0) 
			else 0 end /100
			*
			(1 +  
				Case 
				when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 then (Case @Locality	
							when 1 then IsNull(TAXSUFF.Percentage,0)
							when 2 then IsNull(TAXSUFF.CST_Percentage,0) 
							else 0 end /100)
				else 0 end)
			)
			+
		/************* Tax Suffered *************/
			Case 
			when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 then 
				(Case @Locality	
				when 1 then IsNull(TAXSUFF.Percentage,0)
				when 2 then IsNull(TAXSUFF.CST_Percentage,0) 
				else 0 end /100)
			else 0 end)                     
		when IsNull(JCD.TaskID,'') <> '' and IsNull(JCD.SpareCode,'') = '' then
		IsNull(TASKITMS.Rate,0) * ( 1 + (IsNull(STM.Percentage,0)/100)) 
		else 0 end	
	else Case 
		when IsNull(JCD.SpareCode,'') <> '' then
		isNull(JED.NetValue,0)/IsNull(JED.Quantity,0) * isNull(JCD.Quantity ,0)
		when IsNull(JCD.TaskID,'') <> '' and IsNull(JCD.SpareCode,'') = '' then
		isNull(JED.NetValue,0) 
		else 0 end
	end 'TotalAmount'
	From JobCardAbstract JCA 
	Inner Join JobCardDetail JCD On JCD.JobCardID = JCA.JobCardID
	Left Outer Join EstimationDetail  JED On JCA.EstimationID = JED.EstimationID 
		and JCD.Product_Code = JED.Product_Code 
		and JCD.Product_Specification1 = JED.Product_Specification1
		and JCD.SpareCode = JED.SpareCode and JCD.UOM = JED.UOM and JCD.TaskID = JED.TaskID
	 and JED.SerialNO in (Select Min(SerialNo) 'SerialNO'
		from EstimationDetail where EstimationID = JCA.EstimationID
		Group By EstimationID,Product_Code,Product_Specification1,TaskID,SpareCode,UOM)
	Left Outer Join Items ITEMSPARE On ITEMSPARE.Product_Code = JCD.SpareCode
	Left Outer Join Tax TAXSUFF On ITEMSPARE.TaxSuffered = TAXSUFF.Tax_Code
	Left Outer Join Tax SALETAX On ITEMSPARE.Sale_Tax = SALETAX.Tax_Code
	Left Outer Join TaskMaster TM  On TM.TaskID = JCD.TaskID
	Left Outer Join ServiceTaxMaster STM On STM.ServiceTaxCode = TM.ServiceTax
	Left Outer Join Task_Items TASKITMS On TASKITMS.TaskID = JCD.TaskID 
	and TASKITMS.Product_Code = JCD.Product_Code					
	where JCD.JobCardID = @JobCardID
) AS ResultSet


SELECT
 "JobCardID" =  @JCPrefix + cast(JCA.DocumentID as nvarchar(15))
,"JobCard Date" = JCA.JobCardDate
,"EstimationID" =  @JEPrefix + cast(JEA.DocumentID as nvarchar(15))
,"Estimation Date" = JEA.EstimationDate
,"ServiceInvoiceID" =  IsNull(@SIPrefix + cast(SIA.DocumentID as nvarchar(15)),'')
,"ServiceInvoice Date" = SIA.ServiceInvoiceDate
,"CustomerID" = JCA.CustomerID
,"Customer Name" = CUST.company_Name
,"Doc Ref" = Isnull(JCA.DocRef,'')
,"DocType" = Isnull(JCA.DocSerialType, '')
,"Remarks" = Isnull(JCA.Remarks,'')
,"Est_TotalTaskAmount" = JED.TaskAmount
,"Est_TotalSpareAmount" = JED.SpareAmount
,"Est_TotalNetAmount" = JED.TotalAmount
,"Total Item" = IsNull(
	(Select Count(JCD.Product_Code) from JobCardDetail JCD 
	 where JCD.JobCardID = JCA.JobCardID and JCD.Type = 0)
,0)
from JobCardAbstract JCA
Inner Join EstimationAbstract JEA On JEA.EstimationID = JCA.EstimationID
Inner Join #EstDetail JED On JED.JobCardID = JCA.JobCardID
Inner Join Customer CUST On JCA.customerID = CUST.customerID
Left Outer Join ServiceInvoiceAbstract SIA On SIA.ServiceInvoiceID = JCA.ServiceInvoiceID
where JCA.JobCardID = @JobCardID  

Drop table #EstDetail
