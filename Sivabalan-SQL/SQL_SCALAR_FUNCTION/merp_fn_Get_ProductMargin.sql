Create function dbo.merp_fn_Get_ProductMargin(@Product_Code nvarchar(50),@GRNDate DateTime = Null)
Returns decimal(18,6)  
As
Begin
  Declare @ReturnValue decimal(18,6)  
  Declare @CatID Int
  Declare @ParentID int
  Declare @TmpMargin Table (ID int, Level int, Percentage decimal(18,6),Edate datetime)

If @GRNDate Is Null 
Set @GRNDate = GetDate()

If Exists(select * from tbl_mERP_MarginDetail where ID in (select (ID) from tbl_mERP_MarginDetail where Code=@Product_Code And Level=5  and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
And Code=@Product_Code 
and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
Begin
 Insert into @TmpMargin
 Select ID, IsNull(Level,0) Level, Percentage,EffectiveDate from tbl_mERP_MarginDetail where ID in 
 (select (ID) from tbl_mERP_MarginDetail
 where Code=@Product_Code And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
 And (case when Revokedate is null then 1 
             when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
             then 1 
             else 
             0 end)=1
End    
 Set @ParentID=1
 Select @CatID=CategoryID from Items where Product_Code = @Product_Code
 While @ParentID<>0
 Begin
    If Exists(Select * from tbl_mERP_MarginDetail where ID in (select (ID) from tbl_mERP_MarginDetail where Code=Cast(@CatID as nvarchar) And Level not in (5) And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
       And Code=Cast(@CatID as nvarchar)           
       And (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)        
    Begin
        Insert into @TmpMargin
        Select ID, IsNull(Level,0) Level, Percentage,EffectiveDate from tbl_mERP_MarginDetail where ID in 
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
   
  --Select @ReturnValue = IsNull(Percentage,0) from @TmpMargin where Edate=(select Max(Edate) from @TmpMargin)
  Select @ReturnValue = IsNull(Percentage,0) from @TmpMargin where ID=(select Top 1 ID from @TmpMargin  order by level desc, EDate Desc)
  Return @ReturnValue
End 
