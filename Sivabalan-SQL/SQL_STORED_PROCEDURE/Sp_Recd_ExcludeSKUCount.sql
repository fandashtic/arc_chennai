Create Procedure Sp_Recd_ExcludeSKUCount
As
Begin
If (Select Count(*) from tbl_merp_RecdItemCodeRestricted where Status = 0 and Isnull(Product_Code,'') = '' ) > 0
Begin
Update tbl_merp_RecdItemCodeRestricted Set Status = 2 where Isnull(Product_Code,'') = ''
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCItemcodeRestriction', 'Item Code should not be Empty',  '1000', getdate())
End

Create Table #ReceiveCount (CountNo Int)

Insert Into #ReceiveCount (CountNo)
Select Count(*) from tbl_merp_RecdItemCodeRestricted where Status = 0 and Isnull(Product_Code,'') <> ''

If (Select Count(*) from tbl_merp_RecdItemCodeRestricted where Status = 0 and Isnull(Product_Code,'') <> '' ) > 0
Begin

Declare @Product_Code nVarchar(30)
Declare @ActiveStatus Int
Declare @ID Int
Declare @DocTrackerID Int

Declare InsertAndUpdateProductslevel Cursor For
Select ID,Product_Code,Active,DocumentTrackerID from tbl_merp_RecdItemCodeRestricted Where Status = 0
Open InsertAndUpdateProductslevel
Fetch Next From InsertAndUpdateProductslevel Into @ID,@Product_Code,@ActiveStatus,@DocTrackerID
While (@@Fetch_Status = 0)
Begin

If (select Count(*) from tbl_merp_ItemCodeRestricted where Product_Code = @Product_Code) > 0
Begin
Update tbl_merp_ItemCodeRestricted Set Active = @ActiveStatus,ModifiedDate = Getdate() , DocumentTrackerID = @DocTrackerID ,ReceviedID = @ID
Where Product_Code = @Product_Code
Update tbl_merp_RecdItemCodeRestricted Set Status = 1 Where ID = @ID And Product_Code = @Product_Code
End
Else
Begin
Insert Into tbl_merp_ItemCodeRestricted (Product_Code,Active,CreationDate,DocumentTrackerID,ReceviedID) Values (@Product_Code,@ActiveStatus,Getdate(),@DocTrackerID,@ID)
Update tbl_merp_RecdItemCodeRestricted Set Status = 1 Where ID = @ID And Product_Code = @Product_Code
End

Fetch Next From InsertAndUpdateProductslevel Into @ID,@Product_Code,@ActiveStatus,@DocTrackerID
End
Close InsertAndUpdateProductslevel
Deallocate InsertAndUpdateProductslevel
End

Select * from #ReceiveCount

Drop Table #ReceiveCount

End
