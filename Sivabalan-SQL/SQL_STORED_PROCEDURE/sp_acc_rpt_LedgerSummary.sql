CREATE Procedure sp_acc_rpt_LedgerSummary
(
 @AccID INT,
 @FromDate DateTime,
 @ToDate DateTime,
 @DayWiseDisplay INT = 0,
 @State INT = 0
)
AS
Declare @ToDatePair DateTime
Set @ToDatePair = DateAdd(s,0-1,DateAdd(dd,1,@ToDate))
----------------------Find Out the Transactions that should not come-------------------------
Declare @INVOICE INT
Declare @INVOICEAMENDMENT INT
Declare @INVOICECANCELLATION INT
Declare @BILL INT
Declare @BILLAMENDMENT INT
Declare @BILLCANCELLATION INT
Declare @DEBITNOTE INT
Declare @DEBITNOTE_AMENDMENT INT
Declare @DEBITNOTECANCELLATION INT
Declare @CREDITNOTE INT
Declare @CREDITNOTE_AMENDMENT INT
Declare @CREDITNOTECANCELLATION INT
  
Set @INVOICE = 4
Set @INVOICEAMENDMENT = 5
Set @INVOICECANCELLATION = 6
Set @BILL = 8
Set @BILLAMENDMENT = 9
Set @BILLCANCELLATION = 10
Set @DEBITNOTE = 20
Set @DEBITNOTE_AMENDMENT = 91
Set @DEBITNOTECANCELLATION = 64
Set @CREDITNOTE = 21
Set @CREDITNOTE_AMENDMENT = 90
Set @CREDITNOTECANCELLATION = 65
 

Declare @Tmp_DocRef INT,@Tmp_DocTyp INT

CREATE Table #Temp_TranIDs_1(TranID INT) /*Table to store TransactionIDs*/


If @State = 0
 Begin
  Declare ScanGJ Cursor KeySet For
  Select DocumentReference,DocumentType From GeneralJournal 
  Where AccountID=@AccID And TransactionDate BetWeen @FromDate And @ToDatePair
  And DocumentType Not In (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
  And (IsNULL(Status,0) & 128) = 0 Order By TransactionDate
 End
Else
 Begin
  Declare ScanGJ Cursor KeySet For
  Select DocumentReference,DocumentType From GeneralJournal 
  Where AccountID=@AccID And TransactionDate BetWeen @FromDate And @ToDatePair
  And DocumentType Not In (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
  And dbo.IsClosedDocument(DocumentReference,DocumentType) = @State
  And (IsNULL(Status,0) & 128) = 0 Order By TransactionDate
 End
Open ScanGJ
Fetch From ScanGJ InTo @Tmp_DocRef,@Tmp_DocTyp
 
While @@Fetch_Status = 0
 Begin
  If @Tmp_DocTyp=@INVOICE Or @Tmp_DocTyp=@INVOICEAMENDMENT Or @Tmp_DocTyp=@INVOICECANCELLATION
   Begin
    Insert #Temp_TranIDs_1
    Select TransactionID from GeneralJournal Where AccountID = @AccID
    And DocumentReference In (Select ReferenceID from AdjustmentReference 
    Where InvoiceID = @Tmp_DocRef And TransactionType = 0 And DocumentType = 5)
    And DocumentType In(@DEBITNOTE,@DEBITNOTECANCELLATION)

    Insert #Temp_TranIDs_1
    Select TransactionID from GeneralJournal Where AccountID = @AccID
    And DocumentReference In (Select ReferenceID from AdjustmentReference 
    Where InvoiceID = @Tmp_DocRef And TransactionType = 0 And DocumentType = 2)
    And DocumentType In(@CREDITNOTE,@CREDITNOTECANCELLATION)
   End
  Else If @Tmp_DocTyp=@BILL Or @Tmp_DocTyp=@BILLAMENDMENT Or @Tmp_DocTyp=@BILLCANCELLATION
   Begin
    Insert #Temp_TranIDs_1
    Select TransactionID from GeneralJournal Where AccountID = @AccID
    And DocumentReference In (Select ReferenceID from AdjustmentReference 
    Where InvoiceID = @Tmp_DocRef And TransactionType = 1 And DocumentType = 5)
    And DocumentType In(@CREDITNOTE,@CREDITNOTECANCELLATION)

    Insert #Temp_TranIDs_1
    Select TransactionID from GeneralJournal Where AccountID = @AccID
    And DocumentReference In (Select ReferenceID from AdjustmentReference 
    Where InvoiceID = @Tmp_DocRef And TransactionType = 1 And DocumentType = 2)
    And DocumentType In(@DEBITNOTE,@DEBITNOTECANCELLATION)
   End
  Fetch Next From ScanGJ InTo @Tmp_DocRef,@Tmp_DocTyp
 End
Close ScanGJ
DeAllocate ScanGJ
---------------------------------------------------------------------------------------------
DECLARE @FIXED_AC_COUNT INT
Set @FIXED_AC_COUNT = 500

CREATE Table #Temp_TranIDs_2(TranID INT)
If @State = 0 
 Begin
  Insert Into #Temp_TranIDs_2
  Select TransactionID from GeneralJournal
  Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And AccountID Not In (Select AccountID From AccountsMaster Where AccountID < @FIXED_AC_COUNT And AccountID <> 93)
  And DocumentType In (1,2,3,4,5,6,7,8,9,10,11,12,40,41,42,54,55,66,67,68,69,70,72,73,88,89,22)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192
 End
Else
 Begin
  Insert Into #Temp_TranIDs_2
  Select TransactionID from GeneralJournal
  Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And AccountID Not In (Select AccountID From AccountsMaster Where AccountID < @FIXED_AC_COUNT And AccountID <> 93)
  And DocumentType In (1,2,3,4,5,6,7,8,9,10,11,12,40,41,42,54,55,66,67,68,69,70,72,73,88,89,22)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And dbo.IsClosedDocument(DocumentReference,DocumentType)= @State
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192
 End
---------------------------------------------------------------------------------------------
Declare @C_TD DateTime
Declare @C_DRef INT,@C_DTyp INT,@C_AcID INT,@C_Hint INT
Declare @C_Cr Decimal(18,6),@C_Dr Decimal(18,6),@C_Bal Decimal(18,6)
Declare @C_DBal nVarChar(50),@C_TrID INT,@C_Nar nVarChar(2000),@C_CInfo nVarChar(4000)
Declare @C_OID nVarChar(100),@C_FNO nVarChar(255),@C_Des nVarChar(50),@C_AcN nVarChar(255)

Declare @TranDate DateTime
Declare @DocRef INT,@DocType INT,@SumAcID INT,@Hint INT,@Count INT,@TranID INT,@Flag INT
Declare @Debit Decimal(18,6),@Credit Decimal(18,6)
Declare @Balance Decimal(18,6),@OpeningBalance Decimal(18,6),@ClosingBalance Decimal(18,6)
Declare @DocBalance nVarChar(50),@Narration nVarChar(2000),@ChqInfo nVarChar(4000)
Declare @OriginalID nVarChar(100),@FlexibleNO nVarChar(255),@Desc nVarChar(50)

CREATE TABLE #TempReport
(
 TransactionDate DateTime,
 OriginalID nVarChar(100),
 FlexibleNo nVarChar(255),
 [Description] nVarchar(50),
 AccountName nVarChar(255),
 Debit Decimal(18,6),
 Credit Decimal(18,6),
 DocRef INT,
 DocType INT,
 AccountID INT,
 Balance nVarChar(50),
 DocumentBalance nVarChar(50),
 TranID INT,
 Narration nVarchar(2000),
 ChequeInfo nVarchar(4000),
 HighLight INT
)

If Not Exists(Select * from AccountOpeningBalance Where OpeningDate=@FromDate And AccountID=@AccID)
 Select @OpeningBalance=IsNULL(OpeningBalance,0) from AccountsMaster Where AccountId=@AccID And IsNULL(Active,0)=1
Else                      
 Select @OpeningBalance=IsNULL(OpeningValue,0) from AccountOpeningBalance Where OpeningDate=@FromDate And AccountID=@AccID
                      
Insert #TempReport
Select @FromDate,'','','','Opening Balance',Case When @OpeningBalance > 0 Then @OpeningBalance Else 0 End,Case When @OpeningBalance < 0 Then ABS(@OpeningBalance) Else 0 End,'','','','','','','','',1

Set @Balance = @OpeningBalance
/* If invoice is amended with F11 adjustment, then ledger report in summary mode is showing incorrect value is addressed - SSLTT5519*/
Select * into #tmpstatezero from
  (Select 'TransactionDate' = TransactionDate,
  'OriginalID'= dbo.GetOriginalID(DocumentReference,DocumentType),
  'FlexibleNo'= dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType),
  'Description'= dbo.GetDescription(DocumentReference,DocumentType),
  'Debit'= Case When (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) > 0 
  Then (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) Else 0 End,
  'Credit'= Case When (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) < 0 
  Then ABS((IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End))) Else 0 End,
  'DocRef'=DocumentReference,'DocTyp'=DocumentType,'TranID'=Max(TransactionID),
  'AccID'= dbo.Sp_Acc_Get_SummaryAC(DocumentReference,DocumentType),
  'DocBalance'= dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,0),
  'Narration'= dbo.sp_acc_GetNarration(DocumentReference,DocumentType),
  'ChequeInfo'= dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,0),
  'Hint'= dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),'Flag' = 1
  From GeneralJournal Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And AccountID Not In (Select AccountID From AccountsMaster Where AccountID < @FIXED_AC_COUNT And AccountID <> 93)
  And DocumentType In (1,2,3,4,5,6,7,8,9,10,11,12,40,41,42,54,55,66,67,68,69,70,72,73,88,89,22)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192
  Group By DocumentReference,DocumentType,TransactionDate
  Union All
  Select 'TransactionDate' = TransactionDate,
  'OriginalID'= Case When DocumentType In (26,37) Then dbo.GetOriginalID(DocumentNumber,DocumentType) Else dbo.GetOriginalID(DocumentReference,DocumentType) End,
  'FlexibleNo'= Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End,
  'Description'= dbo.GetDescription(DocumentReference,DocumentType),
  'Debit'= Debit,'Credit'= Credit,'DocRef'=DocumentReference,'DocTyp'=DocumentType,'TranID'=TransactionID,'AccID'= AccountID,
  'DocBalance'= Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,
  'Narration'= Case When DocumentType In (26,37) Then CAST(IsNULL(Remarks,N'') As nVarChar(2000)) Else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) End,
  'ChequeInfo'= dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
  'Hint'= dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),'Flag' = 2
  From GeneralJournal Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And DocumentType Not In (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_2)
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192) T

  Select * into #tmpstateone from
 (Select 'TransactionDate' = TransactionDate,
  'OriginalID'= dbo.GetOriginalID(DocumentReference,DocumentType),
  'FlexibleNo'= dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType),
  'Description'= dbo.GetDescription(DocumentReference,DocumentType),
  'Debit'= Case When (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) > 0 
  Then (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) Else 0 End,
  'Credit'= Case When (IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End)) < 0 
  Then ABS((IsNULL(Sum(Debit-Credit),0)+ dbo.sp_acc_rpt_GetSummaryTransBalance(@AccID,DocumentReference,DocumentType,Case When IsNULL(Sum(Debit-Credit),0) > 0 Then 1 Else 2 End))) Else 0 End,
  'DocRef'=DocumentReference,'DocTyp'=DocumentType,'TranID'=Max(TransactionID),
  'AccID'= dbo.Sp_Acc_Get_SummaryAC(DocumentReference,DocumentType),
  'DocBalance'= dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,0),
  'Narration'= dbo.sp_acc_GetNarration(DocumentReference,DocumentType),
  'ChequeInfo'= dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,0),
  'Hint'= dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),'Flag' = 1
  From GeneralJournal Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And AccountID Not In (Select AccountID From AccountsMaster Where AccountID < @FIXED_AC_COUNT And AccountID <> 93)
  And DocumentType In (1,2,3,4,5,6,7,8,9,10,11,12,40,41,42,54,55,66,67,68,69,70,72,73,88,89,22)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And dbo.IsClosedDocument(DocumentReference,DocumentType)= @State
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192
  Group By DocumentReference,DocumentType,TransactionDate
  Union All
  Select 'TransactionDate' = TransactionDate,
  'OriginalID'= Case When DocumentType In (26,37) Then dbo.GetOriginalID(DocumentNumber,DocumentType) Else dbo.GetOriginalID(DocumentReference,DocumentType) End,
  'FlexibleNo'= Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End,
  'Description'= dbo.GetDescription(DocumentReference,DocumentType),
  'Debit'= Debit,'Credit'= Credit,'DocRef'=DocumentReference,'DocTyp'=DocumentType,'TranID'=TransactionID,'AccID'= AccountID,
  'DocBalance'= Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,
  'Narration'= Case When DocumentType In (26,37) Then CAST(IsNULL(Remarks,N'') As nVarChar(2000)) Else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) End,
  'ChequeInfo'= dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
  'Hint'= dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),'Flag' = 2
  From GeneralJournal Where AccountID = @AccID And TransactionDate Between @FromDate And @ToDatePair
  And DocumentType Not In (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_1)
  And TransactionID Not In (Select Distinct TranID from #Temp_TranIDs_2)
  And dbo.IsClosedDocument(DocumentReference,DocumentType)= @State
  And IsNULL(Status,0) <> 128 And IsNULL(Status,0) <> 192) T

Select * into #tmpDelete1 From
(Select OriginalID,FlexibleNo,Description,max(TranID) as TranID from #tmpstatezero
 Group by OriginalID,FlexibleNo,Description
 Having count(OriginalID)> 1 and count(FlexibleNo) > 1 and count(Description) >1
)T

Select * into #tmpDelete2 From
(Select OriginalID,FlexibleNo,Description,max(TranID) as TranID from #tmpstateone
 Group by OriginalID,FlexibleNo,Description
 Having count(OriginalID)> 1 and count(FlexibleNo) > 1 and count(Description) >1
)T
Delete from #tmpstatezero where TranID in (Select TranID from #tmpDelete1)
Drop table #tmpDelete1

Delete from #tmpstateone where TranID in (Select TranID from #tmpDelete2)
Drop table #tmpDelete2


If @State = 0
 Begin
  Declare ScanTempQuery Cursor KeySet For
  Select TransactionDate,OriginalID,FlexibleNo,[Description],
  Debit,Credit,DocRef,DocTyp,TranID,AccID,DocBalance,
  Narration,ChequeInfo,Hint,Flag From #tmpstatezero
  Order By TransactionDate
 End              
Else
 Begin
  Declare ScanTempQuery Cursor KeySet For
  Select TransactionDate,OriginalID,FlexibleNo,[Description],
  Debit,Credit,DocRef,DocTyp,TranID,AccID,DocBalance,
  Narration,ChequeInfo,Hint,Flag From #tmpstateone
  Order By TransactionDate
 End

Open ScanTempQuery
Fetch From ScanTempQuery Into @TranDate,@OriginalID,@FlexibleNO,@Desc,@Debit,@Credit,@DocRef,@DocType,@TranID,@SumAcID,@DocBalance,@Narration,@ChqInfo,@Hint,@Flag


While @@FETCH_STATUS = 0
 Begin
  If @Debit = 0
   Begin
    If @Flag = 1
     Begin
      Set @Balance=@Balance-@Credit
      Insert Into #TempReport
      Select @TranDate,@OriginalID,@FlexibleNO,@Desc,dbo.GetAccountName(@SumAcID),0,@Credit,
      @DocRef,@DocType,@SumAcID,Case When @Balance < 0 Then CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
      Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,
      @DocBalance,@TranID,@Narration,@ChqInfo,@Hint

     End
    Else
     Begin
      Select @Count=Count(*) from GeneralJournal Where TransactionID=@TranID And DocumentType = @DocType And AccountID <> @AccID And Debit<> 0
      
	  If @Count = 1 
       Begin
        Set @Balance=@Balance-@Credit

        Insert Into #TempReport
        Select TransactionDate,@OriginalID,@FlexibleNO,@Desc,AccountName,0,@Credit,
        DocumentReference,DocumentType,GJ.AccountID,Case When @Balance < 0 Then
        CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
        Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,
        @DocBalance,TransactionID,@Narration,@ChqInfo,@Hint
        From GeneralJournal GJ,AccountsMaster Where TransactionID = @TranID
        And GJ.AccountID = AccountsMaster.AccountID --And DocumentReference = @DocRef
				And GJ.AccountID Not In (Select AccountID from GeneralJournal 
				where TransactionID=@TranID and credit <> 0 and DocumentReference = @DocRef  
			  and DocumentType =@DocType) And DocumentType = @DocType And Debit <> 0 --And GJ.AccountID <> @AccID
       End
      Else If @Count > 1
       Begin

        Declare ScanCount Cursor KeySet For
        Select TransactionDate,@OriginalID,@FlexibleNO,@Desc,AccountName,Credit,Debit,
        DocumentReference,DocumentType,GJ.AccountID,(Credit-Debit),
        @DocBalance,TransactionID,@Narration,@ChqInfo,@Hint
        From GeneralJournal GJ,AccountsMaster Where TransactionID = @TranID 
        And GJ.AccountID = AccountsMaster.AccountID --And DocumentReference = @DocRef
				And GJ.AccountID Not In (Select AccountID from GeneralJournal 
				where TransactionID=@TranID and credit <> 0 and DocumentReference = @DocRef  
			  and DocumentType =@DocType) And DocumentType = @DocType And Debit <> 0 --And GJ.AccountID <> @AccID
        Open ScanCount
        Fetch From ScanCount Into @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,@C_Bal,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
        
        While @@Fetch_Status = 0
         Begin
          Set @Balance = @Balance + @C_Bal

          Insert Into #TempReport
          Select @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,
          Case When @Balance < 0 Then CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
          Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
          Fetch Next From ScanCount Into @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,@C_Bal,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
         End
        Close ScanCount
        DeAllocate ScanCount
       End
     End
   End
  Else If @Credit = 0
   Begin
    If @Flag = 1
     Begin
      Set @Balance=@Balance + @Debit
      
      Insert Into #TempReport
      Select @TranDate,@OriginalID,@FlexibleNO,@Desc,dbo.GetAccountName(@SumAcID),@Debit,0,
      @DocRef,@DocType,@SumAcID,Case When @Balance < 0 Then CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
      Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,
      @DocBalance,@TranID,@Narration,@ChqInfo,@Hint

     End
    Else
     Begin
      Select @Count=Count(*) from GeneralJournal Where TransactionID=@TranID And AccountID <> @AccID And Credit<> 0
      If @Count = 1 
       Begin
        Set @Balance=@Balance + @Debit

        Insert Into #TempReport
        Select TransactionDate,@OriginalID,@FlexibleNO,@Desc,AccountName,@Debit,0,
        DocumentReference,DocumentType,GJ.AccountID,Case When @Balance < 0 Then
        CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
        Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,
        @DocBalance,TransactionID,@Narration,@ChqInfo,@Hint
        From GeneralJournal GJ,AccountsMaster Where TransactionID = @TranID
        And GJ.AccountID = AccountsMaster.AccountID --And DocumentReference = @DocRef
				And GJ.AccountID Not In (select AccountID from generaljournal 
				where TransactionID=@TranID and debit <> 0 
				and DocumentReference = @DocRef and DocumentType =@DocType)
        And DocumentType = @DocType And Credit <> 0 --And GJ.AccountID <> @AccID
       End
      Else If @Count > 1
       Begin

        Declare ScanCount Cursor KeySet For
		-- Debit Value in Ledger report (Summary mode) not shown issue resolved 
        Select @TranDate,@OriginalID,@FlexibleNO,@Desc,AccountName,
		case DocumentType when 37 then
		Credit - (select sum(isnull(debit,0)) from GeneralJournal where transactionId=@TranId and documenttype=37 and accountid <> @accId) 
		else
		Credit
		end,
		Debit,DocumentReference,DocumentType,GJ.AccountID,
		-- Debit Value in Ledger report (Summary mode) not shown issue resolved 
		case DocumentType when 37 then
		(Credit-Debit) -(select sum(isnull(debit,0)) from GeneralJournal where transactionId=@TranId and documenttype=37 and accountid <> @accId)
		else
		(Credit-Debit)
		end,
        @DocBalance,TransactionID,@Narration,@ChqInfo,@Hint
        From GeneralJournal GJ,AccountsMaster Where TransactionID = @TranID 
        And GJ.AccountID = AccountsMaster.AccountID --And DocumentReference = @DocRef
				And GJ.AccountID Not In (select AccountID from generaljournal 
				where TransactionID=@TranID and debit <> 0 
				and DocumentReference = @DocRef and DocumentType =@DocType)
        And DocumentType = @DocType And Credit <> 0 --And GJ.AccountID <> @AccID
        Open ScanCount
        Fetch From ScanCount Into @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,@C_Bal,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
        While @@Fetch_Status = 0
         Begin
          Set @Balance = @Balance + @C_Bal
          Insert Into #TempReport
          Select @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,
          Case When @Balance < 0 Then CAST(ABS(@Balance) As nVarChar(50)) + dbo.LookupDictionaryItem('Cr',Default)
          Else CAST(@Balance as nVarChar(50)) + dbo.LookupDictionaryItem('Dr',Default) End,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
          Fetch Next From ScanCount Into @C_TD,@C_OID,@C_FNO,@C_Des,@C_AcN,@C_Cr,@C_Dr,@C_DRef,@C_DTyp,@C_AcID,@C_Bal,@C_DBal,@C_TrID,@C_Nar,@C_CInfo,@C_Hint
         End
        Close ScanCount
        DeAllocate ScanCount
       End
     End
   End
  Fetch Next From ScanTempQuery Into @TranDate,@OriginalID,@FlexibleNO,@Desc,@Debit,@Credit,@DocRef,@DocType,@TranID,@SumAcID,@DocBalance,@Narration,@ChqInfo,@Hint,@Flag
 End
Close ScanTempQuery
DeAllocate ScanTempQuery

Select @ClosingBalance = IsNULL(Sum(IsNULL(Debit,0)-IsNULL(Credit,0)),0) From #TempReport

Insert #TempReport                        
Select @ToDatePair,'','','','Total',Sum(Debit),Sum(Credit),'','','','','','','','',1 From #TempReport
                        
Insert #TempReport                        
Select @ToDatePair,'','','','Closing Balance',Case When @ClosingBalance > 0 Then @ClosingBalance Else 0 End ,Case When @ClosingBalance < 0 Then ABS(@ClosingBalance) Else 0 End,'','','','','','','','',1
If  @DayWiseDisplay = 0
 Begin            
  Select 'Document Date' = dbo.StripDateFromTime(TransactionDate),
  'Document ID' = OriginalID,'Document Reference' = FlexibleNo,
  'Description' = [Description],'Particular' = AccountName,'Debit' = Debit,'Credit' = Credit,
  'DocRef' = Case When [DocType]=37 Or ([DocType]=26 And [DocRef]=2) Then TranID Else DocRef End,
  'DocType' = DocType,'AccountID' = AccountID,'Balance' = Balance,
  'Document Balance' = DocumentBalance,'Narration' = Narration,
  'Cheque Info' = ChequeInfo,'High Light' = HighLight
  From #TempReport Order By TransactionDate
 End
Else
 Begin
  Declare @Debit_DayWise Decimal(18,6)
  Declare @Credit_DayWise Decimal(18,6)
  Declare @Temp_FromDate DateTime
  Declare @Temp_FromDate_Pair DateTime
  
  Set @Temp_FromDate = @FromDate
  Set @Temp_FromDate_Pair = DateAdd(s,0-1,DateAdd(dd,1,@Temp_FromDate))

  CREATE TABLE #TempReport_DayWise
  (
   Row_Num INT IDENTITY(1,1),
   TransactionDate DateTime,
   OriginalID nVarChar(100),
   FlexibleNo nVarChar(255),
   [Description] nVarchar(50),
   AccountName nVarChar(255),
   Debit Decimal(18,6),
   Credit Decimal(18,6),
   DocRef INT,
   DocType INT,
   AccountID INT,
   Balance nVarChar(50),
   DocumentBalance nVarChar(50),
   TranID INT,
   Narration nVarchar(2000),
   ChequeInfo nVarchar(4000),
   HighLight INT
  )  
  
  While @Temp_FromDate <= @ToDate
   Begin
    If (Select Count(*) from #TempReport Where TransactionDate Between @Temp_FromDate And @Temp_FromDate_Pair) > 0
     Begin
      Insert Into #TempReport_DayWise(TransactionDate,OriginalID,FlexibleNo,[Description],AccountName,
      Debit,Credit,DocRef,DocType,AccountID,Balance,DocumentBalance,TranID,Narration,ChequeInfo,HighLight)
      Select TransactionDate,OriginalID,FlexibleNo,[Description],AccountName,Debit,Credit,
      DocRef,DocType,AccountID,Balance,DocumentBalance,TranID,Narration,ChequeInfo,HighLight
      From #TempReport Where TransactionDate BetWeen @Temp_FromDate And @Temp_FromDate_Pair
      And LTrim(RTrim(AccountName)) Not In (N'Total',N'Closing Balance')
      Order By TransactionDate
      
      Set @Debit_DayWise = 0
      Set @Credit_DayWise = 0
      Select @Debit_DayWise = Sum(IsNULL(Debit,0)),@Credit_DayWise=Sum(IsNULL(Credit,0))
      From #TempReport_DayWise Where TransactionDate BetWeen @Temp_FromDate And @Temp_FromDate_Pair
      
      If @Credit_DayWise > @Debit_DayWise
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',@Credit_DayWise-@Debit_DayWise,0,1)
         
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',@Credit_DayWise,@Credit_DayWise,1)
        
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',0,@Credit_DayWise-@Debit_DayWise,1)
         End
       End
      Else If @Credit_DayWise < @Debit_DayWise
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',0,@Debit_DayWise-@Credit_DayWise,1)
       
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',@Debit_DayWise,@Debit_DayWise,1)
       
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',@Debit_DayWise-@Credit_DayWise,0,1)
         End
       End
      Else
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',0,0,1)
       
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',0,0,1)
        
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',0,0,1)
         End
       End
  End
    Else
     Begin
      Set @Debit_DayWise = 0
      Set @Credit_DayWise = 0
      Select @Debit_DayWise = Sum(IsNULL(Debit,0)),@Credit_DayWise=Sum(IsNULL(Credit,0))
      From #TempReport_DayWise Where TransactionDate BetWeen @Temp_FromDate And @Temp_FromDate_Pair

      If @Credit_DayWise > @Debit_DayWise
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',@Credit_DayWise-@Debit_DayWise,0,1)
         
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',@Credit_DayWise,@Credit_DayWise,1)
        
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',0,@Credit_DayWise-@Debit_DayWise,1)
         End
       End
      Else If @Credit_DayWise < @Debit_DayWise
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',0,@Debit_DayWise-@Credit_DayWise,1)
       
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',@Debit_DayWise,@Debit_DayWise,1)
       
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',@Debit_DayWise-@Credit_DayWise,0,1)
         End
       End
      Else
       Begin
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Closing Balance',0,0,1)
       
        Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
        Values(@Temp_FromDate_Pair,'Total',0,0,1)
        
        If @ToDate <> @Temp_FromDate
         Begin
          Insert Into #TempReport_DayWise(TransactionDate,[Description],Debit,Credit,HighLight)
          Values(DateAdd(dd,1,@Temp_FromDate),'Opening Balance',0,0,1)
         End
       End
     End
    Set @Temp_FromDate = DateAdd(dd,1,@Temp_FromDate)
    Set @Temp_FromDate_Pair = DateAdd(s,0-1,DateAdd(dd,1,@Temp_FromDate))
   End
   
  Update #TempReport_DayWise Set TransactionDate = NULL Where LTrim(RTrim([Description])) In (N'Total',N'Closing Balance')
  Update #TempReport_DayWise Set [Description] = AccountName,AccountName = NULL Where Row_Num = 1

  Select 'Document Date' = dbo.StripDateFromTime(TransactionDate),
  'Document ID' = IsNULL(OriginalID,''),'Document Reference' = IsNULL(FlexibleNo,''),
  'Description' = [Description],'Particular' = IsNULL(AccountName,''),'Debit' = Debit,'Credit' = Credit,
  'DocRef' = Case When [DocType]=37 Or ([DocType]=26 And [DocRef]=2) Then IsNULL(TranID,0) Else IsNULL(DocRef,0) End,
  'DocType' = IsNULL(DocType,0),'AccountID' = IsNULL(AccountID,0),'Balance' = IsNULL(Balance,''),
  'Document Balance' = IsNULL(DocumentBalance,''),'Narration' = IsNULL(Narration,''),
  'Cheque Info' = IsNULL(ChequeInfo,''),'High Light' = HighLight
  From #TempReport_DayWise Order By Row_Num

  Drop Table #TempReport_DayWise
 End
Drop Table #TempReport
Drop Table #Temp_TranIDs_1
Drop Table #Temp_TranIDs_2
Drop table #tmpstatezero
Drop table #tmpstateone
