CREATE procedure sp_ser_loadreturnablejcabstractdoc(@FromID Int,@ToID Int)
as
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix
where TranID = 'JOBCARD'

select JobCardAbstract.JobCardID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),JobCardDate,
Company_Name,'Status'=IsNull(Status,0), IsNUll(DocRef, '') DocRef from JobCardAbstract,Customer
Where DocumentID between @FromID and @ToID
and (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0 
and JobCardAbstract.CustomerID = Customer.CustomerID
and ((Select Count(*) from IssueAbstract Where 
	IssueAbstract.JobCardID = JobCardAbstract.JobCardID) > 0 )
order by Company_Name, JobCardID


