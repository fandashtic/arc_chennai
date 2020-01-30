CREATE Function mERP_fn_SubSlabwiseSalesDetail_ITC(
	@FromMonth Datetime, 
	@ToMonth Datetime, 
	@Cat nVarchar(256), 
	@PCat nVarchar(256), 
	@Type Int,
	@UOM nVarchar(20),
	@CustomerID nVarchar(256)
)    
Returns nVarchar(2555)
As    
Begin    
---

Declare @CatName As nVarchar(255)
Declare @CatID As Int
Declare @CustCount Int
Declare @ItemCount Decimal(18, 6)
Declare @FOP nVarchar(2555)
Declare @UOMDesc nVarchar(256)
Declare @FromDate Datetime, @ToDate Datetime
Declare @CustSaleCount Table (CustName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCount Decimal(18, 6), 
	BilledValue Decimal(18, 6), TaxValue Decimal(18, 6), DiscValue Decimal(18, 6))
Declare @tempCategory Table (CategoryID Int, Status Int)
Declare @tmpCat Table (CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
---

Set @FOP = ''
Set @CustCount = 0
Set @ItemCount = 0

Set @FromDate = Cast(('01' + '-' + Cast(DatePart(mm, @FromMonth) As nVarchar) + '-' + Cast(DatePart(yy, @FromMonth) As nVarchar)) As Datetime)
Set @ToDate = Cast(('01' + '-' + Cast(DatePart(mm, @ToMonth) As nVarchar) + '-' + Cast(DatePart(yy, @ToMonth) As nVarchar)) As Datetime)
Set @ToDate = DateAdd(ss, -1, DateAdd(mm, 1, @ToDate))

--Get leaflevel categories of given hierarchy level
Declare Category Cursor  For
Select itcat.Category_Name, itcat.CategoryID
From ItemCategories itcat
Where itcat.Category_Name In (@Cat)
Open Category
Fetch From Category Into @CatName, @CatID
While @@Fetch_Status = 0
Begin
--	Exec GetLeafCategories @PCat , @CatName
	Insert Into @tmpCat Select @CatID, @CatName, CategoryID From dbo.mERP_fn_GetLeafCategories_ITC(@PCat , @CatName)
	Delete From @tempCategory
	Fetch From Category Into @CatName, @CatID
End
Close Category
Deallocate Category

IF @PCat = N'System SKU'
Begin
		Insert Into  @tmpCat(CatLevel , CatName , LeafLevelCat)
		Select Distinct IT.CategoryID, IT.Product_Code, 0
		From Items IT
		Where IT.Product_Code In (@Cat)
	
End

If @Type = 1
Begin
	Declare UOMMapping Cursor For
		Select Distinct "UOM" = Case @UOM When N'Base UOM'  Then (Select Top 1 Description From UOM Where UOM = its.UOM)
										When N'UOM 1' Then (Select Top 1 Description From UOM Where UOM = its.UOM1)
										When N'UOM 2' Then (Select Top 1 Description From UOM Where UOM = its.UOM2)
							    End
		From InvoiceAbstract ia, InvoiceDetail idl, Items its
		Where ia.InvoiceID = idl.InvoiceID And idl.Product_Code = its.Product_Code And
			(its.CategoryID In (Select LeafLevelCat From @tmpCat) Or its.Product_Code In (Select CatName From @tmpCat))
			And ia.InvoiceDate Between @FromDate And @ToDate
			And ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And
			ia.CustomerID = @CustomerID
	Open UOMMapping 
	Fetch From UOMMapping InTo @UOMDesc
	While @@Fetch_Status = 0
	Begin
		Set @FOP = @FOP + '|' + @UOMDesc 
		Fetch Next From UOMMapping InTo @UOMDesc 
	End
	Close UOMMapping
	Deallocate UOMMapping
	
	Set @FOP = Substring(@FOP, 2, Len(@FOP))
End
Else If @Type In (2, 3, 4, 5)
Begin
	Insert InTo @CustSaleCount
	Select "CustID" = ia.CustomerID, 
        "ItemCount" = Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * 
		(Case @UOM When N'Base UOM'  Then idl.Quantity 
				  When N'UOM 1' Then idl.Quantity / (Case IsNull(its.UOM1_Conversion, 0) When 0 Then 1 
																						Else its.UOM1_Conversion End)
				  When N'UOM 2' Then idl.Quantity / (Case IsNull(its.UOM1_Conversion, 0) When 0 Then 1 
																						Else its.UOM2_Conversion End)
        End)), 
        "BilledValue" = Sum(idl.Quantity * ((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.SalePrice)),
		"TaxValue" = Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.STPayable) + ((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.CSTPayable)), 
        "DiscValue" = Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.DiscountValue))
	From InvoiceAbstract ia, InvoiceDetail idl, Items its
	Where ia.InvoiceID = idl.InvoiceID And idl.Product_Code = its.Product_Code And
		(its.CategoryID In (Select LeafLevelCat From @tmpCat) Or its.Product_Code In (Select CatName From @tmpCat))
		And ia.InvoiceDate Between @FromDate And @ToDate
		And ia.Status & 128 = 0 And ia.InvoiceType In (1, 3, 4) And 
		ia.CustomerID = @CustomerID
	Group By ia.CustomerID 

	If @Type = 2
	Begin
		Select @ItemCount = Sum(IsNull(ItemCount, 0)) From @CustSaleCount 

		Set @FOP = Cast(@ItemCount As nVarchar)
	End
	Else If @Type = 3
	Begin
		Select @ItemCount = Sum(IsNull(BilledValue, 0)) From @CustSaleCount 

		Set @FOP = Cast(@ItemCount As nVarchar)
	End
	Else If @Type = 4
	Begin
		Select @ItemCount = Sum(IsNull(TaxValue, 0)) From @CustSaleCount 

		Set @FOP = Cast(@ItemCount As nVarchar)
	End
	Else If @Type = 5
	Begin
		Select @ItemCount = Sum(IsNull(DiscValue, 0)) From @CustSaleCount 

		Set @FOP = Cast(@ItemCount As nVarchar)
	End
End

Return @FOP

End
