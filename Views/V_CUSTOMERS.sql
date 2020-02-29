--SELECT * FROM V_CUSTOMERS --where CustomerId = 'ARCBAK139'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_CUSTOMERS')
BEGIN
    DROP VIEW V_CUSTOMERS
END
GO
CREATE VIEW V_CUSTOMERS
AS
select Distinct S.SalesmanID, S.Salesman_Name, dbo.fn_Arc_GetSalesmanCategory(S.SalesmanID) SalesmanCategory,
B.BeatID, B.Description, C.CustomerId, C.Company_Name, dbo.fn_Arc_GetCustomerCategory(C.CustomerId) CategoryGroup, dbo.fn_Arc_GetCustomerGroup(C.CustomerId) [Group]
FROM Customer C WITH (NOLOCK)
LEFT OUTER JOIN Beat_Salesman BS ON BS.CustomerID = C.CustomerID
LEFT OUTER JOIN Beat B WITH (NOLOCK) ON B.BeatID = BS.BeatId AND B.Active = 1
LEFT OUTER JOIN Salesman S WITH (NOLOCK) ON BS.SalesmanID = S.SalesmanID AND S.Active = 1
GO