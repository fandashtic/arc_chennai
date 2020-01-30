Create Procedure mERP_sp_InsertRecdTLTypeDetail( @RecdID int, @TLTypeDesc nVarchar(1000), @Active int, @ReportFlag int)
As
	Insert into tbl_mERP_RecdTLTypeDetail(RecdID, TLType_Desc, Active, ReportFlag ) 
	Values (@RecdID, @TLTypeDesc, @Active, @ReportFlag)
