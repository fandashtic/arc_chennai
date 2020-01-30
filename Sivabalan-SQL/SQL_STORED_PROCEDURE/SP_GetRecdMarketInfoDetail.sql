Create Procedure SP_GetRecdMarketInfoDetail (@RecMMID Int)
AS  
Begin
	If @RecMMID > 0 
	Begin
		Set DateFormat DMY
		Declare @Mode as Nvarchar(10)
		Declare @MMID as Int
		Create Table #TempOut (ID Int,
					RecMMID Int,
					District Nvarchar(250),
					Sub_District Nvarchar(250),
					MarketID Int,
					MarketName Nvarchar(240),
					Pop_Group Nvarchar(250),
					DefaultMarketFlag Int,
					Active Int)

		Insert into #TempOut select ID,RecMMID,District,Sub_District,MarketID,MarketName,Pop_Group,DefaultMarketFlag,Active
		From RecdMarketInfoDetail Where RecMMID = @RecMMID and Status = 0

			Declare @ID Int
			Declare @District as Nvarchar(250)
			Declare @Sub_District as Nvarchar(250)
			Declare @MarketID Int
			Declare @MarketName as Nvarchar(240)
			Declare @Pop_Group as Nvarchar(250)
			Declare @DefaultMarketFlag Int
			Declare @Active Int
			Declare @clu Cursor 
			Set @clu = Cursor for
			Select Distinct ID,District,Sub_District,MarketID,MarketName,Pop_Group,DefaultMarketFlag,Active from #TempOut
			Open @clu
			Fetch Next from @clu into @ID,@District,@Sub_District,@MarketID,@MarketName,@Pop_Group,@DefaultMarketFlag,@Active
			While @@fetch_status =0
				Begin					
						Begin
							Declare @OldDistrict as Nvarchar(250)
							Declare @OldSub_District as Nvarchar(250)
							Declare @OldMarketID Int
							Declare @OldMarketName as Nvarchar(240)

							if exists (Select Top 1 * from MarketInfo where MarketID=@MarketID )
							Begin
								update MarketInfo set District = @District , Sub_District = @Sub_District , Pop_Group = @Pop_Group, MarketName = @MarketName , Active=@Active,modifieddate=getdate(),defaultmarketflag=@DefaultMarketFlag where MarketID=@MarketID 
							End
							else							
							Begin
								INSERT INTO MarketInfo(District,Sub_District,MarketID,MarketName,Pop_Group,DefaultMarketFlag,Active,CreationDate,ModifiedDate)
								Select @District,@Sub_District,@MarketID,@MarketName,@Pop_Group,@DefaultMarketFlag,@Active,Getdate(),Getdate()
							End
							Update RecdMarketInfoDetail set Status = 1 Where ID = @ID and RecMMID=@RecMMID
							--Update RecdMarketInfoAbstract set Status = 1 Where Documentid = (select Distinct RecMMID From RecdMarketInfoDetail Where ID = @ID)							
						End
					Fetch Next from @clu into @ID,@District,@Sub_District,@MarketID,@MarketName,@Pop_Group,@DefaultMarketFlag,@Active
				End
			Close @clu
			Deallocate @clu
--Final Entry:
			Update RecdMarketInfoDetail set Status = 2 Where RecMMID = @RecMMID and isnull(Status,0) = 0

			if exists (select top 1 * from RecdMarketInfoDetail where status=2 and RecMMID=@RecMMID)
				Update RecdMarketInfoAbstract set Status = 2 , RecFlag = 2 Where DocumentId = @RecMMID 
			else
				Update RecdMarketInfoAbstract set Status = 1 Where DocumentId = @RecMMID 
			
			Drop table #TempOut
	End
End
