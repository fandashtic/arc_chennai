CREATE PROCEDURE FSU_sp_InsertClientFileInfo(
@Node varchar(200),
@FileName varchar(2000)
)
AS
BEGIN
	Insert into tbl_merp_ClientFileInfo(Node,[FileName],version) values (@Node,@FileName,'0.0.0.0')
END
