CREATE Procedure sp_acc_loadpaymentabstract_DocLU
 (@Mode Int,@Type Int,@FromDocID int,
 @ToDocID int,@DocumentRef nvarchar(510)=N'')        
as    
Declare @PAYMENT_TO_PARTY int    
Declare @PAYMENT_TO_EXPENSE int    
Declare @PAYMENT_TO_PARTY_EXPENSE int    
Declare @CANCEL int    
Declare @VIEW int    
Declare @PETTY_CASH int    
Declare @AMEND INT    
    
set @PAYMENT_TO_PARTY =0    
set @PAYMENT_TO_PARTY_EXPENSE =1    
set @PAYMENT_TO_EXPENSE =2    
    
Set @AMEND = 2    
set @CANCEL = 3    
set @VIEW = 4    
set @PETTY_CASH =4    

If Len(ltrim(rtrim(@DocumentRef))) = 0 
Begin
	if @mode = @CANCEL    
	begin    
 	if @type = @PAYMENT_TO_PARTY     
		begin    
			select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
			DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
			'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),
			'DocRef' = Payments.DocRef 
			from Payments     
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH     
			and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			Status,'PartyID'= isnull(Others,0), DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0 and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0   
			and Isnull(PaymentMode,0) <> 5
		   Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type = @PAYMENT_TO_PARTY_EXPENSE    
	  	begin    
			select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
			DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
			'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),
			'DocRef' = Payments.DocRef 
			from Payments     
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)<> 0     
			and (Payments.Others <> @PETTY_CASH and Isnull(paymentmode,0) <> 5)
			and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
	  	end    
	end    
	else if @mode =@VIEW    
	begin    
	  	if @type = @PAYMENT_TO_PARTY      
	 	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH 
			order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
			and Isnull(PaymentMode,0) <> 5
   			Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type =@PAYMENT_TO_PARTY_EXPENSE     
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
			and (Payments.Others <> @PETTY_CASH and Isnull(paymentmode,0) <> 5)
			order by Payments.Others    
	  	end    
	end    
	Else If @mode = @AMEND    
	begin    
	  	if @type = @PAYMENT_TO_PARTY      
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH    
			order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
			and Isnull(PaymentMode,0) <> 5 
		   	Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type =@PAYMENT_TO_PARTY_EXPENSE     
	  	begin    
		 	select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Payments.DocRef) When 1 then Cast(Payments.DocRef as int)
			end)
			between @FromDocID And @ToDocID) 
			and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
			and (Payments.Others <> @PETTY_CASH and Isnull(paymentmode,0) <> 5)
			order by Payments.Others    
	  	end    
	end 
End
else
Begin
	if @mode = @CANCEL    
	begin    
	  	if @type = @PAYMENT_TO_PARTY     
		begin    
			select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
			DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
			'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),
			'DocRef' = Payments.DocRef 
			from Payments     
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH     
			and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			Status,'PartyID'= isnull(Others,0), DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0 and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0   
			and Isnull(paymentmode,0) <> 5
	   		Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type = @PAYMENT_TO_PARTY_EXPENSE    
	  	begin    
			select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
			DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
			'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
			'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),
			'DocRef' = Payments.DocRef 
			from Payments     
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)<> 0     
			and (Payments.Others <> @PETTY_CASH  and Isnull(paymentmode,0) <> 5)
			and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
	  	end    
	end    
	else if @mode =@VIEW    
	begin    
	  	if @type = @PAYMENT_TO_PARTY      
	 	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH    
			order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
			and Isnull(paymentmode,0) <> 5
   			Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type =@PAYMENT_TO_PARTY_EXPENSE     
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
			and (Payments.Others <> @PETTY_CASH  and Isnull(paymentmode,0) <> 5)
			order by Payments.Others    
	  	end    
	end    
	Else If @mode = @AMEND    
	begin    
	  	if @type = @PAYMENT_TO_PARTY      
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
			and Payments.Others <> @PETTY_CASH    
			order by Payments.Others    
	  	end    
	  	else if @type = @PAYMENT_TO_EXPENSE    
	  	begin    
			select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
			and Isnull(paymentmode,0) <> 5
   			Order By Payments.DocumentDate,DocumentID
	  	end       
	  	else if @type =@PAYMENT_TO_PARTY_EXPENSE     
	  	begin    
		 	select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
			Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
			Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),
			'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
			from Payments 
			where 
			(
			(Payments.DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))) 
			When 1 then Cast(Substring(Payments.DocRef,Len(@DocumentRef)+1,Len(Payments.DocRef))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Payments.DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
			and (Payments.Others <> @PETTY_CASH and Isnull(paymentmode,0) <> 5)
			order by Payments.Others    
	  	end    
	end 
end

