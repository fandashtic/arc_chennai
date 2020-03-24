--EXEC SP_ARC_SAVECustomer_Mappings @CustomerID = '', @CategoryGroupId = 0, @GroupId = 0
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_SAVECustomer_Mappings')
BEGIN
    DROP PROC SP_ARC_SAVECustomer_Mappings
END
GO
Create Proc SP_ARC_SAVECustomer_Mappings(@CustomerID Nvarchar(255), @CategoryGroupId int = 0, @GroupId INT = 0)  
AS  
BEGIN 
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