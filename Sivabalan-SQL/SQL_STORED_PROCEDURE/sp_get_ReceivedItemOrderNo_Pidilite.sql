CREATE procedure sp_get_ReceivedItemOrderNo_Pidilite
(
@GRNID Int,
@ProductCode nvarchar(20),
@Serial int,
@UomID int
) 
As
Select ReceInvItemOrder from batch_Products
Where Grn_ID = @GrnID and  Product_Code = @ProductCode And Serial = @Serial And
UOM = @UOMID

