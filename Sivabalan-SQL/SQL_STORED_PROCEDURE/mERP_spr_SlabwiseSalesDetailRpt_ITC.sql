Create Procedure mERP_spr_SlabwiseSalesDetailRpt_ITC(
	@CategoryAbs nVarchar(256),
	@MonthFrm nVarchar(20),
	@Month2 nVarchar(20),
	@ProductHierarchy nVarchar(256),
	@Category nVarchar(2555),
	@UOM nVarchar(20),
	@Slabs nVarchar(2555)
)
As
Begin
-----

Declare @MonthFrom Datetime, @MonthTo Datetime
Declare @FromDate Datetime, @ToDate Datetime
Declare @CatName As nVarchar(255)
Declare @CatID As Int
Declare @tempCategory Table (CategoryID Int, Status Int)
Declare @tmpCat Table (CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
---

Set @MonthFrom = Cast(('01/' + @MonthFrm) As Datetime)
Set @MonthTo = Cast(('01/' + @Month2) As Datetime)
Set @FromDate = Cast(('01' + '-' + Cast(DatePart(mm, @MonthFrom) As nVarchar) + '-' + Cast(DatePart(yy, @MonthFrom) As nVarchar)) As Datetime)
Set @ToDate = Cast(('01' + '-' + Cast(DatePart(mm, @MonthTo) As nVarchar) + '-' + Cast(DatePart(yy, @MonthTo) As nVarchar)) As Datetime)
Set @ToDate = DateAdd(ss, -1, DateAdd(mm, 1, @ToDate))

--Get leaflevel categories of given hierarchy level
Declare Category Cursor  For
Select itcat.Category_Name, itcat.CategoryID
From ItemCategories itcat
Where itcat.Category_Name In (@CategoryAbs)
Open Category
Fetch From Category Into @CatName, @CatID
While @@Fetch_Status = 0
Begin
--	Exec GetLeafCategories @PCat , @CatName
	Insert Into @tmpCat Select @CatID, @CatName, CategoryID From dbo.mERP_fn_GetLeafCategories_ITC(@ProductHierarchy , @CatName)
	Delete From @tempCategory
	Fetch From Category Into @CatName, @CatID
End
Close Category
Deallocate Category

IF @ProductHierarchy = N'System SKU'
Begin
		Insert Into  @tmpCat(CatLevel , CatName , LeafLevelCat)
		Select Distinct IT.CategoryID, IT.Product_Code, 0
		From Items IT
		Where IT.Product_Code In (@CategoryAbs)
	
End
---

Select "Customer Type" = '', "Customer Type" = (Select Top 1 ChannelDesc From Customer_Channel Where ChannelType = cus.ChannelType), 
	"Outlet ID" = cus.CustomerID, 
	"Outlet Name" = cus.Company_Name, 
	"UOM" = dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 1, @UOM, cus.CustomerID), 
	"Quantity" = IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 2, @UOM, cus.CustomerID) As Decimal(18, 6)), 0),
	"BilledValue" = IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 3, @UOM, cus.CustomerID) As Decimal(18, 6)), 0), 
	"TaxValue" = IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 4, @UOM, cus.CustomerID) As Decimal(18, 6)), 0), 
	"DiscValue" = IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 5, @UOM, cus.CustomerID) As Decimal(18, 6)), 0),
	"TotalValue" = (IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 3, @UOM, cus.CustomerID) As Decimal(18, 6)), 0) + 
				   IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 4, @UOM, cus.CustomerID) As Decimal(18, 6)), 0)) - 
				   IsNull(Cast(dbo.mERP_fn_SubSlabwiseSalesDetail_ITC(@MonthFrom, @MonthTo, @CategoryAbs, @ProductHierarchy, 5, @UOM, cus.CustomerID) As Decimal(18, 6)), 0)
From Customer cus 
Where cus.CustomerID In 
	(Select Distinct ia.CustomerID 
	From InvoiceAbstract ia, InvoiceDetail idl, Items its
	Where ia.InvoiceID = idl.InvoiceID And idl.Product_Code = its.Product_Code And
		(its.CategoryID In (Select LeafLevelCat From @tmpCat) Or its.Product_Code In (Select CatName From @tmpCat))
		And ia.InvoiceDate Between @FromDate And @ToDate
		And ia.Status & 128 = 0 And ia.InvoiceType In (1, 3, 4) 
	)

-----
End
