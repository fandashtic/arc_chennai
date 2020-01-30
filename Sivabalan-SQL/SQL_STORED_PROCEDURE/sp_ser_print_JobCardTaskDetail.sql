Create PROCEDURE sp_ser_print_JobCardTaskDetail(@JobCardID INT)        
AS
Declare @JCPrefix as nVarchar(15)
/************** Prefix for Transactions *****************/
select @JCPrefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'

/******** Create Temporary Tables ************/
Create Table #EstDetail(JobCardID Int,ItemCode nVarchar(15),ItemSpec1 nVarchar(50)
	,TaskID nVarchar(50),Rate Decimal(18,6),[Tax%] Decimal(18,6))
Insert Into #EstDetail
	Select Distinct JCA.JobCardID
	,JCD.Product_Code
	,JCD.Product_Specification1
	,JCD.TaskID
	,Case IsNull(JED.SerialNO,0) 
				when 0 then IsNull(TASKITMS.Rate,0)
			 	else IsNull(JED.Price,0) end
	,Case IsNull(JED.SerialNO,0) 
				when 0 then IsNull(STM.Percentage,0)
				else IsNull(JED.ServiceTax_Percentage,0) end
	from JobCardAbstract JCA
	Inner join JobCardDetail JCD On JCA.JobCardID = JCD.JobCardID 
	and IsNull(JCD.TaskID,'')<>'' and IsNull(JCD.SpareCode,'') = '' and JCD.Type in (1,2) 
	Left Outer Join EstimationDetail JED On JED.EstimationID = JCA.EstimationID
	and JED.TaskID = JCD.TaskID 
	and IsNull(JED.TaskID,'')<>'' and IsNull(JED.SpareCode,'') = '' and JED.Type in (1,2) 
	Left Outer Join TaskMaster TM  On TM.TaskID = JCD.TaskID
	Left Outer Join ServiceTaxMaster STM On STM.ServiceTaxCode = TM.ServiceTax
	Left Outer Join Task_Items TASKITMS On TASKITMS.TaskID = JCD.TaskID 
	and TASKITMS.Product_Code = JCD.Product_Code					
	Where JCD.JobCardID = @JobCardID

Select 
  "Item Code" = JCD.Product_Code
, "Item Name" = ITMS.ProductName
, "Item Spec1" = IsNull(JCD.Product_Specification1, '')
, "Item Spec2" = IsNull(ITINF.Product_Specification2, '')
, "Item Spec3" = IsNull(ITINF.Product_Specification3, '')
, "Item Spec4" = IsNull(ITINF.Product_Specification4, '')
, "Item Spec5" = IsNull(ITINF.Product_Specification5, '')
, "Type" = (Case 
		When Isnull(JCD.JobID, '') <> '' 
		then 'Job' 
		else 'Task' end)
, "Job ID" = isnull(JCD.JobID, '')
, "Job Name" = isnull(JOBM.JobName, '')
, "Task ID" = JCD.TaskID
, "Task Description" = TSKM.[Description]
, "Bounced JobCard ID" = IsNull(@JCPrefix + Cast(BOUJCA.DocumentID as nvarchar(15)),'')
, "Bounce Reason" = IsNull(JCD.BounceCase_Reason,'')
, "Job Free" = (Case IsNull(JCD.JobFree,0) 
			when 1 then 'Free'
			else '' end)
, "Task Type" = (Case IsNull(JCD.TaskType,0)
				when 0 then 'New'
				when 1 then 'Bounced'
				else '' end)
,"Est_Rate" = IsNull(JED.Rate, 0)
,"Est_Tax%" = Isnull(JED.[Tax%], 0)
,"Est_TaxValue" = Isnull((JED.Rate * JED.[Tax%]) / 100, 0)
,"Est_Amount" =  Cast(JED.Rate + (Isnull((JED.Rate * JED.[Tax%]) / 100, 0)) as Decimal(18,6))
, "Total Spares Quantity"  = IsNull(
	(Select Sum(IsNull(I_JCD.Quantity,0)) from JobCardDetail I_JCD 
	where I_JCD.JobCardID = JCD.JobCardID and IsNull(I_JCD.SpareCode,'') <> '' 
	and I_JCD.Product_Specification1 = JCD.Product_Specification1
	and I_JCD.TaskID = JCD.TaskID )
,0)
from JobCardDetail JCD
Inner Join JobCardAbstract JCA On JCA.JobCardID = JCD.JobCardID
Inner Join Items ITMS On ITMS.product_code  = JCD.Product_code
Inner join TaskMaster TSKM On TSKM.TaskID = JCD.TaskID
Inner Join #EstDetail JED On JED.JobCardID = JCA.JobCardID 
and JED.ItemCode = JCD.Product_code and JED.ItemSpec1 = JCD.Product_specification1 
and JED.TaskID = JCD.TaskID
Left Outer join PersonnelMaster PRMS On PRMS.PersonnelID = JCD.InspectedBy
Left outer Join (
	Select I_JCD.Product_Specification1
	,Product_Specification2,Product_Specification3
	,Product_Specification4,Product_Specification5 
	from ItemInformation_Transactions I_ITINF 
	Inner Join JobCardDetail I_JCD on I_JCD.SerialNO = I_ITINF.DocumentID and I_ITINF.DocumentType = 2
	where I_JCD.Type = 0 and I_JCD.JobCardID = @JobCardID
) as ITINF
On ITINF.Product_Specification1 = JCD.Product_Specification1
Left Outer join JobMaster JOBM On JOBM.JobID = JCD.JobID
Left Outer join JobCardAbstract BOUJCA On BOUJCA.JobCardID = JCD.JobCardID_Bounced
Where JCD.JobCardID = @JobCardID
 and JCD.Type in (1,2)   
 and IsNull(JCD.SpareCode, '') = ''  
 and IsNull(JCD.TaskID, '') <> ''  
Order by JCD.SerialNo  

Drop Table #EstDetail
