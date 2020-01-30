
create Procedure mERP_SP_getTallyDetails
AS
BEGIN
	Create Table #Tax(Taxtype nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	ForumDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	TallyDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	insert into #Tax(Taxtype,ForumDesc)
	Select 'Input' as [Type],Tax_description From Tax
	Union
	Select 'Output' as [Type],Tax_description from Tax

	update Temp Set TallyDesc= TallyTax.TallyDesc
	From #Tax Temp join TallyTaxDetails TallyTax
	on Temp.ForumDesc=TallyTax.ForumDesc
	Where Temp.TaxType=TallyTax.Taxtype

	Select ForumDesc,Taxtype,TallyDesc from #Tax order by ForumDesc
	Drop Table #Tax
	
END

