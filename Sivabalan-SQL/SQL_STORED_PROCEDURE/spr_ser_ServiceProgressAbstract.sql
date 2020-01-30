CREATE Procedure spr_ser_ServiceProgressAbstract(@FromDate DateTime, @ToDate DateTime, @ItemCode Varchar(4000))
AS
Begin

Declare @ParamSep nVarchar(10)                
Set @ParamSep = Char(2)                


--For handling multiple Items Selected...
Declare @Delimeter as Char(1)  
Set @Delimeter = Char(15)  

Create table #TmpItem(Item_Code varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @ItemCode='%'   
   Insert into #TmpItem Select Product_Code From Items  
Else  
   Insert into #TmpItem Select * From dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)  


--Temperory Table
Create table #temp(ServiceType nVarChar(150) COLLATE SQL_Latin1_General_CP1_CI_AS
, A int, B int, C int, D int, E int, F int, G int, H int, I int, J int)

Declare @ServiceType int
Declare @ServiceDescription nVarChar(200)

Declare Service_Cursor CURSOR FOR
SELECT TypeCode, TypeName FROM ServiceType  
UNION
SELECT 0, 'Others' -- to count the jobcards which has no servicetype...


OPEN Service_Cursor
FETCH NEXT FROM Service_Cursor INTO @ServiceType, @ServiceDescription

While @@FETCH_STATUS = 0
Begin
	Insert Into #temp (ServiceType, A, B, C, D, E, F, G, H, I, J)
	(Select @ServiceDescription,
		(Select Count(*) from JCAcknowledgementAbstract
		Where (AcknowledgementDate Between @FromDate and @ToDate) and
		(JCAcknowledgementAbstract.Status & 128) <> 128 and
		(JCAcknowledgementAbstract.Status & 64) <> 64 and
		(select count(*) from JCAcknowledgementDetail where JCAcknowledgementDetail.AcknowledgementID = JCAcknowledgementAbstract.AcknowledgementID 
		and JCAcknowledgementDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		ServiceType = @ServiceType
		),
		
		(Select Count(*) from JobCardAbstract
		Where (JobCardDate Between @FromDate and @ToDate) and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardAbstract.JobCardID 
		and JobCardDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		ServiceType = @ServiceType
		) ,

		(Select Count(*) from JobcardIntimation
		Where (IntimationDate Between @FromDate and @ToDate) and 
		Status & 64 <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardIntimation.JobCardID and 
		JobCardDetail.Product_Code in(Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		(select ApprovedStatus from JobCardAbstract where JobCardAbstract.JobCardID = JobcardIntimation.JobCardID) = 1 and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardIntimation.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobcardApproval
		Where (ApprovedDate Between @FromDate and @ToDate) and
		Status & 64 <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardApproval.JobCardID and 
		JobCardDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		(select ApprovedStatus from JobCardAbstract where JobCardAbstract.JobCardID = JobcardApproval.JobCardID) = 2 and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardApproval.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobCardTaskAllocation
		Where (StartDate Between @FromDate and @ToDate) and 
		TaskStatus=2 and
		Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem) and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardTaskAllocation.JobCardID) = @ServiceType
		) ,

		(Select Count(*) from ServiceInvoiceAbstract
		Where (ServiceInvoiceDate Between @FromDate and @ToDate) and
		(ServiceInvoiceAbstract.Status & 128) <> 128 and
		(ServiceInvoiceAbstract.Status & 64) <> 64 and
		(select count(*) from ServiceInvoiceDetail where ServiceInvoiceDetail.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID and 
		ServiceInvoiceDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = ServiceInvoiceAbstract.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobCardAbstract
		Where (JobCardDate Between @FromDate and @ToDate) and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(Select Count(*) from (Select Distinct TaskStatus from JobCardTaskAllocation where 
			JobCardAbstract.JobCardID = JobCardTaskAllocation.JobCardID) as Task) = 1 and
		ServiceInvoiceID is Null and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardAbstract.JobCardID and 
		JobCardDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 		
		ServiceType = @ServiceType
		) ,
		
		
		(Select Count(*) from (Select DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) 'DateDiffCol'
		from JCAcknowledgementAbstract, JobCardAbstract, ServiceInvoiceAbstract
		Where JCAcknowledgementAbstract.AcknowledgementID = JobCardAbstract.AcknowledgementID and 
		JobCardAbstract.JobcardID = ServiceInvoiceAbstract.JobcardID and
		(JCAcknowledgementAbstract.Status & 128) <> 128 and
		(JCAcknowledgementAbstract.Status & 64) <> 64 and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(ServiceInvoiceAbstract.Status & 128) <> 128 and
		(ServiceInvoiceAbstract.Status & 64) <> 64 and
		DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) < 24 and
		(select count(*) from JCAcknowledgementDetail where JCAcknowledgementDetail.AcknowledgementID = JCAcknowledgementAbstract.AcknowledgementID 
		and JCAcknowledgementDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		JobCardAbstract.ServiceType = @ServiceType and
		(JCAcknowledgementAbstract.AcknowledgementDate Between @FromDate and @ToDate)) as DateDiffRows
		) ,
		
		
		(Select Count(*) from (Select DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) 'DateDiffCol'
		from JCAcknowledgementAbstract, JobCardAbstract, ServiceInvoiceAbstract
		Where JCAcknowledgementAbstract.AcknowledgementID = JobCardAbstract.AcknowledgementID and
		JobCardAbstract.JobcardID = ServiceInvoiceAbstract.JobcardID and
		(JCAcknowledgementAbstract.Status & 128) <> 128 and
		(JCAcknowledgementAbstract.Status & 64) <> 64 and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(ServiceInvoiceAbstract.Status & 128) <> 128 and
		(ServiceInvoiceAbstract.Status & 64) <> 64 and
		DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) >= 24 and
		DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) < 48 and
		(select count(*) from JCAcknowledgementDetail where JCAcknowledgementDetail.AcknowledgementID = JCAcknowledgementAbstract.AcknowledgementID and 
		JCAcknowledgementDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		JobCardAbstract.ServiceType = @ServiceType and
		(JCAcknowledgementAbstract.AcknowledgementDate Between @FromDate and @ToDate)) as DateDiffRows
		) ,
		
		
		(Select Count(*) from (Select DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) 'DateDiffCol'
		from JCAcknowledgementAbstract, JobCardAbstract, ServiceInvoiceAbstract
		Where JCAcknowledgementAbstract.AcknowledgementID = JobCardAbstract.AcknowledgementID and
		JobCardAbstract.JobcardID = ServiceInvoiceAbstract.JobcardID and
		(JCAcknowledgementAbstract.Status & 128) <> 128 and
		(JCAcknowledgementAbstract.Status & 64) <> 64 and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(ServiceInvoiceAbstract.Status & 128) <> 128 and
		(ServiceInvoiceAbstract.Status & 64) <> 64 and
		DateDiff(hh, JCAcknowledgementAbstract.AcknowledgementDate, ServiceInvoiceAbstract.ServiceInvoiceDate) >= 48 and
		(select count(*) from JCAcknowledgementDetail where JCAcknowledgementDetail.AcknowledgementID = JCAcknowledgementAbstract.AcknowledgementID and 
		JCAcknowledgementDetail.Product_Code in (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem)) <> 0 and 
		JobCardAbstract.ServiceType = @ServiceType and
		(JCAcknowledgementAbstract.AcknowledgementDate Between @FromDate and @ToDate)) as DateDiffRows
		) 
	)
	
	FETCH NEXT FROM Service_Cursor INTO @ServiceType, @ServiceDescription
End

CLOSE Service_Cursor
DEALLOCATE Service_Cursor


Select 'EID' = Cast(@ItemCode as nVarchar(100)) + @paramsep + Cast(@FromDate as nVarchar(20)) + @paramsep + Cast(@ToDate as nVarchar(20)) + @paramsep + 
cast((case ServiceType when 'Others' then 0 else (select TypeCode from ServiceType where TypeName = ServiceType) end) as nVarchar(2)),  
ServiceType 'Type', A 'Received', B 'Job Card Created', C 'Effort Intimated', 
D 'Effort Approved', (case sign(C - D) when 1 then (C-D) when -1 then 0 when 0 then 0 end) 'Effort Not Approved', E 'No of Task Closing', 
F 'Service Invoice', G 'Pending Delivery', H 'Today In Today Out', I 'Today In Tomorrow Out', 
J 'Repaired Later', (H + I + J) 'Total', 
case (H + I + J) 
when 0 then 0
else cast(H as float)/cast((H + I + J) as float) 
end 'Service %' from #temp


Drop table #TmpItem
Drop table #temp

End

