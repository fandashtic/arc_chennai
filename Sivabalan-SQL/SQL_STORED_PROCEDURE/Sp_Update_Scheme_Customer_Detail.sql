CREATE Procedure Sp_Update_Scheme_Customer_Detail
(@Schemeid int,@CustomerID nvarchar(255),@CreditId int,@SaleValue Decimal(18,6)=-1)
As
if (@SaleValue =-1)
Begin
	Update SchemeCustomers	Set CreditNote=@CreditId Where SchemeId=@SchemeId And CustomerID=@CustomerId
End
Else
Begin
	Update SchemeCustomers	Set CreditNote=@CreditId , AllotedAmount =@SaleValue Where SchemeId=@SchemeId And CustomerID=@CustomerId
End







