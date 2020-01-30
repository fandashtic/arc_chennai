
Create Procedure mERP_SP_Rpt_FailedVisitReport
@Fromdate Datetime,
@Todate Datetime
AS
BEGIN
	SET DATEFORMAT DMY
	Declare @WDCode nVarchar(255)
	Declare @WDDest nVarchar(255)

	Declare @CompaniesToUploadCode nVarchar(255)


	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
	Select Top 1 @WDCode = RegisteredOwner From Setup    
	  
	If @CompaniesToUploadCode='ITC001'  
		Set @WDDest= @WDCode  
	Else  
	Begin  
		Set @WDDest= @WDCode  
		Set @WDCode= @CompaniesToUploadCode  
	End  

	Create Table #tmpOutput(DSID int,[DS Name] nvarchar(50),SuperVisorID int,[Supervisor Name] nvarchar(255),CustomerId nvarchar(15),[Customer Name] nvarchar(150),[Fail_Reason] nvarchar(250), 
	Comments nvarchar(250),uploaddate nvarchar(25))
	
	insert into #tmpOutput(DSID,[DS Name],SuperVisorID,[Supervisor Name],CustomerId,[Customer Name],[Fail_Reason],[Comments],uploaddate)
	Select distinct D.DSID,S.Salesman_Name [DS Name],D.SuperVisorID,case When Supervisor.Salesmanname is null Then 'N/A' else Supervisor.Salesmanname end as [Supervisor Name],D.CustomerId,C.Company_Name as [Customer Name],[Fail_Reason],[Comments],Convert(nVarchar(10),[uploaddate],103) + N' ' + Convert(nVarchar(8),[uploaddate],108)
	from DSFailVisitReasons D
	Inner Join  Salesman S On D.DSID=S.SalesmanID
	Inner Join Customer C On D.CustomerID=C.CustomerID
	Left Outer Join Salesman2 Supervisor On D.SupervisorID =Supervisor.SalesmanID
	Where dbo.stripdatefromtime(uploaddate) between @Fromdate and @Todate
	
	Select 1,@WDCode as WDCode,@WDDest as WDDest,@Fromdate as FromDate,@Todate as ToDate,DSID,[DS Name],SupervisorID,[Supervisor Name],CustomerID,[Customer Name],[Fail_Reason], 
	Comments,uploaddate as [Transaction Date] from #tmpOutput

END
