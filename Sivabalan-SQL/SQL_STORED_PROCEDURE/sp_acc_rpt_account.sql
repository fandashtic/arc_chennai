CREATE Procedure sp_acc_rpt_account(@FromDate datetime,@ToDate datetime,@AccountID Int,@State Int=0,@TBType nvarchar(50) = null)              
As              
Declare @TRANID INT              
Declare @AccountCode INT              
Declare @AccountName nVarchar(30)              
Declare @DEBIT decimal(18,6)              
Declare @CREDIT decimal(18,6)              
Declare @OriginalID nvarchar(15)              
Declare @Description nvarchar(50)              
Declare @RefNumber nvarchar(50)              
Declare @DocType int              
Declare @OpeningBalance Decimal(18,6)              
Declare @Count INT              
Declare @SPECIALCASE int              
Declare @Narration nvarchar(2000)    
Declare @ChequeInfo nVarchar(4000)    
Declare @HIGHLIGHT Int              
Declare @Balance decimal(18,6)              
Declare @DocBalance nVarChar(50)  
Declare @DocReference nVarChar(255) 
            
if isnumeric(@TBType) = 0     
 begin    
  set @TBType = 0    
 end    
    
DECLARE @ToDatePair datetime            
SET @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))            
              
SET @SPECIALCASE =4              
SET @HIGHLIGHT=1              
--              
Declare @f1 datetime              
Declare @f2 nvarchar(15)              
Declare @f3 nVarChar(255)
Declare @f4 nvarchar(50)              
Declare @f5 nvarchar(255)              
Declare @f6 datetime              
Declare @f7 datetime              
Declare @f8 nvarchar(50)              
Declare @f9 int              
Declare @f10 int              
Declare @f11 decimal(18,6)              
Declare @f12 decimal(18,6)              
Declare @f13 int              
Declare @f14 decimal(18,6)              
Declare @f15 nVarChar(50)
Declare @f16 int              
Declare @f17 nvarchar(2000)    
Declare @f18 nvarchar(255)    
Declare @f19 int              
--              
set dateformat dmy    
Create table #TempReport(TransactionDate datetime, OriginalID nvarchar(15), DocumentReference nVarChar(255), Type nVarchar(50),
AccountName nvarchar(255),FromDate datetime,ToDate datetime,DocRef int,DocType int,ColorInfoParam int,              
Debit decimal(18,6),Credit decimal(18,6),AccountID int,Balance nvarchar(50), DocumentBalance nVarChar(50), TranID int,Narration nvarchar(2000),ChequeInfo nvarchar(255),HighLight int)              
              
If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID)              
Begin              
 Select @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId = @AccountID -- and Active=1              
End              
Else              
Begin               
 set @OpeningBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID),0)              
End              
              
if @TBType = 0     
 Begin    
  Insert #tempreport              
  Select @fromdate,'','','',dbo.lookupdictionaryitem('Opening Balance',Default),@fromdate,@todate,'','','',              
  case when @OpeningBalance > 0 then @OpeningBalance else 0 end ,              
  case when @OpeningBalance  < 0 then abs(@OpeningBalance) else 0 end,'','','','','','',@HIGHLIGHT               
  Set @Balance=@OpeningBalance              
 End    
If @State=0      
 Begin      
   Declare ScanJournal Cursor Keyset For              
   Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then               
   dbo.GetOriginalID(DocumentNumber,DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,              
   dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,    
   case when DocumentType in (26,37) then Isnull(Remarks,N'') else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end, dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
   Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,  
   Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End  
   from GeneralJournal where GeneralJournal.AccountID=@AccountID and               
   [TransactionDate] between @FromDate and @ToDatePair and             
   documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and               
   isnull(status,0) <> 128 and isnull(status,0) <> 192 order by TransactionDate              
   Open ScanJournal              
   Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@DocType,@Narration,@ChequeInfo,@DocBalance,@DocReference
 End      
Else      
 Begin      
  Declare ScanJournal Cursor Keyset For              
  Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then               
  dbo.GetOriginalID(DocumentNumber,DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,              
  dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,    
  case when DocumentType in (26,37) then Isnull(Remarks,N'') else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end, dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
  Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,  
  Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End  
  from GeneralJournal where GeneralJournal.AccountID=@AccountID and               
  [TransactionDate] between @FromDate and @ToDatePair and             
  dbo.IsClosedDocument(DocumentReference,DocumentType)=@State and      
  documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and               
  isnull(status,0) <> 128 and isnull(status,0) <> 192 order by TransactionDate              
  Open ScanJournal              
  Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@DocType,@Narration,@ChequeInfo,@DocBalance,@DocReference  
 End      
      
While @@Fetch_Status=0              
Begin              
 If @Debit=0              
 Begin              
  If @DocType=37 or @DocType=26 --for all manual journal dont check document reference              
  Begin              
   Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in              
   (select AccountID from generaljournal where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
   and TransactionID=@TranID and DocumentType =@DocType and Debit<>0              
  End              
  Else              
  Begin              
   Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in              
   (select AccountID from generaljournal where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
   and TransactionID=@TranID and DocumentReference = @RefNumber and DocumentType =@DocType and Debit<>0              
  End              
              
  if @Count=1              
  Begin              
   Set @Balance=isnull(@Balance,0)-@Credit              
   insert into #TempReport              
   Select TransactionDate,@OriginalID,@DocReference,@Description,              
   AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,0,@Credit,              
   GeneralJournal.AccountID,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,
   @DocBalance,@TranID,@Narration,@ChequeInfo,dbo.GetDynamicSetting(DocumentType,DocumentReference)              
   from GeneralJournal,AccountsMaster where               
   GeneralJournal.AccountID not in(select AccountID from generaljournal               
   where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
   and GeneralJournal.AccountID = AccountsMaster.AccountID and               
   TransactionID=@TranID and Debit<>0 and DocumentType = @doctype              
  End              
  Else If @Count>1              
  Begin              
   Declare ScanCount Cursor Keyset For              
   Select TransactionDate,@OriginalID,@DocReference,@Description,              
   AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,Credit,              
   Debit ,GeneralJournal.AccountID,(Credit-Debit),@DocBalance,@TranID,@Narration,@ChequeInfo,dbo.GetDynamicSetting(DocumentType,DocumentReference)               
   from GeneralJournal,AccountsMaster where               
   GeneralJournal.AccountID not in(select AccountID from generaljournal               
   where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)              
   and GeneralJournal.AccountID = AccountsMaster.AccountID and               
   TransactionID=@TranID and Debit<>0 and DocumentType = @doctype              
   Open ScanCount              
   Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16,@f17,@f18,@f19
   while @@Fetch_Status=0              
   Begin              
    Set @Balance=isnull(@Balance,0) + @f14              
    insert into #TempReport              
    Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,@f15,@f16,@f17,@f18,@f19
                    
    Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16,@f17,@f18,@f19
   End              
   Close ScanCount              
   Deallocate ScanCount              
  End              
 End              
 Else if @credit=0               
 Begin              
  If @DocType=37 or @DocType=26 --for manual journal old reference dont check document reference              
  Begin              
   Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in               
   (select AccountID from generaljournal where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
   and TransactionID=@TranID and DocumentType =@DocType and credit<>0              
  End              
  Else              
  Begin              
    Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in               
    (select AccountID from generaljournal where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
    and TransactionID=@TranID and DocumentReference = @RefNumber and DocumentType =@DocType and credit<>0              
  End              
  If @Count=1              
  Begin              
   Set @Balance=isnull(@Balance,0)+@Debit              
   insert into #TempReport              
   Select TransactionDate,@OriginalID,@DocReference,@Description,              
   AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,              
   @Debit,0,GeneralJournal.AccountID,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,
   @DocBalance,@TranID,@Narration,@ChequeInfo,dbo.GetDynamicSetting(DocumentType,DocumentReference)              
   from GeneralJournal,AccountsMaster where GeneralJournal.AccountID               
   not in(select AccountID from generaljournal where TransactionID=@TranID              
   and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and               
   GeneralJournal.AccountID = AccountsMaster.AccountID and               
   TransactionID=@TranID and Credit<>0 and DocumentType = @doctype              
  End              
  Else if @Count>1              
  Begin              
   --to calculate balance for each transaction              
   Declare ScanCount Cursor Keyset For              
   Select TransactionDate,@OriginalID,@DocReference,@Description,              
   AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,Credit,              
   Debit, GeneralJournal.AccountID,(Credit-Debit),@DocBalance,@TranID,@Narration,@ChequeInfo,              
   dbo.GetDynamicSetting(DocumentType,DocumentReference) from GeneralJournal,AccountsMaster where               
   GeneralJournal.AccountID not in(select AccountID from generaljournal               
   where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)              
   and GeneralJournal.AccountID = AccountsMaster.AccountID               
   and TransactionID=@TranID and DocumentType = @doctype and credit<>0--and Debit=0              
   Open ScanCount              
   Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16,@f17,@f18,@f19
   while @@Fetch_Status=0              
   Begin              
    Set @Balance=isnull(@Balance,0) + @f14              
    insert into #TempReport              
    Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,@f15,@f16,@f17,@f18,@f19
                    
    Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16,@f17,@f18,@f19
   End              
   Close ScanCount              
   Deallocate ScanCount              
  End              
 End              
 Fetch Next From scanJournal into @TranID, @Debit, @Credit,@OriginalID,@Description, @RefNumber,@DocType,@Narration,@ChequeInfo,@DocBalance,@DocReference
End              
Close ScanJournal              
Deallocate ScanJournal              
              
Declare @ClosingBalance Decimal(18,6)              
Set @ClosingBalance=(Select sum(isnull(Debit,0)-isnull(Credit,0)) from #TempReport)              
              
Insert #TempReport              
Select @ToDatePair ,'','','',dbo.lookupdictionaryitem('Total',Default),'','','','','',sum(Debit) ,sum(Credit),'','','','','','',@HIGHLIGHT from #Tempreport              
              
Insert #TempReport              
Select @ToDatePair ,'','','',dbo.lookupdictionaryitem('Closing Balance',Default),'','','','','',              
case when isnull(@ClosingBalance,0) > 0 then isnull(@ClosingBalance,0) else 0 end ,              
case when isnull(@ClosingBalance,0)  < 0 then abs(isnull(@ClosingBalance,0)) else 0 end,              
'','','','','','',@HIGHLIGHT              
              
Select 'Date'=dbo.StripDateFromTime(TransactionDate),'Transaction ID'=OriginalID,
'Document Reference'=DocumentReference,'Description'=Type,'AccountID'=AccountID,Fromdate,Todate,              
'DocRef'= case when [DocType]=37 or([DocType]=26 and [DocRef]= 2) then TranID else DocRef end,'DocType'=DocType,ColorInfoParam,'Particular'=AccountName,              
'Debit'=Debit,'Credit'=Credit,'Balance'=Balance,'Document Balance'=DocumentBalance,'Narration' = Narration,'Cheque Info' = ChequeInfo,'High Light'=HighLight from #TempReport order by TransactionDate              
Drop table #TempReport

