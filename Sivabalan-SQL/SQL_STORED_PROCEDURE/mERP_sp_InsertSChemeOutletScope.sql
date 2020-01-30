Create Procedure mERP_sp_InsertSChemeOutletScope (@SchID int, @RecdSchID int)
AS
Declare @SlabType int
Declare @GroupID  int
Declare @UOM  int
Declare @SlabStart Decimal(18,6)
Declare @SlabEnd Decimal(18,6)
Declare @Onward Decimal(18,6)
Declare @Value Decimal(18,6)
Declare @FreeUOM Int
Declare @Volume Decimal(18,6)
DEclare @FreeSKU nVarchar(4000)
DEclare @Errmessage nVarchar(4000)
Declare @SlabID int

Declare @Channel nvarchar(4000)
Declare @Outletclass nvarchar(4000)
Declare @OutletID nvarchar(4000)
Declare @Qps int
Declare @TmpCustomerID nVarchar(4000)
Declare @TmpOutlettypeID nVarchar(4000)

Declare @LoyaltyList nvarchar(4000)

Declare @UnitRate Decimal(18,6)

DECLARE @GpID as Int

Declare @SchemeID int
Set @SchemeID = @SchID

Create table #TChannel (Channel nVarchar(4000))
Create table #TOuteletClass( Outletclass nVarchar(4000))
Create table #TOutelet( OutletID nVarchar(4000))
Create table #Toutlettype(OutletType nVarchar(4000))
Create table #TLoyalty(LoyaltyList nVarchar(4000))


Declare @SchemeType nVarchar(255)
Declare @ApplOn nVarchar(255)
Select @SchemeType  = CS_Type from tbl_mERP_RecdSchAbstract where CS_SchemeID = @RecdSchID
Select @ApplOn  =  CS_ApplicableOn from tbl_mERP_RecdSchAbstract where CS_SchemeID = @RecdSchID

-- Begin: For Display
Declare @CapperOutlet nVarchar(4000)

--Create table #TChannelDisp (Channel nVarchar(200))
--Create table #TOuteletClassDisp(Channel nVarchar(200), Outletclass nVarchar(200))
--Create table #TLoyaltyDisp(Channel nVarchar(200), LoyaltyList nVarchar(200))

Create table #TChannelDisp (ID Int identity(1,1), Channel nVarchar(4000))
Create table #TOuteletClassDisp(ID Int identity(1,1), Channel nVarchar(4000), Outletclass nVarchar(4000))
Create table #TLoyaltyDisp(ID Int identity(1,1), Channel nVarchar(4000), LoyaltyList nVarchar(4000))


Truncate table #TChannelDisp
Truncate table #TOuteletClassDisp
Truncate table #TLoyaltyDisp


/*
Note:
XML SubGroupID is stored only in received Table.
We are not taking SubGroupID from the received table.
By Default SubGroupID treated as 1. If more than One subgroupID is there then again it is Incremented to 2.
If there is different GroupID then again SubgroupID willbe Incremented to 3 and so On..

For Example:
------------
2 Groups  Say 15, 16.
SubGroup  1 and 2 for 15
SubGroup  3 and 4 for 16
Will be saved.

*/



-- End: For Display

If (Upper(Ltrim(@SchemeType)) = 'DISPLAY')
Begin

Declare MyCursor Cursor For
Select CS_Channel, CS_OutletType, CS_SuboutletType, CS_CapperOutlet
from tbl_mERP_RecdDispSchCapPerOutlet where CS_SchemeID = @RecdSchID
Open MyCursor
Fetch From MyCursor Into @Channel, @Outletclass, @LoyaltyList, @CapperOutlet
While @@Fetch_Status = 0
Begin


Insert Into #TChannelDisp
Select * from dbo.sp_SplitIn2Rows(@Channel, '|')

Declare CurChannel Cursor For
Select IsNull(Channel,'') From #TChannelDisp
Open CurChannel
Fetch From CurChannel Into @Channel
While @@Fetch_Status = 0
Begin

Insert Into #TOuteletClassDisp
Select @Channel, * from dbo.sp_SplitIn2Rows(@Outletclass, '|')


Insert Into #TLoyaltyDisp
Select @Channel,* from dbo.sp_SplitIn2Rows(@LoyaltyList, '|')

Fetch Next From CurChannel Into @Channel
End
Close CurChannel
Deallocate CurChannel

Insert into tbl_mERP_DispSchCapPerOutlet(SchemeID, Channel, OutletType, SubOutletType, CapPerOutlet)
Select @SchemeID, TC.Channel, TOC.OutletClass, TL.LoyaltyList, @CapperOutlet
From #TChannelDisp TC, #TOuteletClassDisp TOC, #TLoyaltyDisp TL
Where TC.Channel = TOC.Channel And TOC.Channel = TL.Channel

Truncate table #TChannelDisp
Truncate table #TOuteletClassDisp
Truncate table #TLoyaltyDisp

Fetch next From MyCursor Into @Channel, @Outletclass, @LoyaltyList, @CapperOutlet
End

Close MyCursor
Deallocate myCursor

Drop table #TChannelDisp
Drop table #TOuteletClassDisp
Drop table #TLoyaltyDisp

End
-- DispCapPerOutlet Ends
Declare @SubGroupID int


If (Upper(@SchemeType) <> 'DISPLAY')
Begin
Set @SubGroupID = 1

Declare ChannelCur Cursor for

Select CS_Channel, CS_Group from tbl_mERP_RecdSchChannel
where CS_SchemeID = @RecdSchID
Order By CS_Group, CS_SubGroupID, CS_Channel
Open ChannelCur
Fetch From ChannelCur Into @Channel, @GroupID
While @@Fetch_Status = 0
Begin

Truncate table #TChannel
Insert Into #TChannel
Select * from dbo.sp_SplitIn2Rows(@Channel, '|')

Insert Into tbl_mERP_SchemeChannel(SchemeID, GroupID, Channel)
Select @SchemeID, @SubGroupID, LTrim(#TChannel.Channel) from #TChannel
Set @SubGroupID = @SubGroupID + 1
Fetch Next From ChannelCur Into @Channel, @GroupID
End

SEt @SubGroupID = 1

--OutletClass
Declare OutletClassCur Cursor for
Select CS_OutletClass, CS_Group  from tbl_mERP_RecdSchOutletClass
where CS_SchemeID = @RecdSchID
Order By CS_Group, CS_SubGroupID, CS_OutletClass
Open OutletClassCur
Fetch From OutletClassCur  Into @Outletclass, @GroupID
While @@Fetch_Status = 0
Begin
Truncate table #TOuteletClass
Insert Into #TOuteletClass
Select * from dbo.sp_SplitIn2Rows(@Outletclass, '|')

Insert Into tbl_mERP_SchemeOutletClass(SchemeID, GroupID, OutletClass )
Select @SchemeID, @SubGroupID, LTrim(#TOuteletClass.Outletclass) from #TOuteletClass

Set @SubGroupID = @SubGroupID + 1
Fetch Next From OutletClassCur  Into @Outletclass, @GroupID
End


SEt @SubGroupID = 1

--LoyaltyList
Declare LoyaltyListCur Cursor for
Select CS_LoyaltyList, CS_Group  from tbl_mERP_RecdSchLoyaltyList
where CS_SchemeID = @RecdSchID
Order By CS_Group, CS_SubGroupID, CS_LoyaltyList
Open LoyaltyListCur
Fetch From LoyaltyListCur  Into @LoyaltyList, @GroupID
While @@Fetch_Status = 0
Begin
--#TLoyalty
Truncate table #TLoyalty
Insert Into #TLoyalty
Select * from dbo.sp_SplitIn2Rows(@LoyaltyList, '|')
Insert Into tbl_mERP_SchemeLoyaltyList(SchemeID, GroupID, Loyaltyname )
--Select @SchemeID, @GroupID, LTrim(#TLoyalty.LoyaltyList) from #TLoyalty
Select @SchemeID, @SubGroupID, LTrim(#TLoyalty.LoyaltyList) from #TLoyalty
Set @SubGroupID = @SubGroupID + 1
Fetch Next From LoyaltyListCur  Into @LoyaltyList, @GroupID
End


Set @SubGroupID = 1

--Outlet
Declare OutletCur Cursor for
Select CS_OutletID, CS_Group, CS_QPS  from tbl_mERP_RecdSchOutlet
where CS_SchemeID = @RecdSchID
Order By CS_Group, CS_QPS
Open OutletCur
Fetch From OutletCur  Into @OutletID, @GroupID, @Qps
While @@Fetch_Status = 0
Begin
If (@Qps > 1)
Begin
Set @Errmessage = 'Qps Value should not be greater than 1'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Middle
End

Truncate table #TOutelet
Insert Into #TOutelet
Select * from dbo.sp_SplitIn2Rows(@OutletID, '|')

If IsNull(@OutletID,'') <> 'ALL'
Begin
Declare CustCur Cursor for Select OutletID from #TOutelet
Open CustCur
Fetch From CustCur Into @TmpCustomerID
While @@Fetch_Status = 0
Begin
If Not Exists ( Select CustomerID from Customer where CustomerID = @TmpCustomerID)
Begin
Set @Errmessage = 'Customer Not Exist in the Database. CustomerID = ' + Convert(varchar, @TmpCustomerID)
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Delete from #TOutelet Where OutletID = @TmpCustomerID
End
Fetch Next From CustCur  Into @TmpCustomerID
End
Close CustCur
DeAllocate CustCur
End


Insert Into tbl_mERP_SchemeOutlet(SchemeID, GroupID, OutletID, QPS )
Select @SchemeID, @SubGroupID, LTrim(#TOutelet.OutletID), @Qps from #TOutelet
Set @SubGroupID = @SubGroupID + 1
Fetch Next From OutletCur  Into @OutletID, @GroupID, @Qps
End

---Outlet Ends

Set @SubGroupID = 1

Declare SubGrp Cursor for
Select CS_Group from tbl_mERP_RecdSchOutlet
where CS_SchemeID = @RecdSchID
Order By CS_Group, CS_SubGroupID
Open SubGrp
Fetch From SubGrp Into @GroupID
While @@Fetch_Status = 0
Begin
Insert Into tbl_mERP_SchemeSubGroup(SchemeID, GroupID, SubGroupID)
Values(@SchemeID, @GroupID, @SubGroupID)
Set @SubGroupID = @SubGroupID + 1
Fetch Next From SubGrp  Into @GroupID
End
Close SubGrp
Deallocate SubGrp


-- Subgroup Ends


If ( Select Count(*) from tbl_mERP_RecdSchSlabDetail Where CS_SChemeID = @RecdSchID) = 0
Begin
Set @Errmessage = 'Atleast One Slab should exist to apply scheme'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Middle
End



Declare MyCursor Cursor For
Select CS_SlabType, CS_Group, CS_UOM, CS_SlabStart, CS_SlabEnd, CS_Onward,  CS_Value, CS_FreeUOM
, CS_Volume, CS_SKUCode, CS_UnitRate
From tbl_mERP_RecdSchSlabDetail
Where CS_SChemeID = @RecdSchID
Group By CS_SlabType, CS_Group, CS_UOM, CS_SlabStart, CS_SlabEnd, CS_Onward,  CS_Value, CS_FreeUOM
, CS_Volume, CS_SKUCode, CS_UnitRate

Open MyCursor
Fetch from MyCursor Into @SlabType, @GroupID, @UOM, @SlabStart, @SlabEnd, @Onward,  @Value,
@FreeUOM, @Volume, @FreeSku, @UnitRate
While @@Fetch_Status = 0
Begin

If (Upper(Ltrim(@SchemeType)) = 'POINTS' and @Slabtype <> 5)
Begin
Set @Errmessage = 'If schemetype is Points then SlabType should be 5'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

If (IsNull(@UnitRate,0) < 0)
Begin
Set @Errmessage = 'Unit Rate should not be lesser than  Zero Value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

If (@UOM = 0) Or (@UOM > 5)
Begin
Set @Errmessage = 'UOM Value should not be greater than 5 Or Zero Value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag| 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

If (@SlabStart = 0)  Or (@SlabEnd = 0)
Begin
Set @Errmessage = 'Slab Start Value and SlabEnd Value should not Zero Value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End
IF ((@SlabType = 0) Or (@SlabType > 5))
Begin
Set @Errmessage = 'Given As Value should not be Zero Value Or greater than 5'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

If (@SlabType = 3) and (@FreeUOM = 0 Or @Volume = 0 Or  @FreeSKU = '')
Begin
Set @Errmessage = 'If Sch GivenAS Value is 3 then FreeUOM and Volume and FreeSku Value Should be given'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

IF ((@SlabType = 1) Or (@SlabType = 2)) and ( @Value <= 0)
Begin
Set @Errmessage = 'If GivenAS Scheme [Perc Or Amt] and Value should not be greater than Zero '
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

IF (@SlabType = 3) And ((@FreeUOM > 3) Or (@FreeUOM = 0))
Begin
Set @Errmessage = 'Free UOM Value should NOT be greater than 3 or Zero Value'
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

If (Upper(@ApplOn) = 'INVOICE' AND (@UOM IN (1,2,3)))
Begin
Set @UOM = 4
Set @Errmessage = 'Warning: If Applicable On is Invoice then SlabType- UOM 1-2-3 are Invalid. For the Received SchemeID' + Convert(Varchar, @RecdSchID)
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
End

If (@SlabStart > @SlabEnd)
Begin
Set @Errmessage = 'SlabStart Value should NOT be greater than SlabEnd Value For the Received SchemeID' + Convert(Varchar, @RecdSchID)
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

IF (((@SlabType = 1) Or (@SlabType = 2)) and (IsNull(@FreeUOM,0) >= 0 Or IsNull(@Volume,0) > 0 Or  IsNull(@FreeSKU,'') <> ''))
Begin
Set @Errmessage = 'Warning:If SlabType is 1 then  FreeUOM-Volume-FreeSku Values should not be given but schemes will be Processed'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Set @FreeUOM =0
Set @Volume =0
Set @FreeSKU=0
End

IF ((IsNull(@SlabType,0) = 3) and (IsNull(@Value,0) > 0))
Begin
Set @Errmessage = 'Warning: If SlabType is 3 then  Value should not be given but schemes will be Processed'
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Set @Value =0
End

If (IsNull(upper(@SchemeType),'')  <> 'PR')
Begin
IF ((IsNull(@SlabType,0) = 2) and (IsNull(@Value,0) > 100))
Begin
Set @Errmessage = 'Slab Percentage should not be Greater than 100 percent For % Scheme. For the Received SchemeID' + Convert(Varchar, @RecdSchID)
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End
End

If ((IsNull(@SlabStart,0) < 0)  Or (IsNull(@SlabEnd,0) < 0) Or (IsNull(@Onward,0) < 0)Or (IsNull(@Value,0) < 0) Or (IsNull(@FreeUOM,0)< 0) Or (IsNull(@Volume,0) < 0))
Begin
Set @Errmessage = 'SlabStart Or SlabEnd Or Onward Or Value Or FreeUOm Or Volume should not be In negative Value For the Received SchemeID  ' + Convert(Varchar, @RecdSchID)
Update tbl_mERP_RecdSchAbstract Set CS_Flag = CS_Flag | 64 Where CS_SchemeID = @RecdSchID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSCH', @Errmessage,  @RecdSchID, getdate())
Select -1,@Errmessage
Goto Skip
End

Declare Cur_Subgrp Cursor  For
Select Distinct SubgroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchID And GroupID = @GroupID
Order By SubGroupID
Open Cur_Subgrp
Fetch From Cur_Subgrp Into @GpID
While @@Fetch_Status = 0
Begin
Insert Into tbl_mERP_SchemeSlabDetail (SchemeID, SlabType, GroupID, UOM, SlabStart, SlabEnd
, Onward, Value, FreeUOM, Volume, UnitRate)
Values(@SchID, @SlabType, @GpID, @UOM, @SlabStart, @SlabEnd, @Onward, @Value,  @FreeUOM, @Volume , @UnitRate )

Select @SlabID = @@Identity

If ((@SlabType = 3))
Begin
Create Table #FreeSku (FreeSku nVarchar(4000))
Insert Into #FreeSku
Select * from dbo.sp_SplitIn2Rows(@FreeSku, '|')

Insert Into tbl_mERP_SchemeFreeSKU(SlabID, SKUCode)
Select @SlabID, FreeSku From #FreeSkU

Drop table #FreeSku
End
Fetch Next From  Cur_Subgrp Into @GpID
End
Close Cur_Subgrp
Deallocate Cur_Subgrp


Fetch Next From MyCursor Into @SlabType, @GroupID, @UOM, @SlabStart, @SlabEnd, @Onward,  @Value
, @FreeUOM, @Volume, @FreeSku, @UnitRate
End
Close MyCursor
Deallocate MyCursor

Drop table #TChannel
Drop table #TOuteletClass
Drop table #TOutelet
Drop table #Toutlettype

Select 1,'Done'

GOTO Last
Skip:
Close MyCursor
Deallocate MyCursor
Drop table #TChannel
Drop table #TOuteletClass
Drop table #TOutelet
Close ChannelCur
Deallocate ChannelCur
Close OutletClassCur
DeAllocate OutletClassCur
Close OutletCur
DeAllocate OutletCur
Close LoyaltyListCur
DeAllocate LoyaltyListCur
Goto Endl
Last:
Close ChannelCur
Deallocate ChannelCur
Close OutletClassCur
DeAllocate OutletClassCur
Close OutletCur
DeAllocate OutletCur
Close LoyaltyListCur
DeAllocate LoyaltyListCur
Goto Endl
Middle:
Close ChannelCur
Deallocate ChannelCur
Close OutletClassCur
DeAllocate OutletClassCur
Close OutletCur
DeAllocate OutletCur
Close LoyaltyListCur
DeAllocate LoyaltyListCur
SchemeCapoutlet:
Close CapOutletCur
DeAllocate CapOutletCur
Close DispCapCur
Deallocate DispCapCur
Goto Endl
End -- End for SchemeType

Select 1,'Done'

Endl:

