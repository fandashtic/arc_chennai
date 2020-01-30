CREATE Procedure sp_Category_Created (@Criteria Int,
				      @FromDate Datetime,
					@ToDate Datetime,
					@MFromDate Datetime,
					@MToDate Datetime)
As
If (@Criteria & 3) = 3 
Begin
	Select CategoryID, Category_Name, Description, ParentID, Track_Inventory, 
	Price_Option, CreationDate, Level, ModifiedDate From ItemCategories
	Where (CreationDate Between @FromDate And @ToDate Or 
	ModifiedDate Between @MFromDate And @MToDate) And
	Active = 1 oRDER BY LEVEL asc,Categoryid asc
End
Else If (@Criteria & 3) = 1
Begin
	Select CategoryID, Category_Name, Description, ParentID, Track_Inventory, 
	Price_Option, CreationDate, Level, ModifiedDate From ItemCategories
	Where CreationDate Between @FromDate And @ToDate And
	Active = 1	oRDER BY LEVEL Asc,Categoryid asc
End
Else If (@Criteria & 3) = 2
Begin
	Select CategoryID, Category_Name, Description, ParentID, Track_Inventory, 
	Price_Option, CreationDate, Level, ModifiedDate From ItemCategories
	Where ModifiedDate Between @MFromDate And @MToDate And
	Active = 1	oRDER BY LEVEL asc,Categoryid asc
End



