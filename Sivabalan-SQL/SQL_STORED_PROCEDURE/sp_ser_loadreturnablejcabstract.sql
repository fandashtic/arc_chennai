CREATE procedure sp_ser_loadreturnablejcabstract(@FromDate Datetime,@ToDate Datetime,@CUSTOMER NVARCHAR(15) = '')
as
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix
where TranID = 'JOBCARD'

select JobCardAbstract.JobCardID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),JobCardDate,
Company_Name,'Status'=IsNull(Status,0), IsNUll(DocRef, '') DocRef from JobCardAbstract,Customer
Where dbo.stripdatefromtime(JobCardDate) between @FromDate and @ToDate
and (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0 
and JobCardAbstract.CustomerID = Customer.CustomerID
and JobCardAbstract.CustomerID LIKE @CUSTOMER
and ((Select Count(*) from IssueAbstract Where 
IssueAbstract.JobCardID = JobCardAbstract.JobCardID) > 0 )
order by Company_Name, JobCardID


