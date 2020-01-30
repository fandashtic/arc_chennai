CREATE Procedure sp_han_Save_SOAbstract
(
@SODate DateTime,@DeliveryDate DateTime,@CustomerID NVarChar (15),@Value Decimal(18,6),
@POReference NVarChar(255),@BillAddress NVarChar(255),@ShipAddress NVarChar(255),
@Status Int,@CreditTerm Int,@PODocReference NVarChar(255),@IsAmEnd Int = 0,@SORef Int = 0,
@SalesmanID Int = 0,@BeatID Int = 0,@IsSIDFromDB Int = -1,@VATTaxAmount Decimal(18,6) = 0,
@GroupID nVarchar(1000) = NULL,@ForumSC Int ,@SuperVisorID Int = 0,@RefNumber NVarChar(255)
)
AS
DECLARE @DocumentID Int
If exists ( select POReference from Soabstract where POReference = @POReference and GroupID = @GroupID and forumsc = 0 )
begin
    Select -1, -1
    Goto IfSOAlreadyExists
end

If @IsSIDFromDB = -1
Begin
Select @SalesmanID = ISNULL((Select SalesmanID From Beat_Salesman Where CustomerID = @CustomerID), 0)
End
If (@IsAmEnd=0)
Begin
Begin Tran
Update DocumentNumbers SET DocumentID = DocumentID + 1 Where DocType = 2
Select @DocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 2
Commit Tran
End
Else
Begin
Select @DocumentID=DocumentID From SoAbstract Where SoNumber=@SORef
End

Insert Into SOAbstract
(
SODate,DeliveryDate,CustomerID,Value,POReference,BillingAddress,ShippingAddress,Status,
CreditTerm,DocumentID,PODocReference,SalesmanID,SoRef,BeatID,VatTaxAmount,GroupID,
ForumSC,SupervisorID
)
Values
(
@SODate,@DeliveryDate,@CustomerID,@Value,@POReference,@BillAddress,@ShipAddress,@Status,
@CreditTerm,@DocumentID,@RefNumber,@SalesmanID,@SORef,@BeatID,@VATTaxAmount,@GroupID,
@ForumSC,@SuperVisorID
)
Select @@Identity, @DocumentID

IfSOAlreadyExists:

