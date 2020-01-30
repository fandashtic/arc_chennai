CREATE Procedure sp_get_TempDispatchID
as 
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 3

