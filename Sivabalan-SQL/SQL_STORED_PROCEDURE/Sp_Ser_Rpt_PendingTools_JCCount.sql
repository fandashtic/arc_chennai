

CREATE Procedure Sp_Ser_Rpt_PendingTools_JCCount(@FromDate Datetime,@ToDate Datetime)
As
Begin

Declare @ParamSep nVarchar(10)
Set @ParamSep = Char(2)

/*Main Select Count */
Select  'EID' = cast(@FromDate as nvarchar(20)) + @paramsep + Cast(@ToDate as nvarchar(20)), 
	'Total No of JC'=Sum(JobCard),'Open Acknowledgement'=Sum(Acknowledgement) ,
	'Estimate Intimation Pending'=Sum(Intimate),'Estimate Approval Pending'=Sum(Approval),
	'Issue Spares Pending'=Sum(IssueSparePend),'Task Allocation Pending'=Sum(TaskAllocPend),
	'Task Closed Pending'=Sum(TaskClosePend),'Invoice Pending'=Sum(InvoicePend)
From(

	/*Total No of JC */
	Select Count(JobCardID) as JobCard,0 as Acknowledgement,0 as Intimate,0 as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,0 as InvoicePend
	From JobCardAbstract
	Where (IsNull(Status,0) & 192) = 0 
	And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
	
	UNION
	
	/*Open Acknowledgement */
	Select 0 as JobCard,Count(AcKnowledgementID) as Acknowledgement,0 as Intimate,0 as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,0 as InvoicePend
	From JCAcKnowledgementAbstract
	Where  IsNull(Status,0)=0
	And JCAcKnowledgementAbstract.AcKnowledgementDate Between @FromDate and @ToDate
	And AcKnowledgementID not in (Select Distinct AcknowledgementID From JobCardAbstract)
	
	UNION
	
	/*Estimate Intimation Pending */
	Select 0 as JobCard,0 as Acknowledgement,Count(JobCardID) as Intimate,0 as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,0 as InvoicePend
	From JobCardAbstract
	Where IsNull(ApprovedStatus,0)=0 and (IsNull(Status,0) & 224) = 0
	And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
	
	UNION
	
	/*Estimate Approval Pending */
	Select 0 as JobCard,0 as Acknowledgement,0 as Intimate,Count(JobCardID) as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,0 as InvoicePend
	From JobCardAbstract
	Where IsNull(ApprovedStatus,0)=1 and IsNull(ApprovedStatus,0)<>2 and (IsNull(Status,0) & 224) = 0
	And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
	
	UNION
	
	/*Issue Spares Pending */
	Select 0 as JobCard,0 as Acknowledgement,0 as Intimate,0 as Approval,
	Count(JobCardID) as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,0 as InvoicePend
	 from
	(
	Select Distinct jobcardSpares.JobCardID from jobcardSpares,JobCardAbstract	 
	 Where jobcardAbstract.JobCardID=jobcardSpares.JobCardID
	 And IsNull(SpareStatus,0) NOT IN (1)
	 And (IsNull(Status,0) & 224) = 0
     And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
	)IssueSpare
	
	UNION

	/*Task Allocation Pending */
	Select 0 as JobCard,0 as Acknowledgement,0 as Intimate,0 as Approval,
	0 as IssueSparePend,Count(JobCardID) as TaskAllocPend, 0 as TaskClosePend,0 as InvoicePend
	 From
	(
		Select JobCardAbstract.JobCardID From JobCardAbstract,JobCardDetail
	 	Where 
		JobCardAbstract.JobcardID=JobCardDetail.JobcardID
		And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
		And IsNull(Type,0)in(1,2) And (IsNull(Status,0) & 224) = 0		 
		/*Task Closed Job Card */
		And JobCardAbstract.JobcardID Not In
		(Select JobCardID	
		From JobCardTaskAllocation Where IsNull(Taskstatus,0) in (1,2)
		Group By JobCardID)		
		
		/*Closed Issue Spares */
		--And JobCardAbstract.JobcardID In 
		--(Select JobCardID	
		--From JobCardSpares Where IsNull(SpareStatus,0) = 1
		--Group By JobCardID)
		Group By JobCardAbstract.JobCardID
	) TaskAllocation

	UNION
	
	/*Task Closed Pending */
	Select 0 as JobCard,0 as Acknowledgement,0 as Intimate,0 as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,Count(JobCardID) as TaskClosePend,0 as InvoicePend
	 From
	(
		Select JobCardAbstract.JobCardID From JobCardTaskAllocation,JobCardAbstract
	 	Where 
		JobCardAbstract.JobcardID=JobCardTaskAllocation.JobcardID
		And (IsNull(Status,0) & 224) = 0
		And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
		And JobCardTaskAllocation.TaskStatus not in (0,2)
		Group By JobCardAbstract.JobCardID
	) TaskClose


	UNION
	
	/*Invoice Pending */
	Select 0 as JobCard,0 as Acknowledgement,0 as Intimate,0 as Approval,
	0 as IssueSparePend,0 as TaskAllocPend,0 as TaskClosePend,Count(InvoicePend.JobCardID) as InvoicePend       
	From
	(
		Select Distinct CntJobCard.JobCardID From
			(
				Select JobCardID
				From JobCardAbstract
				Where IsNull(serviceInvoiceId,0)=0 And (IsNull(Status,0) & 192) = 0
    			And JobCardID IN(Select JobCardID From JobCardTaskAllocation Where JobCardID Not In
						 (Select JobCardID From JobCardTaskAllocation 
						   Where IsNull(Taskstatus,0) Not IN(2) Group By JobCardID) )
				And JobCardAbstract.JobCardDate Between @FromDate and @ToDate

				UNION ALL

				Select JobCardID
				From JobCardAbstract
				Where IsNull(serviceInvoiceId,0)=0 And (IsNull(Status,0) & 192) = 0
			    And JobCardID IN(Select JobCardID From JobCardSpares Where JobCardID Not In
						 (Select JobCardID From JobCardSpares 
						   Where IsNull(SpareStatus,0) Not IN(1) Group By JobCardID) )
				And JobCardAbstract.JobCardDate Between @FromDate and @ToDate
			) AS CntJobCard
	) AS InvoicePend

) Main

End
