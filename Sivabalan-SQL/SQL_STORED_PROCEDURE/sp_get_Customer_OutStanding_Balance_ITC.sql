
CREATE procedure sp_get_Customer_OutStanding_Balance_ITC (@Customer nvarchar(15), @Group int)  
as  
	declare @Balance as Decimal(18,6)  
	declare @CLBalance as Decimal(18,6)  
	declare @CRBalance as Decimal(18,6)  
	declare @DBBalance as Decimal(18,6)  
	declare @INVBalance as Decimal(18,6)  
	declare @SRBalance as Decimal(18,6)  
	
	select @CLBalance = sum(Balance) from Collections   
	where CustomerID = @Customer and Balance > 0  
	
	select @CRBalance = sum(Balance) from CreditNote  
	where CustomerID = @Customer and Balance > 0  
	
	select @DBBalance = sum(Balance) from DebitNote  
	where CustomerID = @Customer and Balance > 0  
	
	select @INVBalance = sum(Balance) from InvoiceAbstract  
	where CustomerID = @Customer and GroupID = @Group  and Balance > 0 and InvoiceType in (1, 3) and   
	Status & 128 = 0  
	
	
	select @SRBalance = sum(Balance) from InvoiceAbstract  
	where CustomerID = @Customer and GroupID = @Group and Balance > 0 and Status & 128 = 0 and  
	InvoiceType = 4  
	
	set @Balance = isnull(@CLBalance, 0) + isnull(@CRBalance, 0) + isnull(@SRBalance, 0) -   
	isnull(@DBBalance, 0) - isnull(@INVBalance, 0)  
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') and   
	OBJECTPROPERTY(id, N'IsTable') = 1)  
	begin  
	declare @SERBalance as Decimal(18,6)  
	select @SERBalance = sum(Balance) from ServiceInvoiceAbstract  
	where CustomerID = @Customer and Balance > 0 and Isnull(Status, 0) & 128 = 0  
	set @Balance =  @Balance - Isnull(@SERBalance, 0)   
	end  
	select @Balance  
	

