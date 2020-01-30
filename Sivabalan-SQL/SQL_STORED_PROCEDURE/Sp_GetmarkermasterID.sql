CREATE Procedure Sp_GetmarkermasterID(
				@Market_District Nvarchar(250),
				@Sub_District Nvarchar(250),
				@Pop_Group Nvarchar(250),
				@Market Nvarchar(240),
				@MCFlag int=0
				)
As
Begin
	If isnull(@Market_District,'') = '' or @Market_District = '%' 
	Begin 
		Goto Out 
	End
	ELSE If isnull(@Market,'') = '' or @Market = '%' 
	Begin 
		Goto Out 
	End
	ELSE
	BEGIN
		if @MCFlag=1 
		BEGIN
		--Active condition checking removed for modify customer alone
		select Top 1 MMID from MarketInfo Where District = @Market_District 
		and Sub_District = @Sub_District 
		and Pop_Group = @Pop_Group 
		and (Cast(Marketid as Nvarchar(10)) + '-' + MarketName) = @Market
		--and Active = 1
		END
		ELSE
		BEGIN
		select Top 1 MMID from MarketInfo Where District = @Market_District 
		and Sub_District = @Sub_District 
		and Pop_Group = @Pop_Group 
		and (Cast(Marketid as Nvarchar(10)) + '-' + MarketName) = @Market
		and Active = 1
		END
	End
	Out:

End
