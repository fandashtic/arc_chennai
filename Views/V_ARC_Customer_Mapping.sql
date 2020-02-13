IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Customer_Mapping')
BEGIN
    DROP VIEW V_ARC_Customer_Mapping
END
GO
CREATE VIEW V_ARC_Customer_Mapping
As
SELECT 
	S.SalesmanID,
	S.Salesman_Name,
	SC.SalesmanCategoryName,
	B.BeatID,
	B.Description [Beat],
	C.CustomerID,
	C.Company_Name CustomerName,
	C.AccountType,
	C.ChannelType,
	C.GSTIN
from 
Beat_Salesman BS WITH (NOLOCK)
JOIN Customer C WITH (NOLOCK) ON C.CustomerID = BS.CustomerID
JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = BS.SalesmanID
JOIN Beat B WITH (NOLOCK) ON B.BeatID = BS.BeatID
FULL OUTER JOIN SalesmanCategory SC ON SC.SalesmanCategoryID = S.SalesmanCategoryID
--Where CustomerID = 'ARCBAK101'
GO
