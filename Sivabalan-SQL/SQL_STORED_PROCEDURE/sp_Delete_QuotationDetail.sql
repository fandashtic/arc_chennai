Create PROCEDURE sp_Delete_QuotationDetail(@QuotationID INT)      
AS
Begin      
	DELETE FROM [QuotationItems] WHERE QuotationID = @QuotationID      
	DELETE FROM [QuotationMfrCategory] WHERE QuotationID = @QuotationID      
	DELETE FROM [QuotationUniversal] WHERE QuotationID = @QuotationID      
	DELETE FROM [QuotationCustomers] WHERE QuotationID = @QuotationID      
	DELETE FROM [QuotationMfrCategory_LeafLevel] where  QuotationID = @QuotationID 
End
