CREATE Procedure sp_ser_checkimplicitcollection(@CollectionID as int ) 
as 
Declare @Result as int 
Set @Result = 0
/* checks for Implicit collection */
If Exists(Select * from ServiceInvoiceAbstract 
Inner Join Collections C On (Case when ServiceInvoiceAbstract.PaymentMode > 0 then 
PaymentDetails else 0 end) = C.DocumentID
Where C.DocumentID = @CollectionID)
begin	Set @Result = 1 end

Select @Result



