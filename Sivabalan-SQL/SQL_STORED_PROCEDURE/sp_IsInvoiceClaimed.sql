CREATE Procedure sp_IsInvoiceClaimed(@InvoiceID as int) As
-- Itembased Percentage and ItemBased Amount are Saved as Seperate item
-- with Pending = 1
-- So Claimed will be 1 whenever Pending Qty becomes Zero and it means that
--  Fully Claimed
-- Partially claim can only be for Same Free Item or Diff Free Item
-- Which is Compared with the InvoiceDetail table Free Row and Checked
-- Whether the Quantity in InvoiceDetail Matches with The Pending Quantity
-- if not then it is Partially Calimed 
Select Count(Serial) Claimed from SchemeSale 
Where 
(Claimed = 1 Or 
(Claimed = 0 and
Isnull((Select Case When Max(FlagWord) = 1 Then Sum(Quantity) - SchemeSale.Pending Else 0 End
				from InvoiceDetail 
				Where InvoiceID = SchemeSale.InvoiceID and
				Serial = Isnull(SchemeSale.Serial,0)),0) <> 0 ))
And InvoiceID = @InvoiceID

