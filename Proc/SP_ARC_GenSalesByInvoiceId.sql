--Exec SP_ARC_GetSalesByInvoiceId 'I/19-20/24081'
--Insert into ParameterInfo
--select 642, 'Invoice Number', 200, '', Null, Null, '', NULL

--exec SP_ARC_SalesReturns '2020-02-27 00:00:00','2020-03-05 23:59:59','%','Base UOM'
Exec ARC_Insert_ReportData 624, 'Sales By Invoice Id', 1, 'SP_ARC_GetSalesByInvoiceId', 'Click to view Sales By Invoice Id', 561, 642, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
--Exec ARC_GetUnusedReportId 
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetSalesByInvoiceId')
BEGIN
  DROP PROC [SP_ARC_GetSalesByInvoiceId]
END
GO  
CREATE Proc [dbo].[SP_ARC_GetSalesByInvoiceId](@GSTFullDocID Nvarchar(255))
AS
BEGIN
	Set Dateformat DMY

	select Distinct
	InvoiceID,	
	InvoiceDate,	
	V.CustomerID,	
	(SELECT TOP 1 Company_Name FROM Customer With (Nolock) Where CustomerID = V.CustomerID) [Customer Name],
	--V.SalesmanID,	
	(SELECT TOP 1 Salesman_Name FROM Salesman With (Nolock) Where SalesmanID = V.SalesmanID) [Salesman Name],
	--V.BeatID,	
	(SELECT TOP 1 Description FROM Beat With (Nolock) Where BeatID = V.BeatID) [Beat],
	dbo.Fn_arc_getcustomercategory(V.CustomerID) [CUSTOMER CATEGORY GROUP], 
	dbo.Fn_arc_getcustomergroup(V.CustomerID)    [CUSTOMER GROUP],
	SA.SONumber [Order Number],
	SA.SODate [Order Date],  
	SA.Value [Order Value],    
	GSTFullDocID [Invoice Id],	
	V.DocSerialType [Van Number],	
	DocReference,	
	NetValue + RoundOffAmount [Invoice Amount],		
	Case When DeliveryStatus = 1 then 'Pending' Else 'Delivered' END DeliveryStatus,
	V.DeliveryDate,	
	Balance	[Outstanding],
	(Select TOP 1 GSTFullDocID  FROM V_ARC_SaleReturn_ItemDetails SR WITH (NOLOCK) WHERE SR.ReferenceNumber = V.GSTFullDocID) [Sales Return Id],
	(Select TOP 1 InvoiceDate FROM V_ARC_SaleReturn_ItemDetails SR WITH (NOLOCK) WHERE SR.ReferenceNumber = V.GSTFullDocID) [Sales Return Date],
	(Select TOP 1  NetValue + RoundOffAmount FROM V_ARC_SaleReturn_ItemDetails SR WITH (NOLOCK) WHERE SR.ReferenceNumber = V.GSTFullDocID) [Sales Return Amount],
	(Select TOP 1 Type FROM V_ARC_SaleReturn_ItemDetails SR WITH (NOLOCK) WHERE SR.ReferenceNumber = V.GSTFullDocID) [Sales Return Type],
	Product_Code,	
	(SELECT TOP 1 ProductName FROM Items With (Nolock) Where Product_Code = V.Product_Code) [Produc tName],
	Batch_Code,	
	Batch_Number,	
	Quantity / (SELECT TOP 1 ISNULL(UOM2_Conversion, 1) FROM Items Where Product_Code = V.Product_Code) [Quantity]
	from V_ARC_Sale_ItemDetails V WITH (NOLOCK)
	RIGHT OUTER JOIN SOAbstract SA WITH (NOLOCK) ON V.CustomerID = SA.CustomerID AND V.SONumber = SA.SONumber
	WHERE GSTFullDocID = @GSTFullDocID
END
GO
