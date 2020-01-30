Create Procedure sp_Update_RecItem_ITC(
@ItemID Int,
@CategoryID Int,
@MfrID Int,
@BrandID Int,
@SUOM Int,
@RUOM Int,
@ConversionUnit Int,
@STax Decimal(18,6),
@PTax Decimal(18,6),
@UOM1 Int,
@UOM2 Int)
As
Declare @ForumCode nvarchar(255)
Declare @ItemCode nvarchar(255)
Declare @ItemName nvarchar(255)
Declare @ItemDesc nvarchar(255)
Declare @PurchasePrice Decimal(18,6)
Declare @SalePrice Decimal(18,6)
Declare @MRP Decimal(18,6)
Declare @StockNorm Decimal(18,6)
Declare @MOQ Decimal(18,6)
Declare @TrackBatches Int
Declare @ConversionFactor Decimal(18,6)
Declare @SaleID Int
Declare @StockistMargin Decimal(18,6)
Declare @RetailerMargin Decimal(18,6)
Declare @CompanyMargin Decimal(18,6)
Declare @ReportingUnit Decimal(18,6)
Declare @TrackPKD Int
Declare @VirtualTrackBatches Int
Declare @SoldAs nvarchar(255)
Declare @PTS Decimal(18,6)
Declare @PTR Decimal(18,6)
Declare @ECP Decimal(18,6)
Declare @CompanyPrice Decimal(18,6)
Declare @PurchasedAt Int
Declare @ItemPropCount Int
Declare @PropertyID Int
Declare @PropertyValue nvarchar(255)
Declare @Active Int
Declare @Hyperlink nvarchar(256)
Declare @VAT Int
Declare @COLLECTTAXSUFFERED Int
Declare @AdhocAmount Decimal(18,6)
Declare @TaxInclusive Integer
Declare @TaxInclusiveRate Decimal(18,6)
Declare @PriceOption int
Declare @UOM1_CONVERSION Decimal(18,6)
Declare @UOM2_CONVERSION Decimal(18,6)
Declare @DefaultUOM Int
Declare @Ean_Number nvarchar(50)
Declare @MRPPerPack decimal(18,6)

Declare @UpdateSql nVarChar(4000)
Declare @AllUpdateStatus nVarchar(255)
Declare @EachCNodeStat nVarchar(255)
Declare @ChildNode nVarchar(255)
Declare @ChildNodeStat nVarchar(255)
Declare @Pos Int
Declare @ASL int
Declare @TOQ_Purchase Int
Declare @TOQ_Sales Int
Declare @OldActive int
Declare @NewActive int
Declare @HSNNumber nvarchar(15)
Declare @CategorizationID int
Declare @CategorizationName nvarchar(255)
Declare @GSTEnable Int
Declare @FreeSKUFlag Int


Create Table #AttribPermission(
NodeGramps nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChildNode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Attribute nVarChar(255)   COLLATE SQL_Latin1_General_CP1_CI_AS,
AllowUpdate Integer,
RecPermission Integer,
Permission Integer
)

Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

Select @ForumCode = ForumCode, @ItemCode = Product_Code, @ItemName = ProductName,
@ItemDesc= Description, @PurchasePrice = PurchasePrice, @SalePrice = SalePrice,
@MRP = MRP, @StockNorm = StockNorm, @MOQ = MinOrderQty, @TrackBatches = Track_Batches,
@ConversionFactor = ConversionFactor, @SaleID = SaleID, @StockistMargin = StockistMargin,
@RetailerMargin = RetailerMargin, @CompanyMargin = CompanyMargin,
@ReportingUnit = ReportingUnit, @TrackPKD = TrackPKD,
@VirtualTrackBatches = Virtual_Track_Batches, @SoldAs = SoldAs, @PTS = PTS, @PTR = PTR,
@ECP = ECP, @CompanyPrice = CompanyPrice, @PurchasedAt = PurchasedAt,
@ItemPropCount = ItemPropCount, @Active = Active, @HyperLink = Hyperlink,
@VAT = IsNull(VAT,0), @COLLECTTAXSUFFERED = IsNull(COLLECTTAXSUFFERED,0),
@AdhocAmount = IsNull(AdhocAmount,0),@TaxInclusive = IsNull(TaxInclusive,0),
@TaxInclusiveRate = isNull(TaxInclusiveRate,0),@UOM1_CONVERSION = IsNull(UOM1_CONVERSION,0),
@UOM2_CONVERSION = IsNull(UOM2_CONVERSION,0),@DefaultUOM = IsNull(DefaultUOM,0),
@AllUpdateStatus = isNull(UpdateStatus,''),
@Ean_Number = IsNull(Ean_Number, ''),
@MRPPerPack=isnull(MRPPerPack,0),@ASL = IsNull(ASL,0),@TOQ_Purchase=isnull(TOQ_Purchase,0),@TOQ_Sales=isnull(TOQ_Sales,0),
@HSNNumber = Isnull(HSNNumber, ''),
@CategorizationName   = isnull(CategorizationName,'')  , @FreeSKUFlag=isnull(FreeSKUFlag,0)
From ItemsReceivedDetail
Where ID = @ItemID

set @CategorizationID = 0
select @CategorizationID = ID From ProductCategorization Where CategorizationName = @CategorizationName

--
--Select  Lev1.Category_name "Category",Lev2.Category_name "Sub_Category",Lev3.Category_name "Market_SKU",Items.Product_Code "Product_Code"
--  Into #tempCategoryList1
--  from itemCategories lev1,itemCategories lev2,itemCategories lev3,Items
--  Where Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid And
--  Items.Categoryid = Lev3.CategoryID  And Items.Product_code = @ItemCode

select @OldActive = Active From Items Where Product_code = @ItemCode

If isnull(@STax,0) = 0
Begin
Set @STax = isnull((select Top 1 Sale_Tax From items Where Product_Code = @ItemCode),0)
End
If isnull(@PTax,0) = 0
Begin
Set @PTax = isnull((select Top 1 TaxSuffered From items Where Product_Code = @ItemCode),0)
End

if Len(LTrim(@AllUpdateStatus)) = 0
Begin
Set @AllUpdateStatus = '22222222222222222222222222222222222222222222'
End

Insert InTo #AttribPermission
(NodeGramps,ChildNode,Attribute,AllowUpdate,RecPermission,Permission)
Select A.NodeGramps,A.ChildNode,A.Attributes,A.AllowUpdate,SubString(@AllUpdateStatus,A.Sno,1),A.AllowUpdate+Cast(SubString(@AllUpdateStatus,A.Sno,1) as Integer)
from ItemsRecUpdateStatus A
Where A.NodeGramps='Items'

if Not Exists(Select Product_Code from Items Where Product_Code <> @ItemCode and Alias = @FORUMCODE)
Begin

Set @VirtualTrackBatches = @TrackBatches
If @TrackPKD = 1
Begin
Set @TrackBatches = 1
End

-- Stcok verification for DeActive item in Batch_products and van
If @ACTIVE = 0
Begin
Declare @Quantity decimal(18,6)
Declare @VanQuantity decimal(18,6)
Select @Quantity = Sum(Quantity) from Batch_Products Where Product_Code = @ItemCode
Select @VanQuantity = Sum(Pending)  from VanStatementDetail where Product_Code = @ItemCode
if (IsNull(@Quantity,0) + IsNull(@VanQuantity,0)) > 0
Set @Active = 1
End

Set @UpdateSQL = ''
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ItemName') > 1
Set @UpdateSQL = @UpdateSQL + ', ProductName =''' + @ItemName + ''''
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'Desc') > 1
Set @UpdateSQL = @UpdateSQL + ', Description =''' + @ItemDesc + ''''
If (Select Permission from #AttribPermission Where ChildNode = 'Category' And Attribute = 'Category') > 1
Set @UpdateSQL = @UpdateSQL + ', CategoryID =' + Cast(@CategoryID as nVarChar)
If (Select Sum(Permission) from #AttribPermission Where ChildNode = 'Miscellaneous' And Attribute In ('Mfr','Brand')) > 2
Set @UpdateSQL = @UpdateSQL + ', ManufacturerID =' + Cast(@MfrID as nVarChar) + ', BrandID =' + Cast(@BrandID as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Miscellaneous' And Attribute = 'SUOM') > 1
Set @UpdateSQL = @UpdateSQL + ', UOM =' + Cast(@SUOM as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PurchasePrice') > 1
Set @UpdateSQL = @UpdateSQL + ', Purchase_Price =' + Cast(@PurchasePrice as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'SalePrice') > 1
Set @UpdateSQL = @UpdateSQL + ', Sale_Price =' + Cast(@SalePrice as nVarChar)

If @GSTEnable = 0
Begin
If (Select Permission from #AttribPermission Where ChildNode = 'Tax' And Attribute = 'STax') >= 1
Set @UpdateSQL = @UpdateSQL + ', Sale_Tax =' + Cast(@STax as nVarChar)
End

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'MRP') > 1
Set @UpdateSQL = @UpdateSQL + ', MRP =' + Cast(@MRP as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'StockNorm') > 1
Set @UpdateSQL = @UpdateSQL + ', StockNorm =' + Cast(@StockNorm as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'MOQ') > 1
Set @UpdateSQL = @UpdateSQL + ', MinOrderQty =' + Cast(@MOQ as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TrackBatches') > 1
Set @UpdateSQL = @UpdateSQL + ', Track_Batches =' + Cast(@TrackBatches as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ConversionFactor') > 1
Set @UpdateSQL = @UpdateSQL + ', ConversionFactor =' + Cast(@ConversionFactor as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Miscellaneous' And Attribute = 'ConversionUnit') > 1
Set @UpdateSQL = @UpdateSQL + ', ConversionUnit =' + Cast(@ConversionUnit as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'Active') > 1
Set @UpdateSQL = @UpdateSQL + ', Active =' + Cast(@Active as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'SaleID') > 1
Set @UpdateSQL = @UpdateSQL + ', SaleID =' + Cast(@SaleID as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'SplPrice') > 1
Set @UpdateSQL = @UpdateSQL + ', Company_Price =' + Cast(@CompanyPrice as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PTS') > 1
Set @UpdateSQL = @UpdateSQL + ', PTS =' + Cast(@PTS  as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PTR') > 1
Set @UpdateSQL = @UpdateSQL + ', PTR =' + Cast(@PTR as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ECP') > 1
Set @UpdateSQL = @UpdateSQL + ', ECP =' + Cast(@ECP as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PurchasedAt') > 1
Set @UpdateSQL = @UpdateSQL + ', Purchased_At =' + Cast(@PurchasedAt as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'CompanyMargin') > 1
Set @UpdateSQL = @UpdateSQL + ', Company_Margin =' + Cast(@CompanyMargin as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'StockistMargin') > 1
Set @UpdateSQL = @UpdateSQL + ', Stockist_Margin =' +  Cast(@StockistMargin as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'RetailerMargin') > 1
Set @UpdateSQL = @UpdateSQL + ', Retailer_Margin =' + Cast(@RetailerMargin as nVarChar)

If @GSTEnable = 0
Begin
If (Select Permission from #AttribPermission Where ChildNode = 'Tax' And Attribute = 'PTax') >= 1
Set @UpdateSQL = @UpdateSQL + ', TaxSuffered =' + Cast(@PTax as nVarChar)
End

If (Select Permission from #AttribPermission Where ChildNode = 'Miscellaneous' And Attribute = 'SoldAs') > 1
Set @UpdateSQL = @UpdateSQL + ', SoldAs =''' +  @SoldAs + ''''
If (Select Permission from #AttribPermission Where ChildNode = 'Miscellaneous' And Attribute = 'RUOM') > 1
Set @UpdateSQL = @UpdateSQL + ', ReportingUOM =' + Cast(@RUOM as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ReportingUnit') > 1
Set @UpdateSQL = @UpdateSQL + ', ReportingUnit =' + Cast(@ReportingUnit as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TrackPKD') > 1
Set @UpdateSQL = @UpdateSQL + ', TrackPKD =' + Cast(@TrackPKD as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'VirtualTrackBatches') > 1
Set @UpdateSQL = @UpdateSQL + ', Virtual_Track_Batches =' + Cast(@VirtualTrackBatches as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'VAT') > 1
Set @UpdateSQL = @UpdateSQL + ', VAT =' + Cast(@VAT as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'COLLECTTAXSUFFERED') > 1
Set @UpdateSQL = @UpdateSQL + ', COLLECTTAXSUFFERED =' + Cast(@COLLECTTAXSUFFERED as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ADHOCAMOUNT') > 1
Set @UpdateSQL = @UpdateSQL + ', AdhocAmount =' + Cast(@AdhocAmount as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TAXINCLUSIVE') > 1
Set @UpdateSQL = @UpdateSQL + ', TaxInclusive =' + Cast(@TaxInclusive as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TAXINCLUSIVERATE') > 1
Set @UpdateSQL = @UpdateSQL + ', TaxInclusiveRate =' + Cast(@TaxInclusiveRate as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'UOM1') > 1
Set @UpdateSQL = @UpdateSQL + ', UOM1 =' + Cast(@UOM1 as nVarChar)

--If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'UOM1CONVERSION') > 1
--Set @UpdateSQL = @UpdateSQL + ', UOM1_Conversion =' + Cast(@UOM1_CONVERSION as nVarChar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'UOM2') > 1
Set @UpdateSQL = @UpdateSQL + ', UOM2 =' + Cast(@UOM2 as nVarChar)

--If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'UOM2CONVERSION') > 1
--Set @UpdateSQL = @UpdateSQL + ', UOM2_Conversion =' + Cast(@UOM2_CONVERSION as nVarChar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'DEFAULTUOM') > 1
Set @UpdateSQL = @UpdateSQL + ', DefaultUOM =' + Cast(@DefaultUOM as nVarChar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'EAN_NUMBER') > 1
Set @UpdateSQL = @UpdateSQL + ', EAN_NUMBER =''' + @Ean_Number  + ''''

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'HEALTHCAREITEM') > 1
Set @UpdateSQL = @UpdateSQL + ', ASL =' + Cast(@ASL as nVarchar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TOQ_PURCHASE') > 1
Set @UpdateSQL = @UpdateSQL + ', TOQ_Purchase =' + Cast(@TOQ_Purchase as nVarchar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'TOQ_SALES') > 1
Set @UpdateSQL = @UpdateSQL + ', TOQ_Sales =' + Cast(@TOQ_Sales as nVarchar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'HSNNumber') > 1
Set @UpdateSQL = @UpdateSQL + ', HSNNumber =''' + @HSNNumber + ''''

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'CategorizationName') > 1
Set @UpdateSQL = @UpdateSQL + ', CategorizationID =' + Cast(@CategorizationID as nVarchar)

If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'FreeSKUFlag') > 1
Set @UpdateSQL = @UpdateSQL + ', FreeSKUFlag =' + Cast(@FreeSKUFlag as nVarchar)

if Len(@UpdateSQL) > 0
Set @UpdateSQL = 'Update Items Set ' + SubString(@UpdateSQL,2,Len(@UpdateSQL)) + ' Where Product_Code = ''' + @ItemCode  + ''''
if Len(@UpdateSQL) > 0
Exec sp_SQLexec @UpdateSQL
Update Items set MRPPerPack= @MRPPerPack where Product_Code=@ItemCode

-- Issue: Previously, If transactions created for the Item it is updating the UOM1Conversion and UOM2Conversion
-- Now, we are checking for the Transactions for the ItemCode. If Not created then it will update in Item master.
IF Not EXISTS ( SELECT TOP 1 Product_Code From SODetail WHERE Product_Code  = @ItemCode ) and
Not EXISTS ( SELECT TOP 1 Product_Code From InvoiceDetail Where Product_Code  = @ItemCode) and
Not EXISTS ( SELECT TOP 1 Product_Code From Batch_Products Where Product_Code  = @ItemCode ) and
Not EXISTS ( SELECT TOP 1 Product_Code From BillDetail where Product_Code  = @ItemCode ) and
Not EXISTS ( SELECT TOP 1 Product_Code From GRNDetail where Product_Code  = @ItemCode ) and
Not EXISTS ( SELECT TOP 1 Product_Code From AdjustmentReturnDetail Where Product_Code  = @ItemCode) and
Not EXISTS ( SELECT TOP 1 Product_Code From stocktransferinDetail Where Product_Code  = @ItemCode) and
Not EXISTS ( SELECT TOP 1 Product_Code From stocktransferoutDetail Where Product_Code  = @ItemCode)
begin
Update Items Set UOM1_Conversion = Cast(@UOM1_CONVERSION as nVarChar) Where Product_Code = @ItemCode
Update Items Set UOM2_Conversion = Cast(@UOM2_CONVERSION as nVarChar) Where Product_Code = @ItemCode
end




select @NewActive = Active From Items Where Product_code = @ItemCode

insert into tempCatList2
Select  Lev1.Category_name "Category",Lev2.Category_name "Sub_Category",Lev3.Category_name "Market_SKU",Items.Product_Code "Product_Code"
from itemCategories lev1 with (nolock),itemCategories lev2 with (nolock) ,itemCategories lev3 with (nolock),Items with (nolock)
Where Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid And
Items.Categoryid = Lev3.CategoryID  And Items.Product_code = @ItemCode

----validate for ItemCategory Changed or not
if exists(select tempCatList2.Category From tempCatList1,tempCatList2 Where
tempCatList1.Category  = tempCatList2.Category  And
tempCatList1.Sub_Category = tempCatList2.Sub_Category  And
tempCatList1.Market_SKU   = tempCatList2.Market_SKU  And
tempCatList1.Product_Code = tempCatList2.Product_Code And
tempCatList1.id = @ItemID	)
Begin
if (@OldActive <>@NewActive)
Update ItemsReceivedDetail  SEt SchFlag = 1 Where ID = @ItemID
else
Update ItemsReceivedDetail  SEt SchFlag = 2 Where ID = @ItemID
End
Else
Begin
Update ItemsReceivedDetail  SEt SchFlag = 1 Where ID = @ItemID
End


Truncate  table tempCatList2
Truncate table tempCatList1

select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEMCODE)
If @PriceOption = 0
Begin
Set @UpdateSQL = ''
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'SalePrice') > 1
Set @UpdateSQL = @UpdateSQL + ', SalePrice =' + Cast(@SalePrice as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'SplPrice') > 1
Set @UpdateSQL = @UpdateSQL + ', Company_Price =' + Cast(@CompanyPrice as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PTS') > 1
Set @UpdateSQL = @UpdateSQL + ', PTS =' + Cast(@PTS  as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'PTR') > 1
Set @UpdateSQL = @UpdateSQL + ', PTR =' + Cast(@PTR as nVarChar)
If (Select Permission from #AttribPermission Where ChildNode = 'Info' And Attribute = 'ECP') > 1
Set @UpdateSQL = @UpdateSQL + ', ECP =' + Cast(@ECP as nVarChar)
if Len(@UpdateSQL) > 0
Set @UpdateSQL = 'UPDATE Batch_Products SET ' + SubString(@UpdateSQL,2,Len(@UpdateSQL)) + ' Where Product_Code = ''' + @ItemCode  + ''' and (IsNull([Free],0) <> 1) '
if Len(@UpdateSQL) > 0
Exec sp_SQLexec @UpdateSQL
Update Batch_Products set MRPPerPack= @MRPPerPack where Product_Code=@ItemCode and (IsNull([Free],0) <> 1)
End

Select 1,@ForumCode, @ItemCode
END
Else
Select 0, @ForumCode, @ItemCode

Drop Table #AttribPermission
--Drop Table #tempCategoryList1
--Drop table #tempCategoryList2


