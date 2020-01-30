Create Function GetItems_ITC(@CatGroup nvarchar(2550),@Category nvarchar(2550))
Returns @CatID Table (CatID Int)
As
Begin

Declare @Continue int  
Declare @CategoryID int  
Set @Continue = 1  

Declare @Delimeter as Char(1)    
Set @Delimeter = Char(44)    

Declare @tmp1 Table (CategoryID Int, Status Int)

if @Category = N'%%'
Begin
	if @CatGroup <>  N'%%'
	begin
		Insert into @tmp1 select CategoryID, 0   
		From ProductCategoryGroupDetail Where GroupID In (Select GroupID From ProductCategoryGroupAbstract Where GroupName In(Select * from dbo.sp_SplitIn2Rows(@CatGroup,@Delimeter)))
	end
	else
	begin
		Insert into @tmp1 select CategoryID, 0   
		From ItemCategories
	end
End
Else
Begin
	sELECT @cATEGORY=rEPLACE(@CATEGORY,N'%',N'')

	Insert into @tmp1 select CategoryID, 0   
	From ItemCategories 
	Where ItemCategories.Category_Name in
        (Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))
End
  
While @Continue > 0  
  Begin  
    Declare Parent Cursor Keyset For  
    Select CategoryID From @tmp1 Where Status = 0  
    Open Parent  
    Fetch From Parent Into @CategoryID  
    While @@Fetch_Status = 0  
    Begin  
      Insert into @tmp1   
      Select CategoryID, 0 From ItemCategories   
      Where ParentID = @CategoryID  
      If @@RowCount > 0   
        Update @tmp1 Set Status = 1 Where CategoryID = @CategoryID  
      Else  
        Update @tmp1 Set Status = 2 Where CategoryID = @CategoryID  
        Fetch Next From Parent Into @CategoryID  
    End  
    Close Parent  
    DeAllocate Parent  
    Select @Continue = Count(*) From @tmp1 Where Status = 0  
  End  

Delete @tmp1 Where Status not in  (0, 2)  

Insert @CatID Select Distinct CategoryID From @tmp1
Return

End

