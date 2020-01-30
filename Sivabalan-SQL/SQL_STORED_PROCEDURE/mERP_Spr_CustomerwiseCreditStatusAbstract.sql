Create procedure mERP_Spr_CustomerwiseCreditStatusAbstract @DS nvarchar(4000),@Beat nvarchar(4000),@Customer nvarchar(4000),@FromDate datetime,@ToDate Datetime
AS
BEGIN
	Set dateformat DMY
	Declare @Delimeter as Char(1)              
	Set @Delimeter=Char(15) 

	Create Table #Salesman(SalesmanID int,Smanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)           
	Create Table #Beat(BeatID int,Beatname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)   
	Create Table #Customer(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatID int,Salesmanid int)   

	Create Table #GTInvoice(Documentid int,InvoiceDate datetime,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,AlertType int)
	
	Create Table #Output(DummyColumn nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	TotalBillsCount int,CreditLimitDays nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CreditLimitValue nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,CreditLimitNOB nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CrTermInvCount int,

	--, CrTermInvCountCatGrp int, 
	CrLimitInvCount int,NOBinvCount int)

	if @DS='%'     
	Begin          
		Insert into #Salesman select SalesmanID, Salesman_name from salesman where SalesmanID in 
		(select distinct SalesmanID from Beat_Salesman)   
	End 
	Else              
	Begin
		Insert into #Salesman select SalesmanID, Salesman_name from salesman where Salesman_name in
        (select * from dbo.sp_SplitIn2Rows(@DS,@Delimeter))           
	End
	if @BEAT='%'     
	Begin          
		insert into #Beat select BeatID,[Description] from beat where 
		BeatID in (select distinct beatid from Beat_Salesman)        
	End 
	Else              
	Begin
		Insert into #Beat select BeatID,[Description] from Beat where 
		[Description] in (select * from dbo.sp_SplitIn2Rows(@BEAT,@Delimeter))
	End
	if @Customer='%'     
	Begin          
		insert into #Customer select distinct C.CustomerID,C.Company_Name,B.BeatID,S.Salesmanid from Customer C,Beat_salesman BS,#Salesman S,#Beat B where 
		BS.customerID=C.CustomerID and 
		BS.SalesmanID=S.SalesmanID and
		BS.BeatID=B.BeatID
	End 
	Else              
	Begin
		Insert into #Customer select C.CustomerID,Company_Name,BS.BeatID,BS.Salesmanid from Customer c,Beat_salesman BS where 
		Company_Name in (select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter))
		And BS.CustomerID=C.CustomerID
	End	
	
	Create Table #customermaster (customerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert into #customermaster(customerID) Select distinct CustomerID from #Customer
	
	Insert into #GTInvoice(Documentid,InvoiceDate,CustomerID,AlertType)
	Select distinct IA.DocumentID,IA.InvoiceDate,IA.CustomerID,GT.AlertType from GT_Invoice GT,InvoiceAbstract IA,#Customer C
	Where IA.Invoiceid=GT.Invoiceid And
	IA.CustomerID=C.CustomerID And
	IA.BeatID=C.BeatID And
	IA.Salesmanid=C.Salesmanid And
	Convert(Nvarchar(10),IA.Invoicedate,103) between @FromDate and @ToDate and
	((IA.Status & 64) = 64 OR (IA.Status & 192) = 0) and
	IA.Invoicetype in(1,3) 

		
	Insert into #Output(DummyColumn,CustomerID,Company_name,TotalBillsCount,CreditLimitDays,CreditLimitValue,CreditLimitNOB)
	Select distinct Cus.CustomerId,
		   Cus.CustomerID,
		   Cus.Company_name,
		   (Select count('x') from Invoiceabstract IA where 
				cast(IA.BeatID as nvarchar(255))+cast(IA.Salesmanid as nvarchar(255))+cast(IA.CustomerID as nvarchar(15))
				in (select 
				cast(CUST.BeatID as nvarchar(255))+cast(CUST.Salesmanid as nvarchar(255))+cast(CUST.CustomerID as nvarchar(15)) from #Customer CUST)
				And Convert(Nvarchar(10),IA.Invoicedate,103) between @FromDate and @ToDate and
				((IA.Status & 64) = 64 OR (IA.Status & 192) = 0) and
				IA.Invoicetype in(1,3) and IA.CustomerID=CM.CustomerID),
	Case Cus.CreditTerm When -1 Then 'Not Defined' else (Select Description from creditterm where CreditID= Cus.CreditTerm)end as CreditLimitDays,
	(Case When Cus.CreditLimit= -1 then 'Not Defined' else cast(cast(Cus.CreditLimit as decimal(18,2)) as nvarchar(50)) end) as CreditLimitValue,
	(Case when Cus.NoofBillsOutstanding = -1 then 'Not Defined' else cast(cast(Cus.NoofBillsOutstanding as int) as nvarchar(50)) end) as CreditLimitNOB
	From #customermaster CM, Customer Cus
	Where
	Cus.CustomerID=CM.CustomerID 
	
	
	-- Alert Type 1=No of bills 2=Credit Limit 3 = Credit Term Outstanding

	--Credit Term Oustanding 
	
	Update #Output Set CrTermInvCount= (Select count(distinct documentid) from #GTInvoice G where #Output.CustomerID=G.CustomerID And G.AlertType in(3,4))
	--Update #Output Set CrTermInvCountCatGrp= (Select count(distinct documentid) from #GTInvoice G where #Output.CustomerID=G.CustomerID And G.AlertType=3)
	Update #Output Set CrLimitInvCount= (Select count('x') from #GTInvoice G where #Output.CustomerID=G.CustomerID And G.AlertType=2)
	Update #Output Set NOBinvCount= (Select count('x') from #GTInvoice G where #Output.CustomerID=G.CustomerID And G.AlertType=1)

	Select dummyColumn,CustomerID,Company_name as CustomerName,TotalBillsCount as [Total No. of Bills Cut],CreditLimitDays as [Credit Limit(No. of Days)],
	CreditLimitValue [Credit Limit(Value)],CreditLimitNOB as [Credit Limit(No. of Bill O/S)],CrTermInvCount as [Count of Inv - Credit Term exceed],--, CrTermInvCountCatGrp as [Count of Inv - Credit Term exceed (Cat. Group)],
	CrLimitInvCount as [Count of Inv - Credit Limit exceed],NOBinvCount as [Count of Inv - No. of O/S Bills exceed] from #Output where TotalBillsCount > 0 order by Company_name
	
	Drop Table #Salesman
	Drop Table #Beat
	Drop Table #Customer
	Drop Table #GTInvoice
	Drop Table #customermaster
END
