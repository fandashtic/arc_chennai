Create procedure sp_checkCategoryMatch(@Categoryid int)
As	
Declare @RecParentID Int
Declare @origParentID Int

Declare @RecTrackInv Int
Declare @OrigTrackInv Int

Declare @RecTrackCSP int
Declare @OrigTrackCSP int

Declare @recDesc nvarchar(2000)
Declare @OrigDesc nvarchar(2000)

Select @RecTrackInv=TrackInventory,@RecTrackCSP=PriceOption,@recDesc=Description from
Categoryreceived Where Id=@CategoryId

Select @OrigTrackInv=Track_Inventory,@OrigTrackCSP=Price_Option,@OrigDesc=Description from
ItemCategories Where Category_name=
(Select CategoryName From CategoryReceived Where ID = @CategoryID)

Select @RecParentID = Isnull(CategoryID,0) From ItemCategories 
Where Category_Name = (Select IsNull(Parent, N'') From CategoryReceived
Where ID = @CategoryID)

Select @OrigParentID = Parentid From ItemCategories 
Where Category_Name = (Select CategoryName From CategoryReceived Where ID = @CategoryID)

IF (@recparentid <> @origparentid) or (@RecTrackInv <> @OrigTrackInv) or (@RecTrackCSP <> @OrigTrackCSP) or (@recDesc <>@OrigDesc)
	Select 1
Else
	Select 0





