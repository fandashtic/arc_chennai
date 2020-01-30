
CREATE Procedure sp_get_BatchQty
                 (@ITEMCODE NVARCHAR (15),
                  @BATCHNUMBER NVARCHAR (255),
                  @BATCHTRACK INT,
                  @PURCHASEPRICE Decimal(18,6))
AS
if @BATCHTRACK =1 
Begin
    Select sum(Quantity) from Batch_Products where Product_Code=@ITEMCODE and Batch_Number=@BATCHNUMBER and PurchasePrice=@PURCHASEPRICE
End

Else
begin
        Select sum(Quantity) from Batch_Products where Product_Code=@ITEMCODE and PurchasePrice=@PURCHASEPRICE
end


