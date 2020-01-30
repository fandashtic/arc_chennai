CREATE Procedure sp_acc_rpt_ContraEntry 
(@Type Int,@FromDate Datetime,@ToDate Datetime,@Active Int = 0)
As
/*
CDB : Cash deposited in Bank
CWB : Cash withdrawn from Bank
CPPC: Cash paid to Petty Cash
CRPC: Cash received from Petty Cash
IBT : Internal Bank Transfer
*/
Declare @CDB  nVarchar(50)
Declare @CWB  nVarchar(50)
Declare @CPPC nVarchar(50)
Declare @CRPC nVarchar(50)
Declare @IBT  nVarchar(50)

Set @CDB  = N'Cash deposited in Bank'
Set @CWB  = N'Cash withdrawn from Bank'
Set @CPPC = N'Cash paid to Petty Cash'
Set @CRPC = N'Cash received from Petty Cash'
Set @IBT  = N'Internal Bank Transfer'

set dateformat dmy   
Create Table #ContraReport
(
	DocumentID 		nvarchar(25),
	DocunmentDate 	nVarchar(40),
	Amount 			Decimal(18,6),
	Staff 			nVarchar(255),
	Account_No  	nVarchar(255),
	Bank 			nVarchar(255),
	Branch 			nVarchar(255),
	Mode  			nVarchar(25),
	Cq_Sl_No 		nVarchar(20),
	Cq_Sl_Date 		Datetime,
	To_Account_No  	nVarchar(255),
	To_Bank 		nVarchar(255),
	To_Branch 		nVarchar(255),
	Narration 		nVarchar(2000),
	Status			nVarchar(10),
	Display 		Int,
	ContraType		Int
)
/*
	For Active documents Only
	0 & 192 = 0 
	For all documents 
	0 & 0
	192 & 0
*/
if @Type = 0    
begin  
	/*Cash paid to Petty Cash*/
	
	If (select Count(*) from Deposits where dbo.stripdatefromtime([DepositDate]) 
		between @fromdate and @todate and Transactiontype = 3
		and isnull(status,0) &  
			(case When @Active = 1 then 192 
			 else 0 End) = 0) > 0 
	Begin
		Insert into #contraReport(DocunmentDate,Display) VAlues(@CPPC,1)
		Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, 
		Narration,Status,Display,ContraType)
		select 
		FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
		Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
		Narration as 'Narration',
		Status,5,1
		from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 3
		and 
		isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192 and ContraType = 1
		Insert into #contraReport(DocunmentDate,Display) Values('',1)
	End
	
	/*Cash received from Petty Cash*/
	If (select Count(*) From Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 4
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Display) VAlues(@CRPC,1)
		Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, 
		Narration,Status,Display,ContraType)
		select 
		FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
		Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
		Narration as 'Narration',
		Status,5,2
		from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 4
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192 and ContraType = 2
		Insert into #contraReport(DocunmentDate,Display) Values('',1)
	End

	/*Cash deposited in Bank*/
	IF (select Count(*)	from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and Transactiontype = 1
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Display) VAlues(@CDB,1)
		Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
		Bank, Branch,Narration,Status,Display,ContraType)
		select 
		FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
		Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
		dbo.getaccountname(AccountID) as 'Account No.',
		(Select Distinct BankName from BankMaster where BankCode in 
			(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
		(Select Distinct BranchName from BranchMaster where BranchCode in 
			(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
		Narration as 'Narration',
		Status,5,3
		from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 1
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192 and ContraType = 3
		Insert into #contraReport(DocunmentDate,Display) VAlues('',1)
	End

	/*Cash withdrawn from Bank*/
	If (select Count(*)	from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 2
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Display) VAlues(@CWB,1)
		Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
		Bank, Branch,Mode,Cq_Sl_No,Cq_Sl_Date,Narration,Status,Display,ContraType)
		select 
		FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
		Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
		dbo.getaccountname(AccountID) as 'Account No.',
		(Select Distinct BankName from BankMaster where BankCode in 
			(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
		(Select Distinct BranchName from BranchMaster where BranchCode in 
			(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
		Case 
			When isnull(ChequeID,0) <> 0 then dbo.LookupDictionaryItem('Cheque',Default)
			Else dbo.LookupDictionaryItem('Withdrawal Slip',Default)
		End,
		case 
			When isnull(ChequeID,0) <> 0 then rtrim((Select Cheque_Book_Name From Cheques where ChequeID = Deposits.ChequeID)) + N' - '
			else ''
		end	+ rtrim(cast(ChequeNo as nvarchar(15))),ChequeDate,
		Narration as 'Narration',
		Status,5,4
		from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 2
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192 and ContraType = 4
		Insert into #contraReport(DocunmentDate,Display) VAlues('',1)
	End

	/*Internal Bank Transfer*/
	If(	select Count(*)	from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 6
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0) > 0 
	Begin
		Insert into #contraReport(DocunmentDate,Display) VAlues(@IBT,1)
		Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
		Bank, Branch, Mode, Cq_Sl_No, Cq_Sl_Date, 
		To_Account_No  	,To_Bank ,To_Branch ,
		Narration, Status, Display,ContraType)
		select 
		FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
		Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
		dbo.getaccountname(AccountID) as 'Account No.',
		(Select Distinct BankName from BankMaster where BankCode in 
			(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
		(Select Distinct BranchName from BranchMaster where BranchCode in 
			(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
		Case 
			When isnull(ChequeID,0) <> 0 then dbo.LookupDictionaryItem('Cheque',Default)
			Else dbo.LookupDictionaryItem('DD',Default)
		End,
		case 
			When isnull(ChequeID,0) <> 0 then rtrim((Select Cheque_Book_Name From Cheques where ChequeID = Deposits.ChequeID)) + N' - '
			else ''
		end	+ rtrim(cast(ChequeNo as nvarchar(15))),ChequeDate,
		dbo.getaccountname(ToAccountID) as 'Account No.',
		(Select Distinct BankName from BankMaster where BankCode in 
			(Select Distinct BankCode from Bank where AccountID = Deposits.ToAccountID)) as 'To Bank Name',
		(Select Distinct BranchName from BranchMaster where BranchCode in 
			(Select BranchCode from Bank where AccountID = Deposits.ToAccountID)) as 'To Branch Name',
		Narration as 'Narration',
		Status,5,5
		from Deposits where 
		dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
		and 
		Transactiontype = 6
		And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192 and ContraType = 5
		Insert into #contraReport(DocunmentDate,Display) VAlues('',1)
	End
end    
Else if @Type = 1
Begin
	Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
	Bank, Branch,Narration,Status,Display)
	select 
	FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
	Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
	dbo.getaccountname(AccountID) as 'Account No.',
	(Select Distinct BankName from BankMaster where BankCode in 
		(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
	(Select Distinct BranchName from BranchMaster where BranchCode in 
		(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
	Narration as 'Narration',
	Status,5
	from Deposits where 
	dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
	and 
	Transactiontype = 1
	And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0
	If (Select count(*) from #contraReport) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192
	End
End
Else if @Type = 2
Begin
	Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
	Bank, Branch,Mode,Cq_Sl_No,Cq_Sl_Date,Narration,Status,Display)
	select 
	FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
	Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
	dbo.getaccountname(AccountID) as 'Account No.',
	(Select Distinct BankName from BankMaster where BankCode in 
		(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
	(Select Distinct BranchName from BranchMaster where BranchCode in 
		(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
	Case 
		When isnull(ChequeID,0) <> 0 then dbo.LookupDictionaryItem('Cheque',Default)
		Else dbo.LookupDictionaryItem('Withdrawal Slip',Default)
	End,
	case 
		When isnull(ChequeID,0) <> 0 then rtrim((Select Cheque_Book_Name From Cheques where ChequeID = Deposits.ChequeID)) + N' - '
		else ''
	end	+ rtrim(cast(ChequeNo as nvarchar(15))),ChequeDate,
	Narration as 'Narration',
	Status,5
	from Deposits where 
	dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
	and 
	Transactiontype = 2
	And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0

	If (Select count(*) from #contraReport) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192
	End
End
Else if @Type = 3
Begin
	Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, 
	Narration,Status,Display)
	select 
	FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
	Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
	Narration as 'Narration',
	Status,5
	from Deposits where 
	dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
	and 
	Transactiontype = 3
	And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0

	If (Select count(*) from #contraReport) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192
	End
End
Else if @Type = 4
Begin
	Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, 
	Narration,Status,Display)
	select 
	FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
	Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
	Narration as 'Narration',
	Status,5
	from Deposits where 
	dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
	and 
	Transactiontype = 4
	And isnull(status,0) & 
			(case When @Active = 1 then 192 
			 else 0 End) = 0

	If (Select count(*) from #contraReport) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192
	End
End
Else if @Type = 6
Begin
	Insert into #contraReport(DocumentID, DocunmentDate, Amount, Staff, Account_No, 
	Bank, Branch, Mode, Cq_Sl_No, Cq_Sl_Date, 
	To_Account_No  	,To_Bank ,To_Branch ,
	Narration, Status, Display)
	select 
	FullDocID as 'Dcoument ID',  cast(CONVERT(char(12),Deposits.DepositDate, 103) as nchar(10)) as 'Document Date',
	Value as 'Amount', dbo.getaccountname(StaffID) as 'Staff',
	dbo.getaccountname(AccountID) as 'Account No.',
	(Select Distinct BankName from BankMaster where BankCode in 
		(Select Distinct BankCode from Bank where AccountID = Deposits.AccountID)) as 'Bank Name',
	(Select Distinct BranchName from BranchMaster where BranchCode in 
		(Select BranchCode from Bank where AccountID = Deposits.AccountID)) as 'Branch Name',
	Case 
		When isnull(ChequeID,0) <> 0 then dbo.LookupDictionaryItem('Cheque',Default)
		Else dbo.LookupDictionaryItem('DD',Default)
	End,
	case 
		When isnull(ChequeID,0) <> 0 then rtrim((Select Cheque_Book_Name From Cheques where ChequeID = Deposits.ChequeID)) + N' - '
		else ''
	end	+ rtrim(cast(ChequeNo as nvarchar(15))),ChequeDate,
	dbo.getaccountname(ToAccountID) as 'Account No.',
	(Select Distinct BankName from BankMaster where BankCode in 
		(Select Distinct BankCode from Bank where AccountID = Deposits.ToAccountID)) as 'To Bank Name',
	(Select Distinct BranchName from BranchMaster where BranchCode in 
		(Select BranchCode from Bank where AccountID = Deposits.ToAccountID)) as 'To Branch Name',
	Narration as 'Narration',
	Status,5
	from Deposits where 
	dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
	and 
	Transactiontype = 6
	And isnull(status,0) &  
			(case When @Active = 1 then 192 
			 else 0 End) = 0

	If (Select count(*) from #contraReport) > 0
	Begin
		Insert into #contraReport(DocunmentDate,Amount,Display)
		Select 'Total',Sum(isnull(Amount,0)),1 
		From #contraReport 
		where Isnull(Status,0) <> 192
	End
End

select 
	DocumentID as 'Document ID', 
	DocunmentDate as 'Document Date',
	Amount as 'Value', 
	Staff as 'Staff',
	Account_No as 'Account No.', 
	Bank as 'Bank Name', 
	Branch as 'Branch Name',
	Mode as 'Mode', 
	Cq_Sl_No as 'Chq./Slip No.' , 
	Cq_Sl_Date as 'Chq./Slip Date' , 
	To_Account_No as 'To Account No.', 
	To_Bank as 'To Account Bank Name', 
	To_Branch as 'To Account Branch Name', 
	Case
		When status = 192 and Display = 5 then dbo.LookupDictionaryItem('Cancelled',Default)
		When isnull(status,0) = 0 and Display = 5 then dbo.LookupDictionaryItem('Active',Default)
		Else ''
	End		
	as 'Status',
	Narration as 'Narration',
	Display
from #contraReport

Drop table #contraReport




