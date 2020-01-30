CREATE Procedure sp_DandDTaxComponents
(@ID int, @Product_code nvarchar(30))
AS
BEGIN
--Variable Declartion
Declare @i int,
@reccnt int,
@nTax_Code  int,
@nTaxComponent_code int,
@dTax_percentage  decimal(18,6),
@nCS_ComponentCode  int,
@nComponentType  int,
@nApplicableonComp  int,
@nApplicableOnCode int,
@nApplicableUOM int,
@dPartOff decimal(5,2),
@lFirstPoint int,
@nTaxOnAmt decimal(18,6),
@ntaxamount decimal(18,6),
@nTotTaxAmount decimal(18,6),
@uom1 decimal(18,6),
@uom2 decimal(18,6),
@TotalAmount Decimal(18,6),
@comp_taxamt Decimal(18,6)

Declare @BatchCode int,
@nQty Decimal(18,6),
@TaxSuff Decimal(18,6),
@PTS Decimal(18,6),
@TOQ int,
@GRNTaxID int,
@GRNTaxType int

Declare @GSTCSTaxCode int
Declare @nMultiplier Decimal(18,6)
Declare @TaxableAmount Decimal(18,6)
Declare @BatchAmount Decimal(18,6)

Set @nMultiplier = 1

Create Table #taxcompcalc
(
tmp_id	int identity(1,1),
tmp_Tax_Code	int,
tmp_TaxComponent_code	int,
tmp_Tax_percentage	decimal(18,6),
tmp_ApplicableOn	nvarchar(max),
tmp_SP_Percentage	decimal(18,6),
tmp_LST_Flag	int,
tmp_CS_ComponentCode	int,
tmp_ComponentType	int,
tmp_ApplicableonComp	int,
tmp_ApplicableOnCode	int,
tmp_ApplicableUOM	int,
tmp_PartOff	decimal(5,2),
tmp_TaxType	int,
tmp_FirstPoint	int,
tmp_GSTComponentCode	int,
tmp_CompLevel	int,
tmp_comp_taxamt	decimal(18,6)
)

Declare @RegistrationStatus Int

Select @RegistrationStatus = Case When ISNULL(GSTIN,'') = '' Then 2 Else 1 End  from DandDAbstract where ID = @ID

Declare Cur Cursor FOR
--	Select BP.Batch_Code, D.RFAQuantity,isnull(BP.TaxSuffered,0),BP.PTS,BP.TOQ,BP.GRNTAXID,
--		TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
--		From DandDDetail D,Batch_products BP Where BP.Batch_Code= D.Batch_Code
--		and D.Product_code=@Product_Code and ID=@ID

Select DD.Batch_Code, DD.RFAQuantity, isnull(DD.TaxSuffered,0), DD.PTS, BP.TOQ, DD.TAXID, DD.TaxType,
DD.BatchTaxableAmount, DD.BatchAmount
From DandDDetail DD
Join Batch_Products BP ON DD.Product_Code = BP.Product_Code and DD.Batch_Code = BP.Batch_Code
Where
DD.Product_Code=@Product_Code and DD.ID=@ID

Open Cur
Fetch From Cur Into	@BatchCode,@nQty,@TaxSuff,@PTS,@TOQ,@GRNTaxID,@GRNTaxType,@TaxableAmount,@BatchAmount
While @@Fetch_status = 0
Begin
Set @GSTCSTaxCode = 0
Set @TotalAmount = 0
Set @nTotTaxAmount = 0
Set @ntaxamount = 0
Set @comp_taxamt = 0

Select @GSTCSTaxCode = CS_TaxCode From Tax Where Tax_Code = @GRNTaxID
IF @GSTCSTaxCode > 0
Begin
--Insert TaxComponents records into Temp table
Insert Into #taxcompcalc
(	tmp_Tax_Code		,	tmp_TaxComponent_code	,	tmp_Tax_percentage	,	tmp_ApplicableOn	,
tmp_SP_Percentage	,	tmp_LST_Flag			,	tmp_CS_ComponentCode,	tmp_ComponentType	,
tmp_ApplicableonComp,	tmp_ApplicableOnCode	,	tmp_ApplicableUOM	,	tmp_PartOff			,
tmp_TaxType			,	tmp_FirstPoint			,	tmp_GSTComponentCode,	tmp_CompLevel		,
tmp_comp_taxamt		)
Select
Tax_Code			,	TaxComponent_code		,	Tax_percentage		,	ApplicableOn		,
SP_Percentage		,	LST_Flag				,	CS_ComponentCode	,	ComponentType		,
ApplicableonComp	,	ApplicableOnCode		,	ApplicableUOM		,	PartOff				,
CSTaxType				,	FirstPoint				,	GSTComponentCode	,	CompLevel			,
0
From	TaxComponents (nolock)
Where	Tax_Code	= @GRNTaxID
And		CSTaxType		= @GRNTaxType
And (isnull(RegisterStatus,0) =  0 or isnull(RegisterStatus,0) = isnull(@RegistrationStatus,0))
Order By CompLevel

Select @i = 1
Select @reccnt = max(tmp_id) From  #taxcompcalc

--Total Tax Calculation
IF (@reccnt <> 0 )
Begin
While(@i <= @reccnt)
Begin
Select 	@nTax_Code = tmp_Tax_Code,
@nTaxComponent_code = tmp_TaxComponent_code,
@dTax_percentage  = tmp_Tax_percentage,
@nCS_ComponentCode = tmp_CS_ComponentCode,
@nComponentType = tmp_ComponentType,
@nApplicableonComp = tmp_ApplicableonComp,
@nApplicableOnCode = tmp_ApplicableOnCode,
@nApplicableUOM =  tmp_ApplicableUOM,
@dPartOff =  tmp_PartOff,
@lFirstPoint = tmp_FirstPoint
From	#taxcompcalc
Where	tmp_id = @i

IF (@nApplicableonComp = 0)
Begin
IF (@nApplicableOnCode = 7)
Begin
Select @uom1 = UOM1_Conversion,
@uom2 = UOM2_Conversion
From Items (nolock)
Where Product_Code = @Product_code

Select @ntaxamount = Case @nApplicableUOM
When 1 then @nQty * @nMultiplier * @dTax_percentage
When 2 then ((@nQty * @nMultiplier) / @uom1) * @dTax_percentage
When 3 then ((@nQty * @nMultiplier) / @uom2) * @dTax_percentage
End
End

Else
Begin
--Select @nTaxOnAmt =	Case @dPartOff When 100 Then @PTS Else (@PTS * @dPartOff / 100) End
Select @ntaxamount = @TaxableAmount * (@dTax_percentage / 100)
End
End
Else
Begin
Select @comp_taxamt	= tmp_comp_taxamt
From   #taxcompcalc
--Where  tmp_ApplicableonComp = @nApplicableonComp
Where  tmp_CS_ComponentCode = @nApplicableonComp

Select @ntaxamount = @comp_taxamt * (@dTax_percentage / 100)
select @ntaxamount,@comp_taxamt,@nApplicableonComp
End

Insert Into DandDTaxComponents(DandDID,Product_Code,Batch_code,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
Select @ID,@Product_code,@BatchCode,@GRNTaxType,@nTax_Code,@nTaxComponent_code,@dTax_percentage,@ntaxamount

--Update component wise tax amount
Update	#taxcompcalc
Set		tmp_comp_taxamt =	@ntaxamount
Where	tmp_id = @i
and		tmp_ApplicableonComp = @nApplicableonComp

Select  @nTotTaxAmount = @nTotTaxAmount + @ntaxamount

Select @i = @i+1
End
End

End
Else
Begin
IF @TOQ = 1
Begin
Select @nTotTaxAmount = @nQty * @TaxSuff
End
Else
Begin
--Select @nTotTaxAmount = (@nQty * @PTS) * (@TaxSuff/100)
Select @nTotTaxAmount = @TaxableAmount * (@TaxSuff/100)
End
End

--Select @TotalAmount = (@nQty * @PTS) + @nTotTaxAmount
Select @TotalAmount = @BatchAmount + @nTotTaxAmount
Truncate Table #taxcompcalc

Update DandDDetail Set TaxAmount = @nTotTaxAmount ,TotalAmount = @TotalAmount
Where ID = @ID and Product_Code = @Product_code and Batch_Code = @BatchCode

Fetch Next From Cur Into @BatchCode,@nQty,@TaxSuff,@PTS,@TOQ,@GRNTaxID,@GRNTaxType,@TaxableAmount,@BatchAmount
End
Close Cur
Deallocate Cur

Update DandDDetail Set BatchRFAValue = (BatchAmount + isnull(TaxAmount,0)) - isnull(BatchSalvageValue,0) Where Product_Code=@Product_Code and ID=@ID

Drop Table #taxcompcalc
END
