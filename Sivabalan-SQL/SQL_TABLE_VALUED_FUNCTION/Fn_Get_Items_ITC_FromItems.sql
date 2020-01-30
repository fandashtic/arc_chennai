    
Create Function Fn_Get_Items_ITC_FromItems(@GroupID nVarchar(1000))  
Returns @Items Table    
(    
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS   
)    
As    
Begin    
	Declare @TempItems Table    
	(    
	 Product_Code   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS
	)    
	  
	Declare @GroupId_tbl Table   
	(  
	 CatGroupID Int   
	)  
	  
	Insert Into @GroupId_tbl  
	Select Cast(ItemValue As Int) From dbo.sp_SplitIn2Rows(@GroupID,',')  
	If(Select max(isnull(OCGType,0)) from ProductCategoryGroupAbstract where groupid in (Select CatGroupID from @GroupId_tbl ))=0
	Begin
		insert into @Items
		Select I.Product_Code
		From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA,   
		Items I,tblCGDivMapping CGDIV 
		Where CGDIV.Division = IC3.Category_Name  
		And IC3.CategoryID = IC2.ParentID   
		And IC2.CategoryID = IC1.ParentID   
		And IC1.CategoryID = I.CategoryID  
		And I.Active = 1   
		And CGDIV.CategoryGroup = PCGA.GroupName  
		And PCGA.GroupName<>'GR4'
		and PCGA.GroupID in (Select CatGroupID from @GroupId_tbl)
		And isnull(PCGA.OCGType,0)=0
	End
	Else
	Begin
		Declare @TmpItems table (Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		insert into @TmpItems (Product_Code,Category_name)	
		Select FN.Product_code,IC.Category_Name from dbo.Fn_GetOCGSKU(@GroupID) FN,ItemCategories IC
		Where FN.CategoryID=IC.CategoryID
		
		Delete from @TmpItems Where Category_Name in 
		(Select IC1.Category_Name
		From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA,   
		Items I,tblCGDivMapping CGDIV 
		Where CGDIV.Division = IC3.Category_Name  
		And IC3.CategoryID = IC2.ParentID   
		And IC2.CategoryID = IC1.ParentID   
		And IC1.CategoryID = I.CategoryID  
		And I.Active = 1   
		And CGDIV.CategoryGroup = PCGA.GroupName  
		And PCGA.GroupName='GR4'
		And isnull(PCGA.Active,0)=1)

		insert into @Items
		Select Product_Code from @TmpItems
	End
	Return    
End  
