

CREATE procedure sp_acc_con_sendaccountdata(@FromDate DateTime,@ToDate DateTime)
as
Declare @FetchDate DateTime
Declare @CompanyID nVarchar(128)
Declare @OpeningDate DateTime

Select @CompanyID = RegisteredOwner,@OpeningDate = OpeningDate From Setup


Create Table #TempConsolidate(CompanyID nVarchar (128) Null,[Date] DateTime Null, AccountID Int Null,AccountName nVarchar(255) Null,
AccountGroupID Int Null,OpeningBalance Decimal(18,2),ClosingBalance Decimal(18,2),
Depreciation Decimal(18,2) Null,Fixed Int Null)

Set @FetchDate = dbo.stripdatefromtime(@FromDate)
While @FetchDate <= @ToDate
Begin
	Insert #TempConsolidate
	Select @CompanyID,@FetchDate, AccountID,AccountName,GroupID,

	'Opening Balance'= Case When AccountID = 22 or AccountID = 23 or AccountID = 88
	or AccountID = 89 Then dbo.sp_acc_con_getstock(AccountID,@OpeningDate,getdate())
	Else dbo.sp_acc_con_getaccountopeningbalance(AccountID,@FetchDate)End,
 
	'Closing Balance' = Case When AccountID = 22 or AccountID = 23 or AccountID = 88
	or AccountID = 89 Then dbo.sp_acc_con_getstock(AccountID,@FetchDate,GetDate())
	Else Case When AccountID = 24 Then dbo.sp_acc_con_consolidatedepreciation(AccountID,@FetchDate,2)
	Else dbo.sp_acc_con_getaccountclosingbalance(AccountID,@FetchDate) End End,
	
	'Depreciation' = dbo.sp_acc_con_consolidatedepreciation(AccountID,@FetchDate,1),
	
	'Fixed' = IsNull(Fixed,0)From AccountsMaster Where AccountID <> 500

	Set @FetchDate = DateAdd(day,1,@FetchDate)
End
Select * from #TempConsolidate -- for xml raw
Drop Table #TempConsolidate







