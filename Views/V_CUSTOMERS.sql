--SELECT * FROM V_CUSTOMERS
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_CUSTOMERS')
BEGIN
    DROP VIEW V_CUSTOMERS
END
GO
CREATE VIEW V_CUSTOMERS
AS
select S.SalesmanID, S.Salesman_Name, B.BeatID, B.Description, C.CustomerId, C.Company_Name
FROM Customer C WITH (NOLOCK)
JOIN Beat_Salesman BS ON BS.CustomerID = C.CustomerID
JOIN Beat B WITH (NOLOCK) ON B.BeatID = BS.BeatId AND B.Active = 1
JOIN Salesman S WITH (NOLOCK) ON BS.SalesmanID = S.SalesmanID AND S.Active = 1
GO
