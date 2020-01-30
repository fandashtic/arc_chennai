Create function dbo.merp_fn_Get_InvSchemeValue(@InvoiceID int=0,@Product_Code nvarchar(50)=null,@Serial int=0)
Returns decimal(18,6)
As
Begin 
Declare @InvSchemeAmount as decimal(18,6)
Declare @InvPercentage as decimal(18,6) 
If @InvoiceID > 0  and @Product_Code<>''
Begin
    select @InvPercentage=SchemeDiscountPercentage from InvoiceAbstract where  InvoiceID=@InvoiceID
    select @InvSchemeAmount=sum((((Quantity * SalePrice)- discountValue) * @InvPercentage/100)) from InvoiceDetail 
    where InvoiceID=@InvoiceID and Product_Code=@Product_Code
    and Serial=@Serial 
    and FlagWord=0 
End
Return @InvSchemeAmount
End
