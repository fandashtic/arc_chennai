Create PROCEDURE sp_get_InvDetails_MUOM_ITC (@CustomerID NVARCHAR(15), @Inv_No INT)
AS
Declare @Customer_Type as Int
Declare @Locality as int
Declare @ChannelTypeCode nvarchar(15)
Declare @RegisterStatus int
Declare @GSTIN nvarchar(30)

Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer Where CustomerID = @CustomerID

Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap
Inner Join tbl_mERP_OLClass OLClass ON OLMap.OLClassID = OLClass.ID
Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

Select BP.Batch_Code, BP.Product_Code, BP.PTR, BP.PTS, BP.ECP, BP.Company_Price,BP.Free, BP.MRPPerPack,
Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR'
Into #TmpBatchChannelPTR From Batch_Products BP
Left Join BatchWiseChannelPTR C ON BP.Batch_Code = C.Batch_Code and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0

SELECT @Customer_Type = CustomerCategory,@locality =locality  FROM Customer WHERE CustomerID = @CustomerID

SELECT GrossValue, DiscountPercentage, DiscountValue, NetValue,
AdditionalDiscount, Freight, NewReference, CreditTerm, ReferenceNumber, Memo1,
Memo2, Memo3, PaymentDate, PaymentMode, DocReference, InvoiceDate, "SalesManID"=IsNull(IA.SalesmanID,0),
IsNull(AdjustmentValue, 0), Balance, PaymentDetails,TaxOnMRP,"DocumentType" =DocSerialType  ,
SchemeID , SchemeDiscountPercentage , SchemeDiscountAmount , Status,DeliveryStatus,VanNumber,
"BeatID"=IsNull(IA.BeatID,0),"GroupID"=IsNull(GroupID,'-1'),"BeatName" =IsNull(Bt.Description,''),
"SalesManName" =IsNull(SM.SalesMan_Name,''),"DeliveryDate" = DeliveryDate,
"InvoiceSchemeID" = IsNull(IA.InvoiceSchemeID,''), "MultipleSchemeDetails" = IsNull(MultipleSchemeDetails,''),
"SupervisorID" = isNull(Salesman2,0),"SupervisorName" = isNull((Select SalesmanName From Salesman2 Where SalesmanID = isNull(IA.Salesman2,0)),'')
FROM InvoiceAbstract IA,Beat Bt,SalesMan sm
WHERE InvoiceID = @Inv_No
and IA.BeatID=Bt.BeatID and IA.SalesManID=SM.SalesManID

Select @GSTIN = isnull(GSTIN,'') FROM InvoiceAbstract WHERE InvoiceID = @Inv_No

SELECT Company_Name, BillingAddress, ShippingAddress, NoOfBillsOutstanding, @GSTIN as TIN_Number --TIN_Number
FROM Customer
WHERE CustomerID = @CustomerID

SELECT InvDt.Product_Code AS "ProductCode", ProductName, MIN(InvDt.Batch_Code),
InvDt.Batch_Number, SUM(InvDt.UOMQty), IsNull(InvDt.saleprice,0), Price_Option,
IsNull(MAX(InvDt.TaxCode), 0), SUM(InvDt.DiscountPercentage), SUM(InvDt.DiscountValue),
SUM(InvDt.Amount), Track_Batches, ItemCategories.Track_Inventory , InvDt.SaleID,
IsNull(MAX(InvDt.TaxCode2), 0),
--padhu
IsNull(MAX(InvDt.TaxSuffered), 0),
IsNull(MAX(TaxSuffered2), 0),
InvDt.UOM, IsNull(UOM.Description,N''), InvDt.SalePrice, SUM(InvDt.Quantity),
IsNull(BP.Free,0),
--Isnull(Case @Customer_Type When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
(Case When Price_Option = 0 And Track_Inventory =0 then
Isnull(Case @Customer_Type When 1 Then Max(Items.PTS) When 2 Then Max(Items.PTR) ELSE Max(Items.Company_Price )End,0)
Else
Isnull(Case @Customer_Type When 1 Then Max(BP.PTS) When 2 Then Max(BP.ChannelPTR) ELSE Max(BP.Company_Price) End,0) End),
InvDt.MRP,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, SCHEMEDISCPERCENT = IsNull(InvDt.SCHEMEDISCPERCENT,0), SCHEMEDISCAMOUNT = IsNull(Max(InvDt.SCHEMEDISCAMOUNT),0),
SPLCATDISCPERCENT = IsNull(InvDt.SPLCATDISCPERCENT,0), SPLCATDISCAMOUNT = IsNull(Max(InvDt.SPLCATDISCAMOUNT),0),
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SchemeID),0) SCHEME_INDICATOR,
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR
,"SPBED" = InvDt.SalePriceBeforeExciseAmount, "ExciseDuty" = InvDt.ExciseDuty,
"PTS" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.PTS),0) Else ISNULL(Max(BP.PTS), 0) End),
"PTR" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.PTR),0) Else ISNULL(Max(BP.PTR), 0) End),
"ECP" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.ECP),0) Else ISNULL(Max(BP.ECP), 0) End),
"Company_Price" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.Company_Price),0) Else ISNULL(Max(BP.Company_Price), 0) End),
Max(InvDt.TaxSuffApplicableOn) 'TaxSuffApplicableOn', Max(InvDt.TaxSuffPartOff) 'TaxSuffPartOff',
Max(InvDt. TaxApplicableOn) 'TaxApplicableOn', Max(InvDt.TaxPartOff) 'TaxPartOff' ,
case when @locality = 1 then max(stpayable) else max(cstpayable) end as Stpayable,
max(stcredit) as StCredit,max(taxamount) as TaxAmount,Max(taxsuffamount) as TaxSuffAmount, IsNull(InvDt.OtherCG_Item,0) as OtherCG_Item , Max(Isnull(InvDt.SPLCATCODE,'')) as SPLCATCODE,
"TaxID" = IsNull(max(TAXID),0)
,dbo.fn_GetTaxCode(IsNull(MAX(InvDt.TaxSuffered), 0),Max(InvDt.TaxSuffApplicableOn),Max(InvDt.TaxSuffPartOff) ) as TaxCode,
Max(Isnull(InvDt.QuotationID,0)) as QuotationID, "MultipleSchemeID" = MultipleSchemeID, "TotSchemeAmount" = TotSchemeAmount, "MultipleSplCatSchemeID" = MultipleSplCatSchemeID,
"MultipleSchemeDetails" = MultipleSchemeDetails, "MultipleSplCategorySchDetail" = MultipleSplCategorySchDetail,
"Serial" = InvDt.Serial,"MultipleRebateID" = isNull(MultipleRebateID,''), "RebateRate" = isNull(RebateRate,0),
"MultipleRebateDet" = isNull(MultipleRebateDet,''),
"GroupID" = (Select IsNull(GroupID, 0) From v_mERP_ItemWithCG Where Product_Code = InvDt.Product_Code)
,"MRPPerPack" = isnull(BP.MRPPerPack, 0),"TAXONQTY" = Max(IsNull(TAXONQTY,0))
FROM InvoiceDetail InvDt
Inner Join Items On Items.Product_Code = InvDt.Product_Code
Left Outer Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
Left Outer Join  UOM  On InvDt.UOM = UOM.UOM
Left Outer Join #TmpBatchChannelPTR BP On BP.Batch_Code = InvDt.Batch_Code    --Batch_Products BP
WHERE InvDt.InvoiceID = @Inv_No
group by InvDt.Product_Code, Items.ProductName, InvDt.Batch_Number,
InvDt.UOM, UOM.Description, InvDt.UOMPrice, InvDt.SalePrice,
InvDt.SaleID, Items.Track_Batches, ItemCategories.Price_Option,
ItemCategories.Track_Inventory, Isnull(BP.Free,0),
Isnull(Case @Customer_Type When 1 Then BP.PTS When 2 Then BP.ChannelPTR ELSE BP.Company_Price End,0),
InvDt.MRP,InvDt.Serial,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, IsNull(InvDt.SCHEMEDISCPERCENT,0),  IsNull(InvDt.SPLCATDISCPERCENT,0)
,InvDt.SalePriceBeforeExciseAmount, InvDt.ExciseDuty, InvDt.OtherCG_Item, InvDt.MultipleSchemeID, InvDt.TotSchemeAmount, InvDt.MultipleSplCatSchemeID, InvDt.MultipleSchemeDetails, InvDt.MultipleSplCategorySchDetail
,isNull(MultipleRebateID,''),isNull(RebateRate,0),isNull(MultipleRebateDet,''), isnull(BP.MRPPerPack, 0)
ORDER BY InvDt.Serial

Drop Table #TmpBatchChannelPTR

