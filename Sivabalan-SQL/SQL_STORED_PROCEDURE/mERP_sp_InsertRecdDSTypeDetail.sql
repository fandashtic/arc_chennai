Create Procedure mERP_sp_InsertRecdDSTypeDetail
( @RecdID int, @DSTypeCode nVarchar(510), @DSTypeDesc nVarchar(1000), @szCGrpCode nVArchar(510), @Active int, @ReportFlag int, @Flag int)
As
Insert into tbl_mERP_RecdDSTypeCGDetail(RecdID, DSType_Code, DSType_Desc, CG_Code, Active, ReportFlag, Flag) 
Values (@RecdID, @DSTypeCode, @DSTypeDesc, @szCGrpCode, @Active, @ReportFlag, @Flag)
