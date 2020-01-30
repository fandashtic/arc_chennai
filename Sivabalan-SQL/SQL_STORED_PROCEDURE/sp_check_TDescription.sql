Create Procedure sp_check_TDescription(@Desc nvarchar(2000))
As
Select count(*) from tax where Tax_Description = @Desc


