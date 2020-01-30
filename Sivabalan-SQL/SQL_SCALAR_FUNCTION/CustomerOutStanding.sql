CREATE Function CustomerOutStanding (@Customer nvarchar(15))
Returns float
as
Begin
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
where CustomerID = @Customer and Balance > 0 and InvoiceType in (1, 3) and 
Status & 128 = 0

select @SRBalance = sum(Balance) from InvoiceAbstract
where CustomerID = @Customer and Balance > 0 and Status & 128 = 0 and
InvoiceType = 4

set @Balance = isnull(@INVBalance, 0) + isnull(@DBBalance, 0) 
	       - isnull(@CLBalance, 0) - isnull(@CRBalance, 0) - isnull(@SRBalance, 0)  
		

Return @Balance
End

