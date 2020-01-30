CREATE procedure sp_ser_loadissueabstracdoc(@FromId int, @ToID int, @Mode int)
as
Declare @JCPrefix nvarchar(15)
Declare @ISSUEPrefix nvarchar(15)
Select @JCPrefix = Prefix from Voucherprefix where TranID = 'JOBCARD'
Select @ISSUEPrefix = Prefix from Voucherprefix where TranID = 'ISSUESPARES'

If @Mode = 1   -- 1 for Close and 2 for View
	Select IssueID, IssueDate, 
	@ISSUEPrefix + Cast(IssueAbstract.DocumentID as nvarchar(15)) 'ISSUEDocumentID', 
	@JCPrefix + Cast(JobCardAbstract.DocumentID as nvarchar(15)) 'JCDocumentID', 
	Customer.Company_name, IsNull(IssueAbstract.DocRef, '') DocRef
	from IssueAbstract 
	Inner Join JobCardAbstract On IssueAbstract.JobCardID = JobCardAbstract.JobCardID
	Inner Join Customer on JobCardAbstract.CustomerID = Customer.CustomerID
	Where IssueAbstract.DocumentID between @FromID and @ToID and 
	(IsNull(IssueAbstract.Status,0) & 192) = 0 and 
	(IsNull(JobCardAbstract.Status,0) & 192) = 0 and (IsNull(JobCardAbstract.Status,0) & 32) = 0
	Order by Customer.Company_name, JobCardAbstract.JobCardID, IssueAbstract.IssueID
else
	Select IssueID, IssueDate, IssueAbstract.DocumentID, 
	@ISSUEPrefix + Cast(IssueAbstract.DocumentID as nvarchar(15)) 'ISSUEDocumentID', 
	@JCPrefix + Cast(JobCardAbstract.DocumentID as nvarchar(15)) 'JCDocumentID', 
	Customer.Company_name, 'Status'=IsNull(IssueAbstract.Status,0), IsNull(IssueAbstract.DocRef, '') DocRef 
	from IssueAbstract 
	Inner Join JobCardAbstract On IssueAbstract.JobCardID = JobCardAbstract.JobCardID
	Inner Join Customer on JobCardAbstract.CustomerID = Customer.CustomerID
	Where IssueAbstract.DocumentID between @FromID and @ToID 
	Order by Customer.Company_name, JobCardAbstract.JobCardID, IssueAbstract.IssueID




