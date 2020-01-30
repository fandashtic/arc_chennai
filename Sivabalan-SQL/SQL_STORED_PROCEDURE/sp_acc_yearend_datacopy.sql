CREATE Procedure sp_acc_yearend_datacopy(@SourceDatabase nvarchar(50),@DestinationDatabase nvarchar(50),@YearEndDate datetime)
As
Declare @Criteria nVarchar(1000)
Declare @TruncateSql nVarchar(1000)
Declare @APVDetailSql nVarchar(2048)
Declare @ARVDetailSql nVarchar(2048)
Declare @BatchAssets nVarchar(2048)
Declare @Deposits nVarchar(2048)
Declare @ContraDetail nvarchar(4000)
Declare @ContraIdentInsert nVarchar(2048)
Declare @UpdateSqlNewAcOpn nVarchar(2048)

-- Set @AccountGroupSql='Set Identity_Insert off' + char(13) + char(10) + 'Insert into ' + @DestinationDatabase + '..AccountGroup Select ' + @SourceDatabase + '..AccountGroup' + char(13) + char(10) + 'Set Identity_Insert off' 
-- Set @AccountsMasterSql='Set Identity_Insert off' + char(13) + char(10) + 'Insert into ' + @DestinationDatabase + '..AccountsMaster Select ' + @SourceDatabase + '..AccountsMaster' + char(13) + char(10) + 'Set Identity_Insert off' 
-- Set @AccountOpeningBalanceSql= 'Insert into ' + @DestinationDatabase + '..AccountOpeningBalance Select * from ' + @SourceDatabase + '..AccountOpeningBalance where OpeningDate >dbo.stripdatefromtime(' + @YearEndDate + ')' 
-- Set @GeneralJournalSql= 'Insert into ' + @DestinationDatabase + '..GeneralJourna Select * from ' + @SourceDatabase + '..GeneralJournal where TransactionDate >dbo.stripdatefromtime(' + @YearEndDate + ')' 
-- 
-- Exec sp_ExecuteSql @AccountOpeningBalanceSql
-- Exec sp_ExecuteSql @GeneralJournalSql

/* Remove the records in destination database which arrived from Template */
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..AccountGroup'
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..AccountsMaster'
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..FAReportData'
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..FAPrintSetting'
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..SetupDetail' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..Batch_Assets' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..Denominations' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..AccountOpeningBalance' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..GeneralJournal' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..APVAbstract' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..APVDetail' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..ARVAbstract' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..ARVDetail' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..Deposits' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..ContraAbstract' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..ContraDetail' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..ManualJournal' 
Execute sp_executesql @TruncateSql
Set @TruncateSql=N'Truncate Table ' + @DestinationDatabase + N'..DefaultFAPrintSetting' 
Execute sp_executesql @TruncateSql



/* transfering Master Records from source to destination databse with identity check*/
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'AccountGroup','AccountGroup',1
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'AccountsMaster','AccountsMaster',1
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'FAReportData','FAReportData',1
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'FAPrintSetting','FAPrintSetting',0
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'Batch_Assets','Batch_Assets',1
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'Denominations','Denominations',0
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'SetupDetail','SetupDetail',0
Exec sp_acc_yearend_transfermastertables @SourceDatabase,@DestinationDatabase,'DefaultFAPrintSetting','DefaultFAPrintSetting',0

/* Transfering transaction records from source database to destination database with identity check */
Set @Criteria=@SourceDatabase + N'..AccountOpeningBalance.OpeningDate> ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''''
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'AccountOpeningBalance','AccountOpeningBalance',@Criteria,0

Set @Criteria= N'dbo.stripdatefromtime(' + @SourceDatabase + N'..GeneralJournal.TransactionDate) > ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N'''' 
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'GeneralJournal','GeneralJournal',@Criteria,0

Set @Criteria=N'dbo.stripdatefromtime(' + @SourceDatabase + N'..APVAbstract.CreationTime) > '''
 + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''' Or (' +  @SourceDatabase + 
N'..APVAbstract.Balance > 0 And (IsNull(' + @SourceDatabase + N'..APVAbstract.Status,0) & 192) = 0)'
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'APVAbstract','APVAbstract',@Criteria,1

/* Insertion of detail table records from source to destination with condition as Destination database abstract table documentid=Source database detail table documentid */
Set @APVDetailSql= N'Insert into ' + @DestinationDatabase + N'..APVDetail Select ' + @DestinationDatabase + N'..APVAbstract.DocumentID ,Type,AccountID,Amount,Particular from ' + @SourceDatabase + N'..APVDetail,' + @DestinationDatabase + N'..APVAbstract where '
 +  @DestinationDatabase + N'..APVAbstract.DocumentID=' + @SourceDatabase + N'..APVDetail.DocumentID'
Exec sp_ExecuteSql @APVDetailSql

Set @Criteria=N'dbo.stripdatefromtime(' + @SourceDatabase + N'..ARVAbstract.CreationTime) > ''' 
+ cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''' Or (' +  @SourceDatabase + 
N'..ARVAbstract.Balance > 0 And (IsNull(' + @SourceDatabase + N'..ARVAbstract.Status,0) & 192) = 0)'
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'ARVAbstract','ARVAbstract',@Criteria,1

Set @ARVDetailSql= N'Insert into ' + @DestinationDatabase + N'..ARVDetail (DocumentID,Type,AccountID,Amount,Particular,TaxPercentage,TaxAmount,ServiceChargeAmount) Select ' 
+ @DestinationDatabase + N'..ARVAbstract.DocumentID ,Type,AccountID,' + @SourceDatabase + N'..ARVDetail.Amount,Particular,TaxPercentage,TaxAmount,ServiceChargeAmount from ' 
+ @SourceDatabase + N'..ARVDetail,' + @DestinationDatabase + N'..ARVAbstract where ' +  @DestinationDatabase + N'..ARVAbstract.DocumentID=' + @SourceDatabase + N'..ARVDetail.DocumentID'
Exec sp_ExecuteSql @ARVDetailSql

Set @Criteria=N'dbo.stripdatefromtime(' + @SourceDatabase + N'..Deposits.CreationDate) > ''' 
+ cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''' or ' + @SourceDatabase + 
N'..Deposits.DepositID in (Select Distinct(DepositID) From ' + @DestinationDatabase + N'..Collections) And (IsNull(' + @SourceDatabase + N'..Deposits.Status,0) & 192) = 0'
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'Deposits','Deposits',@Criteria,1

Set @Criteria=N'dbo.stripdatefromtime(' + @SourceDatabase + N'..ContraAbstract.CreationDate) > ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''''
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'ContraAbstract','ContraAbstract',@Criteria,1

Set @ContraIdentInsert = N'SET IDENTITY_INSERT ' + @DestinationDatabase + N'..ContraDetail ON ' + char(13) + char(10)
Set @ContraDetail = @ContraIdentInsert + N'Insert into ' + @DestinationDatabase + N'..ContraDetail 
(ContraID,FromAccountID,ToAccountID,AmountTransfer,PaymentType,AdditionalInfo_Number,
AdditionalInfo_Date,AdditionalInfo_BankCode,AdditionalInfo_BranchCode,AdditionalInfo_Amount,
AdditionalInfo_Qty,AdditionalInfo_Value,AdditionalInfo_Party,AdditionalInfo_Type,
AdditionalInfo_FromSerialNo,AdditionalInfo_ToSerialNo,DocumentReference,DocumentType,
OriginalID,Denominations,AdditionalInfo_Customer,AdjustedFlag,ContraSerialCode,
AdditionalInfo_CollectionID,AdditionalInfo_ServiceCharge) Select ' + @DestinationDatabase + 
N'..ContraAbstract.ContraID,FromAccountID,ToAccountID,AmountTransfer,PaymentType,AdditionalInfo_Number,
AdditionalInfo_Date,AdditionalInfo_BankCode,AdditionalInfo_BranchCode,AdditionalInfo_Amount,
AdditionalInfo_Qty,AdditionalInfo_Value,AdditionalInfo_Party,AdditionalInfo_Type,
AdditionalInfo_FromSerialNo,AdditionalInfo_ToSerialNo,DocumentReference,DocumentType,
OriginalID,Denominations,AdditionalInfo_Customer,AdjustedFlag,ContraSerialCode,
AdditionalInfo_CollectionID,AdditionalInfo_ServiceCharge from ' + @SourceDatabase + N'..ContraDetail,' 
+ @DestinationDatabase + N'..ContraAbstract where ' +  @DestinationDatabase 
+ N'..ContraAbstract.ContraID=' + @SourceDatabase + N'..ContraDetail.ContraID ' + char(13) + char(10)
Set @ContraIdentInsert = N'SET IDENTITY_INSERT ' + @DestinationDatabase + N'..ContraDetail OFF '
Set @ContraDetail = @ContraDetail + @ContraIdentInsert
Exec sp_ExecuteSql @ContraDetail

Set @Criteria=N'dbo.stripdatefromtime(' + @SourceDatabase + N'..ManualJournal.CreationTime) > '''
 + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''' Or (' +  @SourceDatabase + 
N'..ManualJournal.Balance > 0 And IsNull(' + @SourceDatabase + N'..ManualJournal.Status,0) <> 192
And IsNull(' + @SourceDatabase + N'..ManualJournal.Status,0) <> 128)'
Exec sp_acc_yearend_transfertransactiontables @SourceDatabase,@DestinationDatabase,'ManualJournal','ManualJournal',@Criteria,1

/* Updating opening Balance of all accounts in Destination database */
Declare @UpdateSql nVarchar(2048)
Declare @Sql as nVarchar(2048)
Declare @Count Int,@OpeningBalance Decimal(18,6),@LastBalance Decimal(18,6),@CurrentBalance Decimal(18,6),@AccountID Int
/* Check whether 1st date records available in AccountOpeningBalance table of Destination database then update the Opening balance of each account in AccountsMaster table of Destination database */
/* Else Get compute the opening balance from source database tables like AccountsMaster,AccountOpeningBalance and GeneralJournal and then update the opening balance in Destination Database Accounts Master table.*/ 
Set @Sql='select Count(*) from ' + @DestinationDatabase + '..AccountOpeningBalance where OpeningDate= ''' + cast(dateadd(day,1,dbo.stripdatefromtime(@YearEndDate)) as nvarchar) + ''''
exec sp_acc_execquery @Sql, @Count output
If @Count=0
Begin
	Set @Sql = N'DECLARE @ACCOUNTID int' + Char(13) + Char(10)
	Set @Sql = @Sql + N'DECLARE @LastBalance Decimal(18,6)' + Char(13) + Char(10)
	Set @Sql = @Sql + N'DECLARE @CurrentBalance Decimal(18,6)' + Char(13) + Char(10)
	Set @Sql = @Sql + N'DECLARE @OpeningBalance Decimal(18,6)' + Char(13) + Char(10)
	Set @Sql = @Sql + N'DECLARE @LastTranDate datetime' + Char(13) + Char(10)
	Set @Sql=@Sql + N'DECLARE ScanAccountMaster CURSOR KEYSET FOR' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select AccountID from ' + @SourceDatabase + N'..AccountsMaster' + Char(13) + Char(10)
	Set @Sql=@Sql+N'OPEN ScanAccountMaster' + Char(13) + Char(10)
	Set @Sql=@Sql+N'FETCH FROM ScanAccountMaster INTO @ACCOUNTID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'While @@FETCH_STATUS=0' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @LastBalance =0' + Char(13) + Char(10)
	Set @Sql=@Sql+N'If Not exists(Select top 1 openingvalue from ' + @SourceDatabase + N'..AccountOpeningBalance where OpeningDate= ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)+ N''' and AccountID= @AccountID)' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select @LastTranDate = Max(OpeningDate) From ' + @SourceDatabase + N'..AccountOpeningBalance where AccountID = @AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'If @LastTranDate Is Not Null' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select @LastBalance = OpeningValue From ' + @SourceDatabase + N'..AccountOpeningBalance where AccountID = @AccountID And OpeningDate = @LastTranDate' + Char(13) + Char(10)
	Set @Sql=@Sql+N'End' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Else' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select @LastBalance = isNull(OpeningBalance,0) from ' + @SourceDatabase + N'..AccountsMaster where AccountId=@AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select @LastTranDate = OpeningDate From Setup' + Char(13) + Char(10)
	Set @Sql=@Sql+N'End' + Char(13) + Char(10)
	Set @Sql=@Sql+N'End' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Else' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Select @LastBalance = OpeningValue From ' + @SourceDatabase + N'..AccountOpeningBalance where OpeningDate= ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)+ N''' and AccountID= @AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @LastTranDate=dbo.StripDateFromTime(''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar) + N''')'
	Set @Sql=@Sql+N'End' + Char(13) + Char(10)

	Set @Sql=@Sql+N'Select @CurrentBalance = isnull(sum(Debit-Credit),0) from ' + @SourceDatabase 
	+ N'..GeneralJournal where dbo.stripdatefromtime(TransactionDate) between @LastTranDate And ''' + cast(@YearEndDate as nvarchar) + N''' and AccountID=@AccountID' + Char(13) + Char(10)
	--Insert the OpeningBalance + Current balance of the last date as Opening Balance
	-- for the next date in AccountOpeningBalance table.
	Set @Sql=@Sql+N'Set @OpeningBalance = isnull(@LastBalance,0)+isnull(@CurrentBalance,0)' + Char(13) + Char(10)
	--dont insert if openingbalance of that account is 0
	Set @Sql=@Sql+N'Update ' + @Destinationdatabase + N'..Accountsmaster Set OpeningBalance = @OpeningBalance where AccountID=  @AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @LastBalance=0' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @CurrentBalance=0' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @OpeningBalance=0' + Char(13) + Char(10)
	Set @Sql=@Sql+N'Set @LasttranDate=NULL' + Char(13) + Char(10)
	Set @Sql=@Sql+N'FETCH NEXT FROM ScanAccountMaster INTO @AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql+N'End' + Char(13) + Char(10)
	Set @Sql=@Sql+N'CLOSE ScanAccountMaster' + Char(13) + Char(10)
	Set @Sql=@Sql+N'DEALLOCATE ScanAccountMaster' + Char(13) + Char(10)
	
	Exec sp_ExecuteSql @Sql
End
Else
Begin
/*
	Date 					: 09.06.2008
	Scenario			: Creating Bank Account and put opening balance and do close period. 
	Issue 				: The opening balance of the newly created Bank Acccount is zero in new database.
	Reason 				: The opening balance for all accounts, updating from AccountOpeningBalance table. Before updating
									Opening balance in AccountsMaster set the opening balance as zero if the account does't have value(row)
							 		in AccountOpeningBalance table. For the above scenario the newly created bank account does't have any
									value in AccountOpeningBalance.
	Change				: Put another condition of AccountSMaster Updating Query.
	Existing Qry 	:	Set @UpdateSql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=0 where AccountID not in(Select AccountID From ' 
									+ @DestinationDatabase + N'..AccountOpeningBalance where OpeningDate=''' + Cast(dateadd(day,1,dbo.stripdatefromtime(@YearEndDate)) as nvarchar) + N''')'	
*/
	Set @UpdateSql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=0 where OpeningBalance=0 and AccountID not in(Select AccountID From ' 
	+ @DestinationDatabase + N'..AccountOpeningBalance where OpeningDate=''' + Cast(dateadd(day,1,dbo.stripdatefromtime(@YearEndDate)) as nvarchar) + N''')'	
	Exec sp_ExecuteSql @UpdateSql

	--Set @Sql='select AccountID,Openingbalance from ' + @DestinationDatabase + '..AccountOpeningBalance where OpeningDate=' + dateadd(day,1,@YearEndDate)	
	--Exec sp_ExecuteSql @Sql
	Set @Sql = N'DECLARE @AccountID int' + Char(13) + Char(10)
	Set @Sql = @Sql+N'DECLARE @OpeningBalance Decimal(18,6)' + Char(13) + Char(10)
	Set @Sql = @Sql+N'DECLARE @OpeningDate DateTime' + Char(13) + Char(10)
	Set @Sql=@Sql+N'DECLARE scanAccountOpeningBalance CURSOR KEYSET FOR' + Char(13) + Char(10)
	/*Get the AccountID and Min(OpeningDate) from Source Database.*/
	/*This part is critical, bcoz if the source database is more than two years old, then we need to update AccountsMaster table with the Min(OpeningDate) Condition. Earlier It was based on YearEndDate*/
	Set @Sql=@Sql + N'Select AccountID,Min(OpeningDate) from ' + @DestinationDatabase + N'..AccountOpeningBalance Group By AccountID' + Char(13) + Char(10)
	Set @Sql=@Sql + N'OPEN scanAccountOpeningBalance' + Char(13) + Char(10)
	Set @Sql=@Sql + N'FETCH FROM scanAccountOpeningBalance INTO @AccountID,@OpeningDate' + Char(13) + Char(10)
	Set @Sql=@Sql + N'WHILE @@FETCH_STATUS = 0' + Char(13) + Char(10)
	Set @Sql=@Sql + N'BEGIN' + Char(13) + Char(10)
	Set @Sql=@Sql + N'Select @OpeningBalance = OpeningValue from ' + @DestinationDatabase + N'..AccountOpeningBalance Where AccountID = @AccountID And OpeningDate = @OpeningDate' + Char(13) + Char(10)
	Set @Sql=@Sql + N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance = @OpeningBalance where AccountID = @AccountID' + Char(13) + Char(10)
	--Set @UpdateSql='Update ' + @DestinationDatabase + '..AccountsMaster Set OpeningBalance=' + @OpeningBalance + ' where AccountID =' + @AccountID 
	--Exec sp_ExecuteSql @UpdateSql
	Set @Sql=@Sql + N'Set @OpeningBalance = 0' + Char(13) + Char(10)
	Set @Sql=@Sql + N'FETCH NEXT FROM scanAccountOpeningBalance INTO @AccountID,@OpeningDate' + Char(13) + Char(10)
	Set @Sql=@Sql + N'END' + Char(13) + Char(10)
	Set @Sql=@Sql + N'CLOSE scanAccountOpeningBalance' + Char(13) + Char(10)
	Set @Sql=@Sql + N'DEALLOCATE scanAccountOpeningBalance'
	Exec sp_ExecuteSql @Sql
End
/* To update Opening for Accounts which is not having openingdetails for YearEndDate +1*/
Set @UpdateSqlNewAcOpn=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=0 where Accountid not in(Select AccountID From ' 
+ @DestinationDatabase + N'..AccountOpeningBalance where OpeningDate=''' + Cast(dateadd(day,1,dbo.stripdatefromtime(@YearEndDate)) as nvarchar) + N''')'	
Exec sp_ExecuteSql @UpdateSqlNewAcOpn

/*Update the OpeningStock of AccountsMaster from the value of ClosingStock of AccountsMaster table itself */
Set @Sql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=isnull((Select OpeningBalance from ' + @Destinationdatabase + N'..AccountsMaster where AccountID=23),0) where AccountID=22'
Exec sp_ExecuteSql @Sql
/*Update the ClosingStock to zero */
Set @Sql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=0 where AccountID=23'
Exec sp_ExecuteSql @Sql

/*Update the Tax on OpeningStock of AccountsMaster from the value of Tax on ClosingStock of AccountsMaster table itself */
Set @Sql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=isnull((Select OpeningBalance from ' + @Destinationdatabase + N'..AccountsMaster where AccountID=88),0) where AccountID=89'
Exec sp_ExecuteSql @Sql
/*Update the Tax on ClosingStock to zero */
Set @Sql=N'Update ' + @DestinationDatabase + N'..AccountsMaster Set OpeningBalance=0 where AccountID=88'
Exec sp_ExecuteSql @Sql

/* Check whether year end made after year end date */
--Set @Sql='select ' + @Count + '=Count(*) from ' + @DestinationDatabase + '..AccountOpeningBalance where OpeningDate=' + dateadd(day,1,@YearEndDate)
--Execute sp_ExecuteSql @Sql
/* Delete OpeningSock, ClosingStock, Tax on OpeningSock and Tax on ClosingStock account from AccountOpeningBalance table */
Set @Sql = N'Delete ' + @DestinationDatabase + N'..AccountOpeningBalance where AccountID in (22,23,88,89)'
Execute sp_ExecuteSql @Sql

/* For Asset - Depreciation */
/*Update the OPWDV of Batch_Assets from the value of CWDV of Batch_Assets table itself */
--Set @Sql='Update ' + @DestinationDatabase + '..Batch_Assets Set OPWDV=isnull(CWDV,0) where IsNull(Saleable,0)=1 and (dbo.stripdatefromtime(APVDate) <= ''' + Cast(@YearEndDate as nvarchar) + ''' or APVDate Is  Null)'
Set @Sql=N'Update ' + @DestinationDatabase + N'..Batch_Assets Set OPWDV=isnull(CWDV,0) where 
(dbo.stripdatefromtime(APVDate) <= ''' + Cast(@YearEndDate as nvarchar) + N''' or APVDate Is  Null) 
and (IsNull(Saleable,0)=1 Or (IsNull(Saleable,0)=0 and IsNull(ARVId,0)<>0 and 
(select dbo.StripDateFromTime(ARVDate) from ' + @DestinationDatabase + N'..ARVAbstract where ' + @DestinationDatabase + N'..ARVAbstract.DocumentID=' + @DestinationDatabase + N'..Batch_Assets.ARVId) > ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)
 + N'''))'
Exec sp_ExecuteSql @Sql
/*Update the DepPercent,DepAmount,CWDV to zero of Batch_Assets table */
Set @Sql=N'Update ' + @DestinationDatabase + N'..Batch_Assets Set DepPercent=0,DepAmount=0,CWDV=0 where 
(dbo.stripdatefromtime(APVDate) <= ''' + Cast(@YearEndDate as nvarchar) + N''' or APVDate Is  Null) 
and (IsNull(Saleable,0)=1 Or (IsNull(Saleable,0)=0 and IsNull(ARVId,0)<>0 and 
(select dbo.StripDateFromTime(ARVDate) from ' + @DestinationDatabase + N'..ARVAbstract where ' + @DestinationDatabase + N'..ARVAbstract.DocumentID=' + @DestinationDatabase + N'..Batch_Assets.ARVId) > ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)
 + N'''))'
Exec sp_ExecuteSql @Sql

/*Update the sum of OPWDV of AccountID from Batch _Assets in AccountsMaster table */
-- Set @Sql = 'DECLARE @AccountID int' + Char(13) + Char(10)
-- Set @Sql = @Sql+'DECLARE @OpeningBalance Decimal(18,6)' + Char(13) + Char(10)
-- Set @Sql=@Sql+'DECLARE scanbatchassets CURSOR KEYSET FOR' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'Select AccountID,sum(OPWDV) from ' + @DestinationDatabase + '..Batch_Assets Group By AccountID' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'OPEN scanbatchassets' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'FETCH FROM scanbatchassets INTO @AccountID,@OpeningBalance' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'WHILE @@FETCH_STATUS =0' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'BEGIN' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'Exec sp_ExecuteSql (Update ' + @DestinationDatabase + '..AccountsMaster Set OpeningBalance= @OpeningBalance where AccountID = @AccountID)' + Char(13) + Char(10)
-- 	--Set @UpdateSql='Update ' + @DestinationDatabase + '..AccountsMaster Set OpeningBalance=' + @OpeningBalance + ' where AccountID =' + @AccountID 
-- 	--Exec sp_ExecuteSql @UpdateSql
-- Set @Sql=@Sql + 'Set @OpeningBalance=0' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'FETCH NEXT FROM scanbatchassets INTO @AccountID,@OpeningBalance' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'END ' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'CLOSE scanbatchassets' + Char(13) + Char(10)
-- Set @Sql=@Sql + 'DEALLOCATE scanbatchassets'
-- Exec sp_ExecuteSql @Sql

/*
If @Count<>0
Begin
	-- Update the Openingstock of Accountopneningbalance table from Accountsmaster 
	Set @Sql='Update ' + @DestinationDatabase + '..AccountOpeningBalance Set OpeningBalance=isnull((Select OpeningBalance from ' + @Destinationdatabase + '..AccountsMaster where AccountID=23),0) where AccountID=23'
	Exec sp_ExecuteSql @Sql
	--Update the Closingstock of Accountopneningbalance table to zero
	Set @Sql='Update ' + @DestinationDatabase + '..AccountOpeningBalance Set OpeningBalance=0 where AccountID=24'
	Exec sp_ExecuteSql @Sql
End
*/

