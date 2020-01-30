Create Procedure mERP_SP_LoadQuoItems(@ProductHierarchy as nvarchar(200),@Category as nvarchar(2000))
As
Begin
	Declare @GSTFlag as int

	Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

--	Create table #tempCategory(CategoryID int,Status int)
--	Exec dbo.GetLeafCategories @ProductHierarchy,@Category  	
--	select Product_Code,Productname,ECP,(select Percentage from Tax where Tax_Code=Sale_Tax),
--	PTS,PTR,Sale_Tax from Items where Active=1
--	and CategoryID in (select CategoryID from #tempCategory)

	Create table #tempCategory(CategoryID int,Status int)
	Exec dbo.GetLeafCategories @ProductHierarchy,@Category  	
	Select Product_Code,Productname,ECP, Percentage,PTS,PTR,Sale_Tax 
	From Items Inner Join Tax on Items.Sale_Tax = Tax.Tax_Code
	Where Items.Active=1 and isnull(Tax.GSTFlag,0) = @GSTFlag
		and CategoryID in (Select CategoryID From #tempCategory)

End
