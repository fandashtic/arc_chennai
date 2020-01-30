Create Procedure mERP_SP_UpgradeProcedureCount(@Type nVarchar(5))
As
Begin	
    if @Type=N'P'
	Begin
		select Count(*) from sysobjects,tbl_mERP_VersionUpgrade V where 
		xtype in ('P', 'FN', 'TF', 'IF','TR','V')
		and ObjectName=name and (V.status & 128) =0
		and V.ObjectType in ('P','FN','TF', 'IF','TR','V')
	End
	Else if @Type=N'T'		
	Begin
		select Count(*) from sysobjects,tbl_mERP_VersionUpgrade V 
		where xtype in ('U')
		and ObjectName=name and (V.status & 128) =0
		and V.ObjectType in ('U')
	End
End
