CREATE PROCEDURE [sp_put_SODocFooter](
@Product_Code	[nvarchar](15),
@Quantity	Decimal(18,6),
@SalePrice	Decimal(18,6),
@SaleTax	Decimal(18,6),
@Discount	Decimal(18,6),
@SONumber	[int],
@TaxSuffered		Decimal(18,6)=0.0,
@TaxSuffApplicableOn	Int=0,
@TaxSuffPartOff		Decimal(18,6)=0.0,
@TaxApplicableOn	Int=0,
@TaxPartOff		Decimal(18,6)=0.0
)

AS INSERT INTO [SODetailReceived]( 
[Product_Code],
[Quantity],
[SalePrice],
[SaleTax],
[Discount],
[SONumber],
[TaxSuffered],
[TaxSuffApplicableOn],
[TaxSuffPartOff],
[TaxApplicableOn],
[TaxPartOff]

) 
 
VALUES (
@Product_Code,
@Quantity,
@SalePrice,
@SaleTax,
@Discount,
@SONumber,
@TaxSuffered,
@TaxSuffApplicableOn,
@TaxSuffPartOff,
@TaxApplicableOn,
@TaxPartOff
)




