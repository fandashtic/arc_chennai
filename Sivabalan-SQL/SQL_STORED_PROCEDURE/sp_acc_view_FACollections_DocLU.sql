CREATE Procedure sp_acc_view_FACollections_DocLU
(@Mode Int,@Type Int,@FromDocID int,
 @ToDocID int,@DocumentRef nvarchar(510)=N'')        
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
        
If Len(ltrim(rtrim(@DocumentRef))) = 0 
Begin
 	If @Mode=@VIEW        
 	Begin        
  		If @Type=@OTHERS1         
  		Begin         
		   	select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
			Collections.DocReference         
		   	from Collections, AccountsMaster        
		   	where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) 
			and AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 
		   	order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@OTHERS2        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) 
			and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@EXPENSE        
  		Begin        
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,
			RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0         
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
 	End        
 	Else If @Mode = @AMENDMENT        
  	Begin        
   		If @Type=@OTHERS1        
    	Begin         
     		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID,         
     		Collections.DocReference 
			from Collections, AccountsMaster        
     		where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0         
     		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    	End        
   		Else If @Type=@OTHERS2        
    	Begin         
     		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
     		where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 
     		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    	End        
   		Else If @Type=@EXPENSE        
     	Begin        
      		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID,         
      		Collections.DocReference 
			from Collections, AccountsMaster  
      		where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0
      		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
     	End          
  	End        
 	Else IF @Mode=@CANCEL         
 	Begin        
  		If @Type=@OTHERS1        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
   			Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@OTHERS2        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
   			from Collections, AccountsMaster
   			where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@EXPENSE        
  		Begin        
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
  			Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
			OR 
			(Case Isnumeric(Collections.DocReference) When 1 then Cast(Collections.DocReference as int)
			end)
			between @FromDocID And @ToDocID) and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
 	End        
End        
else
Begin
 	If @Mode=@VIEW        
 	Begin        
  		If @Type=@OTHERS1         
  		Begin         
		   	select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
			Collections.DocReference         
		   	from Collections, AccountsMaster        
		   	where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 
		   	order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@OTHERS2        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@EXPENSE        
  		Begin        
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,
			RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0         
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
 	End        
 	Else If @Mode = @AMENDMENT        
  	Begin        
   		If @Type=@OTHERS1        
    	Begin         
     		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID,         
     		Collections.DocReference 
			from Collections, AccountsMaster        
     		where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0         
     		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    	End        
   		Else If @Type=@OTHERS2        
    	Begin         
     		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
			from Collections, AccountsMaster        
     		where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 
     		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
    	End        
   		Else If @Type=@EXPENSE        
     	Begin        
      		select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID,         
      		Collections.DocReference 
			from Collections, AccountsMaster  
      		where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0
      		order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
     	End          
  	End        
 	Else IF @Mode=@CANCEL         
 	Begin        
  		If @Type=@OTHERS1        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
   			Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) = 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@OTHERS2        
  		Begin         
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,
			dbo.getaccountname(ExpenseAccount),RefDocID, Collections.DocReference 
   			from Collections, AccountsMaster
   			where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=Others and ISNULL(ExpenseAccount,0) <> 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
  		Else If @Type=@EXPENSE        
  		Begin        
   			select AccountsMaster.AccountName,AccountsMaster.AccountID, FullDocID, 
			Collections.DocumentDate,Value, DocumentID, Balance, Status,Null,RefDocID, 
  			Collections.DocReference 
			from Collections, AccountsMaster        
   			where 
			(
			(Collections.DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'
			and (
			Case ISnumeric(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))) 
			When 1 then Cast(Substring(Collections.DocReference,Len(@DocumentRef)+1,Len(Collections.DocReference))as int)End) 
			BETWEEN @FromDocID AND @ToDocID)
			or 
			(Collections.DocReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
			)
			and
			AccountsMaster.AccountID=ExpenseAccount and ISNULL(Others,0) = 0 and        
   (IsNULL(OtherDepositID,0) = 0 And (Select Count(*) from Coupon Where Coupon.CollectionID = Collections.DocumentID And Coupon.CouponDepositID <> 0) = 0) and
   (IsNull(Status, 0) & 192) = 0 And (IsNull(Status, 0) = 0 Or (IsNull(Status, 0) & 2)<>0)
   			order by AccountsMaster.AccountName,AccountsMaster.AccountID, Collections.DocumentDate        
  		End        
 	End        
End

