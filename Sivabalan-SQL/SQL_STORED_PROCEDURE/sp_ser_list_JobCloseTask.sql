CREATE Procedure sp_ser_list_JobCloseTask(@FromDate Datetime,@ToDate Datetime,@Mode int,@CUSTOMER NVARCHAR(15) = '' )                      
as                  
Declare @Prefix nvarchar(15)                  
declare @status nvarchar(100)
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                   
Select Jobcardabstract.Jobcardid, 
	'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)), jobcarddate,    
	company_name, 'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobclosestatus(jobcardabstract.Jobcardid) 
	into #CloseStatusTemp
	from Jobcardabstract 
	Inner Join Customer On Jobcardabstract.customerid = Customer.customerid
	where JobCardAbstract.CustomerID LIKE @CUSTOMER
	and dbo.stripdatefromtime(JobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0 and (IsNull(Status,0) & 32) = 0 
	order by company_name, documentid

--All
IF @Mode = 7
Begin
	Select * from #CloseStatusTemp
End
-- Closed
IF @Mode = 8
Begin
        Select * from #CloseStatusTemp where #CloseStatusTemp.status = 'Fully Closed '        
End
-- partially Closed
Else if @Mode = 9 
Begin
        Select * from #CloseStatusTemp where #ClosestatusTemp.status = 'Partially Closed'
End
--- Fully Pending
Else if @Mode = 10 
Begin
        Select * from #CloseStatusTemp where #ClosestatusTemp.status = 'Fully Pending'
End


