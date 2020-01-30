Create PROCEDURE sp_Insert_QuotationItems(@QuotationID INT,  
      @ProductCode nVarchar(50),   
      @ECP Decimal(18,6),   
      @PurchasePrice Decimal(18,6),  
      @SalePrice Decimal(18,6),  
      @MarginOn INT,  
      @MarginPercentage Decimal(18,6),  
      @RateQuoted Decimal(18,6),  
      @QuotedTax Decimal (18,6),  
      @Discount Decimal(18,6),  
      @AllowScheme Int,
	  @QuotedLSTTax Int = 0,	
	  @QuotedCSTTax Int = 0)  

AS 
Declare @UOMID as int
Declare @QUOTYPE as int
Declare @RateQuo as decimal(18,6)
Declare @TaxAmt decimal(18,6)
declare @MarkUpdiff decimal(18,6)
Declare @BaseUOM Decimal (18,6)
Declare @GSTCSTaxCode as int

Set @BaseUOM = 0
Begin
select @UOMID =UOMConversion,@QUOTYPE=QuotationType from QuotationAbstract where QuotationID=@QuotationID
if @UOMID=2 
Begin
	if @QUOTYPE=1 
    Begin 
		set @RateQuo=(@MarginPercentage/100)*@ECP
        set @RateQuo=@ECP-@RateQuo
    End 
    Else if @QUOTYPE=2 or @QUOTYPE=3 or @QUOTYPE=4
    Begin
		if @QUOTYPE=2 
		Begin
			
			select @BaseUOM =  ISnull(Sum(UOM2_Conversion),0) from items where product_code = @ProductCode And TOQ_Sales = 1

			Select @GSTCSTaxCode = isnull(CS_TaxCode,0) From Tax Where Tax_Code = @QuotedTax			
			IF isnull(@GSTCSTaxCode,0) > 0
			Begin
				Select @TaxAmt = isnull(dbo.Fn_openingbal_TaxCompCalc(@ProductCode,@QuotedTax,1,@PurchasePrice,1,1,0),0)
			End
			Else
			Begin
				IF @BaseUOM = 0  
					Set @TaxAmt = @PurchasePrice * isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) / 100
				Else
					Set @TaxAmt =  isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) 
			End
			
			
            Set @MarkUpdiff = @PurchasePrice + @TaxAmt			
            Set @RateQuo = (@MarkUpdiff * @MarginPercentage / 100)
            Set @RateQuo = @RateQuo + @MarkUpdiff

			--set @RateQuo=(@MarginPercentage/100)*@PurchasePrice
			--set @RateQuo=@PurchasePrice+@RateQuo + 
			--Set @TaxAmt =  @PurchasePrice * isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) / 100
			--Set @RateQuo = @PurchasePrice + (@PurchasePrice + @TaxAmt) * @MarginPercentage/100
			
        End
        Else
        Begin
			if @MarginOn=1 
            Begin
                set @RateQuo=(@MarginPercentage/100)*@ECP
				set @RateQuo=@ECP-@RateQuo
            End
			Else
            Begin
--               set @RateQuo=(@MarginPercentage/100)*@PurchasePrice
--			   set @RateQuo=@PurchasePrice+@RateQuo
			--Set @TaxAmt =  @PurchasePrice * isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) / 100
			--Set @RateQuo = @PurchasePrice + (@PurchasePrice + @TaxAmt) * @MarginPercentage/100
			select @BaseUOM =  ISnull(Sum(UOM2_Conversion),0) from items where product_code = @ProductCode And TOQ_Sales = 1

			Select @GSTCSTaxCode = isnull(CS_TaxCode,0) From Tax Where Tax_Code = @QuotedTax			
			IF isnull(@GSTCSTaxCode,0) > 0
			Begin
				Select @TaxAmt = isnull(dbo.Fn_openingbal_TaxCompCalc(@ProductCode,@QuotedTax,1,@PurchasePrice,1,1,0),0)
			End
			Else
			Begin			
				If @BaseUOM = 0  
					Set @TaxAmt = @PurchasePrice * isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) / 100
				Else
					Set @TaxAmt =  isnull((Select Percentage From Tax Where Tax_Code = @QuotedTax),0) 
			End
			
            Set @MarkUpdiff = @PurchasePrice + @TaxAmt
            Set @RateQuo = (@MarkUpdiff * @MarginPercentage / 100)
            Set @RateQuo = @RateQuo + @MarkUpdiff
					
            End   	
        End 
    End       
End
Else
	Set @RateQuo=@RateQuoted

INSERT INTO QuotationItems(QuotationID,   
      Product_Code,   
      ECP,   
      PurchasePrice,   
      SalePrice,   
      MarginOn,   
      MarginPercentage,   
      RateQuoted,   
      QuotedTax,   
      Discount,   
      AllowScheme,
      Quoted_LSTTax,
      Quoted_CSTTax)   
      VALUES(@QuotationID,   
      @ProductCode,  
      @ECP,  
@PurchasePrice,  
      @SalePrice,  
      @MarginOn,  
      @MarginPercentage,  
      @RateQuo,  
      @QuotedTax,  
      @Discount,  
      @AllowScheme,
	  @QuotedLSTTax,
	  @QuotedCSTTax)  
End
