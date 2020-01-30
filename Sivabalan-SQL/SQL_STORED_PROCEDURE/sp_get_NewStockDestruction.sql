CREATE PROCEDURE sp_get_NewStockDestruction
AS  
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 31 

