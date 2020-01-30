Create procedure sp_DeleteFileinfo @Node nvarchar(50)
AS 
BEGIN
	Delete from tbl_merp_Clientfileinfo where filename like '%.dll' or filename like '%.exe'
	and node =@node
END

