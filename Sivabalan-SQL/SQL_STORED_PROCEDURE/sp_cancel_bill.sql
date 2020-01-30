CREATE PROCEDURE sp_cancel_bill(@BILL int, @Remarks nvarchar(100)= N'', @UserName nvarchar(20)= N'', @CancelDate datetime = Null)
AS
DECLARE @Status int
DECLARE @GRNID int
Declare @PaymentID Int

IF NOT EXISTS (Select BillID From BillAbstract Where BillID = @BILL)
BEGIN
	SELECT 0
	GOTO THEEND
END
SELECT @Status = Status, @GRNID = GRNID, @PaymentID = PaymentID 
From BillAbstract Where BillID = @BILL
IF @Status = 0
BEGIN	
If @PaymentID Is Not Null 
Begin
exec dbo.sp_Cancel_Payment @PaymentID
exec dbo.sp_ChangeStatus_AdjRef_BillCancel @Bill
End
	Update BillAbstract Set Status = Status | 192, Balance = 0,Remarks = @Remarks,CancelUserName = @UserName,CancelDate = @CancelDate Where BillID = @BILL
	Update GRNAbstract Set GRNStatus = GRNStatus & (~128), BillID = Null, NewBillID = Null Where GRNID = @GRNID
	If @GRNID Is Not Null Update Batch_Products Set TaxSuffered = 0 Where GRN_ID = @GRNID
	SELECT 1
END
ELSE
	SELECT 0
THEEND:


