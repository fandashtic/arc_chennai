Create View V_ItemCategories
([CATEGORYID],[PARENT_CATEGORY],[CATEGORYNAME],[CATEGORY])
As
Select [CategoryID],IsNull([ParentID],0),IsNull([Description],''),[Category_Name] from ItemCategories
