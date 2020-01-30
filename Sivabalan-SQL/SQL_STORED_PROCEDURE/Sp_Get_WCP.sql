CREATE Procedure Sp_Get_WCP(@SalesmanId As NVarChar(50))
AS 
Select 
	DocumentID,Dbo.StripDateFromTime(WeekDate),Code
From 
	WCPAbstract 
Where 
	Salesmanid=@SalesmanId 
	And (IsNull(Status,0)& 32) = 0 
	And (IsNull(Status,0) & 128) = 0
Order by
	WeekDate


