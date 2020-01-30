CREATE Procedure Sp_InsertmarketMasterinfo(
				@MMID Int,
				@CustomerCode Nvarchar(255))
As
Begin
	If isnull(@MMID,0) > 0 and isnull(@CustomerCode,'') <> ''
	Begin
		If Exists (select Top 1 * from CustomerMarketInfo Where CustomerCode =  @CustomerCode and Active = 1)
		Begin
			Update CustomerMarketInfo set Active = 0, ModifiedDate = Getdate() Where CustomerCode =  @CustomerCode and Active = 1 
		End

		Insert Into CustomerMarketInfo (MMID,CustomerCode,Active,CreationDate,ModifiedDate)
		Values (@MMID,@CustomerCode,1,Getdate(),Null)
	End
	Else If isnull(@MMID,0) = -1 and isnull(@CustomerCode,'') <> ''
		Update CustomerMarketInfo set Active = 0, ModifiedDate = Getdate() Where CustomerCode =  @CustomerCode and Active = 1 
End
