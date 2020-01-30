
CREATE procedure sp_List_RevertStock(@InvoiceID as int)
as
select InvoiceDetail.Product_code, Batch_code, Quantity, Track_Inventory 
from InvoiceDetail, Items, ItemCategories
where InvoiceID = @InvoiceID and
InvoiceDetail.Product_Code = Items.Product_Code and
Items.CategoryID = ItemCategories.CategoryID

