Create Procedure Sp_InsertRecd_LaunchItems(@RecdDocID Int,@ItemCode Nvarchar(15),@OutletCode Nvarchar(15), @LaunchQuantity Decimal(18,6),
				@UOM Nvarchar(10), @LaunchStartDate DateTime = Null, @LaunchEndDate DateTime = Null, @Sequence int, @Active int)
As
Begin
	Set DateFormat DMY
	Insert Into Recd_LaunchItems (RecdDocID,ItemCode,OutletCode,LaunchQuantity,UOM,LaunchStartDate,LaunchEndDate,Sequence,Active,Status,CreationDate)
	Select @RecdDocID,@ItemCode,@OutletCode,@LaunchQuantity,@UOM,@LaunchStartDate,@LaunchEndDate,@Sequence,@Active,0,Getdate()
	Select @@Identity
End
