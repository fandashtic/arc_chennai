
CREATE procedure sp_get_billdetail
                 (@GRNID INTEGER)
AS
Select batch_products.Product_Code,items.Productname, 
Batch_Products.Batch_Number,batch_Products.Expiry,batch_products.batch_Code,batch_products.QuantityReceived,
Items.Track_Batches,Batch_Products.PurchasePrice
from Items,Batch_Products where Items.Product_Code=batch_Products.Product_Code 
and batch_Products.GRN_ID=@GRNID

