Create Procedure sp_Get_AmendCancelInvoiceIDToo(@InvoiceID  nVarchar(Max))
As
Begin
    Declare @cnt as integer	
    Declare @incr as integer	
    Declare @InvID AS Integer	
    Create Table #tmpInv(IDS INT Identity(1,1),InvoiceID Int)			
    Create Table #tmpInvoiceID(IDS INT Identity(1,1),InvoiceID Int)		
    Create Table #tmpFinalInv(InvID Int)
    Set @incr = 1	
    Insert InTo #tmpInv Select * From sp_SplitIn2Rows(@InvoiceID,N',')  
    Insert InTo #tmpInvoiceID(InvoiceID) Select InvoiceID From #tmpInv Order By IDS Desc
    Select @cnt = Count(*) From #tmpInvoiceID
    While @incr <= @cnt
    Begin
	Select @InvID = InvoiceID From #tmpInvoiceID Where IDS = @incr
	--Inserts Open Invoices
	Insert Into #tmpFinalInv(InvID) Values (@InvID)
	--Inserts the corresponding Amended Invoices for the above inserted open invoice
	Insert Into #tmpFinalInv(InvID) 
	Select InvoiceID From InvoiceAbstract Where DocumentID In(Select DocumentID From InvoiceAbstract Where Invoiceid = @InvID)
	And IsNull(Status,0) & 128 <> 0 Order By InvoiceID 
	set @incr = @incr + 1 	
    End		 			
    Select * from #tmpFinalInv
    Drop Table #tmpInvoiceID
    Drop Table #tmpInv
    Drop Table #tmpFinalInv
End
