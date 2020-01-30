Create Procedure mERP_sp_Save_OLClassMapping(@CustomerID nVarchar(50), @OLClassID Int)
As
Begin
Declare @PrevID Int
Declare @Config int
--To allow AE to Map Ol Class for the mapped Customer
Set @Config=0
select @Config=isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenName='EnableAEOLClassMap'
Select @PrevID = IsNull(ID,0) From tbl_mERP_OLClassMapping Where CustomerID = @CustomerID And Active = 1
If @PrevID > 0
Begin
	if @Config=1
    Begin
		Update tbl_mERP_OLClassMapping Set Active = 0, ModifiedDate = GetDate() Where ID = @PrevID
		Insert into tbl_mERP_OLClassMapping(CustomerID, OLClassID) Values(@CustomerID, @OLClassID)
		Select @@IDentity 
    End
	Else
		Select 1
End
Else
Begin
	Insert into tbl_mERP_OLClassMapping(CustomerID, OLClassID) Values(@CustomerID, @OLClassID)
	Select @@IDentity
End
End
