CREATE Procedure sp_update_Payment_Adjustment (	@BillID Int,
						@AdjustedRef nvarchar(255),
						@AdjustedAmount Decimal(18,6),
						@PaymentID Int)
As
Update BillAbstract Set AdjRef = @AdjustedRef, AdjustedAmount = @AdjustedAmount,
PaymentID = @PaymentID Where BillID = @BillID
