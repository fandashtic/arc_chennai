Create PROCEDURE sp_ser_print_JobCardSpareAbstract(@JobCardID INT)        
AS
Declare @Locality Int,@CustomerType Int
/************
@Locality = 1 is Local 2 is Outstation
***********/
Select @Locality =IsNull(locality ,1),@CustomerType = CustomerCategory
from JobCardAbstract JCA
Inner Join Customer CUST On JCA.CustomerID = CUST.CustomerID 
and JCA.JobCardID = @JobCardID

/******** Create Temporary Tables ************/
Create Table #EstDetail(JobCardID Int,ItemCode nVarchar(15),ItemSpec1 nVarchar(50)
	,TaskID nVarchar(50),SpareCode nVarchar(15),UOM Int
	,Price Decimal(18,6),TaxSuffered Decimal(18,6),SalesTax Decimal(18,6)
	,TaxSufferedDesc nVarchar(255),SalesTaxDesc nVarchar(255))

/********* Fetch JobCard details and find estimation details ***********/
Insert Into #EstDetail
	Select JCA.JobCardID,JCD.Product_Code,JCD.Product_Specification1
	,JCD.TaskID,JCD.SpareCode
	,JCD.UOM
	,Case IsNull(JED.SerialNO,0)
	when 0 then dbo.sp_ser_getspareprice(@CustomerType,ITEMSPARE.Product_Code)
	else JED.Amount / JED.Quantity end
	,Case IsNull(JED.SerialNO,0)
	when 0 then 
		Case 
		when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 then (
			Case @Locality	
			when 1 then IsNull(TAXSUFF.Percentage,0)
			when 2 then IsNull(TAXSUFF.CST_Percentage,0) 
			else 0 end)
		else 0 end
	else IsNull(JED.TaxSuffered_percentage,0) end
	,Case IsNull(JED.SerialNO,0)
	when 0 then 
		Case @Locality	
		when 1 then IsNull(SALETAX.Percentage,0)
		when 2 then IsNull(SALETAX.CST_Percentage,0) 
		else 0 end
	else IsNull(JED.SalesTax,0) end
	,IsNull(TAXSUFF.Tax_description,'')
	,IsNull(SALETAX.Tax_description,'')
	From JobCardAbstract JCA 
	Inner Join JobCardDetail JCD On JCD.JobCardID = JCA.JobCardID
	and JCD.SerialNO in (Select Min(SerialNo) 'SerialNO'
				from JobCardDetail where IsNull(SpareCode,'') <> ''
				and JobCardID = @JobCardID 
				Group By EstimationID,Product_Code,Product_Specification1,TaskID,SpareCode,UOM)
	Left Outer Join EstimationDetail  JED On JCA.EstimationID = JED.EstimationID 
	and JCD.Product_Code = JED.Product_Code 
	and JCD.Product_Specification1 = JED.Product_Specification1
	and JCD.SpareCode = JED.SpareCode and JCD.UOM = JED.UOM and JCD.TaskID = JED.TaskID
	and JED.SerialNO in (Select Min(SerialNo) 'SerialNO'
				from EstimationDetail where IsNull(SpareCode,'') <> ''
				and EstimationID = JCA.EstimationID
				Group By EstimationID,Product_Code,Product_Specification1,TaskID,SpareCode,UOM)
	Inner Join Items ITEMSPARE On ITEMSPARE.Product_Code = JCD.SpareCode
	Left Outer Join Tax TAXSUFF On ITEMSPARE.TaxSuffered = TAXSUFF.Tax_Code
	Left Outer Join Tax SALETAX On ITEMSPARE.Sale_Tax = SALETAX.Tax_Code
	where JCD.JobCardID = @JobCardID 


Select 
"Total Spares Qty" = Sum(JCD.Quantity)
,"Est_TotalPrice" = Sum(JED.Price)
,"Est_TotalTaxvalue" = Sum((JED.SalesTax/100) * (JCD.Quantity * JED.Price)* (1+(JED.TaxSuffered/100)))
,"Est_TotalTaxSufferedValue" = Sum((JED.TaxSuffered/100) * (JCD.Quantity * JED.Price))
,"Est_TotalAmount" = Sum(JED.Price * JCD.Quantity)
,"Est_NetAmount" = Sum((JED.Price * JCD.Quantity) * 
(1 + (JED.SalesTax/100) * (1+(JED.TaxSuffered/100))
+ (JED.TaxSuffered/100)))
from 
JobCardDetail JCD
Left Outer Join #EstDetail JED On JED.ItemCode = JCD.Product_Code
and JED.ItemSpec1 = JCD.Product_Specification1 and 
JED.TaskID = JCD.TaskID and JED.SpareCode = JCD.SpareCode and JED.UOM = JCD.UOM
where IsNull(JCD.SpareCode,'') <> '' and JCD.JobCardID = @JobCardID
