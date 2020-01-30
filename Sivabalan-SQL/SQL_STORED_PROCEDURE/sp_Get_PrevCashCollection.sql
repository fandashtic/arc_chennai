CREATE PROCEDURE sp_Get_PrevCashCollection(@CollectionID INT)
AS    
SELECT ISNULL(SUM(Value),0) FROM Collections 
WHERE DocumentID IN (SELECT DocumentID FROM InvoiceWiseCollectionDetail 
WHERE CollectionID = @CollectionID )AND Paymentmode=0
