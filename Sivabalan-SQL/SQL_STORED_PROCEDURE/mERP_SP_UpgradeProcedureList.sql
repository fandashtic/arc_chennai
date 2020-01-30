Create Procedure mERP_SP_UpgradeProcedureList(@Type nvarchar(5))
As
Begin
If @Type=N'P'
Begin
	-- First Exec Functions and then Procedure running
	Select name,xtype,V.version,V.ObjectType from sysobjects,tbl_mERP_VersionUpgrade V where 
	xType in ('FN', 'TF', 'IF')
	and ObjectName=name and (V.status & 128) =0
    and V.ObjectType in ('P','FN','TF','IF')
	Union All
	Select name,xtype,V.version,V.ObjectType from sysobjects,tbl_mERP_VersionUpgrade V where 
	xType in ('P', 'TR', 'V')
	and ObjectName=name and (V.status & 128) =0
    and V.ObjectType in ('P','TR','V')
End
Else if @Type=N'T'		
Begin
	select name,xtype,V.version,V.ObjectType from sysobjects,tbl_mERP_VersionUpgrade V 
    where xtype in ('U')
	and ObjectName=name and (V.status & 128) =0
	and V.ObjectType in ('T') 
End
End
