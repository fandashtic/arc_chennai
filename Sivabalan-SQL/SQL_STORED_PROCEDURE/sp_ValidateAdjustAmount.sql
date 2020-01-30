
Create Procedure sp_ValidateAdjustAmount
(
	@ParentTranID nvarchar(50),
	@TranID int,
	@TranType int,
	@DocBal decimal(18,6),
	@DocAdj decimal(18,6),
	@AdjAmt decimal(18,6),
	@TotAdj decimal(18,6),
	@netaddr as nVarchar(100)
)
As
Begin
Declare @Status as int, @TempAmt as decimal(18,6), @Str as nVarchar(1000)

If @AdjAmt > @DocBal									-- Adjusted in #TempAdjust in popup should not be > Outstanding amount in parent
	Set @Status = 1										-- Don't allow to adjust
Else
Begin
	If (@TotAdj + @DocAdj) > @DocBal					-- Total adjusted amount in popup + collected amount in parent should not be > Outstanding amount in parent
		Set @Status = 1									-- Don't allow to adjust
	Else
		Set @Status = 0									-- Allow to adjust
End

Select @Status

End
