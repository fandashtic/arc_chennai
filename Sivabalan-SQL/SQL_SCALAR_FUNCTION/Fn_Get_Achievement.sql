CREATE FUNCTION Fn_Get_Achievement(@CatLevel Int, @CatName nVarchar(50), @FromDate Datetime, 
	@ToDate Datetime, @SalManID Int, @Flag Int, @ParamID Int = 0, @Frequency int, @Group nVarchar(50))  
RETURNS Decimal(18, 6)
AS      
BEGIN  

Declare @NetAmount Decimal(18, 6) 
Declare @BCount Int 
--Declare @SlabUOM nVarchar(5)
Declare @SlabUOM nVarchar(25) 
Declare @DToDate Datetime

Declare @ProductCode Table (ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Declare @DPoints Table (Points Decimal(18, 6))  
Declare @CG Table (CatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @CatLevel = 5
Begin
	Insert InTo @ProductCode Select Product_Code From Items Where Product_Code = @CatName 
End
Else IF @CatLevel = 4 
Begin
	Insert InTo @ProductCode Select Product_Code From Items Where CategoryID In (
	Select CategoryID From ItemCategories Where Category_Name = @CatName) 
End
Else IF @CatLevel = 3
Begin
	Insert InTo @ProductCode Select Product_Code From Items Where CategoryID In (
		Select ic1.CategoryID From ItemCategories ic1,  ItemCategories ic2 
		Where ic1.ParentID = ic2.CategoryID And ic2.Category_Name = @CatName) 
End
Else IF @CatLevel = 2 
Begin
	Insert InTo @ProductCode Select Product_Code From Items Where CategoryID In (
		Select ic1.CategoryID From ItemCategories ic1,  ItemCategories ic2, ItemCategories ic3 
		Where ic1.ParentID = ic2.CategoryID 
		And ic2.ParentID = ic3.CategoryID 
		And ic3.Category_Name = @CatName) 
End
Else IF @CatLevel = 0 
Begin
	IF @Group = 'GR1'
	Begin
		Insert InTo @CG Select Division From tblcgdivmapping 
		Where CategoryGroup = 'GR1'
	End
	Else If @Group = 'GR2'
	Begin
		Insert InTo @CG Select Division From tblcgdivmapping 
		Where CategoryGroup = 'GR2'
	End
	Else If @Group = 'GR3'
	Begin
		Insert InTo @CG Select Division From tblcgdivmapping 
		Where CategoryGroup = 'GR3'
	End
	Else
	Begin
		Insert InTo @CG Select Division From tblcgdivmapping 
		Where CategoryGroup In ('GR1', 'GR3') 
	End
    	Insert InTo @ProductCode Select Product_Code From Items Where CategoryID In (
		Select ic1.CategoryID From ItemCategories ic1,  ItemCategories ic2, ItemCategories ic3, @CG cg
		Where ic1.ParentID = ic2.CategoryID 
		And ic2.ParentID = ic3.CategoryID 
		And ic3.Category_Name = cg.CatName) 
End

If @Flag = 1 
Begin

	Select Top 1 @SlabUOM = SLAB_UOM From tbl_mERP_PMParamSlab 
	Where ParamID = @ParamID  
	If @SlabUOM = 'Percentage'
	Begin
		Select @NetAmount = Sum((Case When ia.InvoiceType = 4 Then -1 Else 1 End) * idt.Amount) 
		From InvoiceAbstract ia, InvoiceDetail idt 
		Where ia.InvoiceID = idt.InvoiceID And ia.InvoiceType In (1, 3, 4) 
			And (IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @ToDate 
			And ia.SalesmanID = @SalManID 
			And idt.Product_Code In (Select ItemCode From @ProductCode) 
	End
	Else
	Begin
		Set @NetAmount = 0 
	End
End
Else If @Flag = 2
Begin
	If @Frequency = 2
	Begin
		Select @BCount = Count(InvoiceID) From (
		Select Distinct "InvoiceID" = ia.InvoiceID
		From InvoiceAbstract ia, InvoiceDetail idt 
		Where ia.InvoiceID = idt.InvoiceID And ia.InvoiceType In (1, 3) 
			And (IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @ToDate 
			And ia.SalesmanID = @SalManID 
			And idt.Product_Code In (Select ItemCode From @ProductCode)) al 

		Select @NetAmount = 
			(Case when Slab_Every_QTY = 0 
				then SLAB_VALUE 
				else ((@BCount / Slab_Every_QTY) * SLAB_VALUE) 
				End)
				From tbl_mERP_PMParamSlab 
		Where ParamID = @ParamID And SLAB_UOM = 'BC' And @BCount Between SLAB_START And SLAB_END 

	End
	Else If @Frequency = 1
	Begin
		Set @DToDate = DateAdd(SS, -1, DateAdd(DD, 1, @FromDate))
		If @FromDate = dbo.StripDateFromTime(@ToDate)
		Begin
			Set @DToDate = @ToDate
		End
		While @DToDate <= @ToDate
		Begin
			Select @BCount = Count(InvoiceID) From (
			Select Distinct "InvoiceID" = ia.InvoiceID
			From InvoiceAbstract ia, InvoiceDetail idt 
			Where ia.InvoiceID = idt.InvoiceID And ia.InvoiceType In (1, 3) 
				And (IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @DToDate  
				And ia.SalesmanID = @SalManID 
				And idt.Product_Code In (Select ItemCode From @ProductCode)) al 

			Select @NetAmount = 
			(Case when Slab_Every_QTY = 0 
				then SLAB_VALUE 
				else ((@BCount / Slab_Every_QTY) * SLAB_VALUE) 
				End)
				From tbl_mERP_PMParamSlab 
    		Where ParamID = @ParamID And SLAB_UOM = 'BC' And @BCount Between SLAB_START And SLAB_END 

			Insert InTo @DPoints Values(@NetAmount)
			Set @NetAmount = 0 
			Set @BCount = 0 
			Set @FromDate = DateAdd(DD, 1, @FromDate) 
			Set @DToDate = DateAdd(SS, -1, DateAdd(DD, 1, @FromDate))
			If @FromDate = dbo.StripDateFromTime(@ToDate)
			Begin
				Set @DToDate = @ToDate
			End
		End
		Select @NetAmount = Sum(Points) From @DPoints
	End
End
Else If @Flag = 3 
Begin
	If @Frequency = 2
	Begin
		Select @BCount = Count(ItemCode) From (
		Select Distinct "ItemCode" = idt.Product_Code
		From InvoiceAbstract ia, InvoiceDetail idt 
		Where ia.InvoiceID = idt.InvoiceID And ia.InvoiceType In (1, 3) 
			And (IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @ToDate 
			And ia.SalesmanID = @SalManID 
			And idt.Product_Code In (Select ItemCode From @ProductCode)
		Group By idt.Product_Code, ia.InvoiceID ) al 

		Select @NetAmount = 
			(Case when Slab_Every_QTY = 0 
				then SLAB_VALUE 
				else ((@BCount / Slab_Every_QTY) * SLAB_VALUE) 
				End)
				From tbl_mERP_PMParamSlab 
			Where ParamID = @ParamID And SLAB_UOM = 'LC' And @BCount Between SLAB_START And SLAB_END 
	End 
	Else If @Frequency = 1
	Begin
		Set @DToDate = DateAdd(SS, -1, DateAdd(DD, 1, @FromDate))
		If @FromDate = dbo.StripDateFromTime(@ToDate)
		Begin
			Set @DToDate = @ToDate
		End
		While @DToDate <= @ToDate
		Begin
			Select @BCount = Count(ItemCode) From (
			Select  "ItemCode" = idt.Product_Code
			From InvoiceAbstract ia, InvoiceDetail idt 
			Where ia.InvoiceID = idt.InvoiceID And ia.InvoiceType In (1, 3) 
				And (IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceDate Between @FromDate And @DToDate  
				And ia.SalesmanID = @SalManID 
				And idt.Product_Code In (Select ItemCode From @ProductCode)
				Group By idt.Product_Code, ia.InvoiceID ) al 

			Select @NetAmount = 
			(Case when Slab_Every_QTY = 0 
				then SLAB_VALUE 
				else ((@BCount / Slab_Every_QTY) * SLAB_VALUE) 
				End)
				From tbl_mERP_PMParamSlab 
			Where ParamID = @ParamID And SLAB_UOM = 'LC' And @BCount Between SLAB_START And SLAB_END

			Insert InTo @DPoints Values(@NetAmount)
			Set @NetAmount = 0 
			Set @BCount = 0 
			Set @FromDate = DateAdd(DD, 1, @FromDate) 
			Set @DToDate = DateAdd(SS, -1, DateAdd(DD, 1, @FromDate))
			If @FromDate = dbo.StripDateFromTime(@ToDate)
			Begin
				Set @DToDate = @ToDate
			End
		End 
		Select @NetAmount = Sum(Points) From @DPoints 
	End 
End

Return @NetAmount

END
