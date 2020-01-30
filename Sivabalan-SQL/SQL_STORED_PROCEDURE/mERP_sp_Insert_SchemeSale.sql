Create Procedure mERP_sp_Insert_SchemeSale
(
@SKUCode nVarchar(255),
@Primary_Qty Decimal(18,6),
@Original_Qty Decimal(18,6),
@nPrice Decimal(18,6),
@InvoiceID Int,
@MultiSchemeDetails nVarchar(2500),
@SplCategoryScheme Int = 0,
@RowNo Int = 0
)
As
Begin

	
	Declare @SchemeID As Int
	Declare @SlabID As Int
	Declare @SchAmnt as Decimal(18,6)
	Declare @SchPer as Decimal(18,6)
	Declare @Delimeter as  Char(1)
	Declare @SchDet as nVarchar(100)
	Declare @Type as Int
	Declare @RFAApplicable as Int
	Set @Delimeter = char(15)

    Declare @szSchAmnt nvarchar(100)
	Declare @fSchAmnt as Float
	Declare @fSchPer as Float
	Declare @InvType as int


	If @nPrice = 0 
	Begin
	select @nPrice = case C.CustomerCategory when 1 then I.PTS when 2 then I.PTR when 3 then I.Company_Price else 0 end 
		             from Customer C,Items I where C.CustomerID=(select Top 1 CustomerID from InvoiceAbstract 
		             where InvoiceID=@InvoiceID) and I.Product_code=@SKUCode
	End	
	
	Create Table #tmpSch(SchemeDetail nVarchar(250)) 
	Insert Into #tmpSch
	Select * from dbo.sp_SplitIn2Rows(@MultiSchemeDetails,@Delimeter)

	Declare CurSch Cursor For 
	Select SchemeDetail From #tmpSch
	Open CurSch
	Fetch Next From CurSch Into @SchDet
	While @@Fetch_Status = 0 
	Begin
		Set @SchemeID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
		Set @SlabID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))

        --some times the scheme amount and scheme discount are in the exponential format(Eg 1.2345610000E-2 or 1.2345610000E+2 )
        --so we use Covert and Str function to convert Exponential format to Decimal Format.
		--Set @SchAmnt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
	
		
		Set @szSchAmnt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
		if (Charindex('E+',@szSchAmnt) > 0  Or Charindex('E-',@szSchAmnt) > 0)
			set @SchAmnt = convert(decimal(18,6), str(@szSchAmnt, 18, 6))
		Else
			set @SchAmnt = @szSchAmnt
		


		Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))
		if (Charindex('E+',@SchDet) > 0 Or Charindex('E-',@SchDet) > 0 )
			Set @SchPer = convert(decimal(18,6), str(@SchDet, 18, 6))
		Else
			set @SchPer = @SchDet

		Select @InvType = InvoiceType From InvoiceAbstract Where InvoiceID = @InvoiceID
		Select @Type = SlabType From tbl_mERP_SchemeSlabDetail Where SlabID = @SlabID
		Select @RFAApplicable = isNull(RFAApplicable,0) From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID
		

		If  @Type = 1 Or @Type = 2 Or (@InvType = 4 And IsNull(@Type,0) = 0)
		Begin
			Insert Into tbl_mERP_SchemeSale(Product_Code,SchemeID,SlabID,PrimaryQty, FreeQty,SchemeSaleValue,SchemeValue,
			InvoiceID, Claimed,Pending, RFA, SpecialCategory, Serial)  
			Values(@SKUCode,@SchemeID,@SlabID,@Primary_Qty,@Original_Qty, @nPrice * @Original_Qty, @SchAmnt, @InvoiceID, 
			0, @ORIGINAL_QTY,@RFAApplicable,@SplCategoryScheme,@RowNo)
		End
		Else
		Begin
			Insert Into tbl_mERP_SchemeSale(Product_Code,SchemeID,SlabID,PrimaryQty, FreeQty,SchemeSaleValue,SchemeValue,
			InvoiceID, Claimed,Pending, RFA, SpecialCategory, Serial)  
			Values(@SKUCode,@SchemeID,@SlabID,@Primary_Qty,@Original_Qty, @nPrice * @Original_Qty, @nPrice * @Original_Qty, 
			@InvoiceID, 0, @ORIGINAL_QTY,@RFAApplicable,@SplCategoryScheme,@RowNo)						
		End

		Fetch Next From CurSch Into @SchDet
	End
	Close CurSch
	Deallocate CurSch

	Drop Table #tmpSch

End
