CREATE PROCEDURE spr_List_Customers_Ex_Cons
(
 @BranchName NVarChar(4000),
	@FROMDATE DateTime, 
	@TODATE DateTime
)  
AS  

	Declare @FromDateBh DateTime
	Declare @ToDateBh DateTime

 Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
 Set @ToDateBh = dbo.StripDateFromTime(@ToDate)      

	Declare @Delimeter as Char(1)        
 Set @Delimeter=Char(15)  

 CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
 If @BranchName = N'%'            
  Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
 Else            
  Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  

	Declare @Others NVarChar(50)    
	Set @Others = dbo.LookupDictionaryItem(N'Others', Default)    
   
	Declare	@CIDSetUp As NVarChar(15)
	Select @CIDSetUp=RegisteredOwner From Setup 

	Select  
		Cast(0 As NVarChar)+ @CIDSetUp,
		"Distributor Code"=@CIDSetUp, 
		"Beat" = @Others, 
		"Number of Customers" =   
	 (Select 
				Count(CustomerID) 
			From 	
				Customer 
			Where 
				CustomerID Not In (Select CustomerID From Beat_Salesman) And   dbo.StripDateFromTime(CreationDate) = @FROMDATEBH And dbo.StripDateFromTime(CreationDate) = @TODATEBH And CustomerCategory Not In(4,5))  

UNION ALL  

	Select  
		Cast(BeatID As NVarChar)+@CIDSetUp,
		"Distributor Code"=@CIDSetUp, 
		Beat.Description, 
		(Select 
				Count(CustomerID) 
			From 
				Customer 
			Where 
				CustomerID In (Select CustomerID From Beat_Salesman Where Beat_Salesman.BeatID = Beat.BeatID) And  dbo.StripDateFromTime(CreationDate) = @FROMDATEBH And dbo.StripDateFromTime(CreationDate) = @TODATEBH)  
 From  
		Beat  

Union All

 Select       
		Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,
		"Beat" = Field1,"Number of Customers" = Field2
 From  
  Reports,ReportAbstractReceived   
 Where  
  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'New Customers')  
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
  And ReportAbstractReceived.ReportID = Reports.ReportID  
  And Field1 <> N'Beat' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'New Customers') Where FromDate = @FromDateBh And ToDate = @ToDateBh)

