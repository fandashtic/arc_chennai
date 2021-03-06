--Exec Sp_arc_get_SalesFormDelivery '27-Feb-2020', '%'
IF EXISTS(SELECT * 
          FROM   sys.objects 
          WHERE  NAME = N'Sp_arc_get_SalesFormDelivery') 
  BEGIN 
      DROP PROC Sp_arc_get_SalesFormDelivery 
  END 

go 

CREATE PROCEDURE [dbo].Sp_arc_get_SalesFormDelivery (@TODATE     DATETIME, 
                                     @Van      NVARCHAR(100) = '%') 
AS 
BEGIN 
	SET DATEFORMAT DMY
	SELECT DISTINCT 
	InvoiceID, 
	CONVERT(NVARCHAR(10), InvoiceDate , 105) InvoiceDate, 
	CONVERT(NVARCHAR(10), DeliveryDate , 105) DeliveryDate, 
	ISNULL(DeliveryStatus, 0) DeliveryStatus, 
	CustomerId, 
	(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerId = S.CustomerId) [CustomerName],
	SalesmanID, 
	(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = S.SalesmanID) [SalesmanName],
	BeatID, 
	(SELECT TOP 1 Description FROM Beat WITH (NOLOCK) WHERE BeatID = S.BeatID) [Beat],
	GSTFullDocID, 
	DocSerialType, 
	CAST(ISNULL(NetValue,0) + ISNULL(RoundOffAmount,0) AS DECIMAL(18,2)) NetValue,
	CAST(Weight  AS DECIMAL(18,2)) Weight
	FROM V_ARC_Sale_ItemDetails S WITH (NOLOCK) 
	WHERE 
	ISNULL(DeliveryStatus, 0) <> 2 AND
	dbo.StripDateFromTime(InvoiceDate) = @Todate AND DocSerialType = CASE WHEN ISNULL(@Van, '%') = '%' THEN DocSerialType ELSE @Van END
	ORDER BY DocSerialType, GSTFullDocID ASC
END