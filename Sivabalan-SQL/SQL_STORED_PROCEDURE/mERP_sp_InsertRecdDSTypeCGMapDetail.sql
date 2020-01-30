Create Procedure mERP_sp_InsertRecdDSTypeCGMapDetail
( @RecdID int, @DSTypeCode nVarchar(25), @CategoryName nVArchar(255), @Level int, @PortFolio nvarchar(25))
As
Insert into Recd_DSTypeCGCategoryMap(RecdID, DSTypeCode, CG_Name, Level, PortFolio ) 
Values (@RecdID, @DSTypeCode, @CategoryName, @Level, @PortFolio)
