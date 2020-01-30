Create Procedure mERP_sp_InsertRecdMarginDetail
( @RecdID int=0, @Name nVArchar(255)= NULL, @Catlevel nVarchar(510)= NULL, @Percentage Decimal(18,6)= 0, @MarginDate datetime = NULL,  @Type nVarchar(255)= NULL)
As
Insert into tbl_mERP_RecdMarginDetail ( RecdID, CategoryName, Categorylevel, Percentage, MarginDate, Type) 
Values (@RecdID, @Name, @Catlevel, @Percentage, @MarginDate, @Type)
Select @@IDENTITY
