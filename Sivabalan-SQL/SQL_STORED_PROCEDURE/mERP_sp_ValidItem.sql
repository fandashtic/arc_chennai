Create Procedure mERP_sp_ValidItem(@ItemInfo nVarchar(2000))
As
Begin
	Declare @ErrMsg as nVarchar(4000)
	Declare @ProdCode nVarchar(255)
	Declare @ProdName nVarchar(800)
	Declare @UOM nVarchar(10)
	Declare @UOMID Int


	Declare @tmpItem table([RowID] Int Identity(1,1),ItemDetail nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into @tmpItem
	Select * From dbo.sp_SplitIn2Rows(@ItemInfo,'~')

	Select @ProdCode = ItemDetail From @tmpItem Where [RowID] = 1
	Select @ProdName = ItemDetail From @tmpItem Where [RowID] = 2
	Select @UOM = ItemDetail From @tmpItem Where [RowID] = 3

	Select @UOMID = UOM From UOM Where Description = @UOM

	If Not Exists(Select * From Items Where Product_Code = @ProdCode /* And ProductName = @ProdName */ )
		Set @ErrMsg = 'InValid Item'
	Else If Not Exists(Select * From Items Where Product_Code = @ProdCode /* And ProductName = @ProdName */ and Active = 1)
		Set @ErrMsg = 'Inactive Item'
	Else If Not Exists(Select *  From uom Where Description = @UOM)
		Set @ErrMsg = 'InValid UOM'
	Else If Not Exists(Select * From Items I,UOM U
	 Where  Product_Code = @ProdCode 
	/* And ProductName = @ProdName */ And I.Active = 1
	And (I.UOM = @UOMID  OR I.UOM1 = @UOMID OR I.UOM2 = @UOMID ))
		Set @ErrMsg = 'Invalid UOM For The Item'
	
	If (select Isnull(Flag,0) FLAG from tbl_merp_configabstract Where ScreenCode = 'OCGDS')	 = 1
	Begin
		IF (select Count(*) from Fn_GetOCGSKU('%')Where Product_Code = @ProdCode) <> 1
		Begin
			Set @ErrMsg = 'Item Not Mapped With OCG Group / Item Not Mapped With More than One OCG Group'
		End	
	End
	
	Select isNull(@ErrMsg,'1')

End
