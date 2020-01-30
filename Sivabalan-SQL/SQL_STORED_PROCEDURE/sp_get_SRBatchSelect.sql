CREATE PROCEDURE sp_get_SRBatchSelect(@PRODUCT_CODE nvarchar(15), @InvoiceId int = 0,@SerialNo int = 0)
AS
Begin

Create Table #TmpInvBatch (Product_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch_Code int)

IF Exists(Select 'x' From InvoiceAbstract Where InvoiceID = @InvoiceID and isnull(Status,0) & 16 <> 0)
Insert Into #TmpInvBatch(Product_Code, Batch_Code)
Select ID.Product_Code, VD.Batch_Code From InvoiceDetail ID
Inner Join VanStatementDetail VD ON ID.Batch_Code = VD.ID and ID.Product_Code = VD.Product_Code
Where ID.InvoiceID = @InvoiceId and ID.Product_Code = @PRODUCT_CODE
and ID.Serial = @SerialNo
Else
Insert Into #TmpInvBatch(Product_Code, Batch_Code)
Select Product_Code ,Batch_Code From InvoiceDetail Where InvoiceID = @InvoiceId and Product_Code = @PRODUCT_CODE
and Serial = @SerialNo


IF ((select COUNT(B.Batch_code) from Batch_Products B join #TmpInvBatch T ON B.Product_Code = T.Product_Code and B.Batch_Code =T.Batch_Code ) =0)
Select 0
Else
Select 1

Drop Table #TmpInvBatch
End
