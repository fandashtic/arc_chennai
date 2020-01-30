CREATE FUNCTION Fn_Get_OffTake_AchievedScheme()
RETURNS @RetSchemes TABLE (
SchemeID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
, CusCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
, SalesValue Decimal(18,6) Default(0)
, Qty_in_Base_UOM Decimal(18,6) Default(0)
, Qty_in_Base_UOM1 Decimal(18,6) Default(0)
, Qty_in_Base_UOM2 Decimal(18,6) Default(0)
, Product_Code nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS default '' )

AS
BEGIN
DECLARE @tblSch table (
SchemeID int, groupId Int, SchemeIdformat varchar(50), Pcnt Int, SchType Int, SchFromDate Datetime, SchToDate Datetime)

Declare @SchemeID int, @groupId Int, @schemeIdformat varchar(6), @Customer Int, @Pcnt Int, @SchType Int
Declare @SchFromDate Datetime, @SchToDate Datetime
DECLARE @date datetime
SELECT @date = dbo.StripTimeFromDate([vgetdate]) FROM V_getdate

Insert Into @tblSch
Select SchAbs.SchemeID, sch_subgroup.GroupID, cast(sch_subgroup.GroupID as varchar(5))+cast(SchAbs.SchemeID+10000 as varchar(25)),
Case SchSlab.SlabType When 2 Then 1 Else 0 End AS Pcnt,
Case When SchAbs.ApplicableOn = 2 Then (case When SchSlab.SlabType = 3 Then 5 Else 1 End)
When SchAbs.ApplicableOn = 1 Then (case When SchSlab.SlabType = 3 Then 4 Else 2 End) End as SchType,
dbo.StripTimeFromDate(PayPrd.Payoutperiodfrom), dbo.StripTimeFromDate(PayPrd.Payoutperiodto)
from tbl_mERP_SchemeAbstract SchAbs Join ( select schemeId, Min(GroupId) GroupId from tbl_mERP_SchemeOutlet where QPS = 1 Group by schemeId ) SchOlt on SchAbs.SchemeID = SchOlt.SchemeID

Join ( Select Min(slabID) as SlabID, SlabTYpe, SchemeID From tbl_mERP_SchemeSlabDetail Where Isnull(UOM,0) <> 5  Group By SlabTYpe, SchemeID) SchSlab on SchAbs.SchemeID = SchSlab.SchemeID
Join tbl_mERP_SchemePayoutPeriod PayPrd on SchAbs.SchemeID = PayPrd.SchemeID
Join ( select schemeId, Min(subgroupId) subgroupId, groupId from tbl_mERP_SchemeSubGroup group by schemeId, groupId ) sch_subgroup on SchAbs.SchemeID = sch_subgroup.SchemeID
where SchAbs.Active = 1 And
PayPrd.Active = 1 And
@date between dbo.StripTimeFromDate(PayPrd.Payoutperiodfrom) and dbo.StripTimeFromDate(payprd.Payoutperiodto)
and IsNull(SchAbs.schemestatus, 0) In ( 0, 1, 2 )





Declare CurScheme Cursor For
Select SchemeID, groupId, schemeIdformat, Pcnt, SchType, SchFromDate, SchToDate from @tblSch
Open CurScheme
Fetch next From CurScheme Into @SchemeID, @groupId, @schemeIdformat, @Pcnt, @SchType, @SchFromDate, @SchToDate
While(@@fetch_status = 0)
Begin
--------------------

IF (@SchType = 1) or (@SchType = 5)     /*1 - (33 Inv Base Pecr, 34 Inv Base Amt) , 5 - Inv Base FreeItem (35)*/
Begin
Insert into @RetSchemes(SchemeID, Cuscode, SalesValue )
Select @schemeIdformat, InvAb.CustomerID, Sum(Case InvAb.InvoiceType When 4 then 0-NetValue Else NetValue End)
From InvoiceAbstract InvAb, Customer CusMas, tbl_mERP_SchemeAbstract Schemes,
(select SchemeID, CustomerCode, groupId From dbo.mERP_fn_Get_CSOutletScope(@SchemeId,1)) as SchCus
, tbl_mERP_SchemeSubGroup SubGrp
Where InvAb.CustomerId = CusMas.CustomerId
And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchFromDate And @SchToDate
And dbo.StripTimeFromDate(InvAb.Invoicedate) <= @date
And InvAb.InvoiceType In (1,2,3)
And (InvAb.Status & 128)=0
And Schemes.SchemeId = @SchemeId
And SchCus.SchemeId = Schemes.SchemeId
And SchCus.CustomerCode = InvAb.CustomerID
And InvAb.CustomerId <> '0'
and SubGrp.SubGroupID = SchCus.GroupID And SubGrp.SchemeID = SchCus.SchemeID
--   And ( Isnull(schemes.PaymentMode,N'') = N''
--  or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode, schemes.SchemeID) = 1 )
Group by InvAb.CustomerId
End
Else IF( @SchType = 2 ) or (@SchType = 4)     /* 2 - (51 Itm Base Perc, 52 Itm Base Amt), 4 - (49 & 50 - Itm Base Free Itm) */
Begin
Insert into @RetSchemes(SchemeID, Cuscode, SalesValue, Qty_in_Base_UOM, Qty_in_Base_UOM1, Qty_in_Base_UOM2, Product_Code)
Select @schemeIdformat, InvAb.CustomerID,
Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Amount Else InvDet.Amount End),
Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End),
Sum(Case InvAb.InvoiceType When 4 then 0-(InvDet.Quantity / Uom1_conversion) Else InvDet.Quantity / Uom1_conversion End),
Sum(Case InvAb.InvoiceType When 4 then 0-(InvDet.Quantity / Uom2_conversion) Else InvDet.Quantity / Uom2_conversion End),
Invdet.Product_Code
From InvoiceAbstract InvAb, InvoiceDetail InvDet, Customer CusMas, Items,
tbl_mERP_SchemeAbstract Schemes, tbl_mERP_SchemeSubGroup SubGrp,
(Select SchemeID, Product_code from dbo.mERP_fn_Get_CSProductScope(@SchemeId)) as ItemSchemes,
(Select SchemeID, CustomerCode, groupId From dbo.mERP_fn_Get_CSOutletScope(@SchemeId,1)) as SchCus
Where dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchFromDate And @SchToDate
And dbo.StripTimeFromDate(InvAb.Invoicedate) <= @date
And InvAb.InvoiceId=InvDet.InvoiceId
And InvAb.InvoiceType In (1,2,3)
And (InvAb.Status & 128)=0
And InvDet.FlagWord = 0
And Schemes.SchemeId=@SchemeId
And Items.Product_code = InvDet.Product_code
And Items.Product_Code = ItemSchemes.Product_Code
And CusMas.CustomerId = InvAb.CustomerId
And CusMas.CustomerId = SchCus.CustomerCode
And SubGrp.SchemeID = @SchemeId
And SchCus.GroupId = @groupId
And SubGrp.SubGroupID = SchCus.GroupID And SubGrp.SchemeID = SchCus.SchemeID
--  And ( Isnull( schemes.PaymentMode, N'') = N''
--  or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode, schemes.SchemeID) = 1 )
Group by InvAb.CustomerId, Invdet.Product_Code
End
Fetch next From CurScheme Into @SchemeID, @GroupId, @schemeIdformat, @Pcnt, @SchType, @SchFromDate, @SchToDate
End
Close CurScheme
Deallocate CurScheme
RETURN

END

