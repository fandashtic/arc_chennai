Create Procedure mERP_SP_CheckUpgradeProcedureVersion(@Objname nvarchar(500),@ObjType nVarchar(5))
As
declare @CUR_VERSION as nvarchar(12)
Begin
	if exists(select * from sysobjects where xtype='U' and name='tbl_mERP_VersionUpgrade')
    Begin 
		if exists(select * from tbl_mERP_VersionUpgrade where ObjectName=@Objname and ObjectType=@ObjType)
		Begin
			select @CUR_VERSION=max(version) from tbl_mERP_VersionUpgrade where ObjectName=@Objname
			and ObjectType=@ObjType
			/*if @version > @CUR_VERSION
				select 1
			else
				select 0 */ 
            select 1,@CUR_VERSION
		End 
		else
			select 0,0	
    End
    Else
    Begin
		if Not exists(select * from sysobjects where xtype='U' and name='tbl_mERP_VersionUpgrade')
		Begin
            Create Table tbl_mERP_VersionUpgrade 
			(
				ID int Identity,
				ObjectName nVarchar(500),
				Version nVarchar(20),
				ObjectType nVarchar(5),
				Status int,
				ErrorDescription nvarchar(3000),
				LastUpdatedDate datetime default GetDate()
			)
			select 0,0
        End	
    End
End
