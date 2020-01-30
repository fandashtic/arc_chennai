Create Procedure Sp_Process_SpecialSKUMaster
As
Begin

Declare @ID Int
Declare @Period nVarchar(8)
Declare @BilledSKU nVarchar(15)
Declare @FreeSKU nVarchar(15)
Declare @DistributionPercentage Decimal(18,6)
Declare @Active Int
Declare @Status Int
Declare @CreationTime DateTime
Declare @ActiveStatus Int
Declare @UniqueID Int
Declare @FActive nVarchar(15)
Declare @DayMonth Int
Declare @Dayyear Int
Declare @FromDate DateTime
Declare @ToDate DateTime

Set dateformat dmy

/*
--Set dateformat dmy
Select 	@DayMonth = Left(@Period,2),@Dayyear = Right(@Period, LEN(@Period) - 3)

Select @FromDays = Cast('01' as nVarchar(2)) + '/' + Cast(@DayMonth as nvarchar(2)) + '/' + Cast(@Dayyear As nVarchar(4))
SELECT @ToDays = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@FromDays)+1,0))
*/

Declare ProcessSplFreeSKU Cursor For
Select ID,[Period],BilledSKU,FreeSKU,DistributionPercentage,Case When Upper(Active) = 'ACTIVE' Then 1 Else 0 End,Status,CreationTime,
UniqueID,Active
from SpecialSKUMaster_Received where Status = 0
Open ProcessSplFreeSKU
Fetch Next From ProcessSplFreeSKU Into @ID,@Period,@BilledSKU,@FreeSKU,@DistributionPercentage,@Active,@Status,@CreationTime,@UniqueID,@FActive
While (@@Fetch_Status = 0)
Begin

If (Select Count(*) from SpecialSKUMaster_Received where Status = 0 and Isnull(@BilledSKU,'') = Isnull(@FreeSKU,'') ) > 0
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Isnull(BilledSKU,'') = '' and Status = 0	And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'BilledSKU and DDS should not be Same.',  '1000', getdate())
GoTo SKIP
End

If (Select Count(*) from SpecialSKUMaster_Received where Status = 0 and Isnull(@BilledSKU,'') = '' ) > 0
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Isnull(BilledSKU,'') = '' and Status = 0	And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'BilledSKU should not be Empty',  '1000', getdate())
GoTo SKIP
End

If (Select Count(*) from SpecialSKUMaster_Received where Status = 0 and Isnull(@FreeSKU,'') = '' ) > 0
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Isnull(FreeSKU,'') = '' and Status = 0 And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'DDS should not be Empty',  '1000', getdate())
GoTo SKIP
End

If Isnull(@DistributionPercentage,0) <= 0 Or Isnull(@DistributionPercentage,0) > 100
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Status = 0 And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'Distribution percentage cannot be zero or negative or greater than 100.',  '1000', getdate())
GoTo SKIP
End

If Isnull(@Period,'') = ''
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Status = 0 And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'Period should not be Empty.',  '1000', getdate())
GoTo SKIP
End


If Upper(@FActive) <> 'ACTIVE'
Begin
If (Select Count(*) from SpecialSKUMaster_Received where UniqueID = Isnull(@UniqueID,0)) = 1
Begin
If (Select Count(*) from SpecialSKUMaster where Period = Isnull(@Period,'') And Active = 1) = 0
Begin
Update SpecialSKUMaster_Received Set Status = 2 where Status = 0 And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'First Time Received UniqueID with Inactive Status',  '1000', getdate())
GoTo SKIP
End
End
End
If Upper(@FActive) <> 'ACTIVE'
Begin
If (Select Count(*) from SpecialSKUMaster_Received where UniqueID = Isnull(@UniqueID,0)) >= 1
Begin
If (Select Count(*) from SpecialSKUMaster where Period = Isnull(@Period,'') And Active = 1 And UniqueID = Isnull(@UniqueID,0)) = 0
Begin
--Select 25
Update SpecialSKUMaster_Received Set Status = 2 where Status = 0 And ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCSPLFree', 'Different UniqueID and Same month Inactive Status',  '1000', getdate())
GoTo SKIP
End
End
End


Set @FromDate = ''
Set @ToDate = ''

Select @FromDate = Convert(nvarchar(10),dbo.mERP_fn_getFromDate(@Period),103), @ToDate = Convert(nvarchar(10),dbo.mERP_fn_getToDate(@Period),103)


Begin
If (select Count(*) from SpecialSKUMaster where Period = Isnull(@Period,'')) = 0
Begin
Insert Into SpecialSKUMaster(RecdID,UniqueID,Period,BilledSKU,FreeSKU,DistributionPercentage,FromDate,ToDate,Active,CreationTime)
Select @ID,Isnull(@UniqueID,0),@Period,@BilledSKU,@FreeSKU,@DistributionPercentage,@FromDate,@ToDate,Isnull(@Active,0),@CreationTime from SpecialSKUMaster_Received
Where ID = @ID
End
Else
Begin
Update SpecialSKUMaster Set Active = 0 Where Period = Isnull(@Period,'')
Insert Into SpecialSKUMaster(RecdID,UniqueID,Period,BilledSKU,FreeSKU,DistributionPercentage,FromDate,ToDate,Active,CreationTime)
Select @ID,Isnull(@UniqueID,0),@Period,@BilledSKU,@FreeSKU,@DistributionPercentage,@FromDate,@ToDate,Isnull(@Active,0),@CreationTime from SpecialSKUMaster_Received
Where ID = @ID
End

Update SpecialSKUMaster_Received Set Status = 1 where ID = @ID	And Status = 0
SKIP:
End
Fetch Next From ProcessSplFreeSKU Into @ID,@Period,@BilledSKU,@FreeSKU,@DistributionPercentage,@Active,@Status,@CreationTime,@UniqueID,@FActive
End
Close ProcessSplFreeSKU
Deallocate ProcessSplFreeSKU
End
