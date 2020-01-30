CREATE Procedure Sp_Get_BatchExist (@Itemcode NVarchar(15))As
DECLARE @BatchCount INT
SELECT @BatchCount = Count(Batch_Code) FROM Batch_Products WHERE Product_Code = @Itemcode 
and IsNull(DocType, 0) <> 6 
If (@BatchCount = 0) -- only open stk exist it has to verify for qty received and qty
SELECT @BatchCount = Count(Batch_Code) FROM Batch_Products WHERE Product_Code =  @Itemcode
And Quantity <> QuantityReceived

SELECT @BatchCount


