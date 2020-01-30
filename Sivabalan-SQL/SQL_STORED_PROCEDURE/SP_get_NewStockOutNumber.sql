CREATE PROCEDURE SP_get_NewStockOutNumber    
AS    
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 34

