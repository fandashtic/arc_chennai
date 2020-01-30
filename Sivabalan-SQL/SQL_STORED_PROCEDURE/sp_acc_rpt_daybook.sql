CREATE Procedure sp_acc_rpt_daybook(@fromdate datetime,@todate datetime,@State Int=0)          
as          
Create Table #TempDayBook     
(RowNum Integer Identity(1,1),TransactionDate Datetime, DocumentID nVarchar(255),DocumentSerial nVarchar(255),Description nVarchar(255),    
Particular nvarchar(255),Debit Decimal(18,6),Credit Decimal(18,6),DocumentReference Int,    
DocumentType Int,InternalNarration ntext,Narration nVarchar(2000),TranID Int,ColorInfo Int)    
SET @todate = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
If @State=0      
 Begin      
  Insert Into #TempDayBook (TransactionDate,DocumentID,DocumentSerial,Description,
  Particular,Debit,Credit,DocumentReference,DocumentType,InternalNarration,Narration,TranID,ColorInfo) 
  Select 'Document Date'= dbo.StripDateFromTime(TransactionDate),          
  'DocumentID'= case when DocumentType in (26,37) then dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType)          
  else dbo.GetOriginalID(DocumentReference,DocumentType) end,          
  'Document Serial'=Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End,      
  'Description'=dbo.GetDescription(DocumentReference,DocumentType),'Particular'=AccountName,          
  Debit,Credit,'Document Reference' = case when DocumentType in (26,37) then TransactionID           
  else DocumentReference end,DocumentType,'Internal Remarks' =Remarks,    
  'Narration' = case when DocumentType in (26,37) then Isnull(Remarks,N'') --dbo.sp_acc_GetNarration(isnull(DocumentNumber,0),DocumentType)  
  else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end, TranID = TransactionID,          
  'ColorInfo'=dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)          
  from GeneralJournal,AccountsMaster          
  where TransactionDate between @fromdate and @todate          
  and GeneralJournal.AccountID = AccountsMaster.AccountID and          
  documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128           
  and isnull(status,0) <> 192           
  order by TransactionDate,CreationTime,TransactionID       
 End      
Else      
 Begin      
  Insert Into #TempDayBook (TransactionDate,DocumentID,DocumentSerial,Description,
  Particular,Debit,Credit,DocumentReference,DocumentType,InternalNarration,Narration,TranID,ColorInfo)
  Select 'Document Date'= dbo.StripDateFromTime(TransactionDate),          
  'DocumentID'= case when DocumentType in (26,37) then dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType)          
  else dbo.GetOriginalID(DocumentReference,DocumentType) end,          
  'Document Serial'=Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End,      
  'Description'=dbo.GetDescription(DocumentReference,DocumentType),'Particular'=AccountName,          
  Debit,Credit,'Document Reference' = case when DocumentType in (26,37) then TransactionID           
  else DocumentReference end,DocumentType,'Internal Remarks' =Remarks,    
  'Narration' = case when DocumentType in (26,37) then Isnull(Remarks,N'') --dbo.sp_acc_GetNarration(isnull(DocumentNumber,0),DocumentType)  
  else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end,TranID = TransactionID,    
  'ColorInfo'=dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)          
  from GeneralJournal,AccountsMaster          
  where TransactionDate between @fromdate and @todate          
  and GeneralJournal.AccountID = AccountsMaster.AccountID and          
  dbo.IsClosedDocument(DocumentReference,DocumentType)=@State and      
  documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128           
  and isnull(status,0) <> 192           
  order by TransactionDate,CreationTime,TransactionID       
 End      
 
Declare @LastDate Datetime    
Set @LastDate = dbo.StripDateFromTime(@todate)    
Insert Into #TempDayBook (TransactionDate,DocumentID,DocumentSerial,Description,
  Particular,Debit,Credit,DocumentReference,DocumentType,InternalNarration,Narration,TranID,ColorInfo)
Select @LastDate,'','','','Total',Sum(Debit),Sum(Credit),'','','','','',1 from #TempDayBook    
    
Select 'Document Date' = TransactionDate,'DocumentID' = DocumentID,'Document Reference' = DocumentSerial,'Description' = Description,    
'Particular' = Particular,Debit,Credit,'Document Reference' = DocumentReference,DocumentType,    
'Internal Remarks' = InternalNarration,Narration,TranID,'ColorInfo' = ColorInfo From #TempDayBook    
Order by RowNum
Drop Table #TempDayBook 



