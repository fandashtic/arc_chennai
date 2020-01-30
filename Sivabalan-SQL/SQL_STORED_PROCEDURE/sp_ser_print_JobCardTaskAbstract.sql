Create PROCEDURE sp_ser_print_JobCardTaskAbstract(@JobCardID INT)  
AS
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
 "Total No. Of Tasks" = Count(IsNull(JCD.TaskID,''))
,"Est_TotalRate" = IsNull(Sum(ED.Rate), 0)
,"Est_TotalTax%" = Isnull(Avg(ED.[Tax%]) , 0)
,"Est_TotalTaxValue" = Sum(Isnull((ED.Rate * ED.[Tax%]) / 100, 0))
,"Est_TotalNet" =  Cast(Sum(ED.Rate + (Isnull((ED.Rate * ED.[Tax%]) / 100, 0))) as Decimal(18,6))
 from JobCardDetail JCD
Inner Join #EstDetail ED On ED.ItemCode = JCD.Product_Code
and ED.ItemSpec1 = JCD.Product_Specification1 and 
ED.TaskID = JCD.TaskID
where IsNull(JCD.SpareCode,'') = '' and IsNull(JCD.TaskID,'') <> ''
and JCD.Type in (1,2) and JCD.JobCardID = @JobCardID
Having Count(IsNull(JCD.TaskID,'')) <> 0
Drop Table #EstDetail
