Create Function FN_SKUOPT_DailySKU() Returns
	@FinalData Table(CategoryID int,Flag nvarchar(1),customerID nvarchar(15),ProductCode nvarchar(15))
BEGIN
	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @FinalData (CategoryID,Flag,CustomerID,ProductCode)
		Select CategoryID,Flag,CustomerID,ProductCode From Tmp_SKUOPT_DailySKU
	ELSE
	BEGIN
		Declare @tempMarketSKU Table(MKTSKU nvarchar(255),CategoryID int,Flag nvarchar(1),customerID nvarchar(15),OverallSOH decimal(18,6),SKU nvarchar(15))

		insert into @tempMarketSKU (MKTSKU,customerID,Flag,SKU)
		select distinct MarketSKU,customerID,
		Case When
		(max(Case When Type = 'MAIN' Then 0 
			When Type='HM' Then 1
			else 0 end))= 0 Then 'M' else 'H'
		End,
		SKU from tbl_SKUOpt_Monthly where isnull(status,0)=1
		Group by MarketSKU,customerID,SKU


		/* updating category ID*/
		update M set CategoryID=IC.CategoryID from @tempMarketSKU M, Itemcategories IC
		Where IC.Category_Name=M.MKTSKU
		and isnull(IC.active,0)=1

		Insert Into @FinalData (CategoryID,Flag,customerID,ProductCode)
		select M.CategoryID,Flag,customerID,I.Product_Code Product_Code from @tempMarketSKU M,Items I
		Where M.CategoryID=I.CategoryID
		And M.SKU=I.Product_code
		And isnull(i.active,0)=1
	END
	Return
END
