Create Procedure mERP_sp_UpdateRecdScheme (@RecdSchID int, @Flag Int=0)
AS
If @Flag = 1
Update tbl_mERP_RecdSchAbstract Set CS_Flag = IsNull(CS_Flag,0) | 32,CS_ProcessedTime = GetDate() Where CS_SchemeID = @RecdSchID
Else
Update tbl_mERP_RecdSchAbstract Set CS_Flag = IsNull(CS_Flag,0) | 64,CS_ProcessedTime = GetDate() Where CS_SchemeID = @RecdSchID
