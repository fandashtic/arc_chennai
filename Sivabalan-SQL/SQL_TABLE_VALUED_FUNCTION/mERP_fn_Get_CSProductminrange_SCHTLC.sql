Create Function mERP_fn_Get_CSProductminrange_SCHTLC(@SchemeID Int)
Returns @tblCSminrange Table(SchemeID Int,Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,Min_Range Decimal(18,6),UOM Int,Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,CATEGORY_LEVEL int)

As
Begin
Declare @tmp as table (Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
CATEGORY_LEVEL Int, MIN_RANGE Decimal(18,6), UOM Int)

Declare @tmpItems as table (Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,CATEGORY_LEVEL int,
Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, MIN_RANGE Decimal(18,6), UOM Int)

Insert Into @tmp(Category,CATEGORY_LEVEL,MIN_RANGE,UOM)
Select Category,CATEGORY_LEVEL,MIN_RANGE,UOM from SchMinQty Where SchemeID = @SchemeID


Declare @Category as nVarchar(255)
Declare @LEVEL int
Declare @MIN Decimal(18,6)
Declare @UOM Int

Delete From @tmpItems

Declare Cur_tmp Cursor for
Select Distinct Category,CATEGORY_LEVEL,MIN_RANGE,UOM From @tmp Order By CATEGORY_LEVEL Asc
Open Cur_tmp
Fetch from Cur_tmp into @Category,@LEVEL,@MIN,@UOM
While @@fetch_status =0
Begin

If @LEVEL = 2
Begin
IF @Category = 'ALL'
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
--And IC2.Category_Name = @Category

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM  Where CATEGORY_LEVEL = @LEVEL
End
Else
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And IC2.Category_Name = @Category

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM  Where Category = @Category
End
End

Else If @LEVEL = 3
Begin
IF @Category = 'ALL'
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
--And IC3.Category_Name = @Category
And I.Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where Product_Code In (
Select Distinct I.Product_Code From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And CATEGORY_LEVEL = @LEVEL)
End
Else
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And IC3.Category_Name = @Category
And I.Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where Product_Code In (
Select Distinct I.Product_Code From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And IC3.Category_Name = @Category)
End
End

Else If @LEVEL = 4
Begin
IF @Category = 'ALL'
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
--And IC4.Category_Name = @Category
And I.Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where Product_Code In (
Select Distinct I.Product_Code From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And CATEGORY_LEVEL = @LEVEL)
End
Else
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct I.Product_Code,@Category,@LEVEL  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And IC4.Category_Name = @Category
And I.Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where Product_Code In (
Select Distinct I.Product_Code From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4
Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID
And IC4.Category_Name = @Category)
End
End

Else If @LEVEL = 5
Begin
IF @Category = 'ALL'
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct Product_Code ,@Category,@LEVEL From Items Where --Product_Code = @Category And
Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where CATEGORY_LEVEL = @LEVEL
End
Else
Begin
Insert Into @tmpItems (Product_Code,Category,CATEGORY_LEVEL)
Select Distinct Product_Code ,@Category,@LEVEL From Items Where Product_Code = @Category And
Product_Code Not in (select Distinct Product_Code From @tmpItems)

Update @tmpItems Set MIN_RANGE = @MIN,UOM = @UOM Where Product_Code = @Category
End
End
Fetch Next from Cur_tmp into @Category,@LEVEL,@MIN,@UOM
End
Close Cur_tmp
Deallocate Cur_tmp

Delete From @tblCSminrange

Insert Into @tblCSminrange
Select Distinct @SchemeID,Product_Code,MIN_RANGE,UOM,Category,CATEGORY_LEVEL  From @tmpItems Order By Product_Code

Return
End
