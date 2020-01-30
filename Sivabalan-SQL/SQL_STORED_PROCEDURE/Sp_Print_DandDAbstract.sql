
Create Procedure Sp_Print_DandDAbstract(@ID Int)
AS

Declare @CategoryName nvarchar(4000)
Declare @BrandName	nvarchar(510)
Declare @CategoryID Int
Declare @Remarks nvarchar(1000)

Set @CategoryName = ''
Set @BrandName = ''
Set @Remarks = ''

Declare Cur_Category Cursor For
Select CategoryID From DandDCategory Where ID = @ID
Open Cur_Category
Fetch From Cur_Category Into @CategoryID
While @@Fetch_Status = 0
	Begin
		Select @BrandName = IsNull(Category_Name, '') from ItemCategories Where CategoryID = @CategoryID	
		Set @CategoryName = @CategoryName + @BrandName + ','
		Fetch Next From Cur_Category Into @CategoryID
	End
Close Cur_Category
Deallocate Cur_Category

IF LEN(@CategoryName) > 0
	Set @CategoryName = SUBSTRING(@CategoryName, 1, LEN(@CategoryName) - 1)	

--Select @Remarks = Remarks + ' From ' + FromMonth + ' To ' + ToMonth
--From DandDAbstract Where ID = @ID

Select @Remarks = RemarksDescription 
From DandDAbstract Where ID = @ID

Select	
	"Item Count" = count(distinct DD.Product_code),
	"Task Number" = DocumentID,
	"Category" = @CategoryName,
	"Date" = ClaimDate,	
    "Last Day Close Date" = DayCloseDate,
	"Remarks" = @Remarks,
	"Total RFA Value" = Max(IsNull(ClaimValue, 0))
From
	DandDAbstract DA,DandDDetail DD
Where
	DA.ID = @ID
	And DA.ID=DD.ID
	Group by DocumentID,ClaimDate,DayCloseDate

