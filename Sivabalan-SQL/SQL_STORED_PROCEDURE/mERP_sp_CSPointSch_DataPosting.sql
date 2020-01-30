Create Procedure mERP_sp_CSPointSch_DataPosting(@TransDate as Datetime, @QPS int)
As
Begin
--	Set DateFormat DMY
Declare @DAY_CLOSE DateTime
Select @DAY_CLOSE = dbo.StripTimeFromDate(IsNull(LastInventoryUpload, 'Jan 01 1900')) From SetUp

--Cur_SchInfo values
Declare @SchID Int
Declare @PayoutID int
Declare @PayoutFrom DateTime
Declare @PayoutTo DateTime
Declare @ApplicableOn Int
Declare @ItemGrp Int
Declare @ActiveFrom DateTime
Declare @ActiveTo DateTime
Declare @ExpiryDate DateTime
--Cur_SlabInfo values
Declare @SlabGrpID Int
Declare @SlabID Int
Declare @SlabUOM int
Declare @SlabOnward Decimal(18,6)
Declare @SlabValue Decimal(18,6)
Declare @UnitRate Decimal(18,6)
Declare @SlabStart Decimal(18,6)
Declare @SlabEnd Decimal(18,6)

If @QPS = 0
Begin
Declare Cur_SchInfo Cursor For
Select Distinct SchAbs.SchemeID, SchPP.ID, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo,
SchAbs.ApplicableOn , SchAbs.ItemGroup, SchAbs.ActiveFrom, SchAbs.ActiveTo, SchAbs.ExpiryDate
From tbl_mERP_SchemeAbstract SchAbs,  tbl_mERP_SchemePayoutPeriod SchPP, tbl_mERP_SchemeOutlet SchOtl
Where SchPP.SchemeID = SchAbs.SchemeID And
SchPP.Active = 1 And
SchOtl.QPS = 0 And SchAbs.Active = 1 And
SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0 And
SchAbs.SchemeType = 4 And
@TransDate between SchPP.PayoutPeriodFrom and SchPP.PayoutPeriodTo
End
Else if @QPS = 1
-- QPS
Begin
Declare Cur_SchInfo Cursor For
Select Distinct SchAbs.SchemeID, SchPP.ID, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo,
SchAbs.ApplicableOn , SchAbs.ItemGroup, SchAbs.ActiveFrom, SchAbs.ActiveTo, SchAbs.ExpiryDate
From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP
Where SchAbs.SchemeID = SchOtl.SchemeID And
SchAbs.SchemeID = SchPP.SchemeID And
dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= @DAY_CLOSE And
dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) < dbo.StripTimeFromDate(@TransDate) And
SchOtl.QPS = 1 And SchAbs.Active = 1 And
SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0 And
SchAbs.SchemeType = 4
End
Open Cur_SchInfo
Fetch Next From Cur_SchInfo into @SchID, @PayoutID, @PayoutFrom, @PayoutTo, @ApplicableOn, @ItemGrp, @ActiveFrom, @ActiveTo, @ExpiryDate
While (@@Fetch_status = 0)
Begin

--Get the Customer Scope
Declare @SchemeOutlet table (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID Int,Qps Int)
Delete from @SchemeOutlet
Insert into @SchemeOutlet (CustomerID,GroupID,Qps)
select CustomerId,GroupID,QPS from dbo.mERP_fn_GetSchemeOutletDetails(@SchID) Where QPS = @QPS

--To delete the data if already exists
IF @QPS =1
Begin
Delete from tbl_mERP_CSOutletPointAbstract Where SchemeID = @SchID and PayoutId = @PayoutID and QPS = @QPS
--Delete from tbl_mERP_CSOutletPointDetail Where SchemeID = @SchID and PayoutId = @PayoutID

Delete from tbl_mERP_CSOutletPointDetail
Where SchemeID = @SchID and PayoutId = @PayoutID and GroupId in (
Select Distinct SSG.SubGroupID from tbl_mERP_SchemeOutlet SOL, tbl_mERP_SchemeSubGroup SSG
Where SOL.SchemeID = @SchID and SOL.SchemeID = SSG.SchemeID and  SOL.GroupID = SSG.SubGroupId and SOL.QPS = @QPS)
End
Else if @QPS =0
Begin
Delete from tbl_mERP_CSOutletPointAbstract Where dbo.StripTimeFromDate(TransactionDate) = @TransDate and SchemeID = @SchID and PayoutId = @PayoutID and QPS = @QPS

Delete from tbl_mERP_CSOutletPointDetail
Where SchemeID = @SchID and PayoutId = @PayoutID and dbo.StripTimeFromDate(InvoiceDate) = @TransDate
and GroupId in (Select Distinct SSG.SubGroupID from tbl_mERP_SchemeOutlet SOL, tbl_mERP_SchemeSubGroup SSG
Where SOL.SchemeID = @SchID and SOL.SchemeID = SSG.SchemeID and  SOL.GroupID = SSG.SubGroupId and SOL.QPS = @QPS)
End

If @ApplicableOn = 2	--Invoice based scheme
Begin
--Point scheme Detail data
Insert into tbl_mERP_CSOutletPointDetail(SchemeId, PayoutID, GroupId, InvoiceID, InvoiceDate, InvoiceType, OutletCode, Product_Code,BaseUOMQty,Uom1Qty,Uom2Qty,SaleAmount,TaxAmount,Amount, InvCreationTime)
Select @SchID, @PayoutID, SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, Sum(ID.Quantity) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) BaseUOMQty,
Sum(ID.Quantity / IsNull(I.UOM1_Conversion,1)) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) UOM1Qty,
Sum(ID.Quantity / IsNull(I.UOM2_Conversion,1)) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) UOM2Qty,
Sum(ID.Quantity * ID.SalePrice) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) SaleAmount,
Sum(ID.TaxAmount) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) TaxAmount,
Sum(ID.Amount) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) Amount, IA.CreationTime
From InvoiceAbstract IA,  InvoiceDetail ID, Items I, @SchemeOutlet SchCust
Where IA.InvoiceID = ID.InvoiceID And IA.InvoiceType in(1,3,4) and IA.Status & 128 = 0 And Isnull(ID.FlagWord,0) = 0
And dbo.StripTimeFromDate(IA.Invoicedate) between @ActiveFrom and @ActiveTo
And dbo.StripTimeFromDate(IA.Invoicedate) between dbo.StripTimeFromDate(@PayoutFrom) and dbo.StripTimeFromDate(@PayoutTo)
And dbo.StripTimeFromDate(IA.Invoicedate) = Case @QPS When 0 Then @TransDate Else dbo.StripTimeFromDate(IA.Invoicedate) End
And I.Product_Code = ID.Product_Code
And SchCust.CustomerID = IA.CustomerID
Group by SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, IA.CreationTime
End
Else if @ApplicableOn = 1 -- Item Based
Begin
--Product Scope
Declare @SchemeProducts as Table(SchemeID Int, Product_Code  nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID Int)
Delete from @SchemeProducts
Insert into @SchemeProducts(SchemeID, Product_Code)
Select SchemeID, Product_Code From dbo.mERP_fn_Get_CSSku(@SchID)

--Point Scheme Detail data
Insert into tbl_mERP_CSOutletPointDetail(SchemeId, PayoutID, GroupId, InvoiceID, InvoiceDate, InvoiceType, OutletCode, Product_Code,BaseUOMQty,Uom1Qty,Uom2Qty,SaleAmount,TaxAmount,Amount, InvCreationTime)
Select @SchID, @PayoutID, SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, Sum(ID.Quantity) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) BaseUOMQty,
Sum(ID.Quantity / IsNull(I.UOM1_Conversion,1)) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) UOM1Qty,
Sum(ID.Quantity / IsNull(I.UOM2_Conversion,1)) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) UOM2Qty,
Sum(ID.Quantity * ID.SalePrice) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) SaleAmount,
Sum(ID.TaxAmount) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) TaxAmount,
Sum(ID.Amount) * (Case When (IA.InvoiceType =4 and @QPS =1) Then -1 Else 1 End) Amount, IA.CreationTime
From InvoiceAbstract IA,  InvoiceDetail ID, Items I, @SchemeOutlet SchCust, @SchemeProducts SchProd
Where IA.InvoiceID = ID.InvoiceID And IA.InvoiceType in(1,3,4) and IA.Status & 128 = 0 And Isnull(ID.FlagWord,0) = 0
And dbo.StripTimeFromDate(IA.Invoicedate) between @ActiveFrom and @ActiveTo
And dbo.StripTimeFromDate(IA.Invoicedate) between dbo.StripTimeFromDate(@PayoutFrom) and dbo.StripTimeFromDate(@PayoutTo)
And dbo.StripTimeFromDate(IA.Invoicedate) = Case @QPS When 0 Then @TransDate Else dbo.StripTimeFromDate(IA.Invoicedate) End
And I.Product_Code = SchProd.Product_code
And SchProd.Product_code = ID.Product_Code
And SchCust.CustomerID = IA.CustomerID
Group by SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, IA.CreationTime
End

--Invoice Based Sch
If @ApplicableOn = 2
Begin
--Slabwise Points calculation
Set @SlabGrpID  = 0
Set @SlabID = 0
Set @SlabUOM = 0
Set @SlabOnward = 0
Set @SlabValue = 0
Set @UnitRate = 0
Set @SlabStart = 0
Set @SlabEnd = 0

Declare Cur_SlabInfo Cursor For
Select GroupID, SlabID, UOM, Onward, [Value], UnitRate, SlabStart, SlabEnd
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SChID  And GroupID In (select Distinct GroupID from tbl_mERP_SchemeOutlet where schemeid = @SChID And Isnull(QPS,0) = @QPS)
Open Cur_SlabInfo
Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
While (@@Fetch_Status = 0)
Begin
If @QPS = 0 and @SlabUOM = 4 --Value Based Non QPS
Begin
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate,InvoiceID)
Select PSD.SchemeID, PSD.PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(PSD.Amount)/@SlabOnward) as Int) * @SlabValue End) * (Case PSD.InvoiceType When 4 Then -1 Else 1 End)  as Points, @UnitRate, @TransDate,PSD.InvoiceId
From tbl_mERP_CSOutletPointDetail PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and dbo.StripTimeFromDate(PSD.InvoiceDate) = @TransDate
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 0
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.InvoiceId, PSD.InvoiceType
Having Sum(PSD.Amount) between @SlabStart and @SlabEnd
End
Else If @QPS = 1 and @SlabUOM = 4 --Value Based QPS
Begin
Insert into tbl_mERP_CSOutletPointAbstract(SchemeId, PayoutID, QPS, SlabID, OutletCode,  Points, Rate, TransactionDate)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(PSD.Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
From tbl_mERP_CSOutletPointDetail PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 1
Group by PSD.SchemeID, PSD.PayoutID, PSD.GroupID, PSD.OutletCode
Having Sum(Amount) between @SlabStart and @SlabEnd
End
Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
End
Close Cur_SlabInfo
Deallocate Cur_SlabInfo
End
Else if @ApplicableOn = 1	--Item based schemes
Begin

--Slab base Points calculation
Set @SlabGrpID  = 0
Set @SlabID = 0
Set @SlabUOM = 0
Set @SlabOnward = 0
Set @SlabValue = 0
Set @UnitRate = 0
Set @SlabStart = 0
Set @SlabEnd = 0
Declare Cur_SlabInfo Cursor For
Select GroupID, SlabID, UOM, Onward, [Value], UnitRate, SlabStart, SlabEnd
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SChID And GroupID In (select Distinct GroupID from tbl_mERP_SchemeOutlet where schemeid = @SChID And Isnull(QPS,0) = @QPS)
Open Cur_SlabInfo
Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
While (@@Fetch_Status = 0)
Begin
If @QPS = 0
Begin
If @SlabUOM = 4 --Value Based
Begin
If @ItemGrp = 1	-- Item based
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate,InvoiceID)
Select PSD.SchemeID, PSD.PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(PSD.Amount)/@SlabOnward) as Int) * @SlabValue End) * (Case PSD.InvoiceType When 4 Then -1 Else 1 End) as Points, @UnitRate, @TransDate,PSD.InvoiceId
From tbl_mERP_CSOutletPointDetail PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 0
and dbo.StriptimeFromDate(PSD.InvoiceDate) = @TransDate
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.InvoiceId, PSD.Product_Code, PSD.InvoiceType
Having Sum(Amount) between @SlabStart and @SlabEnd
Else If @ItemGrp = 2 --Spl Category
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate,InvoiceID)
Select PSD.SchemeID, PSD.PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(PSD.Amount)/@SlabOnward) as Int) * @SlabValue End) * (Case PSD.InvoiceType When 4 Then -1 Else 1 End) as Points, @UnitRate, @TransDate,PSD.InvoiceId
From tbl_mERP_CSOutletPointDetail  PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 0
and dbo.StriptimeFromDate(PSD.InvoiceDate) = @TransDate
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.InvoiceId, PSD.InvoiceType
Having Sum(Amount) between @SlabStart and @SlabEnd
End
Else --Quantity based
Begin
--Test
If @ItemGrp = 1	-- Item based
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate,InvoiceID)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case @SlabOnward When 0 Then @SlabValue
--(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End)
Else Cast(((case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.Uom1QTY) else Sum(PSD.UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) * (Case PSD.InvoiceType When 4 Then -1 Else 1 End) as Points, @UnitRate, @TransDate,PSD.InvoiceId
From tbl_mERP_CSOutletPointDetail  PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 0
and dbo.StriptimeFromDate(PSD.InvoiceDate) = @TransDate
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.InvoiceId, PSD.Product_Code, PSD.InvoiceType
Having (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End) Between @SlabStart and @SlabEnd
Else If @ItemGrp = 2 --Spl Category
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate,InvoiceID)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,

(Case @SlabOnward When 0 Then @SlabValue
--(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End)
Else Cast(((case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.Uom1QTY) else Sum(PSD.UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) * (Case PSD.InvoiceType When 4 Then -1 Else 1 End) as Points, @UnitRate, @TransDate,PSD.InvoiceId
From tbl_mERP_CSOutletPointDetail  PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 0
and dbo.StriptimeFromDate(PSD.InvoiceDate) = @TransDate
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.InvoiceId, PSD.InvoiceType
Having (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End) Between @SlabStart and @SlabEnd
End
End
Else if @QPS = 1
Begin
If @SlabUOM = 4 --Value Based
Begin
If @ItemGrp = 1	-- Item based
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(PSD.Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
From tbl_mERP_CSOutletPointDetail   PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 1
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.Product_Code
Having Sum(PSD.Amount) between @SlabStart and @SlabEnd
Else If @ItemGrp = 2 --Spl Category
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
Select PSD.SchemeID, PSD.PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
From tbl_mERP_CSOutletPointDetail   PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 1
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode
Having Sum(PSD.Amount) between @SlabStart and @SlabEnd
End
Else --Quantity based
Begin
If @ItemGrp = 1	-- Item based
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case @SlabOnward When 0 Then @SlabValue
--(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End)
Else Cast(((case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.Uom1QTY) else Sum(PSD.UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
From tbl_mERP_CSOutletPointDetail   PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 1
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode, PSD.Product_Code
Having (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End) Between @SlabStart and @SlabEnd
Else If @ItemGrp = 2 --Spl Category
Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
Select PSD.SchemeID, @PayoutID, @QPS, @SlabID, PSD.OutletCode,
(Case @SlabOnward When 0 Then @SlabValue
--(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End)
Else Cast(((case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.Uom1QTY) else Sum(PSD.UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
From tbl_mERP_CSOutletPointDetail   PSD, @SchemeOutlet SchCust
Where PSD.SchemeID = @SchId and PSD.PayoutID = @payoutID and PSD.GroupID = @SlabGrpID
and SchCust.CustomerID = PSD.OutletCode and SchCust.QPS = 1
Group by PSD.OutletCode, PSD.SchemeID, PSD.PayoutID, PSD.GroupId, PSD.OutletCode
Having (Case @SlabUOM when 1 then Sum(PSD.BaseUOMQty) when 2 then Sum(PSD.UOM1Qty) else Sum(PSD.UOM2Qty) End) Between @SlabStart and @SlabEnd
End
End
Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
End
Close Cur_SlabInfo
Deallocate Cur_SlabInfo
End
If @QPS=1
Begin
Update tbl_mERP_SchemePayoutPeriod Set Status = 128 Where ID= @PayoutID and SchemeID = @SchID
End
/* For SCh Min Qty - FITC-4413 start: */
If @QPS = 1
Begin
If Exists(select * from tbl_merp_schemeAbstract Where SchemeID = @SchID And Isnull(IsMinQty,0)=1)
Begin
Declare @Tmp_CustomerID as Nvarchar(255)
Declare Cur_Cust Cursor for
select Distinct OutletCode from tbl_mERP_CSOutletPointAbstract where schemeid = @SchID and payoutid = @PayoutID And QPS = 1
Open Cur_Cust
Fetch from Cur_Cust into @Tmp_CustomerID
While @@fetch_status =0
Begin
Declare @QPSMinstatus as Table(QPSMinstatus Int)
Delete From @QPSMinstatus
Insert Into @QPSMinstatus
Exec sp_GetQPSPointSchValidation @SchID,@PayoutID,@Tmp_CustomerID

If (Select Top 1 QPSMinstatus From @QPSMinstatus) = 0
Begin
Update tbl_mERP_CSOutletPointAbstract Set SlabId = Null,Points = 0 where schemeid = @SchID and payoutid = @PayoutID And QPS = 1 And OutletCode = @Tmp_CustomerID
End
Fetch Next from Cur_Cust into @Tmp_CustomerID
End
Close Cur_Cust
Deallocate Cur_Cust
End
End
Else If Isnull(@QPS,0) = 0
Begin
If Exists(select * from tbl_merp_schemeAbstract Where SchemeID = @SchID And Isnull(IsMinQty,0)=1)
Begin
Declare @TmpInvoiceItems as Table (
InvoiceID Int,
OutLetCode Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SchemeID Int,
PayoutID Int,
Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6),
Salesvalue Decimal(18,6))
Declare @MinStataus as table (MinStatus Int)

Insert Into @TmpInvoiceItems
Select InvoiceId,OutLetCode,SchemeID,PayoutID,Product_Code,BaseUOMQty,SaleAmount from tbl_mERP_CSOutletPointDetail
Where SchemeId = @SchID And payoutId = @PayoutID-- And InvoiceDate = @TransDate

Declare @Product_Code as Nvarchar(255)
Declare @Quantity as Nvarchar(255)
Declare @TMPAmount as Nvarchar(255)
Declare @TMPOutLetCode as Nvarchar(255)
Declare @tmpStr as Nvarchar(Max)
Declare @TMPInvoiceID as Int
Declare @tmpSchemeId as Int
Declare @tmppayoutId as Int

Declare Cur_tmpInv Cursor for
Select Distinct InvoiceID,OutLetCode,SchemeID,PayoutID from @TmpInvoiceItems
Open Cur_tmpInv
Fetch from Cur_tmpInv into @TMPInvoiceID,@TMPOutLetCode,@tmpSchemeId,@tmppayoutId
While @@fetch_status =0
Begin
If Exists (select * From tbl_merp_schemeAbstract Where Isnull(IsminQty,0) = 1 and SchemeId = @tmpSchemeId)
Begin
Set @tmpStr = ''
Declare Cur_Merge Cursor for
Select Product_Code,Isnull(Quantity,0),Isnull(Salesvalue,0)	from @TmpInvoiceItems Where InvoiceId = @TMPInvoiceID And SchemeID =  @tmpSchemeId And payoutId = @tmppayoutId And OutLetCode = @TMPOutLetCode
Open Cur_Merge
Fetch from Cur_Merge into @Product_Code,@Quantity,@TMPAmount
While @@fetch_status =0
Begin
If Isnull(@tmpStr ,'') <> ''
Begin
Set @tmpStr = @tmpStr + '|' + Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@TMPAmount as Nvarchar)
End
Else
Begin
Set @tmpStr = Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@TMPAmount as Nvarchar)
End
Fetch Next from Cur_Merge into @Product_Code,@Quantity,@TMPAmount
End
Close Cur_Merge
Deallocate Cur_Merge

Delete From @MinStataus
Insert Into @MinStataus
Exec mERP_SP_isAllItemsexistsMinQty @tmpSchemeId,@tmpStr

If (Select Top 1 Isnull(MinStatus,0) From @MinStataus) = 0
Begin
Update tbl_mERP_CSOutletPointAbstract Set SlabID = Null,Points = 0
Where SchemeId = @tmpSchemeId And payoutId = @tmppayoutId And OutletCode = @TMPOutLetCode And QPS = 0 and InvoiceID=@TMPInvoiceID
End
End
Else
Begin
Goto SkipInvoice
End
SkipInvoice:
Fetch Next from Cur_tmpInv into @TMPInvoiceID,@TMPOutLetCode,@tmpSchemeId,@tmppayoutId
End
Close Cur_tmpInv
Deallocate Cur_tmpInv

Delete From @TmpInvoiceItems
Delete From @MinStataus
End
End
/* For SCh Min Qty - FITC-4413 End: */
Fetch Next From Cur_SchInfo into @SchID, @PayoutID, @PayoutFrom, @PayoutTo, @ApplicableOn, @ItemGrp, @ActiveFrom, @ActiveTo, @ExpiryDate
End
Close Cur_SchInfo
Deallocate Cur_SchInfo
End
