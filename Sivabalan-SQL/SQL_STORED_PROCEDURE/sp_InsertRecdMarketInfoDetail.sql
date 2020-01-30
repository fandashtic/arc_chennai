Create Procedure sp_InsertRecdMarketInfoDetail
				(@RecID Int, 
				@District Nvarchar(250),
				@Sub_District Nvarchar(250),
				@MarketID Int,
				@MarketName Nvarchar(240),
				@Pop_Group Nvarchar(250),
				@DefaultMarketFlag Int,
				@Active Int)
As
	Begin
		Set DATEFormat DMY
		If isnull(@District,'') <> ''
		Begin 
			If isnull(@MarketID,'') <> ''
				Begin
					If isnull(@MarketName,'') <> ''
						Begin 
							INSERT INTO RecdMarketInfoDetail (RecMMID,District,Sub_District,MarketID,MarketName,Pop_Group,DefaultMarketFlag,Active,Status,CreationDate)     
							Select @RecID, @District ,@Sub_District ,@MarketID ,@MarketName ,@Pop_Group ,@DefaultMarketFlag ,@Active ,0,Getdate()
						End
					Else
						Update RecdMarketInfoAbstract Set Status = 2 , RecFlag = 2 Where DocumentID = @RecID 
				End
			Else
				Update RecdMarketInfoAbstract Set Status = 2 , RecFlag = 2 Where DocumentID = @RecID 
		End
		Else
			Update RecdMarketInfoAbstract Set Status = 2 , RecFlag = 2 Where DocumentID = @RecID 
	End
