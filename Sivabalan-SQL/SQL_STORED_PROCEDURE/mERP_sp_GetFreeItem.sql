CREATE Procedure mERP_sp_GetFreeItem(@InvoiceID as Int, @SchemeId as Int, @SlabId as Int, @Serial as nVarchar(100), @SchType as Int)
As
	Declare @SchDet nVarchar(100)
	Declare @ProductCode nVarchar(255)
	Declare @Slab Int

	If @SchType = 3 --Spl. Category scheme free item
	Begin
	Select @ProductCode = Product_Code, @SchDet = MultipleSplCategorySchDetail
		From InvoiceDetail
		Where InvoiceID = @InvoiceID
		And SplCatSchemeID = @SchemeId

		Set @SchemeID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
		Set @Slab = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
	End
	Else If @SchType = 2 --Invoice based free item
	Begin
	Select @ProductCode = Product_Code, @SchDet = MultipleSchemeDetails 
		From InvoiceDetail
		Where InvoiceID = @InvoiceID
		And SchemeID = @SchemeId

		Set @SchemeID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
		Set @Slab = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
	End
	Else
	Begin
	Select @ProductCode = Product_Code, @SchDet = MultipleSchemeDetails 
		From InvoiceDetail
		Where InvoiceID = @InvoiceID
		And SchemeID = @SchemeId
		And IsNull(Serial,0) In (Select * From dbo.fn_SplitIn2Rows_Int(@Serial, ','))

		Set @SchemeID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
		Set @Slab = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
	End
	If @SlabID = @Slab
		Select @ProductCode
	Else
		Select ''
