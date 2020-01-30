Create Procedure mERP_sp_InsertCustMerchandise(@CustID nVarchar(255),@Mechandise nVarchar(2000))
As
Begin


	Declare  @Merchnd nVarchar(500)
	Declare @ID Int
	Declare @RowCount as Int 
	Declare @ncounter as Int
	Declare @MerchandiseID Int
	Declare @Success Int
	Declare @Err as Int

	Set @ncounter = 1


	Declare @tmpMerchandise Table (ID Int Identity(1,1) ,Merchandise nVarchar(200))
	Declare @tmpMerchndValue Table (ID Int Identity(1,1) ,MerchandiseID Int,Value nVarchar(5))
	Declare @tmpResult Table (ID Int Identity(1,1) ,MerchandiseID Int,Value nVarchar(5))
	Insert Into @tmpMerchandise
	Select * From dbo.sp_splitIn2Rows(@Mechandise,'|')
	Set @RowCount = (select max(ID) from @tmpMerchandise)



	Delete From  @tmpMerchndValue 
	Set @MerchandiseID = ''
	While (@ncounter <= @RowCount)
	Begin
		Select @Merchnd = Merchandise From @tmpMerchandise Where ID = @ncounter

		Select @MerchandiseID =  MerchandiseID From  Merchandise Where 
		Merchandise = Substring(@Merchnd,1,Charindex('~',@Merchnd)-1)

		
		Select @Err = @@Error
		If @Err <> 0 
		 GoTo OverNOut

		Insert Into @tmpMerchndValue Values(@MerchandiseID,Substring(@Merchnd,Charindex('~',@Merchnd)+1,Len(@Merchnd)))
		
		Select @Err = @@Error
		If @Err <> 0 
		 GoTo OverNOut
		
		Set @ncounter = @ncounter + 1

	End


	/* The same Merchndising type may be repeated more than once,while importing merchnaidse through Import
	Hence latest of the same merchandising type will be considered*/
	
	Insert Into @tmpResult
	Select Distinct MerchandiseID,(Select Value From @tmpMerchndValue Where MerchandiseID = T.MerchandiseID And ID = 
							(Select Max(ID) From @tmpMerchndValue Where  MerchandiseID = T.MerchandiseID))
	From @tmpMerchndValue T

	
	Delete From CustMerchandise Where CustomerID = @CustID

	
	Insert Into CustMerchandise
	Select @CustID , MerchandiseID From @tmpResult Where Value = 'YES'

	Select @Err = @@Error
	If @Err <> 0 
		 GoTo OverNOut

	
OverNOut:
	Select @Err	
End

