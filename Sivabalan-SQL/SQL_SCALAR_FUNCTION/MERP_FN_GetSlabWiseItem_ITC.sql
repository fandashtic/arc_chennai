CREATE Function MERP_FN_GetSlabWiseItem_ITC(@SlabID Int)
Returns Varchar(8000)
As
Begin
	
	Declare @FinalItem VarChar(8000)
	Declare @TempItem Varchar(520)
	Declare @Intimate Int
	Set @Intimate = 0
	Set @FinalItem = ''

	Declare ItmDtl Cursor For 
	
	Select "Items" = FreeSKU.SKUCode + '~' + IsNull(Items.ProductName, '') 
	From tbl_mERP_SchemeFreeSKU FreeSKU
	Left Outer Join Items On FreeSKU.SKUCode = Items.Product_Code
	Where FreeSKU.SlabID =@SlabID  	Order by 1 

	Open ItmDtl 
	Fetch From ItmDtl InTo @TempItem
	While @@Fetch_Status = 0
	Begin
		If @Intimate = 0
		Set @FinalItem = @TempItem 
		Else
		Set @FinalItem = @FinalItem + ' | ' + @TempItem 

		Set @Intimate = 1

		Fetch Next From ItmDtl InTo @TempItem
	End

Return @FinalItem

End
