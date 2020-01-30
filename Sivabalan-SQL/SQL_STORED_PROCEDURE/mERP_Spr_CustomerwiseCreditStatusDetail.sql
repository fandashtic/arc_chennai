Create procedure mERP_Spr_CustomerwiseCreditStatusDetail @CustomerID nvarchar(30),@FromDate datetime,@ToDate Datetime
AS
BEGIN
	Set dateformat DMY
	Create Table #Customer(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatID int,Salesmanid int)   
	insert into #Customer select distinct C.CustomerID,C.Company_Name,BS.BeatID,BS.Salesmanid from Customer C,Beat_salesman BS where 
	BS.customerID=C.CustomerID and 
	C.CustomerID=@CustomerID

	Create Table #tmpGroup(GroupID int,GroupName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #Output(GroupID int,
	GroupName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TotalBillsCount int,
	CreditLimitDays nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CreditLimitValue nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CreditLimitNOB nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CrTermInvCount int, CrLimitInvCount int,NOBinvCount int)
	Create Table #GTInvoice(Documentid int,InvoiceDate datetime,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,AlertType int,GroupID int)
	Create Table #InvoiceTmp(Invoiceid Int,GroupID int)

	If (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') = 0 
		Insert into #tmpGroup(GroupID,GroupName)
		Select Max(PDA.GroupID) as 'GroupID', TCD.CategoryGroup as 'GroupName'
		From ProductCategoryGroupAbstract PDA, tblCGDivMapping TCD
		Where TCD.CategoryGroup = PDA.GroupName and IsNull(OCGtype, 0) = 0 and active = 1 
		Group By TCD.CategoryGroup
	Else
		Insert into #tmpGroup(GroupID,GroupName)
		Select GroupID, GroupName
		From ProductCategoryGroupAbstract 
		Where IsNull(OCGtype, 0) = 1 and active = 1 
		order By Groupid

	/* To get the Category Groups in invoice abstract*/
	
	Declare @InvoiceID int
	
	
	Declare AllInv Cursor For Select Invoiceid from InvoiceAbstract IA,#Customer C where
	Convert(Nvarchar(10),Invoicedate,103) between @FromDate and @ToDate and
	((Status & 64) = 64 OR (Status & 192) = 0) and
	Invoicetype in(1,3) And IA.CustomerID=@CustomerID and IA.CustomerID=C.CustomerID and IA.BeatID=C.BeatID and IA.Salesmanid = C.Salesmanid
	Open AllInv
	Fetch from AllInv into @InvoiceID
	While @@Fetch_status=0 
	Begin
		Insert into #InvoiceTmp (Invoiceid,GroupID)
		Select distinct @InvoiceID,GroupID from InvoiceDetail where Invoiceid=@InvoiceID
		Fetch Next from AllInv into @InvoiceID
	End
	Close AllInv
	Deallocate AllInv
	

	Insert into #GTInvoice(Documentid,InvoiceDate,CustomerID,AlertType,GroupID)
	Select distinct IA.DocumentID,IA.InvoiceDate,IA.CustomerID,GT.AlertType,GT.GroupID from GT_Invoice GT,InvoiceAbstract IA,#InvoiceTmp T,#Customer C
	Where IA.Invoiceid=GT.Invoiceid And
	Convert(Nvarchar(10),IA.Invoicedate,103) between @FromDate and @ToDate and
	((IA.Status & 64) = 64 OR (IA.Status & 192) = 0) and
	IA.Invoicetype in(1,3) And IA.CustomerID=@CustomerID and IA.CustomerID=C.CustomerID And IA.BeatID=C.BeatID and IA.Salesmanid = C.Salesmanid and
	T.Invoiceid=IA.Invoiceid And
	T.Invoiceid=GT.Invoiceid


	
	
	Insert into #Output(GroupID,GroupName)--,TotalBillsCount,CreditLimitDays,CreditLimitValue,CreditLimitNOB)
	Select GroupID,GroupName from #tmpGroup

	update #Output set TotalBillsCount=(select count('x') from #InvoiceTmp G where G.GroupID = #Output.GroupID)
	update #Output set CreditLimitDays=(Select Description from #tmpGroup T,CustomerCreditLimit CC,creditterm CT where CC.CreditTermDays=CT.CreditID and CC.customerid=@CustomerID and T.GroupID=CC.GroupID and T.GroupID=#Output.GroupID)
	update #Output set CreditLimitValue=(Select case CC.CreditLimit When -1 then 'Not Defined' else cast(cast(CC.CreditLimit as decimal(18,2)) as nvarchar(50)) end from #tmpGroup T,CustomerCreditLimit CC where CC.customerid=@CustomerID and T.GroupID=CC.GroupID and T.GroupID=#Output.GroupID)
	update #Output set CreditLimitNOB=(Select case CC.NoOfBills When -1 then 'Not Defined' else cast(cast(CC.NoOfBills as int) as nvarchar(50)) end from #tmpGroup T,CustomerCreditLimit CC where CC.customerid=@CustomerID and T.GroupID=CC.GroupID and T.GroupID=#Output.GroupID)
	
	Update #Output Set CrTermInvCount= (Select count(distinct documentid) from #GTInvoice G where G.CustomerID =@CustomerID And G.AlertType =3 and G.GroupID=#Output.GroupID)-- and #Output.CreditLimitDays <> 'Not defined')
	Update #Output Set CrLimitInvCount= (Select count('x') from #GTInvoice G where G.CustomerID =@CustomerID And G.AlertType=2 and G.GroupID=#Output.GroupID)-- and #Output.CreditLimitValue <> 'Not defined')
	Update #Output Set NOBinvCount= (Select count('x') from #GTInvoice G where G.CustomerID =@CustomerID And G.AlertType=1 and G.GroupID=#Output.GroupID)-- and #Output.CreditLimitNOB <> 'Not defined')

	update #Output set CreditLimitDays ='Not Defined' where isnull(CreditLimitDays,'')=''
	update #Output set CreditLimitValue ='Not Defined' where isnull(CreditLimitValue,'')=''
	update #Output set CreditLimitNOB ='Not Defined' where isnull(CreditLimitNOB,'')=''

	Select GroupID, GroupName as [Category Group],TotalBillsCount as [Total No. of Bills Cut], 
	CreditLimitDays as [Credit Limit(No. of Days)],CreditLimitValue as [Credit Limit(Value)],
	CreditLimitNOB as [Credit Limit(No. of Bill O/S)],CrTermInvCount as [Count of Inv - Credit Term exceed],
	CrLimitInvCount as [Count of Inv - Credit Limit exceed],NOBinvCount as [Count of Inv - No. of O/S Bills exceed] 
	from #Output
	Drop Table #Output
	Drop Table #tmpGroup
	Drop Table #InvoiceTmp
	Drop Table #GTInvoice
	Drop Table #Customer
END
