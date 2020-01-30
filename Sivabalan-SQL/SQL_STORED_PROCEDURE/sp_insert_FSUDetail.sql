
CREATE PROCEDURE sp_insert_FSUDetail(@FileID integer , @FileName NVARCHAR(250))  
AS  
INSERT INTO FSUFileDetail([ID],[FileName])  
Values  (@FileID , @FileName) 
