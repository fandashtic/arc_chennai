
CREATE PROCEDURE sp_update_item(@ITEM_CODE nvarchar(15),
@DESCRIPTION nvarchar(255),
@CATEGORYID int,
@MANUFACTURERID nvarchar(15),
@BRANDID int,
@UOM int,
@PURCHASE_PRICE Decimal(18,6),
@SALE_PRICE Decimal(18,6),
@SALE_TAX Decimal(18,6),
@MRP Decimal(18,6),
@PREFERRED_VENDOR nvarchar(15),
@STOCK_NORM Decimal(18,6),
@MOQ Decimal(18,6),
@TRACK_BATCHES int,
@OPENING_STOCK Decimal(18,6),
@OPENING_STOCK_VALUE Decimal(18,6),
@SCHEMEID int,
@CONVERSION_FACTOR Decimal(18,6),
@CONVERSION_UNIT int,
@ACTIVE int,
@SALEID int,
@PURCHASED_AT int,
@COMPANY_PRICE Decimal(18,6),
@PTS Decimal(18,6),
@PTR Decimal(18,6),
@TAXSUFFERED Decimal(18,6),
@SOLDAS nvarchar(50),
@FORUMCODE nvarchar(20),
@REPORTINGUOM Decimal(18,6),
@REPORTINGUNITS Decimal(18,6),
@TRACKPKD int,
@VIRTUAL_TRACK_BATCHES int,
@WAREHOUSEID nvarchar(20),@AutoSC int=0,
@TAXINCLUSIVE Decimal(18,6) = 0,
@TAXINCLUSIVERATE Decimal(18,6) = 0,
@HYPERLINK nvarchar(256) = N'',
@EXCISEDUTY int = 0,
@ADHOCAMOUNT Decimal(18,6) = 0,
@Vat Int = 0,
@CollectTaxSuffered Int = 0,
@UserDefinedCode nvarchar(255) = Null,
@CASEUOM Int = 0,
@CASECONVERSION Decimal(18,6)= 0,
@PFM Decimal(18,6) =0,
@ASL int=0,
@TOQ_Purchase int=0,
@TOQ_Sales int=0
,@GSTProdCatID Int = 0
,@GSTHSNNum nVarChar(15)
)
AS

DECLARE @ORIG_ALIAS nvarchar(15)
Declare @VirtualTrackBatch int

--Track Batch value changed from 'Yes' to 'No' then set Batch_Number to null
Select @VirtualTrackBatch = Virtual_Track_Batches From Items Where Product_Code = @ITEM_CODE

If @VirtualTrackBatch = 1 And @VIRTUAL_TRACK_BATCHES = 0
Begin
Update Batch_Products Set Batch_Number = '' Where Product_Code = @ITEM_CODE
Update DDD Set DDD.Batch_Number = '' From DandDDetail DDD
Join DandDAbstract DDA On DDA.ID = DDD.ID And DDA.ClaimStatus in (1,2)
Where DDD.Product_code = @ITEM_CODE
End

If @VirtualTrackBatch = 0 and @VIRTUAL_TRACK_BATCHES = 0 And @TRACKPKD = 0
Begin
Update batch_products set batch_Number='', PKD = '' where Product_code = @ITEM_CODE
Update invoicedetail set batch_Number=''  where Product_code = @ITEM_CODE
Update vanstatementdetail set batch_Number=''  where Product_code = @ITEM_CODE
Update adjustmentreturndetail set batchNumber=''  where Product_code = @ITEM_CODE
Update stockadjustment set batch_Number=''  where Product_code = @ITEM_CODE
Update stocktransferindetail set batch_Number=''  where Product_code = @ITEM_CODE
Update stocktransferoutdetail set batch_Number=''  where Product_code = @ITEM_CODE
Update vantransferdetail set batchNumber=''  where Product_code = @ITEM_CODE
Update sodetail set batch_Number=''  where Product_code = @ITEM_CODE
Update DDD Set DDD.Batch_Number = '' From DandDDetail DDD
Join DandDAbstract DDA On DDA.ID = DDD.ID And DDA.ClaimStatus in (1,2)
Where DDD.Product_code = @ITEM_CODE
End

Declare @PriceOption int
SELECT @ORIG_ALIAS = IsNull(Alias,N'') From Items Where Product_Code = @ITEM_CODE
IF @ORIG_ALIAS <> @FORUMCODE
BEGIN
Update StockTransferOutDetailReceived Set Product_Code = @ITEM_CODE
Where ForumCode = @FORUMCODE
Update stock_request_detail_received Set Product_Code = @ITEM_CODE
Where ForumCode = @FORUMCODE
if(@AutoSc=1)
update itemclosingstock set Item_ForumCode=@ForumCode where product_code=@Item_Code
END

-- Stcok verification for DeActive item in Batch_products and van
If @ACTIVE = 0
Begin
Declare @Quantity decimal(18,6)
Declare @VanQuantity decimal(18,6)
Select @Quantity = Sum(Quantity) from Batch_Products Where Product_Code = @ITEM_CODE
Select @VanQuantity = Sum(Pending)  from VanStatementDetail where Product_Code = @ITEM_CODE
if (IsNull(@Quantity,0) + IsNull(@VanQuantity,0)) > 0
Set @Active = 1
End

UPDATE Items SET Description = @DESCRIPTION,
CategoryID = @CATEGORYID,
ManufacturerID = @MANUFACTURERID,
BrandID = @BRANDID,
UOM = @UOM,
Purchase_Price = @PURCHASE_PRICE,
Sale_Price = @SALE_PRICE,
Sale_Tax = @SALE_TAX,
MRPPerPack = @MRP,
Preferred_Vendor = @PREFERRED_VENDOR,
StockNorm = @STOCK_NORM,
MinOrderQty = @MOQ,
Track_Batches = @TRACK_BATCHES,
Opening_Stock = @OPENING_STOCK,
Opening_Stock_Value = @OPENING_STOCK_VALUE,
SchemeID = @SCHEMEID,
ConversionFactor = @CONVERSION_FACTOR,
ConversionUnit = @CONVERSION_UNIT,
Active = @ACTIVE,
SaleID = @SALEID,
Purchased_At = @PURCHASED_AT,
Company_Price = @COMPANY_PRICE,
PTS = @PTS,
PTR = @PTR,
ECP = @SALE_PRICE,
TaxSuffered = @TAXSUFFERED,
SoldAs = @SOLDAS,
Alias = @FORUMCODE,
ReportingUOM = @REPORTINGUOM,
ReportingUnit = @REPORTINGUNITS,
TrackPKD = @TRACKPKD,
Virtual_Track_Batches = @VIRTUAL_TRACK_BATCHES,
SupplyingBranch = @WAREHOUSEID,
ModifiedDate = GetDate(),
TaxInclusive = @TAXINCLUSIVE,
TAXINCLUSIVERATE = @TAXINCLUSIVERATE ,
HYPERLINK = @HYPERLINK,
ExciseDuty = @EXCISEDUTY,
AdhocAmount = @ADHOCAMOUNT,
Vat = @Vat,
CollectTaxSuffered = @CollectTaxSuffered,
UserDefinedCode = @UserDefinedCode,
Case_UOM= @CASEUOM, Case_Conversion = @CASECONVERSION,
PFM = @PFM,
ASL=@ASL,
TOQ_Purchase=@TOQ_Purchase,
TOQ_Sales=@TOQ_Sales
,CategorizationID = @GSTProdCatID
,HSNNumber = @GSTHSNNum
WHERE Product_Code = @ITEM_CODE


Select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEM_CODE)
If @PriceOption = 0
Begin
UPDATE Batch_Products SET
SalePrice = @SALE_PRICE,
Company_Price = @COMPANY_PRICE,
PTS = @PTS,
PTR = @PTR,
ECP = @SALE_PRICE ,
PFM = @PFM
WHERE Product_Code = @ITEM_CODE  And isnull(free,0) <> 1

End

--DSTypeWiseSKU DataPost
exec sp_DSTypeWiseSKU_DataPost

