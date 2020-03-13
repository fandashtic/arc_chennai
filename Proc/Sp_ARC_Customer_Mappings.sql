--Exec Sp_ARC_Customer_Mappings 'ARCBAK199', 1, 1
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'Sp_ARC_Customer_Mappings')
BEGIN
	DROP PROC [Sp_ARC_Customer_Mappings]
END
GO
CREATE Procedure Sp_ARC_Customer_Mappings (@CustomerID NVARCHAR(30), @CategoryGroupId Int, @GroupId INT)
As
Begin
	IF NOT EXISTS (SELECT TOP 1 1 FROM Customer_Mappings WITH (NOLOCK) WHERE CustomerID = @CustomerID)
	BEGIN
		
		INSERT INTO Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId)
		SELECT @CustomerID, (SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK)  WHERE CustomerID = @CustomerID), @CategoryGroupId, @GroupId
	END
	ELSE
	BEGIN
		Update C 
		SET 
			C.CategoryGroupId = @CategoryGroupId,
			C.GroupId = @GroupId
		FROM Customer_Mappings C WITH (NOLOCK)
		WHERE CustomerID = @CustomerID
	END
END
GO