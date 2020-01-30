CREATE Procedure sp_get_OfftakeFreeItems @CustomerID as nvarchar(30) as
Select 	SCT.SchemeID,
		S.SchemeName, 
		SCT.Product_Code, 
		Items.ProductName,
		SCT.Pending,
		S.SchemeType
From
		Schemes S,
		SchemeCustomerITems SCT,
		Items
Where
		S.SchemeID = SCT.SChemeID and
		Items.Product_Code = SCT.Product_Code and
		SCT.CustomerID = @CustomerID and
		SCT.Pending > 0		
Order by SCT.SchemeID, SCT.Product_Code


