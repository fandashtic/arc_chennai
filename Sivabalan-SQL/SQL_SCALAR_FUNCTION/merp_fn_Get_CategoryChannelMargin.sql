Create function dbo.merp_fn_Get_CategoryChannelMargin(@Code nvarchar(50),@GRNDate DateTime = Null,@Level int,@Type nVarchar(100),@ChannelCode nvarchar(15),@RegFlag int)
Returns nVarchar(100)  
As
Begin
  Declare @ReturnValue nVarchar(100)
  Declare @MarginID int
  Declare @CatID Int
  Declare @ParentID int
  Declare @TmpMargin Table (ID int, Level int,Percentage decimal(18,6),Edate datetime,RDate datetime)
  Declare @TmpID int
If @GRNDate Is Null 
Set @GRNDate = GetDate()

If @Level<>5 
Begin   
	Set @ParentID=1
	While @ParentID<>0
	Begin
		If Exists(Select * from tbl_mERP_MarginDetail where ID = (select top 1 ID from tbl_mERP_MarginDetail where Code=Cast(@Code as nvarchar) And Level not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, ID desc )
		   And Code=Cast(@Code as nvarchar))         
		   --And (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)        
			Begin
				set @TmpID = (	select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level Not in (5) And 
				dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and 
				isnull(dbo.striptimefromdate(revokeDate),getdate()) >= dbo.striptimefromdate(@GRNDate)) 
			if (isnull(@TmpID,0) = 0)		
				Begin
					set @TmpID = (select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level Not in (5) And 
					dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and revokeDate is null			)
				End
			If (isnull(@TmpID,0) <> 0)
				Begin
					Insert into @TmpMargin
					Select M.ID, C.CatLevel, C.MarginPerc, M.EffectiveDate, M.RevokeDate From tbl_mERP_MarginDetail M 
						Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID 
								and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
					Where M.ID = @TmpID
				End
		set @TmpID =0
--		(
--		select top 1 ID from tbl_mERP_MarginDetail
--		Where Code=Cast(@Code as nvarchar)And Level Not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, ID desc 
--		)
--		And Code=Cast(@Code as nvarchar) 
--		And (case when Revokedate is null then 1 
--			 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
--			 then 1 
--			 else 
--			 0 end)=1
			Select @ParentID=ParentID from ItemCategories where CategoryID=cast(@Code as int)
			Set @Code=Cast(@ParentID as nvarchar)
		End
		Else
		Begin			
			Select @ParentID=ParentID from ItemCategories where CategoryID=cast(@Code as int)
			Set @Code=Cast(@ParentID as nvarchar)
		End   
	 End
End
Else
Begin
	If Exists(select * from tbl_mERP_MarginDetail where ID = (select top 1 ID from tbl_mERP_MarginDetail where Code=@Code And Level=5  and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, ID desc )
	And Code=@Code)
	--and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
	Begin
		set @TmpID = (	select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level = (5) And 
		dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and 
		isnull(dbo.striptimefromdate(revokeDate),getdate()) >= dbo.striptimefromdate(@GRNDate)) 
		if (isnull(@TmpID,0) = 0)		
			Begin
				set @TmpID = (select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level = (5) And 
				dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and revokeDate is null)
			End
		If (isnull(@TmpID,0) <> 0)
			Begin
				Insert Into @TmpMargin
				Select M.ID, C.CatLevel, C.MarginPerc, M.EffectiveDate, M.RevokeDate From tbl_mERP_MarginDetail M
				Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
						and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
				Where M.ID = @TmpID
			End
		If (isnull(@TmpID,0) <> 0)
			Begin
				Insert Into @TmpMargin
				Select M.ID, C.CatLevel, C.MarginPerc, M.EffectiveDate, M.RevokeDate From tbl_mERP_MarginDetail M
				Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
						and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
				Where M.ID = @TmpID
			End
		set @TmpID =0
--	 (select top 1 ID from tbl_mERP_MarginDetail
--	 where Code=@Code And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, ID desc )
--     And (case when Revokedate is null then 1 
--		 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
--		 then 1 
--		 else 
--		 0 end)=1  
	End    
	Set @ParentID=1
	Select @Code=cast(CategoryID as nvarchar) from Items where Product_Code = @Code
	While @ParentID<>0
	Begin
		If Exists(Select * from tbl_mERP_MarginDetail where ID = (select top 1 ID from tbl_mERP_MarginDetail where Code=Cast(@Code as nvarchar) And Level not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, ID desc )
		   And Code=Cast(@Code as nvarchar))           
		   --And (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)        
			Begin
				set @TmpID = (	select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level Not in (5) And 
				dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and 
				isnull(dbo.striptimefromdate(revokeDate),getdate()) >= dbo.striptimefromdate(@GRNDate)) 
			if (isnull(@TmpID,0) = 0)		
				Begin
					set @TmpID = (select max(id) from tbl_mERP_MarginDetail Where Code=Cast(@code as nvarchar)And Level Not in (5) And 
					dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) and revokeDate is null)
				End
			If (isnull(@TmpID,0) <> 0)
				Begin
					Insert into @TmpMargin
					Select M.ID, C.CatLevel, C.MarginPerc, M.EffectiveDate, M.RevokeDate From tbl_mERP_MarginDetail M
					Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
							and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
					Where M.ID = @TmpID
				End
			If (isnull(@TmpID,0) <> 0)
			Begin
				Insert into @TmpMargin
				Select M.ID, C.CatLevel, C.MarginPerc, M.EffectiveDate, M.RevokeDate From tbl_mERP_MarginDetail M
				Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
						and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
				Where M.ID = @TmpID
			End
			set @TmpID =0
--			(select top 1 ID from tbl_mERP_MarginDetail
--			Where Code=Cast(@Code as nvarchar)And Level Not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate) order by dbo.striptimefromdate(EffectiveDate) desc, Level desc, ID desc )
--			And Code=Cast(@Code as nvarchar) 
--			And (case when Revokedate is null then 1 
--				 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
--				 then 1 
--				 else 
--				 0 end)=1            
			Select @ParentID=ParentID from ItemCategories where CategoryID=cast(@Code as int)
			Set @Code=cast(@ParentID as nvarchar)   
		End
		Else
		Begin			
			Select @ParentID=ParentID from ItemCategories where CategoryID=cast(@Code as int)
			Set @Code=cast(@ParentID as nvarchar)  
		End   
	End
End 

  --Select @MarginID = IsNull(ID,0) from @TmpMargin where Edate=(select Max(Edate) from @TmpMargin)
    Select top 1 @MarginID = IsNull(ID, 0) from @TmpMargin order by level desc, ID desc 
  
  IF @Type=N'Percentage' 
     --Select @ReturnValue=Cast(Percentage as nVarchar) from tbl_mERP_MarginDetail where ID=@MarginID
		Select @ReturnValue=Cast(MarginPerc as nVarchar) from tbl_mERP_ChannelMarginDetail where MarginDetID=@MarginID and ChannelTypeCode = @ChannelCode and isnull(RegFlag,0) & @RegFlag <> 0
  Else IF @Type=N'EffectiveDate'
      Select @ReturnValue=Cast(EffectiveDate as nVarchar) from tbl_mERP_MarginDetail where ID=@MarginID
  Else
      Select @ReturnValue=Cast(RevokeDate as nVarchar) from tbl_mERP_MarginDetail where ID=@MarginID
 
  Return @ReturnValue
End 
