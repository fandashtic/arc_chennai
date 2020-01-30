Create Procedure spr_GST_DamageStock_DandD_upload(	
@FromDate Datetime,             
@ToDate DateTime,
@Division nvarchar(max))
As
Begin
	Set DateFormat DMY
	Declare @Last_Close_Date DateTime
	Declare @Delimeter Char(1)

	Declare @WDCode NVarchar(255),@WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255)  
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload          
	Select Top 1 @WDCode = RegisteredOwner From Setup            
  
	If @CompaniesToUploadCode='ITC001'          
		Begin          
			Set @WDDest= @WDCode          
		End          
	Else          
		Begin          
			Set @WDDest= @WDCode          
			Set @WDCode= @CompaniesToUploadCode          
		End
		
	Create Table #TmpDivision(CategoryID Int, CategoryName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpOutput(Division nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
			Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,
			ProductName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18,6))
	
	Create Table #DivItems(CategoryID int, Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)


	Set @Delimeter = Char(15)

	If @Division = N'%'
		Insert Into #TmpDivision(CategoryID, CategoryName) 
		Select Distinct CategoryID, Category_Name From ItemCategories Where isnull(Level,0) = 2
	Else
	Begin	
		Insert Into #TmpDivision(CategoryName) 
		Select * From dbo.sp_SplitIn2Rows(@Division, @Delimeter) 

		Update Tmp Set Tmp.CategoryID = IC.CategoryID From #TmpDivision Tmp, ItemCategories IC 
		Where Tmp.CategoryName = IC.Category_Name and isnull(Level,0) = 2
	End
		
	Insert Into #DivItems(CategoryID,Product_Code,Category,Sub_Category,Market_SKU)
	Select Distinct IC2.CategoryID,I.Product_code,IC2.Category_Name,IC3.Category_Name, IC4.Category_Name
	From items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 
	Where
		IC4.categoryid = i.categoryid 
		And IC4.Parentid = IC3.categoryid 
		And IC3.Parentid = IC2.categoryid And IC2.CategoryId in (Select CategoryID From #TmpDivision)


	Select @Last_Close_Date = Convert(Nvarchar(10),LastInventoryUpload,103) From Setup

	Insert into #tmpOutput(Division, Product_Code, ProductName, Quantity)
	Select 
		D.Category, Items.Product_Code, Items.ProductName, Sum(isnull(BP.quantity,0)) As Damage_Quantity
	From 
		Batch_Products BP
		Inner Join Items ON BP.Product_Code = Items.Product_Code
		Inner Join UOM ON Items.UOM = UOM.UOM
		Inner Join #DivItems D ON Items.Product_Code = D.Product_Code		
		Inner Join Tax ON Items.Sale_Tax = Tax.Tax_Code and isnull(Tax.GSTFlag,0) = 0
	Where		
		Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
		And isnull(BP.Damage,0) <> 0
		And isnull(BP.Free,0) = 0
	Group By
		Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID, D.Category, D.Sub_Category, D.Market_SKU
	Having  Sum(isnull(BP.Quantity,0))>0
	Order By D.Category, D.Sub_Category, D.Market_SKU, Items.Product_Code

	--Update Reports_To_Upload set Frequency = 0 where ReportDataID = 1487

	Select "WDCode"=@WDCode,"WDCode"=@WDCode, "WDDest"=@WDDest,@FromDate [FromDate], @ToDate [ToDate],  Division, Product_Code, ProductName, Quantity From #tmpOutput

	Drop Table #TmpDivision
	Drop Table #DivItems
	Drop Table #tmpOutput
End
