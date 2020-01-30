
CREATE Procedure Sp_Get_ExistingWCP(@WeekDate DateTime,@SalesmanId As NVarChar(50))
AS 
Select Code,WCPDATE
From WCPDetail 
Where Code In (Select Code From WCPAbstract Where Salesmanid=@SalesmanId And ((IsNull(Status,0)& 32) = 0 and (IsNull(Status,0) & 128) = 0))
And  Dbo.StripDateFromTime(WCPDATE)=Dbo.StripDateFromTime(@WeekDate)
Group by WCPDATE,Code

