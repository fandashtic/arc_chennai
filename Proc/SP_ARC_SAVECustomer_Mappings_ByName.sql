--EXEC SP_ARC_SAVECustomer_Mappings_ByName @CustomerID = '', @CategoryGroup = '', @Group = ''
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_SAVECustomer_Mappings_ByName')
BEGIN
    DROP PROC SP_ARC_SAVECustomer_Mappings_ByName
END
GO
Create Proc SP_ARC_SAVECustomer_Mappings_ByName(@CustomerID Nvarchar(255), @CategoryGroup Nvarchar(255) = null, @Group Nvarchar(255) = null)  
AS  
BEGIN 
	Declare @CategoryGroupId AS INT
	Declare @GroupId AS INT

	SET @CategoryGroupId = (select TOP 1 CategoryGroupId from Customer_CategoryGroups WITH (NOLOCK) WHERE LOWER(CategoryGroupName) = LOWER(@CategoryGroup))
	SET @GroupId = (select TOP 1 GroupId from Customer_Groups WITH (NOLOCK) WHERE LOWER(GroupName) = LOWER(@Group))

	IF(ISNULL(@CategoryGroupId, 0) > 0 OR ISNULL(@GroupId, 0) > 0)
	BEGIN
		If NOT Exists (SELECT TOP 1 1 FROM Customer_Mappings WITH (NOLOCK) WHERE CustomerID = @CustomerID)
		BEGIN
			INSERT INTO Customer_Mappings (CustomerID, Company_Name, CategoryGroupId, GroupId)
			SELECT @CustomerID, 
			(SELECT TOP 1 C.Company_Name FROM CUSTOMER C WITH (NOLOCK) WHERE C.CustomerID = @CustomerID),
			@CategoryGroupId, @GroupId
		END
		ELSE
		BEGIN
			UPDATE Customer_Mappings SET CategoryGroupId = @CategoryGroupId, GroupId = @GroupId WHERE CustomerID = @CustomerID
		END
	END
END
GO
