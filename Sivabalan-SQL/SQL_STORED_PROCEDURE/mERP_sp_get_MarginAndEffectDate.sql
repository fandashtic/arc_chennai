CREATE PROCEDURE mERP_sp_get_MarginAndEffectDate
(
@ItemCode nVarChar(30),
@GRNDate DateTime = Null
)
AS
Declare @PTRMargin Decimal(18,6)
Declare @CatID Int
Declare @ParentID int

Create Table #TmpMargin(ID int,Percentage decimal(18,6),EDate datetime)

If @GRNDate Is Null 
Set @GRNDate = GetDate()


	/* To get the latest effective % for the itemcode */
	if Exists(select * from tbl_mERP_MarginDetail where ID in (select (ID) from tbl_mERP_MarginDetail where Code=@ItemCode And Level=5  and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
	   And Code=@ItemCode 
	   and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
	Begin
		 insert into #TmpMargin
		 Select ID,Percentage,EffectiveDate from tbl_mERP_MarginDetail where ID in 
		 (select (ID) from tbl_mERP_MarginDetail
		 where Code=@ItemCode And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
		 And (case when Revokedate is null then 1 
			 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
			 then 1 
			 else 
			 0 end)=1 
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


Select IsNull(Percentage,0),isNull(EDate,''), ID from #TmpMargin where ID=(select isnull(Max(ID),0) from #TmpMargin)

drop table #TmpMargin

