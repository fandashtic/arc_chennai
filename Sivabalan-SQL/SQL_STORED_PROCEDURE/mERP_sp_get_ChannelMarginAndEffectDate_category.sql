CREATE PROCEDURE mERP_sp_get_ChannelMarginAndEffectDate_category
(
@CategoryName nVarChar(30),
@ChannelCode nvarchar(15),
@RegFlag int,
@GRNDate DateTime = Null
)
AS
Begin
	Set DateFormat DMY

	Declare @PTRMargin Decimal(18,6)
	Declare @CategoryID Int
	Declare @ParentID int

	Declare @MarginDetID int
	Declare @MarginPercentage Decimal(18,6)
	Declare @MarginDate Datetime
	Declare @ChannelDetID int
	Declare @ChannelPercentage Decimal(18,6)

	Select @CategoryID=CategoryID From ItemCategories Where Category_Name =@CategoryName

	Create Table #TmpMargin(ID int,Percentage decimal(18,6),EDate datetime)

	IF @GRNDate Is Null 
		Set @GRNDate = GetDate()

	/* To get the latest effective % for the itemcode */
	if Exists(select * from tbl_mERP_MarginDetail where ID in 
     (select (ID) from tbl_mERP_MarginDetail where Code=@CategoryID And Level<>5  and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
	 And Code=@CategoryID 
	 And Level<>5
	 and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
	Begin
		 insert into #TmpMargin
		 Select ID,Percentage,EffectiveDate from tbl_mERP_MarginDetail where Level<>5 and ID in 
		 (select (ID) from tbl_mERP_MarginDetail
		 where Level<>5 and Code=@CategoryID And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
		 And (case when Revokedate is null then 1 
			 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
			 then 1 
			 else 
			 0 end)=1 
	End

	Select @MarginDetID = ID, @MarginPercentage = IsNull(Percentage,0), @MarginDate = isNull(EDate,'')
	From #TmpMargin Where ID = (Select isnull(Max(ID),0) From #TmpMargin)

	--Select IsNull(C.MarginPerc,0) 'ChannelMargin',isNull(M.EDate,''),M.ID 'MarginDetID',C.ID 'ChannelDetID',
	--	IsNull(M.Percentage,0) 'ProdMargin' From #TmpMargin M 
	--Inner Join tbl_mERP_ChannelMarginDetail C ON M.ID = C.MarginDetID
	--		and C.ChannelTypeCode = @ChannelCode and isnull(C.RegFlag,0) & @RegFlag <> 0
	--Where M.ID =(Select isnull(Max(ID),0) From #TmpMargin)

	Select  @ChannelDetID = ID, @ChannelPercentage = IsNull(MarginPerc,0) From tbl_mERP_ChannelMarginDetail
	Where ID = (Select Max(ID) From tbl_mERP_ChannelMarginDetail Where MarginDetID = @MarginDetID and ChannelTypeCode = @ChannelCode and isnull(RegFlag,0) & @RegFlag <> 0)

	Select @MarginDetID, @MarginPercentage, @MarginDate, @ChannelDetID, @ChannelPercentage

	Drop Table #TmpMargin
End
