CREATE PROCEDURE mERP_sp_update_GRNBillInfo(@GRNID Int, @BillNo Int, @BillDocID Int)
AS

Update GRNAbstract set GRNStatus = GRNStatus | 128, BillID = @BillNo, NewBillID = @BillDocID
Where GRNID = @GRNID

If (Select len(Ltrim(GRNID)) From BillAbstract Where BillID = @BillNo) = 0
	Update BillAbstract Set GRNID = Cast(@GRNID As nVarchar) Where BillID = @BillNo
Else
	Update BillAbstract Set GRNID = GRNID + ',' + Cast(@GRNID As nVarchar) Where BillID = @BillNo

