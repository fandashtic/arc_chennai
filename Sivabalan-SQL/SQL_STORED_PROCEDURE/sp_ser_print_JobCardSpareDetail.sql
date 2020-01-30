CREATE PROCEDURE sp_ser_print_JobCardSpareDetail(@JobCardID INT)    
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


SELECT 
  "Item Code" = JCD.Product_Code
, "Item Name" = ITMSPROD.ProductName
, "Item Spec1" = IsNull(JCD.Product_Specification1, '')
, "Item Spec2" = IsNull(ITINF.Product_Specification2, '')
, "Item Spec3" = IsNull(ITINF.Product_Specification3, '')
, "Item Spec4" = IsNull(ITINF.Product_Specification4, '')
, "Item Spec5" = IsNull(ITINF.Product_Specification5, '')
, "Spare Code" = JCD.SpareCode
, "Spare Name" = ITEMSPARE.ProductName
, "Spare Description" = IsNull(ITEMSPARE.[Description],'')
, "Mfr" = MFR.ManufacturerCode
, "Mfr Name" = MFR.Manufacturer_Name
, "Divison" = BRND.BrandName
, "Category" = ITMCATE.Category_Name
, "Property1" = dbo.GetProperty(JCD.SpareCode, 1)
, "Property2" = dbo.GetProperty(JCD.SpareCode, 2)
, "Property3" = dbo.GetProperty(JCD.SpareCode, 3)
, "Quantity" = IsNull(JCD.Quantity,0)
, "UOM" = BUOM.[Description]
, "Reporting Unit Qty" = IsNull(JCD.Quantity,0) / 
		(Case IsNull(ITEMSPARE.ReportingUnit,0) 
		when 0 then 1
		else ITEMSPARE.ReportingUnit end)
, "Rounded Reporting Unit Qty" = Ceiling(IsNull(JCD.Quantity,0) / 
		(Case IsNull(ITEMSPARE.ReportingUnit,0) 
		when 0 then 1
		else ITEMSPARE.ReportingUnit end))
, "Reporting UOM" = IsNull(RUOM.[Description],'')
, "Reporting Factor" = IsNull(ITEMSPARE.ReportingUnit,0)
, "Conversion Unit Qty" = IsNull(JCD.Quantity,0) * IsNull(ITEMSPARE.ConversionFactor,0)
, "Rounded Conversion Unit Qty" = Ceiling(IsNull(JCD.Quantity,0) * IsNull(ITEMSPARE.ConversionFactor,0))
, "Conversion Unit" = IsNull(CONVTABLE.ConversionUnit,0)
, "Conversion Factor" = IsNull(ITEMSPARE.ConversionFactor,0)
, "Task ID" = IsNull(JCD.TaskID,'')
, "Task Description" = IsNull(TASKMS.[Description],'')
, "Job ID" = IsNull(JCD.JobID,'')
, "Job Name" = IsNull(JOBM.JobName,'')
, "Warranty" = (Case IsNull(JCD.Warranty,2)
				when 1 then 'Yes'
				when 2 then 'No' end)
, "Warranty No" = IsNull(JCD.WarrantyNo,'')
, "Date of Sale" = dbo.sp_ser_StripDateFromTime(JCD.DateofSale)
,"Est_Sale Price" = JED.Price
,"Est_Tax%" = JED.SalesTax
,"Est_Taxvalue" = (JED.SalesTax/100) * (JCD.Quantity * JED.Price)* (1+(JED.TaxSuffered/100))
,"Est_Amount" = JED.Price * JCD.Quantity
,"Est_TaxSuffered" = JED.TaxSuffered
,"Est_TaxSufferedValue" = (JED.TaxSuffered/100) * (JCD.Quantity * JED.Price)
,"Est_NetValue" = (JED.Price * JCD.Quantity) * 
(1 + (JED.SalesTax/100) * (1+(JED.TaxSuffered/100))
+ (JED.TaxSuffered/100))
,"Est_NetRate" = JED.Price * 
(1 + (JED.SalesTax/100) * (1+(JED.TaxSuffered/100))
+ (JED.TaxSuffered/100))
,"Est_NetItem Rate" = JED.Price
,"Est_TaxSufferedDesc" = JED.TaxSufferedDesc
,"Est_SalesTaxDesc" = JED.SalesTaxDesc
from JobCardDetail JCD
Inner Join JobCardAbstract JCA On JCA.JobCardID = JCD.JobCardID
Inner Join Items ITMSPROD On ITMSPROD.product_code  = JCD.Product_code
Inner Join Items ITEMSPARE On ITEMSPARE.Product_Code = JCD.SpareCode 
Left Outer Join #EstDetail JED On JED.ItemCode = JCD.Product_Code
and JED.ItemSpec1 = JCD.Product_Specification1 and 
JED.TaskID = JCD.TaskID and JED.SpareCode = JCD.SpareCode and JED.UOM = JCD.UOM
Inner Join ItemCategories ITMCATE On ITMCATE.CategoryID = ITEMSPARE.CategoryID 
Inner Join Brand BRND On BRND.BrandID = ITEMSPARE.BrandID
Inner Join Manufacturer MFR On ITEMSPARE.ManufacturerID = MFR.ManufacturerID 
Inner Join UOM BUOM On ITEMSPARE.UOM = BUOM.UOM
Left outer Join (
	Select I_JCD.Product_Specification1
	,Product_Specification2,Product_Specification3
	,Product_Specification4,Product_Specification5 
	from ItemInformation_Transactions I_ITINF 
	Inner Join JobCardDetail I_JCD on I_JCD.SerialNO = I_ITINF.DocumentID and I_ITINF.DocumentType = 2
	where I_JCD.Type = 0 and I_JCD.JobCardID = @JobCardID
) as ITINF
On ITINF.Product_Specification1 = JCD.Product_Specification1
Left Outer Join TaskMaster TASKMS on TASKMS.TaskID = JCD.TaskID
Left Outer join JobMaster JOBM On JOBM.JobID = JCD.JobID
Left Outer Join UOM RUOM On ITEMSPARE.ReportingUOM = RUOM.UOM
Left Outer Join ConversionTable CONVTABLE On ITEMSPARE.ConversionUnit = CONVTABLE.ConversionID
WHERE JCD.JobCardID = @JobCardID and IsNull(JCD.SpareCode, '') <> '' 
Order by JCD.SerialNo

Drop Table #EstDetail
