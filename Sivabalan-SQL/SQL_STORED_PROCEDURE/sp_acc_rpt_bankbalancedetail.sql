CREATE Procedure sp_acc_rpt_bankbalancedetail(@BankAccountID Int,@PostDate dateTime)
As
Declare @LastBalance as Decimal(18,6)
Declare @BankBalance as Decimal(18,6)
Declare @ChequeinHand as Decimal(18,6)
Declare @ChequeIssued as Decimal(18,6)
Declare @Currentdate as DateTime
Declare @MaxPostDated as DateTime
Declare @LoopDate as DateTime
Set @Currentdate=dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@CurrentDate and AccountID =@BankAccountID)
Begin
	Select @LastBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@BankAccountID
End
Else
Begin	
	set @LastBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate=@CurrentDate and AccountID=@BankAccountID),0)
End
set @BankBalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal 
where dbo.stripdatefromtime([TransactionDate]) = @CurrentDate and AccountID=@BankAccountID 
and 
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63)),0)
set @BankBalance=@BankBalance + @LastBalance

Set @MaxPostDated=(Select Max(Cheque_Date) from Payments where dbo.StripDatefromTime(Cheque_Date)>@Currentdate and (Status & 192) <> 192)
If dbo.stripdatefromtime(@MaxPostDated) > @PostDate 
--Begin
	Set @LoopDate =dbo.stripdatefromtime(@MaxPostDated)
--End
Else
--Begin
	Set @LoopDate =@PostDate 
--End

While @CurrentDate<=@LoopDate
Begin
	If @Currentdate > dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
	Begin
		Set @ChequeinHand=isnull((Select sum(Value) from collections 
		where dbo.stripdatefromtime(chequeDate) =@CurrentDate
		and (isnull(DepositID,0)=0) and PaymentMode>0  and ((Status & 192) <> 192)),0)
	End

	Set @ChequeIssued=isnull((Select sum(Value) from Payments 
	where dbo.stripdatefromtime(cheque_Date) = @CurrentDate and
	PaymentMode>0 and BankID=(Select BankID from Bank where AccountID=@BankAccountID)  and ((Status & 192) <> 192)),0)

	Select 'Date'=@CurrentDate,'Current Bank balance'=@BankBalance,'PDC Collected'=@ChequeinHand,
	'PDC Issued'=@ChequeIssued,'Projected Bank Balance'=@BankBalance + (@ChequeinHand-@ChequeIssued)
	
	Set @BankBalance=@BankBalance + (@ChequeinHand-@ChequeIssued)
	Set @CurrentDate=DateAdd(day,1,@CurrentDate)
End

