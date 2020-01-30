
CREATE Function mERP_fn_GetCGOutstandingBalance(@CustomerID nVarchar(255), @GroupID int, @InvoiceID Int)  
	Returns Decimal(18,6)
As
Begin
	Declare @Balance as Decimal(18,6)  
	Declare @CLBalance as Decimal(18,6)  
	Declare @CRBalance as Decimal(18,6)  
	Declare @DBBalance as Decimal(18,6)  
	Declare @INVBalance as Decimal(18,6)  
	Declare @SRBalance as Decimal(18,6)  
	
	Select @CLBalance = Sum(Balance) From Collections   
	Where CustomerID = @CustomerID And Balance > 0  
	
	Select @CRBalance = Sum(Balance) From CreditNote  
	Where CustomerID = @CustomerID And Balance > 0  
	
	Select @DBBalance = Sum(Balance) From DebitNote  
	Where CustomerID = @CustomerID And Balance > 0  
	
--	select @INVBalance = sum(Balance) from InvoiceAbstract  
--	where CustomerID = @Customer and GroupID = @Group  and Balance > 0 and InvoiceType in (1, 3) and   
--	Status & 128 = 0  

	Select @INVBalance = IsNull(Sum(ID.Amount/IA.NetValue*IA.Balance), 0) 
		From InvoiceAbstract IA, InvoiceDetail ID
		Where IA.CustomerID = @CustomerID 
		And IA.InvoiceID = ID.InvoiceID
		And ID.GroupID = @GroupID
		--And GroupID = @Group  
		And IA.Balance > 0 
		And IA.InvoiceType In (1, 3) 
		And IA.Status & 128 = 0  
		And IA.InvoiceID <> @InvoiceID

	Select @SRBalance = IsNull(Sum(ID.Amount/IA.NetValue*IA.Balance), 0) 
		From InvoiceAbstract IA, InvoiceDetail ID  
		Where IA.CustomerID = @CustomerID 
		And IA.InvoiceID = ID.InvoiceID
		And ID.GroupID = @GroupID
		--And GroupID = @GroupID 
		And IA.Balance > 0 
		And IA.Status & 128 = 0 
		And IA.InvoiceType = 4  
		And IA.InvoiceID <> @InvoiceID
	
	Set @Balance = IsNull(@CLBalance, 0) + IsNull(@CRBalance, 0) + IsNull(@SRBalance, 0) -   
	IsNull(@DBBalance, 0) - IsNull(@INVBalance, 0)  
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') and   
	OBJECTPROPERTY(id, N'IsTable') = 1)  
	Begin  
		Declare @SERBalance As Decimal(18,6)  
		Select @SERBalance = Sum(Balance) From ServiceInvoiceAbstract  
		Where CustomerID = @CustomerID And Balance > 0 And Isnull(Status, 0) & 128 = 0  
		Set @Balance =  @Balance - Isnull(@SERBalance, 0)   
	End  

	Return @Balance  
End

