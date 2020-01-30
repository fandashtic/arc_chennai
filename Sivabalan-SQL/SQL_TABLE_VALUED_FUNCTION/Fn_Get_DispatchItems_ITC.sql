  
CREATE Function Fn_Get_DispatchItems_ITC(@GroupID nVarchar(1000), @DispatchID Int)
Returns @Items Table  
(  
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As  
Begin  
Declare @TempItems Table  
(  
Product_Code   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
 
	Declare @TempCategory Table(CategoryID Int, Status Int)  

	Declare @Continue Int  
	Declare @CategoryID Int  

	Set @Continue = 1  

		
	Insert Into @TempCategory
	Select 
		IC.CategoryID,0 
	From 
		ProductCategoryGroupAbstract PCGA,
		tblCGDivMapping CGDIV,
		ItemCategories IC
	Where 
		PCGA.GroupID In(Select * From dbo.sp_splitIn2Rows(@GroupID,','))
		And CGDIV.CategoryGroup = PCGA.GroupName
		And IC.Category_Name = CGDIV.Division 
   
	While @Continue > 0      
	Begin      
		Declare Parent Cursor Keyset For Select CategoryID From @TempCategory Where Status = 0      
		Open Parent  
		Fetch From Parent Into @CategoryID      
		While @@Fetch_Status = 0      
		Begin      
			Insert Into @TempCategory       
			Select CategoryID, 0 From ItemCategories Where ParentID = @CategoryID      
			If @@RowCount > 0  
			Update @TempCategory Set Status = 1 Where CategoryID = @CategoryID  
			Else  
			Update @TempCategory Set Status = 2 Where CategoryID = @CategoryID  
		Fetch Next From Parent Into @CategoryID  
	End  
	Close Parent  
	DeAllocate Parent  
	Select @Continue = Count(*) From @TempCategory Where Status = 0  
	End  
	Delete @TempCategory Where Status Not In (0, 2)  
   
	Insert Into @TempItems  
	Select  
	Distinct IT.Product_Code,IT.ProductName  
	From  
	@TempCategory TC,Items IT, Batch_Products BP 
	Where  
	TC.CategoryID = IT.CategoryID  
	And IT.Active = 1  
	And IT.Product_Code = BP.Product_Code
	And IsNull(BP.Damage,0) = 0
	Group by IT.Product_Code, IT.ProductName Having IsNull(Sum(BP.Quantity),0) > 0

	Insert Into @Items Select Product_Code,ProductName From @TempItems  

    Insert Into @Items
		Select Distinct IT.Product_Code,IT.ProductName  
		from Items IT, DispatchAbstract DA, DispatchDetail DD, @TempItems,@TempCategory TC
		where DA.DispatchID = @DispatchID
		And DA.DispatchID = DD.DispatchID
		And DD.Product_Code = IT.Product_Code
		And TC.CategoryID = IT.CategoryID  
		And IT.Product_Code Not in (Select Product_Code from @TempItems)    
		Group by IT.Product_Code, IT.ProductName
	Return  
End
