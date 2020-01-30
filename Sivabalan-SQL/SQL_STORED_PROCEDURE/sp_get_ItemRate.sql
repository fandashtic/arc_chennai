
Create proc sp_get_ItemRate
            (@BILLID INT,
             @ITEMCODE NVARCHAR (15))
AS
Select  Quantity,PurchasePrice from billDetail where billDetail.billID=@billID and BillDetail.Product_Code=@ITEMCODE


