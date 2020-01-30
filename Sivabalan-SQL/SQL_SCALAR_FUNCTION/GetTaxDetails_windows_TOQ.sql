Create Function [dbo].[GetTaxDetails_windows_TOQ] (@InvNo int, @type int = 0)
Returns nvarchar(2000)
As
Begin

	Declare @Result nvarchar(2000)
	Declare @InvNos nvarchar(200)
	Declare @AdjDocs Int
	Declare @Tax int
	Declare @SP_Per int
	Declare @Sale_Value Decimal(18,2)
	Declare @Tax_Amt Decimal(18,2)
	Declare @Total_Tax_Amt Decimal(18,2)
	Declare @Total_Sale_Value Decimal(18,2)
	Declare @Customer_Type int
	Declare @ActualTaxPercentage nvarchar(15)
	Declare @ActualTaxCompPercentage nvarchar(15)
	Declare @sp_percentage Decimal(18,2)

	Declare @tmpInvTaxComp Table (IDS Int Identity(1, 1), InvoiceID Int,
	Product_Code nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxType Int, Tax_Code Int,
	Tax_Component_Code Int, Tax_Percentage Decimal(18, 6), SP_Percentage Decimal(18, 6),
	Tax_Value Decimal(18, 6))

	Insert Into @tmpInvTaxComp Select * From invoicetaxcomponents where invoiceid  = @InvNo

	Set @InvNos= Cast(@InvNo as nvarchar(10)) + ','

	Declare AdjustedDocs Cursor Keyset For
	Select DocumentID from CollectionDetail where CollectionID = 
	(Select PaymentDetails from InvoiceAbstract where InvoiceID=@InvNo and DocumentType in (1,4))
	Open AdjustedDocs
	Fetch From AdjustedDocs into @AdjDocs
	While @@Fetch_Status = 0	
	Begin
		Set @InvNos = IsNull(@InvNos, N'') + cast(@AdjDocs as nvarchar(10)) + ','
	Fetch Next From AdjustedDocs into @AdjDocs
	End

	Set @InvNos = Left(IsNull(@InvNos, N''),Len(@InvNos)-1)
	Set @Result = '  |' + Space(18) +'Tax Details   ' + Space(15) + '|;'

	Set @Total_Tax_Amt= 0.00
	set @Total_Sale_Value=0.00
	Set @Customer_Type=2

	Set @Result =  IsNull(@Result, N'') + '|Tax Rate|  Sale         |Comp%  |      TaxAmt   |' + ';'

	Declare TaxData Cursor Keyset For
	Select Cast(Tax_Code as Decimal(18,3)) TaxCode,cast(Sum(SalesValue) as Decimal(18,2)) NetSalesValue,cast(SP_Per as Decimal(18,3)),Cast(Sum(TaxCompValue) as Decimal(18,2)) TaxValue,
	isnull(sp_percentage,0) sp_percentage
	From
	(Select ID.InvoiceID,ID.Product_Code,ITC.Tax_Code, (Select Case When (Select Top 1 ApplicableOn from Taxcomponents Where TaxComponent_Code in(
				Select Top 1 Tax_Component_Code from InvoiceTaxComponents where InvoiceID in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
				And Tax_Component_Code=ITC.Tax_Component_Code) and Tax_Code=ITC.Tax_code)= 'Price' then Cast((SUM(ID.Quantity) * Max(ID.SalePrice)) - Max(ID.DiscountValue) as Decimal(18,2))
	Else Cast(((Max(ITC.Tax_Value) / ITC.tax_Percentage)* 100) as decimal(18,2))
	End) SalesValue,
	Cast(ITC.Tax_Component_Code as Decimal(18,3)) SP_Per,
	Cast(max(ITC.Tax_Value) as Decimal(18,2)) TaxCompValue,
	isNull((Select Top 1 Percentage From Tax Where Tax_Code = ITC.Tax_Code),0) Percentage,
	isNull(SP_Percentage,0) sp_percentage
	from @tmpInvTaxComp ITC,InvoiceDetail ID
	Where	ITC.InvoiceID=ID.InvoiceID
	and		ITC.InvoiceID in (select invoiceid from invoiceabstract where invoicetype in (1,3) and invoiceid in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N',')))
	and		ITC.Product_Code=ID.Product_Code
	and		ITC.InvoiceID in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
	and		IsNull(ITC.Tax_Value,0) > 0
	and		ID.FlagWord = 0
	and		ID.SalePrice>0
	Group by ID.Product_Code,ITC.Tax_code,ITC.tax_Percentage,ID.InvoiceID,ITC.Tax_Component_Code,
	ID.FlagWord, ITC.IDS, isNull(SP_Percentage,0)

	Union ALL

	Select InvoiceID,Product_Code,Cast(TaxID as Decimal(18,3)) TaxCode,
	Cast((SUM(Quantity) * Max(SalePrice)) - Max(DiscountValue) as Decimal(18,2)) SalesValue,
	Cast('0.00' as Decimal(18,3)) SP_Per,
	Cast(Sum(StPayable) as Decimal(18,3)) TaxCompValue ,
	isNull(TaxCode,0) as Percentage, 0 as sp_Percentage
	from InvoiceDetail where InvoiceID in (select invoiceid from invoiceabstract where invoicetype in (1,3) and invoiceid in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N',')))
	and InvoiceID in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N',')) and TaxID Not In(
	Select ID.TaxID from InvoiceTaxComponents ITC,InvoiceDetail ID
	Where	ITC.InvoiceID=ID.InvoiceID
	and		ITC.InvoiceID in (select invoiceid from invoiceabstract where invoicetype in (1,3) and invoiceid in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N',')))
	and		ITC.Product_Code=ID.Product_Code
	and		ITC.InvoiceID  in (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
	and		Tax_Value > 0
	and		ID.FlagWord = 0
	and		ID.SalePrice>0
	Group by ID.TaxID)
	Group by Taxid,Product_Code,InvoiceID,TaxCode) TempData
	Group By Tax_Code,SP_Per,Percentage, isnull(sp_percentage,0)
	--order By TaxCode Asc,SP_Per Desc
	Order By Percentage desc,SP_Per Desc

	Open TaxData
	Fetch From TaxData into @Tax,@Sale_Value,@SP_Per,@Tax_Amt, @sp_percentage
	While @@Fetch_Status = 0
	Begin

		Set @ActualTaxPercentage=''
		Set @ActualTaxCompPercentage='0.00'

		if @tax>0
		Begin
			Select @ActualTaxPercentage=Cast(Cast(Percentage as Decimal(18,3))as Nvarchar(15)) From Tax Where Tax_Code=@Tax
		End

		if @sp_per>0
		Begin
			Select @ActualTaxCompPercentage=Cast(Cast(Tax_Percentage as Decimal(18,3))as Nvarchar(15)) From TaxComponents Where TaxComponent_code=@sp_per and Tax_code=@tax
		end

		DECLARE @TmptaxDetails  Table (TaxRowID Int Identity(1,1),TaxPercentage nVarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,
		SalesValue nVarchar(100) Collate SQL_Latin1_General_CP1_CI_AS,
		Comppercentage nVarchar(10) Collate SQL_Latin1_General_CP1_CI_AS,
		TaxAmount nVarchar(100) Collate SQL_Latin1_General_CP1_CI_AS,
		sp_percentage decimal(18,6), Tax_percentage_order decimal(18,6))

		Insert Into @TmptaxDetails
		Select @ActualTaxPercentage,  @Sale_Value, @ActualTaxCompPercentage, @Tax_Amt, @sp_percentage, @ActualTaxPercentage

		Set @Total_Tax_Amt=@Total_Tax_Amt + @Tax_Amt
		set @Total_Sale_Value=@Total_Sale_Value+@Sale_Value

		Fetch Next From TaxData into @Tax,@Sale_Value,@SP_Per,@Tax_Amt, @sp_percentage
	End

	If @type = 0
	Begin
		Set @Result =  IsNull(@Result, N'')
		+ '|' + Cast(@ActualTaxPercentage as nvarchar(15)) + Space(7 -Len(Cast(@ActualTaxPercentage as nvarchar(15))))
		+ '|' + Space(15 -len(Cast(@Sale_Value as nvarchar(10)))) + Cast(@Sale_Value as nvarchar(10))
		+ '|' + Space(7 -Len(Cast(@ActualTaxCompPercentage as nvarchar(15)))) + Cast(@ActualTaxCompPercentage as nvarchar(15))
		+ '|' + Space(15 -len(Cast(@Tax_Amt as nvarchar(10)))) + Cast(@Tax_Amt as nvarchar(10))
		+ '|;'

		Set @Result = SubString(@Result, 3, Len(@Result) - 2)
		Set @Result= @Result + '|Total'
		+ Space(42 - Len (Cast(@Total_Tax_Amt as nvarchar(10)))) + Cast(@Total_Tax_Amt as nvarchar(10))
		+ '|;'
	End
	Else
	Begin
		Set @Result = ''
		Declare @Per as nVarchar(10)
		If (@type = 1)
		--Select @Result = @Result  + '||'+ Replicate(' ',1) + (Case len(Substring(TaxPercentage,1,CharIndex('.',TaxPercentage,1)-1)) When 1 Then Cast('0' as nVarchar(1)) + Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(15)) Else Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(15)) End) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc


			Select @Result = @Result + '||' + Replicate(' ',10 - Len((Case len(Substring(TaxPercentage,1,CharIndex('.',TaxPercentage,1)-1)) When 1 Then Cast('0' as nVarchar(1)) + Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(9)) Else Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(9)) End))) + (Case len(Substring(TaxPercentage,1,CharIndex('.',TaxPercentage,1)-1)) When 1 Then Cast('0' as nVarchar(1)) + Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(9)) Else Cast(Cast(TaxPercentage as Decimal(18,3)) as nVarchar(9)) End) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc
		Else If (@type = 2)
			Select @Result = @Result + '||' + Replicate('  ',7 -len(Substring(SalesValue,1,CharIndex('.',SalesValue,1)-1)))  + Cast(Cast(SalesValue as Decimal(18,2)) as nVarchar) + Replicate(' ',1) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc

		--	Select @Result = @Result + '||' + Replicate(' ',12 -len(Cast(Cast(SalesValue as Decimal(18,2)) as nVarchar)))  + Cast(Cast(SalesValue as Decimal(18,2)) as nVarchar) + Replicate(' ',1) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc

		Else If (@type = 3)
			Select @Result = @Result + '||' + Replicate(' ',1) + (Case len(Substring(Comppercentage,1,CharIndex('.',Comppercentage,1)-1)) When 1 Then Cast('0' as nVarchar(1)) + Cast(Cast(Comppercentage as Decimal(18,3)) as nVarchar(15)) Else Cast(Cast(Comppercentage as Decimal(18,3)) as nVarchar(15)) End) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc
		Else If (@type = 4)
			Select @Result = @Result  + '||' +  Replicate('  ',7 -len(Substring(TaxAmount,1,CharIndex('.',TaxAmount,1)-1))) + Cast(Cast(TaxAmount as Decimal(18,2)) as nVarchar) + Replicate(' ',1) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc
		--	Select @Result = @Result  + '||' +  Replicate(' ',12 -len(Cast(Cast(TaxAmount as Decimal(18,2)) as nVarchar))) + Cast(Cast(TaxAmount as Decimal(18,2)) as nVarchar) + Replicate(' ',1) From  @TmptaxDetails order by Tax_percentage_order desc, sp_percentage desc
		Else If (@type = 5)
			Select @Result = Cast(@Total_Tax_Amt as nvarchar(11))
	End
	Close TaxData
	Deallocate TaxData

	Return @Result
End
