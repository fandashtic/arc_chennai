Create Procedure sp_GetLvlCat (
				@Parent [Int],
				@Level [Int]
			       )
As
Declare @Continue int  
Declare @CategoryID int  
Declare @LevelID Int
Declare @PCatID Int

Set @Continue = 1  

CREATE TABLE [#tLvlCat] (
			 [PCateID] [Int] NOT NULL, 
			 [CatID] [Int] NOT NULL,
			 [CatName] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			 [LvlID] [Int] NOT NULL
)

CREATE TABLE [#tempCategory] ([PCatID] [int] NOT NULL,
			      [CategoryID] [int] NOT NULL,
			      [Status] [int] NOT NULL,
			      [Lvl] [int] NOT NULL
)

Insert Into [#tempCategory] ([PCatID] , [CategoryID], [Status], [Lvl])
Select [CategoryID], [CategoryID], 0, [Level]
From [ItemCategories]
Where [Level] In (@Parent) and Active = 1

While @Continue > 0  
Begin  
	Declare Parent Cursor Keyset For  
 	Select [PCatID], [CategoryID], [Lvl] From [#tempCategory] Where [Status] = 0  
	Open Parent  
 	Fetch From Parent Into @PCatID, @CategoryID, @LevelID 
	While @@Fetch_Status = 0  
 	Begin  
		Insert into [#tempCategory] ([PCatID], [CategoryID], [Status], [Lvl])
  		Select @PCatID, [CategoryID], 0, [Level] From [ItemCategories]
		Where [ParentID] = @CategoryID And [Level] <= @Level
  		If @@RowCount > 0   
			Update [#tempCategory] Set [Status] = 1 
			Where [CategoryID] = @CategoryID  
		Else  
   			Update [#tempCategory] Set Status = 2 
			Where CategoryID = @CategoryID  
		Fetch Next From Parent Into @PCatID, @CategoryID, @LevelID 
 	End  
	Close Parent  
 	DeAllocate Parent  
 	Select @Continue = Count(*) From #tempCategory Where Status = 0  
End  

Insert Into [#tLvlCat] ([PCateID], [CatID], [CatName], [LvlID])
Select ic.[PCatID], itc.[CategoryID], itc.[Category_Name], itc.[Level] 
From [ItemCategories] itc, [#tempCategory] ic
Where itc.[CategoryID] = ic.[CategoryID] And ic.[Lvl] = @Level

Select * From [#tLvlCat]

