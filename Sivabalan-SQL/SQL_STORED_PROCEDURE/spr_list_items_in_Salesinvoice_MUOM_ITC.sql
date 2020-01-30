Create PROCEDURE spr_list_items_in_Salesinvoice_MUOM_ITC
(
	@INVOICEID int,
	@UOMDesc nvarchar(30),
	@Salesman nvarchar(255),
	@BreakUpValue nvarchar(20)	
)          
AS          

DECLARE @ADDNDIS AS Decimal(18,6)          
DECLARE @TRADEDIS AS Decimal(18,6)          
Declare @Count Int
Declare @Str nVArchar(4000)
Declare @i Int
Declare @ID nVArchar(255)
Declare @TaxPercentage Decimal(18,6)
Declare @TaxValue Decimal(18,6)
Declare @Product_Code nVarchar(255)
Declare @CustLocality Int
Declare @Locality Int
Declare @LSTCount Int
Declare @CSTCount Int
Declare @TaxCompCode int
Declare @TempTaxCompCode int
Declare @TaxCode Int
Declare @ColumnName nVarchar(4000)

Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)
Exec sp_CatLevelwise_ItemSorting

SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract          
WHERE InvoiceID = @INVOICEID          
          
SELECT  #tempCategory1.IDS,"Item Code" = InvoiceDetail.Product_Code,           
"Item Name" = Items.ProductName,           
"Quantity" =(
	Case When @UOMdesc = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
		When @UOMdesc = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
		Else SUM(InvoiceDetail.Quantity)
	End),        
"Volume" = SUM(InvoiceDetail.Quantity),
"Sales Price" = (    
	Case When @UOMdesc = 'UOM1' then InvoiceDetail.SalePrice * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
		When @UOMdesc = 'UOM2' then InvoiceDetail.SalePrice * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
		Else InvoiceDetail.SalePrice
 	End),
"Invoice UOM" = (Select Description From UOM Where UOM = InvoiceDetail.UOM),
"Invoice Qty" = Sum(InvoiceDetail.UOMQty),
"Sales Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nVARCHAR) + '%',          
--"Sales Tax" = Cast( Case When InvoiceDetail.TaxCode <> 0 Then InvoiceDetail.TaxCode
--					When InvoiceDetail.TaxCode2 <> 0 Then InvoiceDetail.TaxCode2
--					Else 0  End  as Varchar) + '%',	

"Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nVARCHAR) + '%',          
"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',          
"STCredit" =           
(SUM(InvoiceDetail.TaxCode) / 100.00) *          
((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -           
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *          
(@ADDNDIS / 100.00)) +          
(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -           
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *          
(@TRADEDIS / 100.00))),
"Total" = SUM(Amount),
"Forum Code" = Items.Alias,         
"Tax Suffered Value" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),            
"Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0)  ,      
--"Sales Tax Value" = Case When STPayable <> 0 Then IsNull(STPayable, 0)
--						   When CSTPayable <> 0 then IsNull(CSTPayable, 0)
--						   Else 0 End,
"Locality " 	         = Case When Sum(STPayable) <> 0 Then 1
						   When Sum(CSTPayable) <> 0 then 2
						   Else 0 End,
TaxID
Into #TempItemDetails
FROM InvoiceDetail, Items, #tempCategory1
WHERE InvoiceDetail.InvoiceID = @INVOICEID 
AND #tempCategory1.CategoryID = Items.CategoryID 
AND InvoiceDetail.Product_Code = Items.Product_Code          
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,           
InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion, 
--InvoiceDetail.TaxCode, InvoiceDetail.TaxCode2, 
--InvoiceDetail.STPayable, InvoiceDetail.CSTPayable,
TaxID,InvoiceDetail.UOM,
#tempCategory1.IDS
Order By #tempCategory1.IDS, InvoiceDetail.Product_Code

If @BreakUpValue = 'Yes'
Begin

	Declare @LSTCompCount Int
	Declare @CSTCompCount Int

	Set @ColumnName = 'IDS,[Item Code],[Item Name],[Quantity],Volume,[Sales Price],[Invoice UOM],[Invoice Qty],[Sales Tax],[Tax Suffered],Discount,STCredit,Total,[Forum Code],[Tax Suffered Value],[Sales Tax Value] '

	--To get count of LST component level to create dynamic columns
	Select Distinct InvoiceDetail.InvoiceID,  InvoiceDetail.Product_Code, InvoiceDetail.TaxID, 
 			(  Select Count(Distinct ITC.Tax_Component_Code) 
			From TaxComponentDetail TCD,  InvoiceTaxComponents ITC 
			Where ITC.Tax_Code= InvoiceDetail.TaxID 
			And ITC.InvoiceID = InvoiceDetail.InvoiceID 
			And ITC.Tax_Component_Code = TCD.TaxComponent_Code 
			And InvoiceDetail.TaxCode <> 0 And TaxCode2 = 0  
 			) as ComponentLevel
		Into #TempLSTCompLevel
		From InvoiceAbstract,InvoiceDetail, Tax, TaxComponents, TaxComponentDetail
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
		And InvoiceDetail.InvoiceId = @InvoiceID
		And InvoiceDetail.TaxID = Tax.Tax_Code
		And InvoiceDetail.TaxCode <> 0 And TaxCode2 = 0 
		And Tax.Tax_Code = TaxComponents.Tax_Code
		And TaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code

	
	Select @LSTCount = IsNull(Max(ComponentLevel),0) From #TempLSTCompLevel

	--To get count of CST component level to create dynamic columns
	Select Distinct InvoiceDetail.InvoiceID,  Product_Code, InvoiceDetail.TaxID,
		(Select Count(Distinct ITC.Tax_Component_Code) 
			From TaxComponentDetail TCD,  InvoiceTaxComponents ITC 
			Where ITC.Tax_Code= InvoiceDetail.TaxID 
			And ITC.InvoiceID = InvoiceDetail.InvoiceID 
			And ITC.Tax_Component_Code = TCD.TaxComponent_Code 
			And InvoiceDetail.TaxCode = 0 And TaxCode2 <> 0  
	 ) as ComponentLevel
	Into #TempCSTCompLevel
	From InvoiceAbstract,InvoiceDetail, Tax, TaxComponents, TaxComponentDetail
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	And InvoiceDetail.InvoiceId = @InvoiceID 
	And InvoiceDetail.TaxID = Tax.Tax_Code
	And InvoiceDetail.TaxCode = 0 And TaxCode2 <> 0  
	And Tax.Tax_Code = TaxComponents.Tax_Code
	And TaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code

	Select @CSTCount = IsNull(Max(ComponentLevel),0) From #TempCSTCompLevel

	Drop Table #TempCSTCompLevel
	Drop Table #TempLSTCompLevel

	Set @Count = @CSTCount + @LSTCount

	Set @i = 0
	Set @LSTCompCount =1
	Set @CSTCompCount =1
	While @i < @Count
	Begin
		Set @i = @i + 1

		If @i <= @LSTCount And @LSTCount > 0
		Begin
			Set @Str = 'Alter Table #TempItemDetails Add [LST Component '	+ 	Cast(@LSTCompCount as varchar) + ' Tax%] Decimal(18,6), ' + 
								 '[LST Component '	+ 	Cast(@LSTCompCount as varchar) + ' Tax Amount] Decimal(18,6)'
			Set @ColumnName = @ColumnName +', ' + '[LST Component '	+ 	Cast(@LSTCompCount as varchar) + ' Tax%], [LST Component '	+ 	Cast(@LSTCompCount as varchar) + ' Tax Amount]'
			Set @LSTCompCount = @LSTCompCount + 1
			
		End
		Else If @CSTCount > 0
		Begin 
			Set @Str = 'Alter Table #TempItemDetails Add [CST Component '	+ 	Cast(@CSTCompCount as varchar) + ' Tax%] Decimal(18,6), ' + 
								 '[CST Component '	+ 	Cast(@CSTCompCount as varchar) + ' Tax Amount] Decimal(18,6)'
			Set @ColumnName = @ColumnName +', ' + '[CST Component '	+ 	Cast(@CSTCompCount as varchar) + ' Tax%], [CST Component '	+ 	Cast(@CSTCompCount as varchar) + ' Tax Amount]'  
			Set @CSTCompCount = @CSTCompCount + 1
		End
		Exec sp_executesql @Str
	End

	Declare ItemCursor Cursor
	For 	Select Distinct [Item Code], TaxID  From  #TempItemDetails
	Open ItemCursor
	Fetch Next From ItemCursor Into @Product_Code, @TaxCode
	While @@Fetch_Status = 0 
	Begin
		----------------------------------------------------------------------------------------------------------------------
		Set @LSTCompCount =1
		Set @CSTCompCount =1

		Declare ComponentCur Cursor
		For Select Tax_Code, Tax_Component_Code,  Sum(Tax_Value) , Tax_Percentage, Locality
			From InvoiceTaxComponents, #TempItemDetails
			Where InvoiceTaxComponents.Product_Code  = #TempItemDetails.[Item Code]
			And #TempItemDetails.[Item Code] = @Product_Code 
			And InvoiceTaxComponents.Product_Code = @Product_Code 
			And InvoiceTaxComponents.InvoiceId  = @InvoiceID
			And InvoiceTaxComponents.Tax_Code = @TaxCode
			And #TempItemDetails.TaxID = @TaxCode
			And Locality <> 0
			Group By Tax_Code, Tax_Component_Code , Tax_Percentage, Locality
			Order By Tax_Code,  Tax_Component_Code
-- 			Select Distinct Tax_Code, Tax_Component_Code,  Tax_Value , Tax_Percentage, Locality
-- 			From InvoiceTaxComponents, #TempItemDetails
-- 			Where InvoiceTaxComponents.Product_Code  = #TempItemDetails.[Item Code]
-- 			And #TempItemDetails.[Item Code] = @Product_Code 
-- 			And InvoiceTaxComponents.InvoiceId  = @InvoiceID
-- 			And InvoiceTaxComponents.Tax_Code = @TaxCode
-- 			And Locality <> 0
-- 			Order By Tax_Code,  Tax_Component_Code
		Open ComponentCur
		Fetch Next From ComponentCur Into  @TaxCode, @TaxCompCode, @TaxValue, @TaxPercentage, @Locality
		While @@Fetch_Status = 0
		Begin
			If @Locality = 1 
			Begin
				Set @Str = 'Update #TempItemDetails Set [LST Component '	+ Cast(@LSTCompCount as varchar) + ' Tax%] =' + cast( @TaxPercentage as varchar) 
								 + ', [LST Component '	+ Cast(@LSTCompCount as varchar) + ' Tax Amount] =' + cast( @TaxValue as varchar) + ' Where [Item Code] = ''' + @Product_Code + ''''
								+ ' And TaxID = ' + Cast(@TaxCode as Varchar)							
				Set @LSTCompCount = @LSTCompCount +  1
			End
			Else If @Locality = 2
			Begin
				Set @Str = 'Update #TempItemDetails Set [CST Component '	+ Cast(@CSTCompCount as varchar) + ' Tax%] =' + cast( @TaxPercentage as varchar) 
								 + ', [CST Component '	+ Cast(@CSTCompCount as varchar) + ' Tax Amount] =' + cast( @TaxValue as varchar) + ' Where [Item Code] = ''' + @Product_Code + ''''
							+ ' And TaxID = ' + Cast(@TaxCode as Varchar)							
				Set @CSTCompCount = @CSTCompCount + 1
			End				
			Exec sp_executesql @Str	
		Fetch Next From ComponentCur Into  @TaxCode, @TaxCompCode, @TaxValue, @TaxPercentage, @Locality
 		End
 		Close ComponentCur
 		Deallocate ComponentCur
		----------------------------------------------------------------------------------------------------------------------
	Fetch Next From ItemCursor Into @Product_Code, @TaxCode
	End	
Close ItemCursor
Deallocate ItemCursor
End

If @BreakUpValue = 'Yes'
Begin
	Set @Str = 'Select ' + @ColumnName + ' From   #TempItemDetails  Order By [Item Code]'
	Exec sp_executesql @Str	

End
Else
	SELECT  IDS,[Item Code],[Item Name],[Quantity],Volume,[Sales Price],[Invoice UOM],[Invoice Qty],[Sales Tax],[Tax Suffered],Discount,STCredit,Total,[Forum Code],[Tax Suffered Value],[Sales Tax Value] 			
	From #TempItemDetails Order By [Item Code]

 Drop Table #tempCategory1
 Drop Table #TempItemDetails


