Create Procedure mERP_sp_InsertRecdCGDefnDetail
( @RecdID int, @CatGrpCode nVArchar(255), @Division nVarchar(510), @CategoryGroup nVarchar(255), @CGActive nVArchar(510))
As
Insert into tbl_mERP_RecdCGDefnDetail (RecdID, CatGrpCode, Category, Groupname, Active ) 
Values (@RecdID, @CatGrpCode, @Division, @CategoryGroup, @CGActive)
