CREATE PROCEDURE mERP_get_RecdInvInfo(@GRNBillID Int,@Flag Int)
AS

Declare @RecdInvID Int

If @Flag = 1
Begin
	Select @RecdInvID = Max(RecdInvoiceID) From GRNAbstract Where BillID = @GRNBillID
End
Else If @Flag = 2
Begin
	Select @RecdInvID = Max(RecdInvoiceID) From GRNAbstract Where GRNID = @GRNBillID
End

If IsNull(@RecdInvID,0) > 0
Begin
	Select InvoiceID , InvoiceDate, DocumentID, NetValue,
	"RecedInvStatus" = (Case When IsNull(Status,0) & 1 <> 0 Then 'Closed' When IsNull(Status,0) & 32 <> 0 Then 'Partial' Else 'Open' End),
	"Tax Type" = IsNull(TaxType,1)
	,"GSTFlag"=GSTFlag ,"StateType"=StateType ,"FromStateCode"=FromStateCode ,"ToStateCode"=ToStateCode ,"GSTIN"=GSTIN 	
	,"ODNumber" = ODNumber
	From InvoiceAbstractReceived Where InvoiceID = @RecdInvID
End
Else
Begin
Select "InvoiceID" = 0
End
