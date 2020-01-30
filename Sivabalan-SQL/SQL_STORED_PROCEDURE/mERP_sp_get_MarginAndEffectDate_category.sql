CREATE PROCEDURE mERP_sp_get_MarginAndEffectDate_category
(
@CategoryName nVarChar(30),
@GRNDate DateTime = Null
)
AS
Declare @PTRMargin Decimal(18,6)
Declare @CategoryID Int
Declare @ParentID int

select @CategoryID=categoryID from itemcategories where category_name =@CategoryName

Create Table #TmpMargin(ID int,Percentage decimal(18,6),EDate datetime)

If @GRNDate Is Null 
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


Select IsNull(Percentage,0),isNull(EDate,''), ID from #TmpMargin where ID=(select isnull(Max(ID),0) from #TmpMargin)

drop table #TmpMargin

