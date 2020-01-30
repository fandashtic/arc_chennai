  
Create Function Fn_Get_Items_ITC(@GroupID nVarchar(1000))  
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
  
	Declare @GroupId_tbl Table   
	(  
	 CatGroupID Int   
	)  
	Declare @BP Table(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into @BP(Product_Code)
	Select Product_Code
	From Batch_Products BP where IsNull(BP.Damage, 0) = 0  
	And IsNull(BP.Quantity, 0) > 0   
	Group by Product_Code
	Having IsNull(Sum(BP.Quantity),0) > 0

	Declare @OCGFlag as Int  
	Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')  
  
	Insert Into @GroupId_tbl  
	Select Cast(ItemValue As Int) From dbo.sp_SplitIn2Rows(@GroupID,',')  
  
	If isnull(@OCGFlag ,0) = 0  
	Begin  
		Insert Into @Items   
		Select ITv.Product_Code,ITv.ProductName   
		From v_mERP_ItemWithCG ITv, @BP BP , @GroupId_tbl gtbl  
		Where ITv.Product_Code = BP.Product_Code  
		And ITv.GroupID = gtbl.CatGroupID         
	End  
	Else  
	Begin  
		Declare @OCGSKU Table(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID Int,GroupID Int)  
		insert into @OCGSKU(Product_Code,ProductName,CategoryID,GroupID)
		Select Product_Code,ProductName,CategoryID,GroupID from Fn_GetOCGSKU(@GroupID)
		Insert Into @Items  
		Select ITv.Product_Code,ITv.ProductName From @OCGSKU ITv,  
		@BP BP  
		Where ITv.Product_Code = BP.Product_Code  
	End       
	Delete from @OCGSKU
    Return    
End  

