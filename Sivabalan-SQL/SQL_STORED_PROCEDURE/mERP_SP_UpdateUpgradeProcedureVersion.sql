Create Procedure mERP_SP_UpdateUpgradeProcedureVersion(@ObjectName nvarchar(500),@Version nvarchar(12),@Status int,@ErrMessage varchar(4000),@ObjectType nVarchar(5))
As
Begin	
     insert into tbl_mERP_VersionUpgrade(ObjectName,version,Status,errordescription,ObjectType) 
     values(@ObjectName,@Version,@Status,@ErrMessage,@ObjectType)
End
