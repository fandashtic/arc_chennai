
Create Procedure sp_Validate_SalesmanGroup(@InvNo int)
As
Begin
Declare @SalesmanID int, @GroupID int
Select @SalesmanID=SalesmanID, @GroupID=GroupID From InvoiceAbstract where InvoiceID=@InvNo
Select Count(*) From DSHandle Where SalesmanID=@SalesmanID And GroupID=@GroupID
End
