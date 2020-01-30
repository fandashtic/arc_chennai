
Create Procedure sp_Def_Beat
as
SELECT Customer.CustomerID, Customer.Company_Name, Customer.AreaID, Beat_Salesman.BeatID
FROM Customer LEFT JOIN Beat_Salesman ON Customer.CustomerID = Beat_Salesman.CustomerID


