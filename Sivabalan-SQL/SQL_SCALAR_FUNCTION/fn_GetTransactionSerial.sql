CREATE Function fn_GetTransactionSerial(@TranType int,@DocType nvarchar(100),@Cnt int=-1)
Returns nvarchar(200)
as
Begin
	
	Declare @TranSerialNo nvarchar(200)
	Declare @LastCnt int
	Declare @GenTranNo int
	Declare @CharacterPart nvarchar(100)
	Declare @NumberPart nvarchar(100)


	If (@Cnt=-1)
		Begin
			Select @CharacterPart=Case Isnumeric(documentnumber) when 1 then N'' else left(documentnumber,len(documentnumber)-PATINDEX(N'%[^0-9]%',Reverse(documentnumber))+1) end,
				   @NumberPart=case isnumeric(documentnumber) when 1 then documentnumber else ISnull(REVERSE(left(reverse(documentnumber),PATINDEX(N'%[^0-9]%',Reverse(documentnumber))-1)),0) end,
				   @LastCnt=LastCount from TransactionDocNumber Where TransactionDocNumber.TransactionType=@TranType
				   And	 TransactionDocNumber.DocumentType=@DocType			
		End
	Else
		Begin
				   Select @CharacterPart=case isnumeric(documentnumber) when 1 then N'' else left(documentnumber,len(documentnumber)-PATINDEX(N'%[^0-9]%',Reverse(documentnumber))+1) end,
				   @NumberPart=case isnumeric(documentnumber) when 1 then documentnumber else ISnull(REVERSE(left(reverse(documentnumber),PATINDEX(N'%[^0-9]%',Reverse(documentnumber))-1)),0) end
				   from TransactionDocNumber Where TransactionDocNumber.TransactionType=@TranType
				   And	 TransactionDocNumber.DocumentType=@DocType				

				   Select @LastCnt=@Cnt				
		End

	if (@NumberPart <> 0)
			Select @GenTranNo=Cast(@NumberPart as int) + @LastCnt
	Else
			Select @GenTranNo=@LastCnt + 1


	if  Len(@GenTranNo) <= Len(@NumberPart)
	begin
			Select @TranSerialNo=@CharacterPart + Stuff(@NumberPart,Len(@NumberPart)-Len(@GenTranNo)+ 1,Len(@GenTranNo),@GenTranNo)
	End
	Else
	begin
			Select @TranSerialNo=@CharacterPArt + CAST(@GenTranNo AS nvarchar)
	End
	
	RETURN(@TranSerialNo)


End











