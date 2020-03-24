--Exec ARC_Insert_ReportData 312, 'Items Master', 1, 'ARC_Items', 'Click to view Items Master', 151, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Items')
BEGIN
	DROP PROC ARC_Items
END
GO
CREATE procedure [dbo].ARC_Items
As
Begin
	SELECT 1, V.* 
	, ISNULL(V.UOM1_Conversion, 0) / (CASE WHEN ISNULL(V.UOM2_Conversion, 0) = 0 THEN 1 ELSE ISNULL(V.UOM2_Conversion, 0) END) [Packs in CFC]
	--,(SELECT SUM(Quantity) FROM Batch_Products WITH (NOLOCK) Where ISNULL(Damage, 0) = 0 AND Product_Code = V.Product_Code Group By Product_Code) [Salable On Hand Stock]
	--,(SELECT SUM(Quantity) FROM Batch_Products WITH (NOLOCK) Where ISNULL(Damage, 0) = 0 AND Product_Code = V.Product_Code Group By Product_Code) [Damage On Hand Stock]
	,(select BillDate from BillAbstract With (Nolock) Where BillID = (select top 1 BillID from BillDetail With (NOlock) Where Product_Code = V.Product_Code order By BillID Desc)) [Last Purchase Date]
	,(select InvoiceDate from InvoiceAbstract With (Nolock) Where InvoiceType IN (1, 3) AND InvoiceID = (select top 1 InvoiceID from InvoiceDetail With (NOlock) Where Product_Code = V.Product_Code order By InvoiceID Desc)) [Last Sales Date]
	,(select InvoiceDate from InvoiceAbstract With (Nolock) Where InvoiceType = 4 AND InvoiceID = (select top 1 InvoiceID from InvoiceDetail With (NOlock) Where Product_Code = V.Product_Code order By InvoiceID Desc)) [Last Sales Return Date]
	,Case When (select ISNULL(Count(ProductName), 0) FROM V_ARC_Items WITH (NOLOCK) WHERE ProductName =  V.ProductName GROUP BY ProductName) > 1 THEN 'Yes' Else 'No' END [Is Name Duplicate]
	FROM V_ARC_Items V WITH (NOLOCK) 
	Order By V.ItemFamily, V.CategoryGroup, V.Category, V.ItemSubFamily, V.ItemGroup, V.ProductName ASC
END
GO
--select BillDate from BillAbstract With (Nolock) Where BillID = (select top 1 BillID from BillDetail With (NOlock) Where Product_Code = '300' order By BillID Desc)