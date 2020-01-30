CREATE Procedure mERP_sp_getMerchandise(@CustID nVarChar(50))
As
Begin
Select MerchandiseID from CustMerchandise where CustomerID = @CustID
End
