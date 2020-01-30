Create Procedure Sp_Process_CustomerWiseMerchandise
As
Begin

Declare @MerchandiseName nVarchar(50)
Declare @ActiveStatus Int
Declare @ID Int
Declare @DocTrackerID nVarchar(255)
Declare @MerchandiseID Int
Declare @Customerid nVarchar(15)

Create Table #ReceiveCount (CountNo Int)

Insert Into #ReceiveCount (CountNo)
Select Count(*) from tbl_merp_RecdCustomerwiseMerchandise where Status = 0 and Isnull(MerchandiseName,'') <> ''

If (Select Count(*) from tbl_merp_RecdCustomerwiseMerchandise where Status = 0 ) > 0
Begin
Set @MerchandiseName= ''
Set @ActiveStatus = 0
Set @ID  = 0
Set @DocTrackerID  = 0
Set @MerchandiseID  = 0
Set @Customerid = ''

Declare ProcessCustomerwiseMerchandise Cursor For
Select ID,Customerid,MerchandiseName,Active,DocumentTrackerID from tbl_merp_RecdCustomerwiseMerchandise Where Status = 0
Open ProcessCustomerwiseMerchandise
Fetch Next From ProcessCustomerwiseMerchandise Into @ID,@Customerid,@MerchandiseName,@ActiveStatus,@DocTrackerID
While (@@Fetch_Status = 0)
Begin

If Isnull(@MerchandiseName,'') = ''
Begin
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 2 where Isnull(MerchandiseName,'') = '' and ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCCustMerchandise', 'MerchandiseName should not be Empty :-' +  ' ' + Convert(nVarchar(4000), @MerchandiseName),  '1000', getdate())

GoTo SKIP
End

If Isnull(@Customerid,'') = ''
Begin
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 2 where Isnull(Customerid,'') = '' and ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCCustMerchandise', 'CustomerID should not be Empty :-' +  ' ' + Convert(nVarchar(4000), @Customerid),  '1000', getdate())
GoTo SKIP
End

If Isnull(Upper(@MerchandiseName),'') = 'ALL MERCHANDISE'
Begin
If ISNULL(@ActiveStatus,0) = 0
Begin
Delete From CustMerchandise Where Isnull(CustomerID,'') = @Customerid
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName and CustomerID = @Customerid
End
Else
Begin
Delete From CustMerchandise Where Isnull(CustomerID,'') = @Customerid
Insert Into CustMerchandise (CustomerID,MerchandiseID)
Select @Customerid,MerchandiseID from Merchandise
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName and CustomerID = @Customerid
End

End
Else
Begin

If ( Select Count(*) from Customer where Customerid = Isnull(@Customerid,'') ) = 0
Begin
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 2 where Isnull(Customerid,'') = @Customerid and ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCCustMerchandise', 'Invalid Customerid :-' +  ' ' + Convert(nVarchar(4000), @Customerid),  '1000', getdate())
GoTo SKIP
End

select @MerchandiseID = MerchandiseID from Merchandise where Merchandise = @MerchandiseName
If ISNULL(@ActiveStatus,0) = 0
Begin
Delete From CustMerchandise Where Isnull(CustomerID,'') = @Customerid And MerchandiseID = @MerchandiseID
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName and CustomerID = @Customerid
End
Else
If Isnull(@MerchandiseID,0) > 0
Begin
If (Select COUNT(*) from CustMerchandise Where MerchandiseID = @MerchandiseID and Customerid = @Customerid) = 0
Begin
Insert Into CustMerchandise(CustomerID,MerchandiseID)
Select @Customerid,@MerchandiseID
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName and CustomerID = @Customerid
End
Else
Begin
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 1 Where ID = @ID And MerchandiseName = @MerchandiseName and CustomerID = @Customerid
End
End
Else
Begin
Update tbl_merp_RecdCustomerwiseMerchandise Set Status = 2 where ID = @ID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCCustMerchandise', 'MerchandiseName not availble in the Master :-' +  ' ' + Convert(nVarchar(4000), @MerchandiseName),  '1000', getdate())
GoTo SKIP
End
End
SKIP:
Fetch Next From ProcessCustomerwiseMerchandise Into @ID,@Customerid,@MerchandiseName,@ActiveStatus,@DocTrackerID
End
Close ProcessCustomerwiseMerchandise
Deallocate ProcessCustomerwiseMerchandise
End

Select * from #ReceiveCount

Drop Table #ReceiveCount

End
