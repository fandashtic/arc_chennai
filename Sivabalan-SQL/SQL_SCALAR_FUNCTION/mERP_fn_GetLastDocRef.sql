Create Function mERP_fn_GetLastDocRef(@DocRef nVarchar(1000))
Returns nvarchar(200)
As
Begin
	Declare @Prefix nVarchar(100)
	Declare @TranSerialNo nvarchar(200)
	Declare @CharacterPart nvarchar(100)
	Declare @NumberPart nvarchar(100)
	Declare @MaxDocRef nVarchar(100)


	/* Get the Number and the string part */
	Select @CharacterPart = Case Isnumeric(@DocRef) when 1 then N'' else left(@DocRef,len(@DocRef)-PATINDEX(N'%[^0-9]%',Reverse(@DocRef))+1) end,
		   @NumberPart    = Case isnumeric(@DocRef) when 1 then @DocRef else ISnull(REVERSE(left(reverse(@DocRef),PATINDEX(N'%[^0-9]%',Reverse(@DocRef))-1)),0) end

	
	If (@NumberPart <> 0 And @CharacterPart <> '')
	Begin 
		Set @NumberPart = @NumberPart + 1
		Set @TranSerialNo = ''
		Set @TranSerialNo = @CharacterPart +  Cast(@NumberPart as nVarchar)	
	End
	Else if (@NumberPart = 0)
	Begin
		
		/* When there is no Number part Get the latest DocumentReference that starts with InvoicePrefix 
		and Increment it by 1 */
		SELECT @Prefix = Prefix FROM VoucherPrefix WHERE TranID = 'Invoice'
	
		/* Get the DocumentReference for the last InvoiceID */
		Select 
			Top 1 @MaxDocRef = DocReference 
		From 
			InvoiceAbstract Where DocSerialType = '' And 
			DocReference Like @Prefix + Cast('%' as nVarchar) 
		Order By 
			InvoiceID Desc
		
		/* Increment the number part by 1 */
		Select @NumberPart=case isnumeric(@MaxDocRef) when 1 then @MaxDocRef else ISnull(REVERSE(left(reverse(@MaxDocRef),PATINDEX(N'%[^0-9]%',Reverse(@MaxDocRef))-1)),0) end
		Set @NumberPart = @NumberPart + 1
		
		Set @TranSerialNo = ''
		Set @TranSerialNo = @Prefix +  Cast(@NumberPart as nVarchar)	
	End
	
	Return @TranSerialNo
End

