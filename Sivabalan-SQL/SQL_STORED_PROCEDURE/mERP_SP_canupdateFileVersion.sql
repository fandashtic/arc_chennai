
create procedure mERP_SP_canupdateFileVersion  @Filename nvarchar(4000),@Fileversion nvarchar(25) 
AS
BEGIN
	--If Max of Version number is not equal to file recovered then don't receover the file.
	if((select max(cast(replace(isnull(VersionNumber,''),'.','')as int))from tbl_mERP_Fileinfo where filename = @Filename)<>replace(isnull(@Fileversion,''),'.',''))
		Select 0
	else
		Select 1
END
