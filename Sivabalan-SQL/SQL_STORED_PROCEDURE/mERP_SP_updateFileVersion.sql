create procedure mERP_SP_updateFileVersion  @Filename nvarchar(4000),@Fileversion nvarchar(25),@FSUID nvarchar(25)  
AS
BEGIN
 update tbl_mERP_Fileinfo set active = 0 where filename=@Filename   
 update tbl_mERP_Fileinfo set active = 1 where filename=@Filename and versionnumber=@Fileversion and isnull(FSUID,0) =   
    case @FSUID When 'Build' Then 0  
    Else @FSUID  
 End  
End
