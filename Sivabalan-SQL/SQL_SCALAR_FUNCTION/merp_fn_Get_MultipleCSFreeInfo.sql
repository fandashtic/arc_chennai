Create function dbo.merp_fn_Get_MultipleCSFreeInfo(@InvoiceID Int, @FreeSerialList nVarchar(2000),
@PriceType nVarchar(20),@ReturnType Int, @SchType Int,@Product_Code nvarchar(50)='',@Serial int=0)
Returns nVarchar(1020)  
As
Begin

Declare @SumOfPrimaryItemQty Decimal(18,6) 	 
Declare @SumOfLineItemQty Decimal(18,6) 	 

Select @SumOfPrimaryItemQty = IsNull(sum(Quantity),0) from InvoiceDetail where InvoiceID = @InvoiceID and Quantity > 0
and (Case @SchType When 1 then FreeSerial Else SplCatSerial End)  = @FreeSerialList

Select @SumOfLineItemQty = isNull(sum(Quantity),0) from InvoiceDetail where InvoiceID = @InvoiceID
and Serial = @Serial

  Declare @ReturnValue nVarchar(1020)
  IF @ReturnType = 4 
    Set @ReturnValue = 0
  Else 
    Set @ReturnValue = ''
  Declare @ProductList as nVarchar(1020)
  Declare @ProdCode nVarchar(50)
  Declare @Quantity Decimal(18,6)
  Declare @SalePrice Decimal(18,6)
  Declare @SPlFreeSerial nVarchar(256)
  Set @SalePrice = 0
  Declare @PTS Decimal(18,6)
  Declare @PTR Decimal(18,6)
  Declare @UOM2 Decimal(18,6)
  Declare @SchemeID Int
  If @SchType = 3 /*Invoice Based Free Qty */
  Begin
	If @ReturnType = 1  
     -- SET @ReturnValue = '0|0|'
	  SET @ReturnValue = ''	
    Else 
      SET @ReturnValue = '0'
	  
    Declare CurProdList Cursor For 
    Select IDT.Product_Code, IDT.Quantity, IDT.PTR, IDT.PTS, IsNull(UOM2,0), IDT.SchemeID
    From InvoiceDetail IDT, Items
    Where Items.Product_Code = IDT.Product_Code And 
      IDT.InvoiceID = @InvoiceID And
      IDT.SchemeID In (Select * from dbo.sp_splitIn2Rows(@FreeSerialList,',')) And
      @Product_Code=(select Top 1 Product_Code from InvoiceDetail where InvoiceID=IDT.InvoiceID and IsNull(FlagWord,0)=0)
      and @Serial=(select Top 1 Serial from InvoiceDetail where InvoiceID=IDT.InvoiceID and IsNull(FlagWord,0)=0 order by serial)
	  and IsNull(IDT.FlagWord,0) = 1
    Open CurProdList
    Fetch Next From CurProdList Into @ProdCode, @Quantity, @PTR, @PTS, @UOM2, @SchemeID
    While @@Fetch_Status = 0
    Begin 
      If @ReturnType = 1 
       Begin
		Set @SalePrice = 0
        SET @SalePrice = @SalePrice + (@Quantity * Case @PriceType When 'PTR' Then @PTR Else @PTS End)
        SET @ReturnValue = @ReturnValue + Cast(@SchemeID as nVarchar(10)) + '|' + Cast(@SalePrice as nVarchar(50)) + Char(15)
       End
      Else If @ReturnType = 2 
       Begin
        SET @SalePrice = @SalePrice + (@Quantity * Case @PriceType When 'PTR' Then @PTR Else @PTS End)
        SET @ReturnValue = Cast(@SalePrice as nVarchar(50))
       End
      Fetch Next From CurProdList Into @ProdCode, @Quantity, @PTR, @PTS, @UOM2, @SchemeID
    End
    Close CurProdList
    Deallocate CurProdList
    End
  Else   /*Item or Spl Category Based Free Qty */
    Begin
	If (@ReturnType=3 or @ReturnType=4) 
    Begin 
		Declare CurProdList Cursor For 
		Select 
		ID.Product_Code, ID.Quantity, isnull(ID.PTR,0), isnull(ID.PTS,0), IsNull(I.UOM2,0), 
		Case @SchType When 1 Then ID.SchemeID Else ID.SplCatSchemeID  End
		From  InvoiceDetail ID, Items I
		where ID.Product_Code = I.Product_Code and 
			ID.InvoiceID = @InvoiceID and
		  ID.Serial in (select * from dbo.sp_SplitIn2Rows(@FreeSerialList,','))
		And IsNull(ID.FlagWord,0) = 1
    End
    Else
    Begin
		Declare CurProdList Cursor For 
		Select 
		IDT.Product_Code, Sum(IDT.Quantity), isnull(IDT.PTR,0), isnull(IDT.PTS,0), IsNull(UOM2,0), 
		Case @SchType When 1 Then IDT.SchemeID Else IDT.SplCatSchemeID  End
		From InvoiceDetail IDT, Items 
		where Items.Product_Code = IDT.Product_Code And 
		  IDT.InvoiceID = @InvoiceID And 
		  IDT.Serial in (select * from dbo.sp_SplitIn2Rows(@FreeSerialList,',')) And
		  IsNull(IDT.FlagWord,0) = 1
		Group by IDT.Product_Code, isnull(IDT.PTR,0), isnull(IDT.PTS,0), IsNull(UOM2,0), 
		(Case @SchType When 1 Then IDT.SchemeID Else IDT.SplCatSchemeID End)
    End

    Open CurProdList
    Fetch Next From CurProdList Into  @ProdCode, @Quantity, @PTR, @PTS, @UOM2, @SchemeID
    While @@Fetch_Status = 0
    Begin 
      If @ReturnType = 1 
       Begin
        Set @ReturnValue = @ReturnValue + @ProdCode + N'|' 
       End
      Else if @ReturnType = 2 
       Begin
        Set @ReturnValue = @ReturnValue + Cast((@Quantity * @SumOfLineItemQty/ @SumOfPrimaryItemQty) as nVarchar(25))+ N'|' 
       End
      Else if @ReturnType = 3
       Begin

		/*
				SET @SalePrice = ((@Quantity * Case @PriceType When 'PTR' Then @PTR Else @PTS End) / 
						(Case (select Count(*) from dbo.sp_SplitIn2Rows(@SPlFreeSerial,',')) When 0 Then 1 Else 
						(select Count(*) from dbo.sp_SplitIn2Rows(@SPlFreeSerial,',')) End) )
		*/

			SET @SalePrice = (@Quantity * @SumOfLineItemQty/ @SumOfPrimaryItemQty) *
							Case @PriceType When 'PTR' Then @PTR Else @PTS End
        SET @ReturnValue = @ReturnValue + Cast(@SchemeID as nVarchar(5)) + '|' + Cast(@SalePrice as nVarchar(25))+ Char(15)
       End
      Else if @ReturnType = 4
       Begin
        SET @SalePrice = @SalePrice + @Quantity * Case @PriceType When 'PTR' Then @PTR Else @PTS End
        SET @ReturnValue = Cast(@SalePrice as nVarchar(50))
       End
      Else if @ReturnType = 5
       Begin
        Set @ReturnValue = @ReturnValue + Cast(@UOM2 as nVarchar(25))+ N'|' 
       End
      Fetch Next From CurProdList Into @ProdCode, @Quantity, @PTR, @PTS, @UOM2, @SchemeID
    End
    Close CurProdList
    Deallocate CurProdList
  End

  If CharIndex('|', @ReturnValue) > 0 
  Begin
    Set @ReturnValue = SubString(@ReturnValue, 1 , Len(@ReturnValue)-1)
  End

  Return @ReturnValue
End 

