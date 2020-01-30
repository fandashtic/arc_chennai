Create Procedure sp_ser_print_JobCardDetail(@JobCardID as int)  
as  
Declare @Locality Int,@CustomerType Int

/************
@Locality = 1 is Local 2 is Outstation
***********/
Select @Locality =IsNull(locality ,1),@CustomerType = CustomerCategory
from JobCardAbstract JCA Inner Join Customer CUST On JCA.CustomerID = CUST.CustomerID 
and JCA.JobCardID = @JobCardID

/******** Create Temporary Tables ************/
Create Table #EstDetail(JobCardID Int,ItemCode nVarchar(15),ItemSpec1 nVarchar(50)
	,SpareAmount Decimal(18,6),TaskAmount Decimal(18,6),TotalAmount Decimal(18,6))

/********* Fetch JobCard details and find estimation details ***********/
Insert Into #EstDetail
Select 
Min(JobCardID)
,ItemCode
,ItemSpec1
,Sum(SpareAmount)
,Sum(TaskAmount)
,Sum(TotalAmount)
from (Select 
	JCA.JobCardID 'JobCardID'
	,JCD.Product_Code 'ItemCode'
	,JCD.Product_Specification1 'ItemSpec1'
	,Case 
	when IsNull(JCD.SpareCode,'') <> '' then
		Case IsNull(JED.SerialNO,0)
		when 0 then (dbo.sp_ser_getspareprice(@CustomerType,ITEMSPARE.Product_Code) * IsNull(JCD.Quantity,0)) *
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
		else isNull(JED.NetValue,0) / IsNull(JED.Quantity,0) * IsNull(JCD.Quantity,0) end
	else 0 end 'SpareAmount'
	,Case 
	when IsNull(JCD.TaskID,'') <> '' and IsNull(JCD.SpareCode,'') = '' then
		Case IsNull(JED.SerialNO,0)
		when 0 then IsNull(TASKITMS.Rate,0) * ( 1 + (isNull(STM.Percentage,0)/100))
		else isNull(JED.NetValue,0) end
	else 0 end 'TaskAmount'
	,Case IsNull(JED.SerialNO,0)
	when 0 then 
		Case 
		when IsNull(JCD.SpareCode,'') <> '' then
		(dbo.sp_ser_getspareprice(@CustomerType,ITEMSPARE.Product_Code) * IsNull(JCD.Quantity,0)) *
		/************* Sale Tax *************/
		(1+ (Case @Locality	
			when 1 then IsNull(SALETAX.Percentage,0)
			when 2 then IsNull(SALETAX.CST_Percentage,0) 
			else 0 end /100
			*
			(1 +  
				Case 
				when IsNull(ITEMSPARE.CollectTaxSuffered,0) = 1 and IsNull(ITEMSPARE.VAT,0) = 0 
				then (Case @Locality	
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
		isNull(JED.NetValue,0)/(JED.Quantity) * JCD.Quantity 
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
Group by JobCardID,ItemCode,ItemSpec1


Select
 "Item Code" = JCD.product_code
, "Item Name" = ITMS.productname
, "Item Spec1" = JCD.product_specification1
, "Item Spec2" = IsNull(ITINF.product_specification2,'')
, "Item Spec3" = IsNull(ITINF.product_specification3,'')
, "Item Spec4" = IsNull(ITINF.product_specification4,'')
, "Item Spec5" = IsNull(ITINF.product_specification5,'')
, "Colour" = Isnull(GM.[Description], '')
, "DateofSale" = dbo.sp_ser_StripDateFromTime(ITINF.DateofSale)
, "Sold By" = Isnull(ITINF.soldby, '')
, "Job Type" = (
	Case IsNull(JCD.JobType,2) 
	when 0 then 'Major'
	when 1 then 'Minor'
	else '' end)
, "Delivery Date" = dbo.sp_ser_StripDateFromTime(JCD.Deliverydate)
, "Delivery Time" = dbo.sp_ser_StripTimeFromDate(JCD.DeliveryTime)
, "Door Delivery" = (
	Case IsNull(JCD.DoorDelivery,0)
	when 0 then 'No'
	when 1 then 'Yes'
	else '' end)
, "Time in" = dbo.sp_ser_StripTimeFromDate(TimeIn)
, "Inspected By" = IsNull(PRMS.PersonnelName,'')
, "Customer Complaints" = IsNull(JCD.CustomerComplaints,'')
, "Personnel Comments" = IsNull(JCD.PersonnelComments,'')
,"Est_TaskAmount" = JED.TaskAmount
,"Est_SpareAmount" = JED.SpareAmount
,"Est_TotalAmount" = JED.TotalAmount
from JobCardDetail JCD
Inner Join JobCardAbstract JCA On JCA.JobCardID = JCD.JobCardID
Inner Join Items ITMS On ITMS.product_code  = JCD.Product_code
Inner Join #EstDetail JED On JED.JobCardID = JCA.JobCardID
and JED.ItemCode = JCD.Product_Code and JED.ItemSpec1 = JCD.Product_Specification1
Left Outer join PersonnelMaster PRMS On PRMS.PersonnelID = JCD.InspectedBy
Left outer Join ItemInformation_Transactions ITINF On
ITINF.DocumentID = JCD.SerialNo and ITINF.DocumentType = 2 
Left outer join GeneralMaster GM On ITINF.Color = GM.code 
where JCD.JobCardID = @JobCardID and JCD.Type = 0
Order by JCD.SerialNo  

Drop Table #EstDetail 
