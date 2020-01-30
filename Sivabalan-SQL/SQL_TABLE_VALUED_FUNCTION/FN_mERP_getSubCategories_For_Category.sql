
create function FN_mERP_getSubCategories_For_Category (@CategoryName nvarchar(255))  
Returns @tmpCat table(CategoryID int,[level] int)  
AS  
BEGIN  
	Declare @Level as int  
	Declare @Cat_Name as nvarchar(255)
	Declare @ParentID int
	--Create Table #tmpCat (CategoryID int,[level] int)  
	select @level= [level] from itemcategories where category_name=@CategoryName
	
	If  @Level <> 2
	BEGIN
		If  @Level = 3
		BEGIN
			Select @ParentID = ParentID from itemcategories where category_Name=@CategoryName
			select @Cat_Name = category_Name from  itemcategories where CategoryID=@ParentID
		END
	END
	ELSE IF @Level = 2
	BEGIN
		set @Cat_Name = @CategoryName
	END
	if (@Level = 2 or @Level = 3)
	BEGIN
		while @level <= 5
		BEGIN
			 insert into @tmpCat   
			 select Distinct IC.CategoryID,IC.[Level] from ItemCategories IC,    
						(Select ICatA.CategoryID 'Level_2', ICatB.CategoryID 'Level_3', ICatC.CategoryID 'Level_4'  
			   from ItemCategories iCatA, ItemCategories iCatB, ItemCategories iCatC  
			   Where 
			   iCatA.Category_Name=@Cat_Name And  
			   iCatA.CategoryID = iCatB.ParentID and   
			   iCatC.ParentID = iCatB.CategoryID) GR4_Cat  
				Where IC.Active=1 and IC.CategoryID = Case @Level When 2 Then GR4_Cat.Level_2 When 3 Then GR4_Cat.Level_3 When 4 Then GR4_Cat.Level_4 End  
   			 --Select Product_code from Items where CategoryID in (select CategoryID from #tmpCat) and isnull(active,0) = 1 order by Product_code  
			 set @level = @level+1
		END  
	END
	ELSE IF @Level = 1
	BEGIN
		Declare @DivName as nvarchar(255)
		
		Declare AllDiv Cursor For Select Category_Name from ItemCategories where ParentID = (Select CategoryID from ItemCategories where isnull([level],0) = 1 )
		Open AllDiv
		Fetch from AllDiv into @DivName
		while @@fetch_status = 0
		BEGIN
			Set @level =2
			while @level <= 5
			BEGIN
				 insert into @tmpCat   
				 select Distinct IC.CategoryID,IC.[Level] from ItemCategories IC,    
							(Select ICatA.CategoryID 'Level_2', ICatB.CategoryID 'Level_3', ICatC.CategoryID 'Level_4'  
				   from ItemCategories iCatA, ItemCategories iCatB, ItemCategories iCatC  
				   Where 
				   iCatA.Category_Name=@DivName And  
				   iCatA.CategoryID = iCatB.ParentID and   
				   iCatC.ParentID = iCatB.CategoryID) GR4_Cat  
					Where IC.Active=1 and IC.CategoryID = Case @Level When 2 Then GR4_Cat.Level_2 When 3 Then GR4_Cat.Level_3 When 4 Then GR4_Cat.Level_4 End  
   				 --Select Product_code from Items where CategoryID in (select CategoryID from #tmpCat) and isnull(active,0) = 1 order by Product_code  
				 set @level = @level+1
			END  
			Fetch next from AllDiv into @DivName
		END
		Close AllDiv
		Deallocate AllDiv
	END
	ELSE IF @Level = 4
	BEGIN
		set @Cat_Name = @CategoryName
		insert into @tmpCat  
		select IC.CategoryID,IC.[Level] from ItemCategories IC where category_Name=@Cat_Name
	END
	Delete from @tmpCat where level <> 4
--select CategoryID from @tmpCat where [level]=4
RETURN
END
