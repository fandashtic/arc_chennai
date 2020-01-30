Create Procedure mERP_Sp_ProcessSchemeAbstract (@SchID int)
AS
Declare @CSRecSchemeID nVarchar(255)
Declare @Errmessage nVarchar(255)
Declare @ActCode  nVarchar(255)
Declare @SchDesc nVarchar(255)
Declare @Color  nVarchar(50)

Declare @SchType nVarchar(10)
Declare @ApplOn nVarchar(255)
Declare @SKUGrp nVarchar(255)
Declare @RFA int
Declare @ClaimedAs nVarchar(255)
Declare @SchMonth nVarchar(255)
Declare @DownloadedOn Datetime
Declare @Month int
Declare @Year int
Declare @SchFromDate datetime
Declare @tempToDate datetime
Declare @SChToDate datetime
Declare @ActiveFrom datetime
Declare @ActiveTo datetime
Declare @TActiveTo datetime
Declare @SKuCount int
Declare @Active int
Declare @Budget Decimal(18,6)
Declare @CSStatus int
Declare @RecdID int

Declare @SChtypeID int
Declare @SchapplyOnID int
Declare @SKUGrpID int

Declare @AYear int
Declare @AMonth int

Declare @TranDate datetime
Declare @TActiveFrom datetime

Declare @ExpiryDate datetime

--38477
DEclare @PayoutFrequency nVarchar(255)
DEclare @BudgetOverrun int
Declare @Uniformallocflag int
Declare @Payoutperiod nVarchar(4000)
Declare @SchemeStatus int
Declare @GraceDays int

Declare @ViewDate datetime
Declare @SchSubtype nVarchar(255)

Declare @Date nVarchar(4000)
Declare @PayoutFrom datetime
Declare @PayoutTo datetime

Declare @Drop int
Set @Drop = 0

Declare @Expired int
Set @Expired = 0

Declare @PayoutStatusNew Int
Set @PayoutStatusNew  = 0


Create table #tmp (Date nVarchar(4000))
Create table #tmp2 (Date nVarchar(4000))
Create table #Payout(ID int Identity(1,1), SchemeID int , PayoutFrom datetime, PayoutTo datetime)

Set DateFormat DMY

Select @RecdID = CS_SchemeID, @CSRecSchemeID = CS_RecSchID, @ActCode = CS_ActCode, @SchDesc = CS_Description, @Color = CS_Color
, @SChType = CS_Type, @ApplOn = CS_ApplicableOn, @DownloadedOn = CS_DownloadedOn
, @SKUGrp = CS_SKUGroup, @RFA = CS_RFAApplicable, @ClaimedAs = CS_ClaimedAs, @SchMonth = CS_Month
, @ActiveFrom = dbo.StripTimeFromDate(CS_ActiveFrom), @ActiveTo = dbo.StripTimeFromDate(CS_ActiveTo), @SKuCount = CS_SKUCount, @Active = CS_Active
, @Budget = CS_Budget, @CSStatus = CS_Status,  @ExpiryDate = dbo.StripTimeFromDate(CS_ExpiryDate)
, @PayoutFrequency = CS_PayoutFrequency
, @BudgetOverrun = CS_BudgetOverRun , @Uniformallocflag = CS_UniformAllocFlag, @Payoutperiod = CS_PayoutPeriod
, @GraceDays = GraceDays, @ViewDate = dbo.StripTimeFromDate(CS_ViewDate), @SchSubtype = CS_SchSubType
from tbl_mERP_RecdSchAbstract Where CS_SchemeID = @SchID

--TCL Changes
Declare @TLCSlabUOM Int
Select @TLCSlabUOM = Max(CS_UOM) From tbl_mERP_RecdSchSlabDetail Where CS_SChemeID = @SchID

If Isnull(@TLCSlabUOM,0) = 5
Begin
Set @TLCSlabUOM = 1
End
Else
Begin
Set @TLCSlabUOM = 0
End

Declare @ActivityExist int

If Exists (Select SchemeID from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode)
Begin
Set @ActivityExist = 1
End

If (select Count(ActivityCode)  from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >= 1
Begin
Set @PayoutStatusNew = 6
End

If (Upper(@SChType) = 'PR')
Begin
Set @ClaimedAs = ''
Set @Budget = 0
Set @Uniformallocflag = 0
Set @Payoutperiod = ''
Set @SKuCount = 0
Set @BudgetOverrun = 0
End


If ((Upper(@SChType) = 'SP')  Or (Upper(@SChType) = 'CP') Or (upper(@SChType) = 'DISPLAY') Or (upper(@SChType) = 'POINTS') Or (upper(@SChType) = 'PR'))
Begin
Set @ExpiryDate = dbo.StripTimeFromDate(@ActiveTo) + @GraceDays
Set @ExpiryDate = dbo.StripTimeFromDate(@ExpiryDate)
End

If (Upper(@SChType) = 'DISPLAY')
Begin
If (IsNull(@Budget,0) <=0)
Begin
Set @Errmessage = 'Budget value should not be zero value for display scheme'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End

If (Upper(@SChType) <> 'PR')
Begin
If (IsNull(@Payoutperiod, '') =  '')
Begin
Set @Errmessage = 'Payout Period should not be null'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End

If IsNull(@PayoutFrequency, '') <> ''
Begin
If ltrim(@PayoutFrequency) = 'Monthly'
Set @PayoutFrequency = 0
Else If ltrim(@PayoutFrequency) = 'Quarterly'
Set @PayoutFrequency = 1
Else If ltrim(@PayoutFrequency) = 'Half Yearly'
Set @PayoutFrequency = 2
Else If ltrim(@PayoutFrequency) = 'Yearly'
Set @PayoutFrequency = 3
Else
Set @PayoutFrequency = 4
End


If IsNull(@CSRecSchemeID, '') = ''
Begin
Set @Errmessage = 'Central SChemeID has null value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End

If ( Select Count(*) from tbl_mERP_SchemeAbstract Where CS_RecSchID = @CSRecSchemeID) >= 1
Begin
Set @Errmessage = 'Central SchemeID must be Unique'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End

If IsNull(@ActCode,'') = ''
Begin
Set @Errmessage = 'Activity Code has null value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End

/*Chk in RecdScheme table for any recd Scheme already exists with processed status */
If ( Select Count(*) from tbl_mERP_RecdSchAbstract Where CS_RecSchID = @CSRecSchemeID and CS_Flag & 32 = 32) >= 1
Begin
Set @Errmessage = 'Central SchemeID must be Unique'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @CSRecSchemeID and CS_Flag & 32 = 0  and CS_Flag & 64 = 0
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End

If Not (upper(@SChType) = 'SP' Or upper(@SChType) = 'CP' Or upper(@SChType) = 'DISPLAY' Or upper(@SChType) = 'POINTS' Or upper(@SChType) = 'PR')
Begin
Set @Errmessage = 'Scheme Type should be SP/CP/Display/Points/PR'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End

If (Upper(@SChType) = 'PR')
Begin
If Not (upper(@ApplOn) = 'LINE')
Begin
Set @Errmessage = 'Applicable On should be Line for Price Rebate scheme[PR]'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End

If (Upper(@SChType) = 'PR')
Begin
If Not (@RFA = 0)
Begin
Set @Errmessage = 'RFAApplicable Value should be 0 for Price Rebate[PR] Scheme'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End



--If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If Not (upper(@ApplOn) = 'LINE' Or upper(@ApplOn) = 'INVOICE')
Begin
Set @Errmessage = 'Applicable On should be Line/Invoice'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End

If (Upper(@SChType) <> 'PR')
Begin
If Not (@RFA = 1 Or @RFA = 0)
Begin
Set @Errmessage = 'RFAApplicable Value should be 0/1'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End


If (Len((IsNull(@SchMonth,''))) > 6)
Begin
Set @Errmessage = 'Scheme Month Should be in the Format of YYYYMM'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End

-- If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If Not (upper(@ClaimedAs) = 'AMOUNT' Or upper(@ClaimedAs) = 'ITEM')
Begin
Set @Errmessage = 'ClaimedAs should be Amount /SPL_CATEGORY'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End


--If (IsNull(@SchMonth,'') <> '')
--Begin
-- Set @Year= Left(@SchMonth, 4)
-- Set @month = Right(@SchMonth, 2)
-- if (Month(@ActiveFrom) <> cast(Right(@SchMonth,2) as Integer))
-- Begin
--  Set @Errmessage = 'Mismatch in Scheme Month'
--  Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
--  Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
--  Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
--  Select -1,@Errmessage
--  Goto Skip
-- End
--    If @month > 12
-- Begin
--  Set @Errmessage = 'Month Should be Less than 12'
--  Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
--  Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
--  Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
--  Select -1,@Errmessage
--  Goto Skip
-- End
-- Else
-- Begin
-- Set @SchFromDate =Cast(Cast(1 as nvarchar) + Cast(N'-' as nvarchar) + Cast(@Month as nVarChar) + CAst(N'-' as nvarchar) + Cast(@Year As nVarChar) as DateTime)
-- Set @tempToDate = DateAdd(month, 1, @SchFromDate)
-- Set @SChToDate = DateAdd(day, -1, @tempToDate)
-- End
--End

If (@ActiveFrom > @ActiveTo )
Begin
Set @Errmessage = 'Active From Period should not be greater than ActiveTo Period'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End

If Not (@ActiveFrom >= @SchFromDate and @ActiveFrom <= @ActiveTo) And (@ActiveTo >=@SchFromDate and @ActiveTo <= @SChToDate)
Begin
Set @Errmessage = 'Active From and To Period lie between Scheme Period'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End

--If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If ((LTrim(upper(@ApplOn)) = 'LINE') and ((Ltrim(upper(@SKUGrp)) <> 'SKU') and (LTrim(upper(@SKUGrp)) <> 'SPL_CATEGORY')))
Begin
Set @Errmessage = 'SKUGroup should be SKU/SPL_CATEGORY for Item based Schemes'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto skip
End
End

-- If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If ((upper(@ApplOn) = 'INVOICE') and (@SKuCount =0))
Begin
Set @Errmessage = 'Lines in Bill should be atleast 1 value for Invoice'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
End


-- @SChType
If (Upper(@SChType) = 'SP')
Begin
Select @SChtypeID = ID from tbl_mERP_SchemeType Where SchemeType = 'SP'
End
Else If (Upper(@SChType) = 'CP')
Begin
Select @SChtypeID = ID from tbl_mERP_SchemeType Where SchemeType = 'CP'
End
Else If (Upper(@SChType) = 'DISPLAY')
Begin
Select @SChtypeID = ID from tbl_mERP_SchemeType Where SchemeType = 'DISPLAY'
End
Else If (Upper(@SChType) = 'POINTS')
Begin
Select @SChtypeID = ID from tbl_mERP_SchemeType Where SchemeType = 'POINTS'
End
Else If (Upper(@SChType) = 'PR')
Begin
Select @SChtypeID = ID from tbl_mERP_SchemeType Where SchemeType = 'PR'
End


If (Upper(@SChType) = 'PR')
Begin
If (Upper(@ApplOn) = 'LINE')
Begin
Select @SchapplyOnID = ID from tbl_mERP_SchemeApplicableType Where ApplicableOn ='LINE'
End
Else
Begin
Set @Errmessage = 'PriceTo Rebate scheme will have the value for Applicable on is LINE'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
End

If (Upper(@SChType) = 'PR')
Begin
If (upper(@SKUGrp) <> 'SKU')
Begin
Set @Errmessage = 'PriceTo Rebate scheme will have the Sku Group as SKU. Spl_category not allowed for PR'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
End

If (Upper(@SChType) = 'PR')
Begin
If (upper(@SKUGrp) = 'SKU')
Begin
Select @SKUGrpID = ID from tbl_mERP_SchemeItemGroup Where ItemGroup = 'SKU'
End
End



--If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If (Upper(@ApplOn) = 'LINE')
Begin
Select @SchapplyOnID = ID from tbl_mERP_SchemeApplicableType Where ApplicableOn ='LINE'
End
Else
Begin
Select @SchapplyOnID = ID from tbl_mERP_SchemeApplicableType Where ApplicableOn ='INVOICE'
End
End

--If (Upper(@SChType) <> 'DISPLAY')
If ((Upper(@SChType) <> 'DISPLAY') And (Upper(@SChType) <> 'PR'))
Begin
If (upper(@SKUGrp) = 'SKU')
Begin
Select @SKUGrpID = ID from tbl_mERP_SchemeItemGroup Where ItemGroup = 'SKU'
End
Else
Begin
Select @SKUGrpID = ID from tbl_mERP_SchemeItemGroup Where ItemGroup = 'SPL_CATEGORY'
End
End
--------- Begin: New ActivityCode Validation If Duplicated --------------------------------------
-- Select * from tbl_mERP_SchemeAbstract
Declare @ActFrom datetime
Declare @Actto datetime

Select @TranDate  = dbo.StripTimeFromDate(TransactionDate)  from setup
Select @TActiveTo = dbo.StripTimeFromDate(ActiveTo) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and Active = 1


-- CC commented on 11.10.2010
--If (@TranDate = @ActiveTo)
--Begin
--Set @Errmessage = 'Invalid Scheme: Tran Date Equals to ActiveTo Period'
--Insert Into tbl_mERP_SchemeAbstract
--(CS_RecSchID, CS_SchemeID, ActivityCode, Description, Color, SchemeType ,
--ApplicableOn, ItemGroup, RFAApplicable, ClaimedAs, SchemeMonth,
--SchemeFrom, SchemeTo, ActiveFrom, ActiveTo, DownloadedOn, Active,
--SKUCount, Budget, CS_Status, SchMonth, ExpiryDate)
--Values
--(@CSRecSchemeID, @RecdID, @ActCode, @SchDesc, @Color, @SChtypeID,
--@SchapplyOnID, @SKUGrpID, @RFA, @ClaimedAs, @SchMonth,
-- @ActiveFrom, @ActiveTo, @ActFrom, @ActTo,   @DownloadedOn,  0,
--@SKuCount, @Budget, @CSStatus, @SchMonth, @ExpiryDate)
--
--Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
--Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
--Select -1,@Errmessage
--Goto Skip
--End


--If (@TranDate  = @ActiveFrom and @TranDate  = @ActiveTo)
--Begin
--Set @Errmessage = 'Tran Date Equals to ActiveFrom and ActiveTo Period'
--Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
--Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
--Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
--Select -1,@Errmessage
--Goto Skip
--End
-- CC commented on 11.10.2010

Declare @MaxSchemeID int
Declare @ExistingSchActiveTo datetime
Select @MaxSchemeID = Max(SchemeID) from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode

Set @ExistingSchActiveTo = null
Select @ExistingSchActiveTo = dbo.StripTimeFromDate(ActiveTo) from tbl_mERP_SchemeAbstract Where SchemeID = @MaxSchemeID

If (IsNull(@ActivityExist,0) <> 1)
Begin
If ((Upper(@SChType) = 'SP')  Or (Upper(@SChType) = 'CP') OR (Upper(@SChType) = 'PR') OR (Upper(@SChType) = 'POINTS') OR (Upper(@SChType) = 'DISPLAY') )
Begin
If ((@ActiveTo) < (@TranDate))
Begin
Set @Errmessage = 'ActiveTo Date lesser than Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else If (@ActiveFrom <= @TranDate and @ActiveTo = @TranDate)
Begin
Set @Errmessage = 'To Date is equal to Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else If (@TranDate = @ActiveFrom and @TranDate  = @ActiveTo)
Begin
Set @Errmessage = 'Tran Date Equals to ActiveFrom and ActiveTo Period'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else
Set @SchemeStatus = 0
End
End


Declare @DrSchemeID int
Declare @DrActivityCode  nVarchar(1000)
Declare @DrActiveFrom Datetime
Declare @DrActiveTo Datetime
Declare @DropPayoutPeriodto Datetime
Declare @PayoutID int
Declare @LatestPayoutID int

-- For TradeSChemes
If ((Upper(@SChType) = 'SP')  Or (Upper(@SChType) = 'CP') OR (Upper(@SChType) = 'PR'))
Begin
If (@TranDate between @ActiveFrom and @ActiveTo)
Begin
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom and @ActFrom <=@ActiveTo )
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo =  dbo.StripTimeFromDate(@ActiveTo)
End

If (select Count(ActivityCode)  from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >=1
Begin
If (IsNull(@Active,0) = 1)
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom)= 0
Begin
Update tbl_mERP_SchemeAbstract Set Active = 0 where ActivityCode = @ActCode --and CS_RecSchID = @SchID
Set @SchemeStatus = 1
/* UAT Observation - When Expired(i.e. ActiveFrom and ActiveTo < TranDate) CR scheme received mark it as inactive after processing it */
If @TranDate > @ActFrom and @TranDate > @ActTo
Set @Expired = 1
End
Else
Begin
-- Code Added as on 23.12.2010
If (@ActiveFrom <= @TranDate and @ActiveTo <= @TranDate)
Begin
-- Code added to Extend the latest Payout only when ActiveTo = Tran. date
If @ActiveTo = @TranDate
Begin
IF Exists(Select Top 1 ID from tbl_merp_SchemePayoutPeriod Where SchemeId = @MaxSchemeID
and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1
Group by Id Having DateDiff(Day, Max(PayoutPeriodTo), @TranDate) >= 0)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = dbo.StripTimeFromDate(@TranDate) + @GraceDays, SchemeStatus = 1
where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Select Top 1 @LatestPayoutID = ID from tbl_merp_SchemePayoutPeriod Where SchemeId = @MaxSchemeID
and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1
Group by Id Having DateDiff(Day, Max(PayoutPeriodTo), @TranDate) >= 0
Order by DateDiff(Day, Max(PayoutPeriodTo), @TranDate)

Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = dbo.StriptimeFromDate(@TranDate) Where ID = IsNull(@LatestPayoutID,0)
End
Else
Begin
Set @Errmessage = 'Tran Date Lesser/Equals to ActiveFrom and ActiveTo Period'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto Skip
End
End
Else
Begin
-- Code added to Extend the Scheme only when TranDate between existing Payout
If Exists(Select ID From tbl_mERP_SchemePayoutPeriod Where SchemeID = @MaxSchemeID and
dbo.StriptimeFromDate(@TranDate) Between PayoutPeriodFrom and PayoutPeriodTo
and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = dbo.StripTimeFromDate(@TranDate) + @GraceDays, SchemeStatus = 1
where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = dbo.StriptimeFromDate(@TranDate)
Where SchemeID = @MaxSchemeID and
dbo.StriptimeFromDate(@TranDate) Between PayoutPeriodFrom and PayoutPeriodTo
and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1
End
Else
Begin
Set @Errmessage = 'Tran Date should Lesser than ActiveFrom and ActiveTo Period'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto Skip
End
End
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 Where SchemeID = @maxSchemeID and IsNull(Status,0) <> 128
and dbo.StriptimeFromDate(@TranDate) < PayoutPeriodFrom
and IsNull(Status,0) <> 128
and IsNull(ClaimRFA,0) <> 1

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 32  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto Skip
End
-- Code Added as on 23.12.2010
-- Begins: Code Added as on 06.01.2011
If (@ExistingSchActiveTo < @TranDate)
Begin
--Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @SchemeStatus = 1
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
GoTo CR
End
-- Ends: Code Added as on 06.01.2011
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @ActFrom = DateAdd(day, 1, @TranDate)
Set @SchemeStatus = 1

If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End -- End of Active - CR
Else -- Else Active Checking - For Drop Scheme
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom) >= 1
Begin
Set @Drop = 5
Declare Mycur Cursor for Select SchemeID, ActivityCode, ActiveFrom, ActiveTo from tbl_merp_SchemeAbstract
Where ActivityCode = @ActCode
Order By SchemeID
Open Mycur
Fetch From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
While @@Fetch_Status = 0
Begin
Set @DrActiveFrom = dbo.StriptimeFromDate(@DrActiveFrom)
Set @DrActiveTo =  dbo.StriptimeFromDate(@DrActiveTo)
Set @TranDate =  dbo.StriptimeFromDate(@TranDate)

If exists (Select SchemeID from tbl_merp_SchemeAbstract where SchemeID = @DrSchemeID and
@TranDate between  @DrActiveFrom and @DrActiveTo)
Begin
Update tbl_mERP_SchemeAbstract Set  ActiveTo = @TranDate
, ExpiryDate = @TranDate + @GraceDays
, SchemeStatus = 2
where ActivityCode = @ActCode and SchemeID = @DrSchemeID and
@TranDate between  @DrActiveFrom and @DrActiveTo

Select @PayoutID = ID, @DropPayoutPeriodto =  PayoutPeriodTo
from tbl_mERP_SchemePayoutPeriod SPP , tbl_merp_SchemeAbstract SA
where SA.ActivityCode = @ActCode and SA.SchemeID = @DrSchemeID
And @TranDate between  @DrActiveFrom and @DrActiveTo
And  SA.SchemeID = Spp.SChemeID
And  @TranDate between Spp.PayoutPeriodFrom and SPP.PayoutPeriodTo

Update tbl_mERP_SchemePayoutPeriod Set PayoutPeriodTo = @TranDate
Where ID = @PayoutID

Update tbl_mERP_SchemePayoutPeriod Set Active = 0  where
PayoutPeriodFrom > dbo.StriptimeFromDate(@DropPayoutPeriodto)
and SchemeID = @DrSchemeID
and IsNull(Status,0) <> 128
and IsNull(ClaimRFA,0) <> 1
End
Else
Begin
Update tbl_mERP_SchemeAbstract Set SchemeStatus = 2, Active = 0
where ActivityCode = @ActCode and SchemeID = @DrSchemeID and @TranDate <= ActiveFrom
--Added on 06.01.2011
Update SPP Set Active = 0  From
tbl_mERP_SchemePayoutPeriod SPP Inner join tbl_mERP_SchemeAbstract SA
On SA.SchemeID = SPP.SchemeID Where SPP.SchemeID = @DrSchemeID
and @TranDate <= SA.ActiveFrom
and IsNull(SPP.Status,0) <> 128
and IsNull(SPP.ClaimRFA,0) <> 1
--Added on 06.01.2011
End
Fetch Next From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
End -- FetchStatus End
Close Mycur
Deallocate Mycur
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 32  Where CS_SchemeID = @SchID
Set @Errmessage = 'Trade SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
Else
Begin
Set @Drop = 5
Update tbl_mERP_SchemeAbstract Set Active = 0, SchemeStatus = 2 where ActivityCode = @ActCode
and SchemeID = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set Status = Status|192, Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID
and IsNull(Status,0) <> 128
and IsNull(ClaimRFA,0) <> 1

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Set @Errmessage = 'Trade SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
End
End -- Select Count(*) Activity Code
End -- End of SchemeType Check


-----  38477 - Display and Points Scheme
-- Or (upper(@SChType) = 'POINTS'
Declare @ExpiryDatewithGraceDays datetime
Declare @ExistingExpDate datetime
Declare @ExistingFromDate datetime
Declare @ExistingToDate datetime
Declare @ChangedActiveTo datetime
Declare @ExistingPayoutPeriodTo datetime
Declare @updatedToDate datetime

--Declare @ActualActiveFrom Datetime
--Select @ActualActiveFrom = ActiveFrom from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Select @ExistingExpDate = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingToDate = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingFromDate = ActiveFrom from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID


If (upper(@SChType) = 'DISPLAY')
Begin
If (@TranDate between @ActiveFrom and @ActiveTo)
Begin
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom  and @ActFrom <=@ActiveTo)
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo =  dbo.StripTimeFromDate(@ActiveTo)
End

If (select Count(ActivityCode)  from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >=1
Begin
If (IsNull(@Active,0) = 1)
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom)= 0
Begin
Update tbl_mERP_SchemeAbstract Set Active = 0 where ActivityCode = @ActCode --and CS_RecSchID = @SchID
Set @SchemeStatus = 1
End
Else
Begin
-- Code Added as on 23.12.2010
If ((@ActiveTo <= @TranDate) and (@ActiveFrom <= @TranDate))
Begin
--Extend the scheme only when TranDate and ActiveTo are equal else reject [24 Aug 2012]
If @ActiveTo = @TranDate
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, SchemeStatus = 1 where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 32 Where CS_SchemeID = @SchID
End
Else
Begin
Set @Errmessage = 'Tran Date Lesser/Equals to ActiveFrom and ActiveTo Period'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64 Where CS_SchemeID = @SchID
End
Select '999999999',@Errmessage
Goto skip
End
-- Code Added as on 23.12.2010

Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @ActFrom = DateAdd(day, 1, @TranDate)
Set @SchemeStatus = 1

If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End

/*
Begin
If (select Count(*)  from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >=1
Begin
If (IsNull(@Active,0) = 1)
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom)= 0
Begin
Update tbl_mERP_SchemeAbstract Set Active = 0 where ActivityCode = @ActCode --and CS_RecSchID = @SchID
Set @SchemeStatus = 1
End

If (@ActiveTo = @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = @ExpiryDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @Errmessage = '(Display SCH) ActiveTo Date Equals Transaction Date for the Existing ActivityCode'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select '999999999',@Errmessage
Goto Skip
End
If (@ActiveTo < @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExpiryDatewithGraceDays = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExpiryDatewithGraceDays- @ActiveTo) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @Errmessage = '(Display SCH) ActiveTo Date lesser than Transaction Date for the Existing ActivityCode'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select '999999999',@Errmessage
Goto Skip
End

If (@Activefrom <= @ExistingFromDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
Set @SchemeStatus = 1

IF Not (Select Count(*) from tbl_mERP_SchemePayoutPeriod  where SchemeID = @MaxSchemeID and IsNull(Status,0) = 128 ) >=1
BEGIN
Update tbl_mERP_SchemeAbstract Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID
END

Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID and
IsNull(Status,0) <> 128
End

If (@Activefrom > @TranDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExpiryDatewithGraceDays = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @updatedToDate = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExpiryDatewithGraceDays - @updatedToDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @SchemeStatus = 1
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)

Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

IF Not (Select Count(*) from tbl_mERP_SchemePayoutPeriod  where SchemeID = @MaxSchemeID and IsNull(Status,0) = 128 ) >=1
Update tbl_mERP_SchemeAbstract Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID and
IsNull(Status,0) <> 128
End

If (@Activefrom < @TranDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingExpDate = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingToDate = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExistingExpDate - @ExistingToDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @SchemeStatus = 1
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)

IF Not (Select Count(*) from tbl_mERP_SchemePayoutPeriod  where SchemeID = @MaxSchemeID and IsNull(Status,0) = 128 ) >=1
Update tbl_mERP_SchemeAbstract Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID and
IsNull(Status,0) <> 128
End
*/


End -- End of Active
Else
--Drop Procedure
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom) >= 1
Begin
Set @Drop = 5
Declare Mycur Cursor for Select SchemeID, ActivityCode, ActiveFrom, ActiveTo from tbl_merp_SchemeAbstract
Where ActivityCode = @ActCode
Order By SchemeID
Open Mycur
Fetch From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
While @@Fetch_Status = 0
Begin
Set @DrActiveFrom = dbo.StriptimeFromDate(@DrActiveFrom)
Set @DrActiveTo =  dbo.StriptimeFromDate(@DrActiveTo)
Set @TranDate =  dbo.StriptimeFromDate(@TranDate)

If exists (Select SchemeID from tbl_merp_SchemeAbstract where SchemeID = @DrSchemeID and
@TranDate between  @DrActiveFrom and @DrActiveTo)
Begin
Update tbl_mERP_SchemeAbstract
Set ActiveTo = @TranDate
, ExpiryDate =  @TranDate + @GraceDays
where ActivityCode = @ActCode and SchemeID = @DrSchemeID
and @TranDate between  @DrActiveFrom and @DrActiveTo

Select @PayoutID = ID, @DropPayoutPeriodto =  PayoutPeriodTo from tbl_mERP_SchemePayoutPeriod SPP , tbl_merp_SchemeAbstract SA
where SA.ActivityCode = @ActCode and SA.SchemeID = @DrSchemeID
And @TranDate between  @DrActiveFrom and @DrActiveTo
And  SA.SchemeID = Spp.SChemeID
And @TranDate between Spp.PayoutPeriodFrom and SPP.PayoutPeriodTo

Update tbl_mERP_SchemePayoutPeriod Set PayoutPeriodTo = @TranDate
Where ID = @PayoutID

Update tbl_mERP_SchemePayoutPeriod Set Active = 0  where PayoutPeriodFrom > dbo.StriptimeFromDate(@DropPayoutPeriodto)
and IsNull(Status,0) <> 128 and SchemeID = @DrSchemeID
and IsNull(ClaimRFA,0) <> 1
--ID Not In (@PayoutID)
End
Update tbl_mERP_SchemeAbstract Set SchemeStatus = 2 where ActivityCode = @ActCode and SchemeID = @DrSchemeID
Fetch Next From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
End -- FetchStatus End
Close Mycur
Deallocate Mycur
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Set @Errmessage = 'Display SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
Else
Begin
Set @Drop = 5
Update tbl_mERP_SchemeAbstract Set Active = 0, SchemeStatus = 2 where ActivityCode = @ActCode
and SchemeID = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set Status = Status|192, Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID
and IsNull(Status,0) <> 128
and IsNull(ClaimRFA,0) <> 1

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Set @Errmessage = 'Display SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
End
End
Else  -- NEW SCHEME
Begin
If (@ActiveTo < @TranDate)
Begin
Set @Errmessage = '(Display SCH) ActiveTo Date lesser than Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else If (@ActiveFrom <= @TranDate) and (@ActiveTo = @TranDate)
Begin
Set @Errmessage = '(Display SCH) To Date is equal to Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else
Set @SchemeStatus = 0

/*
If (@TranDate between @ActiveFrom and @ActiveTo)
Begin
Set @ActFrom = DateAdd(day, 1, @TranDate)

--If (@ActFrom = @Activefrom)
If (@ActFrom >= @Activefrom)
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo =  dbo.StripTimeFromDate(@ActiveTo)
End

*/

End
End -- End of SchemeType (Display and Points)


-- Display Points Scheme CR/Drop
If (upper(@SChType) = 'POINTS')
Begin
If (@TranDate between @ActiveFrom and @ActiveTo)
Begin
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom and @ActFrom <=@ActiveTo)
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo =  dbo.StripTimeFromDate(@ActiveTo)
End

If (select Count(ActivityCode)  from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >=1
Begin
If (IsNull(@Active,0) = 1)
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom)= 0
Begin
Update tbl_mERP_SchemeAbstract Set Active = 0 where ActivityCode = @ActCode --and CS_RecSchID = @SchID
Set @SchemeStatus = 1
End
Else
Begin
-- Code Added as on 23.12.2010
If ((@ActiveTo <= @TranDate) and (@ActiveFrom <= @TranDate))
Begin
-- Code added to Extend the latest Payout only when ActiveTo = Tran. date
If @ActiveTo = @TranDate
Begin
IF Exists(Select Top 1 ID from tbl_merp_SchemePayoutPeriod Where SchemeId = @MaxSchemeID
and IsNull(Status,0) = 0 and IsNull(ClaimRFA,0) <> 1
Group by Id Having DateDiff(Day, Max(PayoutPeriodTo), @TranDate) >= 0)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = dbo.StripTimeFromDate(@TranDate) + @GraceDays, SchemeStatus = 1
where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Select Top 1 @LatestPayoutID = ID from tbl_merp_SchemePayoutPeriod Where SchemeId = @MaxSchemeID
and IsNull(Status,0) = 0 and IsNull(ClaimRFA,0) <> 1
Group by Id Having DateDiff(Day, Max(PayoutPeriodTo), @TranDate) >= 0
Order by DateDiff(Day, Max(PayoutPeriodTo), @TranDate)

Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = dbo.StriptimeFromDate(@TranDate) Where ID = IsNull(@LatestPayoutID,0)
End
Else
Begin
Set @Errmessage = 'Tran Date Lesser/Equals to ActiveFrom and ActiveTo Period'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto Skip
End
End
Else
Begin
-- Code added to Extend the Scheme only when TranDate between existing Payout
If Exists(Select ID From tbl_mERP_SchemePayoutPeriod Where SchemeID = @MaxSchemeID and
dbo.StriptimeFromDate(@TranDate) Between PayoutPeriodFrom and PayoutPeriodTo
and IsNull(Status,0) = 0 and IsNull(ClaimRFA,0) <> 1)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = dbo.StripTimeFromDate(@TranDate) + @GraceDays, SchemeStatus = 1
where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = dbo.StriptimeFromDate(@TranDate)
Where SchemeID = @MaxSchemeID and
dbo.StriptimeFromDate(@TranDate) Between PayoutPeriodFrom and PayoutPeriodTo
and IsNull(Status,0) = 0 and IsNull(ClaimRFA,0) <> 1
End
Else
Begin
Set @Errmessage = 'Tran Date should Lesser than ActiveFrom and ActiveTo Period'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto Skip
End
End
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 Where SchemeID = @maxSchemeID and IsNull(Status,0) <> 1
and @TranDate < PayoutPeriodFrom
and IsNull(ClaimRFA,0) <> 1
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 32  Where CS_SchemeID = @SchID
Select '999999999',@Errmessage
Goto skip
End
-- Code Added as on 23.12.2010

Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @ActFrom = DateAdd(day, 1, @TranDate)
Set @SchemeStatus = 1

If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
/*
Begin
If (select Count(*) from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) >=1
Begin
If (IsNull(@Active,0) = 1)
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom)= 0
Begin
Update tbl_mERP_SchemeAbstract Set Active = 0 where ActivityCode = @ActCode --and CS_RecSchID = @SchID
Set @SchemeStatus = 1
End
Else
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @ActFrom = DateAdd(day, 1, @TranDate)
Set @SchemeStatus = 1

If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End

If (@ActiveTo = @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate, ExpiryDate = @ExpiryDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @Errmessage = '(Points SCH) ActiveTo Date Equals Transaction Date for the Existing ActivityCode'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select '999999999',@Errmessage
Goto Skip
End
If (@ActiveTo < @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExpiryDatewithGraceDays = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExpiryDatewithGraceDays- @ActiveTo) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @Errmessage = '(Points) ActiveTo Date lesser than Transaction Date for the Existing ActivityCode'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select '999999999',@Errmessage
Goto Skip
End

If (@Activefrom <= @ExistingFromDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
Set @SchemeStatus = 1

End

If (@Activefrom > @TranDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExpiryDatewithGraceDays = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @updatedToDate = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExpiryDatewithGraceDays - @updatedToDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @SchemeStatus = 1
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)

Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
End

If (@Activefrom < @TranDate and @ActiveTo > @TranDate)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingExpDate = ExpiryDate from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Select @ExistingToDate = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @TranDate + (@ExistingExpDate - @ExistingToDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Select @ChangedActiveTo = ActiveTo from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Set @SchemeStatus = 1
Set @ActFrom = DateAdd(day, 1, @TranDate)
If (@ActFrom >= @Activefrom)
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Else
Set @ActFrom = @ActiveFrom

Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
*/

End -- End of Active
Else
--Drop Procedure
Begin
If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom) >= 1
Begin
Set @Drop = 5
Declare Mycur Cursor for Select SchemeID, ActivityCode, ActiveFrom, ActiveTo from tbl_merp_SchemeAbstract
Where ActivityCode = @ActCode
Order By SchemeID
Open Mycur
Fetch From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
While @@Fetch_Status = 0
Begin

Set @DrActiveFrom = dbo.StriptimeFromDate(@DrActiveFrom)
Set @DrActiveTo =  dbo.StriptimeFromDate(@DrActiveTo)

If exists (Select SchemeID from tbl_merp_SchemeAbstract where SchemeID = @DrSchemeID and
@TranDate between  @DrActiveFrom and @DrActiveTo)
Begin
Update tbl_mERP_SchemeAbstract Set ActiveTo = @TranDate
, ExpiryDate = @TranDate + @GraceDays
where ActivityCode = @ActCode and SchemeID = @DrSchemeID and @TranDate between  @DrActiveFrom and @DrActiveTo

Select @PayoutID = ID, @DropPayoutPeriodto = PayoutPeriodTo
from tbl_mERP_SchemePayoutPeriod SPP , tbl_merp_SchemeAbstract SA
where SA.ActivityCode = @ActCode and SA.SchemeID = @DrSchemeID
And @TranDate between  @DrActiveFrom and @DrActiveTo
And SA.SchemeID = Spp.SChemeID
And @TranDate between Spp.PayoutPeriodFrom and SPP.PayoutPeriodTo

Update tbl_mERP_SchemePayoutPeriod Set PayoutPeriodTo = @TranDate
Where ID = @PayoutID
Update tbl_mERP_SchemePayoutPeriod Set Active = 0  where PayoutPeriodFrom > dbo.StriptimeFromDate(@DropPayoutPeriodto)
and SchemeID = @DrSchemeID and IsNull(Status,0) <> 1
and IsNull(ClaimRFA,0) <> 1
End
Else
Begin
Update tbl_mERP_SchemeAbstract Set SchemeStatus = 2, Active = 0
where ActivityCode = @ActCode and SchemeID = @DrSchemeID and @TranDate <= ActiveFrom
End
Fetch Next From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo
End -- FetchStatus End
Close Mycur
Deallocate Mycur

/* Old Code commented
Update tbl_mERP_SchemeAbstract Set ActiveTo = dbo.StripTimeFromDate(@TranDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set Active = 0, SchemeStatus = 2 where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = dbo.StripTimeFromDate(ActiveTo) + @GraceDays where ActivityCode = @ActCode and SchemeID = @MaxSchemeID
Update tbl_mERP_SchemeAbstract Set ExpiryDate = @ActiveTo + (@ExistingExpDate - @ExistingToDate) where ActivityCode = @ActCode and SchemeID = @MaxSchemeID

Update tbl_mERP_SchemePayoutPeriod Set Status = Status|192, Active = 0 Where IsNull(SchemeID,0) = @MaxSchemeID
and IsNull(ClaimRFA,0) = 0
and IsNull(Status,0) = 0
*/

--Updating the Received Table Status
Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Set @Errmessage = 'Points SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
Else
Begin
Set @Drop = 5

Update tbl_mERP_SchemeAbstract Set Active = 0, SchemeStatus = 2 where ActivityCode = @ActCode  and SchemeID = @MaxSchemeID --and CS_RecSchID = @SchID
Update tbl_mERP_SchemePayoutPeriod Set Status = Status|192, Active = 0 Where IsNull(SchemeID,0) = @MaxSchemeID
and IsNull(Status,0) <> 1
and IsNull(ClaimRFA,0) <> 1

Update tbl_mERP_RecdSchAbstract Set CS_Flag = 64  Where CS_SchemeID = @SchID
Set @Errmessage = 'Points SCHEME made Inactive'
Select '999999999',@Errmessage
Goto Skip
End
End
End
Else  -- NEW SCHEME
Begin
If (@ActiveTo < @TranDate)
Begin
Set @Errmessage = '(Points SCH) ActiveTo Date lesser than Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else If (@ActiveFrom <= @TranDate) and (@ActiveTo = @TranDate)
Begin
Set @Errmessage = '(Points SCH) To Date is equal to Transaction Date'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skip
End
Else
Set @SchemeStatus = 0
End

/*
If (@TranDate between @ActiveFrom and @ActiveTo)
Begin
Set @ActFrom = DateAdd(day, 1, @TranDate)

--If (@ActFrom = @Activefrom)
If (@ActFrom >= @Activefrom)
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo = dbo.StripTimeFromDate(@ActiveTo)
End
End
Else
Begin
Set @ActFrom = dbo.StripTimeFromDate(@ActiveFrom)
Set @ActTo =  dbo.StripTimeFromDate(@ActiveTo)
End
*/

End -- End of SchemeType (Points)

If (@ExpiryDate <= @ActiveTo )
Begin
Set @ExpiryDate = @ActiveTo
Set @Errmessage = 'Warning: Expiry Date should be Greater than ActiveTo Period. Scheme Will be Processed'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
End


--If (@ViewDate < @ActiveFrom)
--Begin
-- Set @ViewDate = @ActiveFrom
-- Set @Errmessage = 'Warning: View Date should be Greater than ActiveFrom Period. Scheme Will be Processed'
-- Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
-- Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
--End


If IsNull(@Payoutperiod,'') <> ''
Begin
Truncate table #tmp2
Insert Into #tmp2
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')


Declare Mycur Cursor for Select Date from #tmp2
Open Mycur
Fetch From Mycur Into @Date
While @@Fetch_Status = 0
Begin
Set @PayoutFrom = null
Set @PayoutTo = null
Select @PayoutFrom = Convert(Datetime, substring(@Date,1,charindex('-',@Date,1)-1), 103)
Select @PayoutTo = Convert(Datetime, substring(@Date,charindex('-',@Date,1)+1, len(@date)), 103)

Set @PayoutFrom = dbo.StripTimeFromDate(@PayoutFrom)
Set @PayoutTo = dbo.StripTimeFromDate(@PayoutTo)

If (@PayoutFrom > @PayoutTo)
Begin
Set @Errmessage = 'Payout From is greater than Payout period - Scheme Rejected'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @SchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
Select -1,@Errmessage
Goto Skippayout
End
Fetch Next From Mycur Into @Date
End
Close Mycur
Deallocate Mycur
End
Drop table #tmp2

--- 38477
CR:
IF IsNull(@Expired,0) = 1
Begin
Set @Active = 0  /* Save Received CR as Inactive when Sch Date < @Tran Date */
Set @Errmessage = 'Warning: When Transaction_Date greater than ActiveTo_Date then Scheme become expired. CR Processed with Inactive Status'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @CSRecSchemeID, getdate())
End



Insert Into tbl_mERP_SchemeAbstract
(CS_RecSchID, CS_SchemeID, ActivityCode, Description, Color, SchemeType ,
ApplicableOn, ItemGroup, RFAApplicable, ClaimedAs, SchemeMonth,
SchemeFrom, SchemeTo, ActiveFrom, ActiveTo, DownloadedOn, Active,
SKUCount, Budget, CS_Status, SchMonth, ExpiryDate,
PayoutFrequency, BudgetOverRun, UniformAllocFlag, SchemeStatus, ViewDate, SchSubtype,TLCFlag)
Values
(@CSRecSchemeID, @RecdID, @ActCode, @SchDesc, @Color, @SChtypeID,
@SchapplyOnID, @SKUGrpID, @RFA, @ClaimedAs, @SchMonth,
--@SchFromDate, @SChToDate, @ActiveFrom, @ActiveTo, @DownloadedOn,  @Active,
@ActiveFrom, @ActiveTo, dbo.StripTimeFromDate(@ActFrom), dbo.StripTimeFromDate(@ActTo), @DownloadedOn,  @Active,
@SKuCount, @Budget, @CSStatus, @SchMonth, dbo.StripTimeFromDate(@ExpiryDate)
, @PayoutFrequency, @BudgetOverRun, @UniformAllocFlag, @SchemeStatus, @ViewDate, @SchSubtype,@TLCSlabUOM)


-- Select @@Identity,'Done'

Set @SchID = @@Identity

Declare @CrNoteRaisedLastPayToDate datetime
Declare @newFromDate datetime
Declare @newToDate datetime
Declare @NewPayoutFromDate Datetime
Declare @ActualActiveFrom Datetime
Declare @ID int
Declare @SchemeID int
Declare @NewPayoutFrom datetime
Declare @ExistingPayoutTo datetime
Declare @NextPayoutTranDate datetime
Declare @ExistingPayoutID int

Select @ActualActiveFrom = IsNull(ActiveFrom,'') from tbl_merp_schemeAbstract where SchemeID = @SchID
Set @ActualActiveFrom = dbo.StripTimeFromDate(@ActualActiveFrom)

If (upper(@SChType) = 'DISPLAY')
Begin
If (Isnull(@Drop,0) <> 5)
Begin
If IsNull(@Payoutperiod,'') <> ''
Begin
--If (select Count(*) ActivityCode from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode and Active = 1) > 1
If (Isnull(@payoutStatusNew,0) = 6)
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Declare Mycur Cursor for Select Date from #tmp
Open Mycur
Fetch From Mycur Into @Date
While @@Fetch_Status = 0
Begin
Truncate table #Payout
Insert Into #Payout
Select @SchID, substring(@Date,1,charindex('-',@Date,1)-1), substring(@Date,charindex('-',@Date,1)+1,len(@Date))

Select @CrNoteRaisedLastPayToDate = Max(PayoutPeriodTo)
from tbl_mERP_SchemePayoutPeriod SchemePayoutPeriod
where SchemePayoutPeriod.SchemeID = @MaxSchemeID and Isnull(Status,0) = 128

Select @NewFromDate = PayoutFrom, @newToDate = PayoutTo from #Payout Order by ID desc

If (@CrNoteRaisedLastPayToDate > @NewFromDate)
Begin
If (@CrNoteRaisedLastPayToDate < @newToDate)
Begin
--New Payout Valid
Set @NewPayoutFromDate = DateAdd(day, 1, @CrNoteRaisedLastPayToDate)
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @NewPayoutFromDate, PayoutTo from #Payout
End
End
Else
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, PayoutFrom, PayoutTo from #Payout
End
Fetch Next From Mycur Into @Date
End
Close Mycur
Deallocate Mycur
End -- count(*) ActivityCode end
Else -- New Activitycode
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Declare Mycur Cursor for Select Date from #tmp
Open Mycur
Fetch From Mycur Into @Date
While @@Fetch_Status = 0
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select @SchID, substring(@Date,1,charindex('-',@Date,1)-1), substring(@Date,charindex('-',@Date,1)+1,len(@Date))
Fetch Next From Mycur Into @Date
End
Close Mycur
Deallocate Mycur
End
End  -- @Payoutperiod Ends
End -- Drop <> 5 end
Drop table #tmp
Drop table #Payout
End --end of SchType Display


If (upper(@SChType) = 'POINTS')
Begin
If (Isnull(@Drop,0) <> 5)
Begin
If IsNull(@Payoutperiod,'') <> ''
Begin
If (Isnull(@payoutStatusNew,0) = 6)
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Truncate table #Payout
Insert Into #Payout
Select @SchID, substring(Date,1,charindex('-',Date,1)-1), substring(Date,charindex('-',Date,1)+1,len(Date))
From #tmp

Declare Mycur Cursor for Select ID, SchemeID, PayoutFrom, PayoutTo from #Payout Order By ID
Open Mycur
Fetch From Mycur Into @ID, @SchemeID, @PayoutFrom, @PayoutTo
While @@Fetch_Status = 0
Begin

Set @PayoutFrom = dbo.StripTimeFromDate(@PayoutFrom)
Set @PayoutTo = dbo.StripTimeFromDate(@PayoutTo)

If (@TranDate between @PayoutFrom and @PayoutTo)
Begin
Select @ExistingPayoutTo = @PayoutTo from #Payout Where SchemeID = @SchemeID
Update #Payout Set @PayoutTo = @TranDate from #Payout Where SchemeID = @SchemeID
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID
Set @NewPayoutFrom = DateAdd(day, 1, @TranDate)
Set @NewPayoutFrom = dbo.StripTimeFromDate(@NewPayoutFrom)
If Not (@NewPayoutFrom > @ExistingPayoutTo)
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @NewPayoutFrom, @ExistingPayoutTo from #Payout Where ID = @ID
End
If (Select Count(*) from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID) > 1
Begin
Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = @TranDate
Where SchemeID = @MaxSchemeID and
@TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0
Set @NextPayoutTranDate = @TranDate + 1
Select @ExistingPayoutID = ID from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID
and @TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0
Set @ExistingPayoutID =@ExistingPayoutID + 1
If ( Select Count(*) from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID and ID = @ExistingPayoutID) >=1
Begin
Update tbl_mERP_SchemePayoutPeriod  Set payoutperiodFrom = dbo.StripTimeFromDate(@NextPayoutTranDate)
where SchemeID = @MaxSchemeID and ID = @ExistingPayoutID
End
End
Else
Begin
Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = @TranDate
Where SchemeID = @MaxSchemeID and
@TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0
End
End
Else If (@PayoutFrom > @TranDate)
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID
End
Else
Begin
If (@TranDate < @PayoutFrom)
Begin
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 Where SchemeID = @maxSchemeID and IsNull(Status,0) <> 1
and IsNull(ClaimRFA,0) <> 1
End
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID
End
Fetch Next From Mycur Into @ID, @SchemeID, @PayoutFrom, @PayoutTo
End
Close Mycur
Deallocate Mycur
--   If (@ActiveTo <= @TranDate)
--   Begin
--    Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where SchemeID = @SchID
--   End
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where PayoutPeriodFrom <  @ActualActiveFrom
and SchemeID = @SchID and IsNull(Status,0) <> 1 and IsNull(ClaimRFA,0) <> 1
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where ( PayoutPeriodFrom >= @ActualActiveFrom Or PayoutPeriodTo >= @ActualActiveFrom)
and SchemeID = @maxSchemeID
and IsNull(Status,0) <> 1 and IsNull(ClaimRFA,0) <> 1
End -- count(*) ActivityCode end
Else -- New Activitycode
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Declare Mycur Cursor for Select Date from #tmp
Open Mycur
Fetch From Mycur Into @Date
While @@Fetch_Status = 0
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select @SchID, substring(@Date,1,charindex('-',@Date,1)-1), substring(@Date,charindex('-',@Date,1)+1,len(@Date))
Fetch Next From Mycur Into @Date
End
Close Mycur
Deallocate Mycur
End
End  -- @Payoutperiod Ends
End -- Drop <> 5 end
Drop table #tmp
Drop table #Payout
End --end of SchType Display

If ((Upper(@SChType) = 'SP')  Or (Upper(@SChType) = 'CP'))
Begin
If (Isnull(@Drop,0) <> 5)
Begin
If IsNull(@Payoutperiod,'') <> ''
Begin
If (Isnull(@payoutStatusNew,0) = 6)
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Truncate table #Payout
Insert Into #Payout
Select @SchID, substring(Date,1,charindex('-',Date,1)-1), substring(Date,charindex('-',Date,1)+1,len(Date))
From #tmp

Declare Mycur Cursor for Select ID, SchemeID, PayoutFrom, PayoutTo from #Payout Order By ID
Open Mycur
Fetch From Mycur Into @ID, @SchemeID, @PayoutFrom, @PayoutTo
While @@Fetch_Status = 0
Begin
Set @PayoutFrom = dbo.StripTimeFromDate(@PayoutFrom)
Set @PayoutTo = dbo.StripTimeFromDate(@PayoutTo)
Set @TranDate = dbo.StripTimeFromDate(@TranDate)

If (@TranDate between @PayoutFrom and @PayoutTo)
Begin
Select @ExistingPayoutTo = @PayoutTo from #Payout Where SchemeID = @SchemeID
Update #Payout Set @PayoutTo = @TranDate from #Payout Where SchemeID = @SchemeID

Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID

Set @NewPayoutFrom = DateAdd(day, 1, @TranDate)
Set @NewPayoutFrom = dbo.StripTimeFromDate(@NewPayoutFrom)

If Not (@NewPayoutFrom > @ExistingPayoutTo)
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @NewPayoutFrom, @ExistingPayoutTo from #Payout Where ID = @ID
End
If ( Select Count(*) from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID) > 1
Begin
Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = @TranDate
Where SchemeID = @MaxSchemeID and
@TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0

Set @NextPayoutTranDate = @TranDate + 1
Select @ExistingPayoutID = ID from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID
and @TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0
Set @ExistingPayoutID =@ExistingPayoutID + 1
If ( Select Count(*) from tbl_mERP_SchemePayoutPeriod where SchemeID = @MaxSchemeID and ID = @ExistingPayoutID) >=1
Begin
Update tbl_mERP_SchemePayoutPeriod  Set payoutperiodFrom = dbo.StripTimeFromDate(@NextPayoutTranDate)
where SchemeID = @MaxSchemeID and ID = @ExistingPayoutID
End
End
Else
Begin
Update tbl_mERP_SchemePayoutPeriod Set PayoutperiodTo = @TranDate
Where SchemeID = @MaxSchemeID and
@TranDate Between PayoutPeriodFrom and PayoutPeriodTo and IsNull(Status,0) = 0
End
End
Else If (@PayoutFrom > @TranDate)
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID
End
Else
Begin
If (@TranDate < @PayoutFrom)
Begin
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 Where SchemeID = @maxSchemeID and IsNull(Status,0) <> 128
and IsNull(ClaimRFA,0) <> 1
End
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select  SchemeID, @PayoutFrom, @PayoutTo from #Payout Where ID = @ID
End
Fetch Next From Mycur Into @ID, @SchemeID, @PayoutFrom, @PayoutTo
End -- FetchStatus End
Close Mycur
Deallocate Mycur
--   If (dbo.StripTimeFromDate(@ActiveTo) <= dbo.StripTimeFromDate(@TranDate))
--   Begin
--    Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where SchemeID = @SchID
--   End
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where PayoutPeriodFrom <  dbo.StripTimeFromDate(@ActualActiveFrom)
and SchemeID = @SchID and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1
Update tbl_mERP_SchemePayoutPeriod Set Active = 0 where (PayoutPeriodFrom >= dbo.StripTimeFromDate(@ActualActiveFrom) Or PayoutPeriodTo >= dbo.StripTimeFromDate(@ActualActiveFrom))
and SchemeID = @maxSchemeID and IsNull(Status,0) <> 128 and IsNull(ClaimRFA,0) <> 1
End -- count(*) ActivityCode end
Else -- New Activitycode
Begin
Truncate table #tmp
Insert Into #tmp
Select * from dbo.sp_SplitIn2Rows(@Payoutperiod, '|')

Declare Mycur Cursor for Select Date from #tmp
Open Mycur
Fetch From Mycur Into @Date
While @@Fetch_Status = 0
Begin
Insert Into tbl_mERP_SchemePayoutPeriod(SchemeID, PayoutPeriodFrom, PayoutPeriodTo)
Select @SchID, substring(@Date,1,charindex('-',@Date,1)-1), substring(@Date,charindex('-',@Date,1)+1,len(@Date))
Fetch Next From Mycur Into @Date
End
Close Mycur
Deallocate Mycur
End
End -- End of Payout Period Check
End
Drop table #tmp
Drop table #Payout
End -- End Of Schemtype check - SP/CP

Select @SchID, 'Done'
Goto Skip

Skippayout:
close mycur
Deallocate Mycur
Goto Skip

skip:
