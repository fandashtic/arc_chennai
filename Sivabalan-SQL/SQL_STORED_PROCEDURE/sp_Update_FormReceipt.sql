Create Procedure sp_Update_FormReceipt (@InvoiceID Int, @RecptForm Int, @CFormNo nvarchar(30), @DFormNo nvarchar(30))
As

Update InvoiceAbstract Set Flags = Flags | @RecptForm, CFormNo = Isnull(@CFormNo,N''), DFormNo = Isnull(@DFormNo, N'')
Where InvoiceID = @InvoiceID


