CREATE Procedure Sp_Acc_Get_PaymentID (@Fulldocid Int,@DocReference nVarchar(510))  
as  
Declare @PETTY_CASH int 
set @PETTY_CASH =4 
If isnull(@Fulldocid,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select DocumentID from Payments   
	Where dbo.GetTrueVal(FullDocID) =  @Fulldocid  
	and isnull(DocRef,N'') = @DocReference  
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)  
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))  
	and isnull(others,0) <> @PETTY_CASH and Isnull(Paymentmode,0) <> 5
End
Else if isnull(@Fulldocid,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) = N''
Begin
	Select DocumentID from Payments   
	Where dbo.GetTrueVal(FullDocID) =  @Fulldocid  
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)  
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))  
	and isnull(others,0) <> @PETTY_CASH and Isnull(Paymentmode,0) <> 5
End
Else if isnull(@Fulldocid,0) = 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select DocumentID from Payments   
	Where isnull(DocRef,N'') = @DocReference  
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)  
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))  
	and isnull(others,0) <> @PETTY_CASH and Isnull(Paymentmode,0) <> 5
End





