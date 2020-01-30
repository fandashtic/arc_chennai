Create PROCEDURE sp_Insert_QuotationCustomers(@QuotationID INT, @CustomerID nVarchar(50),@SplTaxApplicable Int = 0)  
AS  
If not exists(Select CustomerID From QuotationCustomers Where QuotationID=@QuotationID
And CustomerID=@CustomerID)
Begin
INSERT INTO [QuotationCustomers](QuotationID, CustomerID,SpecialTaxApplicable) Values(@QuotationID, @CustomerID,@SplTaxApplicable)  
End
