CREATE FUNCTION dbo.Fn_Quotation_TaxCompCalc
(@ItemCode nvarchar(30),
@TaxID int ,
@TaxType int,
@flag  int,
@RegisterStatus int = 0)
returns decimal(18,6)
AS
BEGIN
--Variable Declartion
declare @i int,
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
@nDiscountedAmount decimal(18,6),
@nQty decimal(18,6),
@nMultiplier decimal(18,6)

Set @nMultiplier = 1
Set @nQty = 1

declare @taxcompcalc table
(
tmp_id int identity(1,1),
tmp_Tax_Code int,
tmp_TaxComponent_code int,
tmp_Tax_percentage decimal(18,6),
tmp_ApplicableOn nvarchar(max),
tmp_SP_Percentage decimal(18,6),
tmp_LST_Flag int,
tmp_CS_ComponentCode int,
tmp_ComponentType int,
tmp_ApplicableonComp int,
tmp_ApplicableOnCode int,
tmp_ApplicableUOM int,
tmp_PartOff decimal(5,2),
tmp_TaxType int,
tmp_FirstPoint int,
tmp_GSTComponentCode int,
tmp_CompLevel int,
tmp_comp_taxamt decimal(18,6)
)

--Tax CS Check
if exists ( select 'x'
from Tax(nolock)
where Tax_Code = @TaxID
and  isnull(CS_TaxCode,0) > 0 )
begin
--Insert TaxComponents records into Temp table
insert into @taxcompcalc
( tmp_Tax_Code  , tmp_TaxComponent_code , tmp_Tax_percentage , tmp_ApplicableOn ,
tmp_SP_Percentage , tmp_LST_Flag   , tmp_CS_ComponentCode, tmp_ComponentType ,
tmp_ApplicableonComp, tmp_ApplicableOnCode , tmp_ApplicableUOM , tmp_PartOff   ,
tmp_TaxType   , tmp_FirstPoint   , tmp_GSTComponentCode, tmp_CompLevel  ,
tmp_comp_taxamt  )
select
Tax_Code   , TaxComponent_code  , Tax_percentage  , ApplicableOn  ,
SP_Percentage  , LST_Flag    , CS_ComponentCode , ComponentType  ,
ApplicableonComp , ApplicableOnCode  , ApplicableUOM  , PartOff    ,
CSTaxType    , FirstPoint    , GSTComponentCode , CompLevel   ,
0
from TaxComponents (nolock)
Where Tax_Code = @TaxID
And  CSTaxType  = @TaxType
and (isnull(RegisterStatus,0) =  0 or isnull(RegisterStatus,0) = isnull(@RegisterStatus,0))
Order By CompLevel

select @i = 1
select @reccnt = max(tmp_id) from  @taxcompcalc

--Total Tax Calculation
if (@reccnt <> 0 )
begin
while(@i <= @reccnt)
begin
select  @nTax_Code = tmp_Tax_Code,
@nTaxComponent_code = tmp_TaxComponent_code,
@dTax_percentage  = tmp_Tax_percentage,
@nCS_ComponentCode = tmp_CS_ComponentCode,
@nComponentType = tmp_ComponentType,
@nApplicableonComp = tmp_ApplicableonComp,
@nApplicableOnCode = tmp_ApplicableOnCode,
@nApplicableUOM =  tmp_ApplicableUOM,
@dPartOff =  tmp_PartOff,
@lFirstPoint = isnull(tmp_FirstPoint,0)
from @taxcompcalc
where tmp_id = @i

if (@nApplicableonComp = 0)
begin
if (@nApplicableOnCode = 7)
begin
select @uom1 = UOM1_Conversion,
@uom2 = UOM2_Conversion
From Items (nolock)
Where Product_Code = @ItemCode

IF @FLAG = 1
select @ntaxamount = Case @nApplicableUOM
when 1 then @nQty * @nMultiplier * @dTax_percentage
when 2 then ((@nQty * @nMultiplier) / @uom1) * @dTax_percentage
when 3 then ((@nQty * @nMultiplier) / @uom2) * @dTax_percentage
end
ELSE
SET @ntaxamount = 0

end
else
begin
--select @nTaxOnAmt = case @dPartOff            when 100 then @nDiscountedAmount
--else (@nDiscountedAmount * @dPartOff / 100 )
--end
IF @FLAG <> 1
select @ntaxamount =  @dTax_percentage
ELSE
SET @ntaxamount = 0

end
end
else
begin
select @nTaxOnAmt   = tmp_comp_taxamt
from   @taxcompcalc
where  tmp_CS_ComponentCode = @nApplicableonComp

select @ntaxamount = @nTaxOnAmt * (@dTax_percentage / 100)
end

--Update component wise tax amount
update @taxcompcalc
set  tmp_comp_taxamt = @ntaxamount
where tmp_id = @i
and  tmp_ApplicableonComp = @nApplicableonComp


select  @nTotTaxAmount = isnull(@nTotTaxAmount,0) + @ntaxamount


select @i = @i+1
end --While
end --Total Tax Calculation
end --Tax Check
else
begin
select  @nTotTaxAmount = 0
end

return  @nTotTaxAmount
END
