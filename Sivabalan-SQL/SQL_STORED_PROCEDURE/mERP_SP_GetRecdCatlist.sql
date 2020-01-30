Create Procedure mERP_SP_GetRecdCatlist  
As  
Begin
Select Isnull(RecdID,0) from tbl_mERP_RecdCGDefnAbstract where isNull(Status,0) = 0  
End
