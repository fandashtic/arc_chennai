Create Procedure mERP_SP_GetPriceListDetails(@QuotationID int)
As
Declare @QuoLevel int
Begin
	Select @QuoLevel=QuotationLevel from QuotationAbstract where QuotationID=@QuotationID
	if @QuoLevel=1 
    Begin
		select Items.Product_Code,Items.ProductName,QuotationItems.ECP,(select Percentage from Tax where Tax_Code=QuotedTax),
        QuotationItems.PurchasePrice,QuotationItems.SalePrice,QuotationItems.MarginOn,QuotationItems.MarginPercentage,QuotationItems.RateQuoted,
		QuotedTax,Quoted_LSTTax,(select Percentage from Tax where Tax_Code=Quoted_LSTTax),
	    Quoted_CSTTax,(select CST_Percentage from Tax where Tax_Code=Quoted_CSTTax),IsNull(Items.TOQ_Sales,0) as TOQ_Sales
        from QuotationItems,Items 
        where QuotationID=@QuotationID and Items.Product_Code = QuotationItems.Product_Code
    End
	Else if @QuoLevel=2 
	Begin
		select ItemCategories.CategoryID,ItemCategories.Category_Name,ItemCategories.Description,
        MarginOn,MarginPercentage,Quoted_LSTTax,(select Percentage from Tax where Tax_Code=Quoted_LSTTax),
	    Quoted_CSTTax,(select CST_Percentage from Tax where Tax_Code=Quoted_CSTTax)
        from QuotationMfrCategory,ItemCategories 
        where QuotationID=@QuotationID and MfrCategoryID=CategoryID
    End
End
