Create Procedure mERP_Sp_SchemesCount (@ServerDate datetime)
AS
Declare @Actualdate datetime
Set @Actualdate = dbo.stripTimeFromDate(@ServerDate)

Select Count(*) from tbl_mERP_SchemeAbstract where @Actualdate between ActiveFrom and ActiveTo
and Active = 1
