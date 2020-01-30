CREATE procedure [dbo].[spr_list_Closing_Stock_Detail_Cons]
(     
	@ProductCode NVarChar(50),
 @BranchName NVarChar(4000),
	@UOM NVarChar(255),  
	@Given_Date DateTime
)
    
AS  
  
	Declare @Operating_Period as DateTime    
	Select @Given_Date = dbo.StripDatefromTime(@Given_Date)   
	Select @Operating_Period = dbo.StripDatefromTime (GetDate())   

	Declare		@CIDSetUp As NVarChar(15)
	Select @CIDSetUp=RegisteredOwner From Setup 

	Create table #TmpLocalStk
	(
		ItemCode NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		DistID NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SaleableStock Decimal(18,6), 
		FreeStock Decimal(18,6),
		ClosingValue Decimal(18,6),
		ForumCode NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
		)           

	Declare @Delimeter as Char(1)        
	Set @Delimeter=Char(15)  
	
	CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
	If @BranchName = N'%'            
	 Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
	Else            
	 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  

	If @UOM = N'Sales UOM'    
		Begin  
			If @Operating_Period <= @Given_Date
				Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)   
				Select 
					Batch_Products.Product_Code,@CIDSetUp,
					Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),
					Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),
					Cast((
						Case ItemCategories.Price_Option  
							When 0 Then Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Cast((Quantity * Items.Purchase_Price) As Decimal(18,6)) Else 0 End)As Decimal(18,6))    
							Else	Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Cast((Quantity * Batch_Products.PurchasePrice) As Decimal(18,6)) Else 0 End) As Decimal(18,6))  
						End) As Decimal(18,6)),  
					Items.AliAs   
				From 
					Batch_Products, Items, UOM, ItemCategories  
				Where 
					Items.UOM = UOM.UOM  
					And Items.CategoryID = ItemCategories.CategoryID  
					And Batch_Products.Product_Code = @ProductCode
					And	Items.Product_Code  = @ProductCode
				Group By 
					Batch_Products.Product_Code, ItemCategories.Price_Option,Items.AliAs 
			Else  
				Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)
				Select 
					OpeningDetails.Product_Code,@CIDSetUp,
					Cast(Opening_Quantity - Damage_Opening_Quantity As NVarChar),
					Cast(Free_Opening_Quantity As NVarChar),
					Opening_Value,Items.AliAs   
				From 
					OpeningDetails, Items, UOM  
				Where 
					Opening_Date = DateAdd(day,1,@Given_date)  
					And Items.UOM = UOM.UOM  
					And OpeningDetails.Product_Code = @ProductCode
					And Items.Product_Code = @ProductCode
		End  
	Else If @UOM = N'Conversion Factor'   
		Begin   
			If @Operating_Period <= @Given_Date   
				Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)
				Select 
					Batch_Products.Product_Code,@CIDSetUp,
					(Case IsNull(Items.ConversionFactor,0) When 0 Then 1 Else IsNull(Items.ConversionFactor,0) End) * Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),
					(Case IsNull(Items.ConversionFactor,0) When 0 Then 1 Else IsNull(Items.ConversionFactor,0) End) * Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),
					Cast((
						Case ItemCategories.Price_Option  
							When 0 Then Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Items.Purchase_Price) Else 0 End)) As Decimal(18,6))    
							Else Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Batch_Products.PurchasePrice) Else 0 End)) As Decimal(18,6))    
						End) As Decimal(18,6)),  
					Items.AliAs   
				From 
					Batch_Products, Items, ConversionTable, ItemCategories  
				Where 
					Items.ConversionUnit *= ConversionTable.ConversionID  
				And Items.CategoryID = ItemCategories.CategoryID  
				And Batch_Products.Product_Code = @ProductCode
				And Items.Product_Code = @ProductCode 
				Group By 
					Batch_Products.Product_Code, Items.ConversionFactor, ItemCategories.Price_Option,Items.AliAs
			Else  
				Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)
				Select 
					OpeningDetails.Product_Code,@CIDSetUp,
					Cast(Cast((Opening_Quantity - Damage_Opening_Quantity) * (Case IsNull(Items.ConversionFactor,0) When 0 Then 1 Else IsNull(Items.ConversionFactor,0) End)As Decimal(18,6)) As NVarChar),		   
					Cast(Cast(Free_Opening_Quantity * (Case IsNull(Items.ConversionFactor,0) When 0 Then 1 Else IsNull(Items.ConversionFactor,0) End)As Decimal(18,6))  As NVarChar),
					Opening_Value,  
					Items.AliAs   
				From 
					OpeningDetails, Items, ConversionTable   
				Where 
					Opening_Date = DateAdd(day,1,@Given_date)  
					And Items.ConversionUnit *= ConversionTable.ConversionID  
					And OpeningDetails.Product_Code = @ProductCode
					And Items.Product_Code = @ProductCode
		End  
	Else If @UOM = N'Reporting UOM'    
		Begin  
			If @Operating_Period <= @Given_Date   
				Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)
				Select 
					Batch_Products.Product_Code,@CIDSetUp,
					Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code, Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End)) As Decimal(18,6)),   
					Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code, Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End)) As Decimal(18,6)),   
					Cast((
						Case ItemCategories.Price_Option  
							When 0 Then Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Items.Purchase_Price) Else 0 End)) As Decimal(18,6))    
							Else Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Batch_Products.PurchasePrice) Else 0 End)) As Decimal(18,6))     
						End)As Decimal(18,6)),  
					Items.AliAs   
				From 
					Batch_Products, Items, ItemCategories  
				Where 
					Items.CategoryID = ItemCategories.CategoryID  
					And Batch_Products.Product_Code = @ProductCode
					And Items.Product_Code = @ProductCode
				Group By 
					Batch_Products.Product_Code, ItemCategories.Price_Option,Items.AliAs  
		Else  
			Insert Into #TmpLocalStk(ItemCode,DistID,SaleableStock,FreeStock,ClosingValue,ForumCode)
			Select 
				OpeningDetails.Product_Code,@CIDSetUp,
				dbo.sp_Get_ReportingUOMQty(OpeningDetails.Product_Code,Opening_Quantity - Damage_Opening_Quantity), "Free Stock" = dbo.sp_Get_ReportingUOMQty(OpeningDetails.Product_Code,Free_Opening_Quantity),  
				Opening_Value,  
				Items.AliAs   
			From 
				OpeningDetails, Items   
			Where 
				Opening_Date = DateAdd(day,1,@Given_date)  
				And OpeningDetails.Product_Code = @ProductCode
				And Items.Product_Code = @ProductCode
	End  

	Select 
		ItemCode,"Item Code" = ItemCode,"Distributor Code"=DistID,"Saleable Stock" = SaleableStock,
		"Free Stock" = FreeStock,"Closing Value (%c)" = ClosingValue,"Forum Code" =	ForumCode 
	From 
		#TmpLocalStk   

Union All

 Select       
  RAR.Field1,
		"Item Code" = IsNull(Field1,''),
		"Distributor Code"=CompanyId,
		"Saleable Stock" = 
		 (Case 
				When Field2='' Then Cast(0 As Decimal(18,6))
				When Field2=NULL Then Cast(0 As Decimal(18,6))   
				Else Cast(Field2 As Decimal(18,6))
			End),
  "Free Stock" = 
		 (Case 
					When Field3='' Then Cast(0 As Decimal(18,6))
					When Field3=Null Then Cast(0 As Decimal(18,6))
					Else Cast(Field3 As Decimal(18,6))
				End),
  "Closing Value (%c)" = Cast(Field4 As Decimal(18,6)),
  "Forum Code" = IsNull(Field5,'')   
 From  
  Reports,ReportAbstractReceived RAR,Items
 Where  
  Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Closing Stock'  
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_ClosingStk_DAILY(N'Closing Stock') Where GivenDate = @Given_Date) Group by CompanyId)
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)
  And RAR.ReportID = Reports.ReportID
  And RAR.Field1 <> N'Item Code' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
		And RAR.Field1=@ProductCode
		And Items.Product_Code=@ProductCode


	Drop Table #TmpLocalStk
