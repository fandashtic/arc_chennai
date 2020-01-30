
Create Procedure mERP_SP_ValidateCategory (@CategoryName nvarchar(255))
AS
BEGIN
	If ((select count(*) from EditMarginLock where CategoryName=(@CategoryName)) = 0)
	BEGIN
		Select 0,'This level of categories / System SKU level margin can not be edited'
	END
	ELSE IF ((Select isnull(Active,0) from ItemCategories where category_Name=@CategoryName)) = 0
	BEGIN 
		Select 0,'Inactive Category Entered'
	END
	ELSE IF ((select count(*) from ItemCategories where Category_Name=(@CategoryName)) = 0)
	BEGIN
		Select 0,'Category Does Not Exist in the Database'
	END
	ELSE
	BEGIN
		Select 1,''
	END
	/* the below condidtions were removed after confirming with Project Team*/
	/*This SP is to check whether the Entered Category Name is valid in Edit Margin Screen. If Yes, this will return 1 else 0 */
	/*To check whether the Category Name is active in ItemCategories Table. If Yes, proceed further*/
    /*
	If ((Select isnull(Active,0) from ItemCategories where category_Name=@CategoryName) = 0)
	BEGIN
		Select 0,'Inactive Category Entered'
	END
	ELSE IF (((Select count(*) from ItemCategories where category_Name=@CategoryName) > 0) and ((Select count(*) from EditMarginLock where CategoryName= @CategoryName)=0) )
	BEGIN
		Select 0,'Category level Margin cannot be changed for the entered category'
	END
	ELSE IF ((Select isnull(level,0) from ItemCategories where category_Name=@CategoryName) <> 2)
	BEGIN
		Select 0,'This level of Categories / System SKU level margin cannot be edited'
	END
	ELSE IF (((Select Count(*) from EditMarginLock where CategoryName = @CategoryName)=0) and (@CategoryName in ('CG','SM','CI')))
	BEGIN
		select 0,'This level of categories margin cannot be edited'
	END
	ELSE if (((Select count(*) from items where ProductName=@CategoryName and isnull(active,0) = 1) > 0) and ((Select count(*) from EditMarginLock where CategoryName= @CategoryName)=0))
	BEGIN
		Select 0,'Margin for this product can be updated through System SKU margin edit section'
	END
	Else If ((Select count(*) from ItemCategories where category_Name=@CategoryName) = 0)
	BEGIN
		Select 0,'Category Does Not Exist in the Database'
	END
	ELSE If ((Select count(*) from EditMarginLock where CategoryName = @CategoryName and CategoryName in ('CG','SM','CI')) > 0)
	BEGIN
		Select 1,''
	END
	*/
END
