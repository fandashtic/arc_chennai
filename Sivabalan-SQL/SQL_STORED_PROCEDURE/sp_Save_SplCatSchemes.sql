Create Proc sp_Save_SplCatSchemes(@InvoiceID Int,@SchemeID Int,@ProductCode Nvarchar(15))
As
Insert Into SplCatSchemes Values (@InvoiceID,@SchemeID,@ProductCode)
