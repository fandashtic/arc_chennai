Create Function mERP_fn_GetInvSchemeDetail(@InvoiceID Int, @SchDetail nVarchar(2500), @FlagWord Int, @SalePrice Decimal(18, 6), @Quantity Decimal(18,6))
Returns @SchemeValue Table(InvoiceID Int, SchemeID Int, SlabID Int, SchAmt Decimal(18,6), SchPer Decimal(18,6))
As
Begin
--Declare @SchemeValue Table(InvoiceID Int, SchDetail Decimal(18, 6))
	Declare @Delimiter Char(1)
	Set @Delimiter = Char(15)
	Declare @SchemeID As Int
	Declare @SlabID As Int
	Declare @SchAmt as Decimal(18,6)
	Declare @szSchAmt as nVarchar(4000)
	Declare @SchPer as Decimal(18,6)
	Declare @SchDet as nVarchar(255)

	IF @SchDetail <> ''
		Begin
			If @FlagWord = 1
			Begin
				Set @SchemeID = Substring(@SchDetail,1,Charindex('|',@SchDetail) - 1)
				Set @SchDetail = Substring(@SchDetail,Charindex('|',@SchDetail)+1,len(@SchDetail))
				Set @SlabID = Substring(@SchDetail,1,Charindex('|',@SchDetail) - 1)
				Set @SchDetail = Substring(@SchDetail,Charindex('|',@SchDetail) + 1,len(@SchDetail))

				Set @szSchAmt = Substring(@SchDetail,1,Charindex('|',@SchDetail) - 1)
				if (Charindex('E+',@szSchAmt) > 0  Or Charindex('E-',@szSchAmt) > 0)
					set @SchAmt = convert(decimal(18,6), str(@szSchAmt, 18, 6))
				Else
					set @SchAmt = cast(@szSchAmt as decimal(18,6))

--				Set @SchAmt = Substring(@SchDetail,1,Charindex('|',@SchDetail) - 1)

				Set @SchDetail = Substring(@SchDetail,Charindex('|',@SchDetail) + 1,len(@SchDetail))
				Set @SchPer = @SchDetail
				Set @SchAmt = @SalePrice * @Quantity
				Insert Into @SchemeValue Values(@InvoiceID, @SchemeID, @SlabID, @SchAmt, @SchPer)
			End
			Else
			Begin
			--If Slab Type Amt/Per
				Declare DetailCur Cursor For
				Select * From dbo.sp_splitin2rows(@SchDetail,@Delimiter)
				Open DetailCur
				Fetch Next From DetailCur Into @SchDet
				While (@@Fetch_Status=0)
				Begin
					Set @SchemeID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
					Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
					Set @SlabID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
					Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))

					Set @szSchAmt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
					if (Charindex('E+',@szSchAmt) > 0  Or Charindex('E-',@szSchAmt) > 0)
						set @SchAmt = convert(decimal(18,6), str(@szSchAmt, 18, 6))
					Else
						set @SchAmt = cast(@szSchAmt as decimal(18,6))
					--Set @SchAmt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)

					Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))
					Set @SchPer = @SchDet
					Insert Into @SchemeValue Values(@InvoiceID, @SchemeID, @SlabID, @SchAmt, @SchPer)
					Fetch Next From DetailCur Into @SchDet
				End
				Close DetailCur
				Deallocate DetailCur
			End
		End
		Else
		Begin
			Set @SlabID = 0
			Set @SchemeID = 0
			Insert Into @SchemeValue Values(@InvoiceID, @SchemeID, @SlabID, @SchAmt, @SchPer)
		End
	Return
End

