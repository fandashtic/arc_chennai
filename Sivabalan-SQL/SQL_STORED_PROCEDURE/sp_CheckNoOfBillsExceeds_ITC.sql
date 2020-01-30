
Create Procedure sp_CheckNoOfBillsExceeds_ITC
	(@SalesmanID int, @BeatID int, @CustomerID nvarchar(30), @GroupID int)
As
Begin
	Declare @GroupInvoiceLimit int
	Declare @Flag int, @InvoiceLimit int 

	If @GroupId < 1
	Begin
		Set @Flag = 0
		GoTo Done
	End
	Select @InvoiceLimit = dbo.fn_get_CustomerInvoiceLimit_ITC(@CustomerID, @GroupID )
	Select @GroupInvoiceLimit = NoOfBills From CustomerCreditLimit Where CustomerID = @CustomerID And GroupID = @GroupID
	If (@InvoiceLimit >= @GroupInvoiceLimit) And (@GroupInvoiceLimit > -1)
		Set @Flag = 1 --Exceeds
	Else
		Set @Flag = 0

Done: 
	Select @Flag
End	
