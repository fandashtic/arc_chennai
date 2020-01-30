CREATE Procedure sp_acc_view_FACollections(@Mode Int,@Type Int,@AccountID nvarchar(15),        
       @FromDate datetime,        
       @ToDate datetime)        
as        
Declare @VIEW Int,@CANCEL Int        
Declare @AMENDMENT Int        
Set @AMENDMENT = 1        
Set @CANCEL = 2        
Set @VIEW = 3        
        
Declare @OTHERS1 Int,@OTHERS2 Int,@EXPENSE Int        
Set @OTHERS1=0        
Set @OTHERS2=1        
Set @EXPENSE=2        
        
If @AccountID=0        
Begin        
 If @Mode=@VIEW        
 Begin        
  If @Type=@OTHERS1         
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@OTHERS2        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@EXPENSE        
  Begin        
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
 End        
 Else If @Mode = @AMENDMENT        
  Begin        
   If @Type=@OTHERS1        
    Begin         
     select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
     Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
     where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 and        
     Collections.DocumentDate between @FromDate and @ToDate  
     order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    End        
   Else If @Type=@OTHERS2        
    Begin         
     select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
     Value, DocumentID, Balance, Status,dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
     where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 and        
     Collections.DocumentDate between @FromDate and @ToDate   
     order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    End        
   Else If @Type=@EXPENSE        
     Begin        
      select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
      Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
      where AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0 and        
      Collections.DocumentDate between @FromDate and @ToDate  
      order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
     End          
  End        
 Else IF @Mode=@CANCEL         
 Begin        
  If @Type=@OTHERS1        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@OTHERS2        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@EXPENSE        
  Begin        
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
 End        
End        
Else         
Begin        
 If @Mode=@VIEW        
 Begin        
  If @Type=@OTHERS1         
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@OTHERS2        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status, dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) <> 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@EXPENSE        
  Begin        
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status,Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=ExpenseAccount and ExpenseAccount=@AccountID and ISNULL(Others,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate         
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
 End        
 Else If @Mode = @AMENDMENT        
  Begin        
   If @Type=@OTHERS1        
    Begin         
     select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
     Value, DocumentID, Balance, Status, Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
     where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) = 0 and        
     Collections.DocumentDate between @FromDate and @ToDate   
     order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    End        
   Else If @Type=@OTHERS2        
    Begin         
     select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
     Value, DocumentID, Balance, Status, dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
     where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) <> 0 and        
     Collections.DocumentDate between @FromDate and @ToDate   
     order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    End        
   Else If @Type=@EXPENSE        
    Begin        
     select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
     Value, DocumentID, Balance, Status, Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
     where AccountsMaster.AccountID=ExpenseAccount and ExpenseAccount=@AccountID and ISNULL(Others,0) = 0 and        
     Collections.DocumentDate between @FromDate and @ToDate   
     order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    End        
  End        
 Else If @Mode=@CANCEL        
 Begin        
  If @Type=@OTHERS1        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status, Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@OTHERS2        
  Begin         
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status, dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=Others and Others=@AccountID and ISNULL(ExpenseAccount,0) <> 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
  Else If @Type=@EXPENSE        
  Begin        
   select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, Collections.DocumentDate,         
   Value, DocumentID, Balance, Status, Null,RefDocID, Collections.DocReference from Collections, AccountsMaster        
   where AccountsMaster.AccountID=ExpenseAccount and ExpenseAccount=@AccountID and ISNULL(Others,0) = 0 and        
   Collections.DocumentDate between @FromDate and @ToDate and        
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  End        
 End        
End        
/*        
Declare @CASH Int,@CHEQUEINHAND Int,@ALL Int        
Set @CASH=3        
Set @CHEQUEINHAND=7        
Set @ALL=0        
Create table #Temp(AccountName varchar(250),AccountID Integer,CollectionID varchar(50),DocumentDate datetime,        
  Value decimal(18,6),PaymentMode integer,Status integer,DocumentID integer)        
If @AccountID=@CASH or @AccountID=@CHEQUEINHAND        
Begin        
 Insert #Temp        
 select AccountsMaster.AccountName, Accountsmaster.AccountID, Collections.FullDocID, Collections.DocumentDate,         
 Value,PaymentMode,Status, Collections.DocumentID        
 from Collections, Accountsmaster        
 where Collections.CustomerID is null and        
 Collections.DocumentDate between @FromDate and @ToDate         
 and AccountsMaster.AccountID=@AccountID        
 order by AccountsMaster.AccountName, Collections.DocumentDate        
End        
Else if @AccountID=0        
Begin        
        
 Insert #Temp        
 select AccountsMaster.AccountName, Accountsmaster.AccountID, Collections.FullDocID, Collections.DocumentDate,         
 Value,PaymentMode,Status, Collections.DocumentID        
 from Collections, Accountsmaster        
 where Collections.CustomerID is null and        
 Collections.DocumentDate between @FromDate and @ToDate         
 and AccountsMaster.AccountID in (case when Paymentmode=0 then @CASH Else @CHEQUEINHAND END)        
 order by AccountsMaster.AccountName, Collections.DocumentDate        
        
 Insert #Temp        
 Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,        
 CollectionDetail.AdjustedAmount,PaymentMode,Status,Collections.DocumentID        
 from Collections,CollectionDetail,AccountsMaster where Collections.CustomerID is Null and         
 --Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)        
 Collections.DocumentID=CollectionDetail.CollectionID and CollectionDetail.Others is not null        
 and Collections.DocumentDate between @FromDate and @ToDate         
 and AccountsMaster.AccountID=CollectionDetail.Others        
 order by AccountsMaster.AccountName, Collections.DocumentDate        
        
--Select 'All Accounts'        
End        
Else         
Begin        
 Insert #Temp        
 Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,        
 CollectionDetail.AdjustedAmount,PaymentMode,Status,Collections.DocumentID        
 from Collections,CollectionDetail,AccountsMaster where Collections.CustomerID is Null and         
 --Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)        
 Collections.DocumentID=CollectionDetail.CollectionID and CollectionDetail.Others=@AccountID        
 and Collections.DocumentDate between @FromDate and @ToDate         
 and AccountsMaster.AccountID=CollectionDetail.Others        
 order by AccountsMaster.AccountName, Collections.DocumentDate        
         
End        
Select * from #temp order by AccountName,DocumentDate        
Drop Table #Temp        
*/
