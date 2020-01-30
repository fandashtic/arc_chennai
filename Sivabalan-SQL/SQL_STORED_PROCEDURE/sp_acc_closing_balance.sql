CREATE Procedure sp_acc_closing_balance(@FromDate datetime,@ToDate datetime,@AccountID Int,@State Int,@ClBal Decimal(18,6) Output)
As              
Declare @TRANID INT              
Declare @DEBIT decimal(18,6)              
Declare @CREDIT decimal(18,6)              
Declare @RefNumber nvarchar(50)              
Declare @DocType int              
Declare @OpeningBalance Decimal(18,6)              
Declare @Count INT              
Declare @Balance decimal(18,6)              
Declare @f1 decimal(18,6)
Declare @f2 decimal(18,6)
Declare @f3 decimal(18,6)
           
DECLARE @ToDatePair datetime            
SET @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))            
              
set dateformat dmy    
Create table #TempReport(
Debit decimal(18,6),Credit decimal(18,6),Balance nvarchar(50))
              
If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID)              
Begin              
 	Select @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster 
	where AccountId = @AccountID -- and Active=1              
End              
Else              
Begin               
 	set @OpeningBalance= isnull((Select OpeningValue from AccountOpeningBalance 
	where OpeningDate=@fromdate and AccountID = @AccountID),0)              
End              
Insert #tempreport
Select case when @OpeningBalance > 0 then @OpeningBalance else 0 end ,              
case when @OpeningBalance  < 0 then abs(@OpeningBalance) else 0 end,0
Set @Balance=@OpeningBalance              

If @State=0      
	Begin      
		Declare ScanJournal Cursor Keyset For              
		Select TransactionID,Debit,Credit ,
		DocumentReference,DocumentType
		from GeneralJournal where GeneralJournal.AccountID=@AccountID and               
		[TransactionDate] between @FromDate and @ToDatePair and             
		documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and               
		isnull(status,0) <> 128 and isnull(status,0) <> 192 order by TransactionDate              
		Open ScanJournal              
		Fetch From ScanJournal Into @TranID,@Debit,@Credit, @RefNumber,@DocType
 	End      
Else      
 	Begin      
		Declare ScanJournal Cursor Keyset For              
		Select TransactionID,Debit,Credit ,
		DocumentReference,DocumentType
		from GeneralJournal where GeneralJournal.AccountID=@AccountID and               
		[TransactionDate] between @FromDate and @ToDatePair and             
		dbo.IsClosedDocument(DocumentReference,DocumentType)=@State and      
		documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and               
		isnull(status,0) <> 128 and isnull(status,0) <> 192 order by TransactionDate              
		Open ScanJournal              
		Fetch From ScanJournal Into @TranID,@Debit,@Credit, @RefNumber,@DocType
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
			Set @Balance=isnull(@Balance,0)- isnull(@Credit,0)
			Insert into #TempReport              
			Select 0,@Credit,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + N'Cr' else cast(@Balance as nvarchar(50)) + N'Dr' end
			from GeneralJournal,AccountsMaster where               
			GeneralJournal.AccountID not in(select AccountID from generaljournal               
			where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)               
			and GeneralJournal.AccountID = AccountsMaster.AccountID and               
			TransactionID=@TranID and Debit<>0 and DocumentType = @doctype              
	  	End              
	  	Else If @Count>1              
	  	Begin              
		   	Declare ScanCount Cursor Keyset For              
		   	Select Debit,Credit,(Credit-Debit)
		   	from GeneralJournal,AccountsMaster where               
		   	GeneralJournal.AccountID not in(select AccountID from generaljournal               
		   	where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)              
		   	and GeneralJournal.AccountID = AccountsMaster.AccountID and               
		   	TransactionID=@TranID and Debit<>0 and DocumentType = @doctype              
	   		Open ScanCount              
	   		Fetch From ScanCount Into @f1,@f2,@f3
	   		while @@Fetch_Status=0              
	   		Begin              
				Set @Balance=isnull(@Balance,0) + isnull(@f3,0)
				insert into #TempReport              
				Select @f1,@f2,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + N'Cr' else cast(@Balance as nvarchar(50)) + N'Dr' end
	                    
	    		Fetch Next From ScanCount Into @f1,@f2,@f3
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
   			Set @Balance=isnull(@Balance,0)+isnull(@Debit,0)
		   	insert into #TempReport              
		   	Select 0,@Credit,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + N'Cr' else cast(@Balance as nvarchar(50)) + N'Dr' end
		   	from GeneralJournal,AccountsMaster where GeneralJournal.AccountID               
		   	not in(select AccountID from generaljournal where TransactionID=@TranID              
		   	and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and               
		   	GeneralJournal.AccountID = AccountsMaster.AccountID and               
		   	TransactionID=@TranID and Credit<>0 and DocumentType = @doctype              
  		End              
  		Else if @Count>1              
  		Begin              
		   	Declare ScanCount Cursor Keyset For              
		   	Select Debit,Credit,(Credit-Debit)
		   	from GeneralJournal,AccountsMaster where               
		   	GeneralJournal.AccountID not in(select AccountID from generaljournal               
		   	where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)              
		   	and GeneralJournal.AccountID = AccountsMaster.AccountID               
		   	and TransactionID=@TranID and DocumentType = @doctype and credit<>0--and Debit=0              
   			Open ScanCount              
   			Fetch From ScanCount Into @f1,@f2,@f3
   			while @@Fetch_Status=0              
   			Begin              
				Set @Balance=isnull(@Balance,0) + isnull(@f3,0)
				insert into #TempReport              
				Select @f1,@f2,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + N'Cr' else cast(@Balance as nvarchar(50)) + N'Dr' end
    			Fetch Next From ScanCount Into @f1,@f2,@f3
   			End              
			Close ScanCount              
			Deallocate ScanCount              
  		End              
 	End              
 	Fetch Next From scanJournal into @TranID,@Debit,@Credit, @RefNumber,@DocType
End              
Close ScanJournal              
Deallocate ScanJournal              

Declare @ClosingBalance Decimal(18,6)              
Set @ClosingBalance=(Select sum(isnull(Debit,0)-isnull(Credit,0)) from #TempReport)              
set @ClBal = @ClosingBalance


