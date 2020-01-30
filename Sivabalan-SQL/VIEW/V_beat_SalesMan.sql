Create View V_beat_SalesMan
([Beat_ID], [Beat_Name], [Salesman_ID], [Salesman_Name], [Customer_ID], [Customer_Name], [Active])
AS
SELECT      Beat_Salesman.BeatID, Beat.Description, Beat_Salesman.SalesmanID, Salesman.Salesman_Name,Beat_Salesman.CustomerID, 
            Customer.Company_Name, 'Active' = (Case When (Isnull(Beat.Active, 1) 
	    + Isnull(Salesman.Active, 1) + Isnull(Customer.Active, 1)) <> 3 then 0 else 1 end) 
FROM        Beat_Salesman 
Inner Join Beat On Beat.BeatID = Beat_Salesman.BeatID 
Left Outer Join Salesman On Salesman.SalesmanID = Beat_Salesman.SalesmanID
Left Outer Join Customer on Customer.CustomerID = Beat_SalesMan.CustomerID
inner join 
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=Salesman.Salesmanid
Where Beat_Salesman.CustomerID in (Select C.CustomerID from Customer C)
