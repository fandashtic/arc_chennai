CREATE Procedure sp_ser_list_joballocationdoc(@JobcardIDFrom int, @JobCardToID int,@Mode int=0) -- 0 for Task Allocation and 1 for Close Task
as                        
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'
Select Jobcardabstract.Jobcardid, 'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),    
Jobcarddate, company_name, 'DocRef' = Isnull(DocRef,''),                                              
"Status" = (Case @Mode 
			when 0
			then dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid)
			when 1
			then dbo.sp_ser_jobclosestatus(jobcardabstract.Jobcardid)
			end)
from Jobcardabstract 
Inner Join Customer On Jobcardabstract.customerid = Customer.customerid
where Documentid between @JobcardIDFrom and @JobCardToID
and (IsNull(Status, 0) & 192) = 0 and (IsNull(Status,0) & 32) = 0
order by company_name,Documentid

