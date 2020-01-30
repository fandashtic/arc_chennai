CREATE Procedure [dbo].[sp_acc_rpt_DayBookTShape](@fromdate datetime,@todate datetime)
as
Declare @LeftCount Int
Declare @RightCount Int
Declare @DocumentDate Datetime
Declare @Credit Decimal(18,6)
Declare @Debit Decimal(18,6)
Declare @LAccount nVarchar(255)
Declare @RAccount nVarchar(255)
Declare @LDocumentID nVarchar(50)
Declare @RDocumentID nVarchar(50)
Declare @LActualID Int
Declare @RActualID Int
Declare @LDocumentType Int
Declare @RDocumentType Int
Declare @ColorInfo Int
Declare @OpeningBalance Decimal(18,6)
Declare @CASH Int
Declare @PrevDate Datetime 
Declare @Balance Decimal(18,6)
Declare @ReportDate DateTime
Declare @TotalDebit Decimal(18,6)
Declare @TotalCredit Decimal(18,6)
Declare @PrevBalance Decimal(18,6) 
Declare @AccountBalance Decimal(18,6) 
Declare @TempReportDate DateTime

Set @CASH = 3

create table #DayBookTempLeft(DocumentDate DateTime,Credit Decimal(18,6),Account nVarchar(255),
DocumentID nvarchar(50),ActualID Int,DocumentType Int,ColorInfo Int,SerialNo Int IDENTITY(1,1))

create table #DayBookTempRight(DocumentDate DateTime,Debit Decimal(18,6),Account nVarchar(255),
DocumentID nvarchar(50),ActualID Int,DocumentType Int,ColorInfo Int,SerialNo Int IDENTITY(1,1))

create table #DayBookTemp(DocumentDate DateTime,Credit Decimal(18,6),LAccount nVarchar(255),
LDocumentID nvarchar(50),LActualID Int,LDocumentType Int,LHighlight Int,Debit Decimal(18,6),
RAccount nVarchar(255),RDocumentID nVarchar(50),RActualID Int,RDocumentType Int,RHighlight Int)

Set @ReportDate = dbo.stripdatefromtime(@FromDate)
Set @TempReportDate=DateAdd(s,0-1,(DateAdd(dd,1,@ReportDate)))

While @ReportDate <= @ToDate
Begin 
	Select @OpeningBalance = IsNull(OpeningValue,0)
	From AccountOpeningBalance Where AccountID = @CASH 
	and OpeningDate = @ReportDate
	
	If @OpeningBalance > 0 
	Begin
		Insert #DayBookTempLeft(Credit,Account,ColorInfo)
		Values(@OpeningBalance,'Opening Balance',101) 
	End
	Else If @OpeningBalance < 0 
	Begin
		Insert #DayBookTempRight(Debit,Account,ColorInfo)
		Values(@OpeningBalance,'Opening Balance',101) 
	End
	Else 
	Begin
			
		Insert #DayBookTempLeft(Credit,Account,ColorInfo)
		Values(@OpeningBalance,'Opening Balance',101) 
		
		Insert #DayBookTempRight(DocumentDate,ColorInfo)
		Values(@ReportDate,1) 
	
		Insert #DayBookTempRight(Debit,Account,ColorInfo)
		Values(@OpeningBalance,'Opening Balance',101) 
	End

	Insert #DayBookTempLeft(Credit,Account,
	DocumentID,ActualID,DocumentType,ColorInfo)
	
	Select IsNull(Credit,0),AccountName,
	case when DocumentType in (26,37) then dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType)
	else dbo.GetOriginalID(DocumentReference,DocumentType) end,
	case when DocumentType in (26,37) then TransactionID else DocumentReference end,
	DocumentType,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
	from GeneralJournal,AccountsMaster
	where (TransactionDate between @ReportDate and @TempReportDate)
	and GeneralJournal.AccountID <> @CASH and
	GeneralJournal.AccountID = AccountsMaster.AccountID and
	documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 
	and isnull(status,0) <> 192 and IsNull(GeneralJournal.Credit,0) <> 0 and 
	IsNull(GeneralJournal.Debit,0) = 0
	order by TransactionDate,CreationTime,TransactionID
	
-- 	If @ReportDate = '11/06/2004' 	
-- 	select * from #DayBookTempLeft 

	Select @TotalCredit = Sum(IsNull(Credit,0)) from #DayBookTempLeft
	Set @TotalCredit = Isnull(@TotalCredit,0) 	
	
	Insert #DayBookTempRight(Debit,Account,
	DocumentID,ActualID,DocumentType,ColorInfo)
	
	Select IsNull(Debit,0),AccountName, 
	case when DocumentType in (26,37) then dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType)
	else dbo.GetOriginalID(DocumentReference,DocumentType) end,
	case when DocumentType in (26,37) then TransactionID else DocumentReference end,
	DocumentType,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
	from GeneralJournal,AccountsMaster
	where (TransactionDate between @ReportDate and @TempReportDate)
	and GeneralJournal.AccountID <> @CASH
	and GeneralJournal.AccountID = AccountsMaster.AccountID and
	documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) 
	and isnull(status,0) <> 128 and isnull(status,0) <> 192
	and IsNull(GeneralJournal.Debit,0) <> 0
	and IsNull(GeneralJournal.Credit,0) = 0
	order by TransactionDate,CreationTime,TransactionID
	
-- 	If @ReportDate = '11/06/2004' 
-- 	select * from #DayBookTempRight
	
	Select @TotalDebit =  Sum(IsNull(Debit,0)) from #DayBookTempRight
	Set @TotalDebit = Isnull(@TotalDebit,0) 	
-- 	Select @AccountBalance = IsNull(OpeningValue,0)
-- 	From AccountOpeningBalance Where AccountID = @CASH 
-- 	and dbo.stripdatefromtime(OpeningDate) = dbo.stripdatefromtime(@ReportDate)
-- 
-- 			
-- 	If @AccountBalance > 0 
-- 	Begin
-- 		Set @TotalDebit = @TotalDebit + @AccountBalance	
-- 	End
-- 	Else If @AccountBalance < 0 
-- 	Begin
-- 		Set @TotalCredit = @TotalCredit + @AccountBalance	
-- 	End

	--Select 'credit'= @TotalCredit,'debit' = @TotalDebit,@ReportDate
	--Select @TotalCredit,@TotalDebit

	If @TotalCredit > @TotalDebit
	Begin
		Insert #DayBookTempRight(Debit,Account,ColorInfo)
		Values (abs((@TotalCredit - @TotalDebit)),'Closing Balance',101)
		Set @Balance = @TotalCredit - @TotalDebit 
	End
	Else If @TotalDebit > @TotalCredit
	Begin
		Insert #DayBookTempLeft(Credit,Account,ColorInfo)
		Values (abs((@TotalDebit - @TotalCredit)),'Closing Balance',101)
		Set @Balance = @TotalDebit - @TotalCredit
	End
	
	Select @LeftCount = Count(*) from #DayBookTempLeft
	Select @RightCount = Count(*) from #DayBookTempRight
	
	
-- 	If @ReportDate = dbo.stripdatefromtime(@FromDate)
-- 	Begin
-- 		Select @OpeningBalance = IsNull(OpeningValue,0)
-- 		From AccountOpeningBalance Where AccountID = @CASH 
-- 		and dbo.stripdatefromtime(OpeningDate) = dbo.stripdatefromtime(@FromDate)
-- 
-- 		If @OpeningBalance < 0 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Credit,LAccount,
-- 			RHighLight)
-- 			Values(@FromDate,@OpeningBalance,'Opening Balance',1) 
-- 		End
-- 		Else If @OpeningBalance > 0 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Debit,RAccount,
-- 			RHighLight)
-- 			Values(@FromDate,@OpeningBalance,'Opening Balance',1) 
-- 		End
-- 		Else 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Credit,LAccount,
-- 			Debit,RHighLight)
-- 			Values(@FromDate,@OpeningBalance,'Opening Balance',
-- 			@OpeningBalance,1) 
-- 		End
-- 	End
-- 	Else
-- 	Begin
-- 		If @PrevBalance < 0 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Credit,LAccount,
-- 			RHighLight)
-- 			Values(@ReportDate,@PrevBalance,'Opening Balance',1) 
-- 		End
-- 		Else If @PrevBalance > 0 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Debit,RAccount,
-- 			RHighLight)
-- 			Values(@ReportDate,@PrevBalance,'Opening Balance',1) 
-- 		End
-- 		Else 
-- 		Begin
-- 			Insert #DayBookTemp(DocumentDate,Credit,LAccount,
-- 			Debit,RHighLight)
-- 			Values(@ReportDate,@PrevBalance,'Opening Balance',
-- 			@OpeningBalance,1) 
-- 		End
-- 	End
	
	Insert #DayBookTemp(LAccount,RHighLight)
	Values (convert(nvarchar,@ReportDate,103),1)
	
	If @LeftCount = @RightCount
	Begin
		Insert #DayBookTemp(DocumentDate,Credit,LAccount,LDocumentID,LActualID,LDocumentType,
		LHighLight,Debit,RAccount,RDocumentID,RActualID,RDocumentType,RHighLight)
		Select #DayBookTempLeft.DocumentDate,#DayBookTempLeft.Credit,#DayBookTempLeft.Account,
		#DayBookTempLeft.DocumentID,#DayBookTempLeft.ActualID,
		#DayBookTempLeft.DocumentType,#DayBookTempLeft.ColorInfo,#DayBookTempRight.Debit,
		#DayBookTempRight.Account,#DayBookTempRight.DocumentID,
		#DayBookTempRight.ActualID,#DayBookTempRight.DocumentType,
		#DayBookTempRight.ColorInfo from #DayBookTempLeft,#DayBookTempRight
		Where #DayBookTempLeft.SerialNo = #DayBookTempRight.SerialNo 
	End
	Else If @LeftCount > @RightCount
	Begin
		Insert #DayBookTemp(DocumentDate,Credit,LAccount,LDocumentID,LActualID,LDocumentType,
		LHighLight,Debit,RAccount,RDocumentID,RActualID,RDocumentType,RHighLight)
		Select #DayBookTempLeft.DocumentDate,#DayBookTempLeft.Credit,#DayBookTempLeft.Account,
		#DayBookTempLeft.DocumentID,#DayBookTempLeft.ActualID,
		#DayBookTempLeft.DocumentType,#DayBookTempLeft.ColorInfo,#DayBookTempRight.Debit,
		#DayBookTempRight.Account,#DayBookTempRight.DocumentID,
		#DayBookTempRight.ActualID,#DayBookTempRight.DocumentType,
		#DayBookTempRight.ColorInfo 
		from #DayBookTempLeft
		Left Join #DayBookTempRight on #DayBookTempLeft.SerialNo = #DayBookTempRight.SerialNo 
		--Where #DayBookTempLeft.SerialNo *= #DayBookTempRight.SerialNo 
	End
	Else If @LeftCount < @RightCount
	Begin
		Insert #DayBookTemp(DocumentDate,Credit,LAccount,LDocumentID,LActualID,LDocumentType,
		LHighLight,Debit,RAccount,RDocumentID,RActualID,RDocumentType,RHighLight)
		Select #DayBookTempLeft.DocumentDate,#DayBookTempLeft.Credit,#DayBookTempLeft.Account,
		#DayBookTempLeft.DocumentID,#DayBookTempLeft.ActualID,
		#DayBookTempLeft.DocumentType,#DayBookTempLeft.ColorInfo,#DayBookTempRight.Debit,
		#DayBookTempRight.Account,#DayBookTempRight.DocumentID,
		#DayBookTempRight.ActualID,#DayBookTempRight.DocumentType,
		#DayBookTempRight.ColorInfo 
		from #DayBookTempLeft
		Right Join #DayBookTempRight on #DayBookTempLeft.SerialNo = #DayBookTempRight.SerialNo
		--Where #DayBookTempLeft.SerialNo =* #DayBookTempRight.SerialNo 
	End


	If @TotalCredit > @TotalDebit
	Begin
		Insert #DayBookTemp(Credit,LAccount,LHighLight,Debit,RAccount,RHighLight)
		Values (@TotalCredit,'Total',1,@TotalCredit,'Total',1)	
	End
	Else If @TotalDebit > @TotalCredit
	Begin
		Insert #DayBookTemp(Credit,LAccount,LHighLight,Debit,RAccount,RHighLight)
		Values (@TotalDebit,'Total',1,@TotalDebit,'Total',1)	
	End
	Else
	Begin
		Insert #DayBookTemp(Credit,LAccount,LHighLight,Debit,RAccount,RHighLight)
		Values (@TotalDebit,'Total',1,@TotalDebit,'Total',1)	
	End

	Set @ReportDate = DateAdd(day,1,@ReportDate)
	Set @TempReportDate=DateAdd(s,0-1,(DateAdd(dd,1,@ReportDate)))
	--Delete #DayBookTempLeft
	Truncate table #DayBookTempLeft
	Truncate table #DayBookTempRight 
	--Delete #DayBookTempRight 
	Set @PrevBalance = @Balance
End
Drop Table #DayBookTempLeft
Drop Table #DayBookTempRight 

Select 'Document Date' =DocumentDate,Credit,'Account' = LAccount,
'DocumentID'= LDocumentID,LActualID,LDocumentType,LhighLight,Debit,'Account'= RAccount,
'DocumentID'= RDocumentID,RActualID,RDocumentType,RHighLight
from #DayBookTemp

Drop table #DayBookTemp

