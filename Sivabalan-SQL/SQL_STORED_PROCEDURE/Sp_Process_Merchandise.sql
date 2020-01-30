Create Procedure Sp_Process_Merchandise
As
Begin

Declare @MerchandiseName nVarchar(50)
Declare @ActiveStatus Int
Declare @ID Int
Declare @DocTrackerID nVarchar(255)
Declare @MerchandiseID Int
Declare @Customerid nVarchar(15)

If (Select Count(*) from tbl_merp_RecdMerchandise where Status = 0 and Isnull(MerchandiseName,'') = '' ) > 0
Begin
Update tbl_merp_RecdMerchandise Set Status = 2 where Isnull(MerchandiseName,'') = '' and Status = 0
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCMerchandise', 'MerchandiseName should not be Empty',  '1000', getdate())
GoTo SKIP
End

Create Table #ReceiveCount (CountNo Int)

Insert Into #ReceiveCount (CountNo)
Select Count(*) from tbl_merp_RecdMerchandise where Status = 0 and Isnull(MerchandiseName,'') <> ''

Declare ProcessMerchandise Cursor For
Select ID,MerchandiseName,Active,DocumentTrackerID from tbl_merp_RecdMerchandise Where Status = 0
Open ProcessMerchandise
Fetch Next From ProcessMerchandise Into @ID,@MerchandiseName,@ActiveStatus,@DocTrackerID
While (@@Fetch_Status = 0)
Begin
If (select Count(*) from Merchandise where Merchandise = Isnull(@MerchandiseName,'')) > 0
If Isnull(@ActiveStatus,0) = 0
Begin
select @MerchandiseID = MerchandiseID from Merchandise where Merchandise = Isnull(@MerchandiseName,'')
update Merchandise set Active = 0 where Merchandise = Isnull(@MerchandiseName,'')
Delete From CustMerchandise where MerchandiseID = @MerchandiseID
Update tbl_merp_RecdMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName
End
Else
Begin
update Merchandise set Active =1  where Merchandise = Isnull(@MerchandiseName,'')
Update tbl_merp_RecdMerchandise Set [Status] = 1 Where ID = @ID And MerchandiseName = @MerchandiseName
End
Else
Begin
Insert Into Merchandise (Merchandise,Active,CreateDate) Values (@MerchandiseName,@ActiveStatus,Getdate())
Update tbl_merp_RecdMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName
End
SKIP:
Fetch Next From ProcessMerchandise Into @ID,@MerchandiseName,@ActiveStatus,@DocTrackerID
End
Close ProcessMerchandise
Deallocate ProcessMerchandise

Select * from #ReceiveCount

Drop Table #ReceiveCount

End
