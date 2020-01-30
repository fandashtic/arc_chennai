Create Procedure mERP_SP_GetRecdDSTypeMaplist
AS
	Select ID from RecdDoc_DSTypeCGCategoryMap where IsNull(Status,0) = 0
