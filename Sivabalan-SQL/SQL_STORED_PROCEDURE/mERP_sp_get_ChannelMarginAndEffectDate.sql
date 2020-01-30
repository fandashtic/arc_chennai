CREATE PROCEDURE mERP_sp_get_ChannelMarginAndEffectDate
(
@ItemCode nVarChar(30),
@ChannelCode nvarchar(15),
@RegFlag int,
@GRNDate DateTime = Null
)
AS
Begin
	Set DateFormat DMY

	Declare @PTRMargin Decimal(18,6)
	Declare @CatID Int
	Declare @ParentID int

	Declare @MarginDetID int
	Declare @MarginPercentage Decimal(18,6)
	Declare @MarginDate Datetime
	Declare @ChannelDetID int
	Declare @ChannelPercentage Decimal(18,6)

	Create Table #TmpMargin(ID int,Percentage decimal(18,6),EDate datetime)

	IF @GRNDate Is Null 
		Set @GRNDate = GetDate()

	/* To get the latest effective % for the itemcode */
	IF Exists(Select * From tbl_mERP_MarginDetail Where ID in (select (ID) from tbl_mERP_MarginDetail where Code=@ItemCode And Level=5  and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
	   And Code=@ItemCode 
	   and (Case When Revokedate is null Then 1 When dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
	Begin
		 Insert Into #TmpMargin
		 Select ID,Percentage,EffectiveDate From tbl_mERP_MarginDetail Where ID in 
			(Select (ID) from tbl_mERP_MarginDetail
				Where Code=@ItemCode And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
		 And (Case when Revokedate is null Then 1 
			 When dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) Then 1 Else 0 End)=1 
	End
	Set @ParentID=1
	Select @CatID=CategoryID from Items where Product_Code = @ItemCode
	While @ParentID<>0
	Begin
		If Exists(Select * from tbl_mERP_MarginDetail where ID in (select (ID) from tbl_mERP_MarginDetail where Code=Cast(@CatID as nvarchar) And Level not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
		And Code=Cast(@CatID as nvarchar)           
		And (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)        
		Begin
			insert into #TmpMargin            
			Select ID,Percentage,EffectiveDate from tbl_mERP_MarginDetail where ID in 
			(select (ID) from tbl_mERP_MarginDetail
			Where Code=Cast(@CatID as nvarchar)And Level Not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
			And Code=Cast(@CatID as nvarchar) 
			And (case when Revokedate is null then 1 
				 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
				 then 1 
				 else 
				 0 end)=1        
			Select @CatID=ParentID from ItemCategories where CategoryID=@CatID
			Set @ParentID=@CatID     
		End
		Else
		Begin			
			Select @CatID=ParentID from ItemCategories where CategoryID=@CatID
			Set @ParentID=@CatID  
		End   
	End

	Select @MarginDetID = ID, @MarginPercentage = IsNull(Percentage,0), @MarginDate = isNull(EDate,'')
	From #TmpMargin Where ID = (Select isnull(Max(ID),0) From #TmpMargin)

--	Select IsNull(C.MarginPerc,0) 'ChannelMargin',isNull(M.EDate,''),M.ID 'MarginDetID',C.ID 'ChannelDetID',
--			IsNull(M.Percentage,0) 'ProdMargin' From #TmpMargin M 
--	Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
--			and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
--	Where M.ID =(Select isnull(Max(ID),0) From #TmpMargin)

	Select  @ChannelDetID = ID, @ChannelPercentage = IsNull(MarginPerc,0) From tbl_mERP_ChannelMarginDetail
	Where ID = (Select Max(ID) From tbl_mERP_ChannelMarginDetail Where MarginDetID = @MarginDetID and ChannelTypeCode = @ChannelCode and isnull(RegFlag,0) & @RegFlag <> 0)

	Select @MarginDetID, @MarginPercentage, @MarginDate, @ChannelDetID, @ChannelPercentage

	Drop Table #TmpMargin
End
