Create Function GetCustomerOutStanding_DOS(@InvNo Int) 
Returns Varchar(250)
as  
Begin

declare @Result as nVarchar(250)
declare @Customer as nVarchar(15)
declare @Balance as Decimal(18,2)  
declare @CLBalance as Decimal(18,6)  
declare @CRBalance as Decimal(18,6)  
declare @DBBalance as Decimal(18,6)  
declare @INVBalance as Decimal(18,6)  
declare @SRBalance as Decimal(18,6)
declare @ChequeNumber as int
declare @ChequeonHand as decimal(18,2)

declare @NoOfOpenInvoice int



Select @Customer = CustomerID from InvoiceAbstract where InvoiceID=@InvNo

Select @NoOfOpenInvoice= Isnull(count(InvoiceID),0) from InvoiceAbstract  Where CustomerID =@Customer and IsNull(status,0) & 128 = 0 and IsNull(Balance,0) > 0  and InvoiceType <>4

Select @ChequeNumber=Count(isnull(C.ChequeNumber,0)), 
@ChequeonHand=isnull(sum(isnull(C.Value,0)),0) from Collections C   
Where C.CustomerID=@Customer and isnull(C.PaymentMode,0) = 1 
and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(1,2,3) 
  
select @CLBalance = sum(Balance) from Collections where CustomerID = @Customer and Balance > 0  
select @CRBalance = sum(Balance) from CreditNote where CustomerID = @Customer and Balance > 0  
select @DBBalance = sum(Balance) from DebitNote where CustomerID = @Customer and Balance > 0  

select @INVBalance = sum(Balance) from InvoiceAbstract where CustomerID = @Customer and 
Balance > 0 and InvoiceType in (1, 3) and Status & 128 = 0  
    
select @SRBalance = sum(Balance) from InvoiceAbstract where CustomerID = @Customer and 
Balance > 0 and Status & 128 = 0 and  InvoiceType = 4  
  
set @Balance = (isnull(@DBBalance, 0) + isnull(@INVBalance, 0)) - 
               (isnull(@CLBalance, 0) + isnull(@CRBalance, 0) + isnull(@SRBalance, 0))  
   
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') and   
OBJECTPROPERTY(id, N'IsTable') = 1)  
begin  
	declare @SERBalance as Decimal(18,6)  
	select @SERBalance = sum(Balance) from ServiceInvoiceAbstract  
	where CustomerID = @Customer and Balance > 0 and Isnull(Status, 0) & 128 = 0  
	set @Balance =  @Balance - Isnull(@SERBalance, 0)   
	
end
	
	set @Result = Isnull(@Result,'') --+ '|' + Replicate('-',55) + '|' + ';'
									 + '|Open Inv : ' + cast(@NoOfOpenInvoice as nvarchar(20)) + Space(3-len(@NoOfOpenInvoice))     
									 + '|Outstanding : ' + cast(@Balance as nvarchar(20)) + Space(11-len(@Balance))	+ '|'	+ ';'
									 + '|No.ofChq : ' + cast(@ChequeNumber as nvarchar(20)) + Space(3-len(@ChequeNumber))										 
									 + '|Chq in Hand : ' + cast(@ChequeonHand as nvarchar(20)) + Space(11-len(@ChequeonHand))	+ '|'	+ ';'	                                 
									 --+ '|' + Replicate('-',35) + '|' + ';'
	Return @Result
End
