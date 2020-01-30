Create Procedure Spr_Sales_DailySales_Abs_Upload_Consolidated(@BranchName nVarchar(255),@SalesDateN DateTime, @Salesmanid nVarchar(15))                                        
As                                                            
Declare @SODate_Tmp  as DateTime                                       
Declare @Delimeter  Char(1)                                        
Declare @SalesDate as DateTime                                    
Declare @Actualcalls Decimal(18,6)                                  
Declare @ActualcallsToDate Decimal(18,6)                                  
Declare @FromDateBh DateTime                                                                      
Declare @Rcode nVarchar(255)    
    
Set @Delimeter=Char(15)                                                  
Set Dateformat DMY                                    
Set @SalesDate=dbo.StripDateFromTime(@SalesDateN)    
Set @FromDateBh = dbo.StripDateFromTime(@SalesDateN)    
    
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
            
If @BranchName = N'%'                
Insert InTo #TmpBranch Select Distinct CompanyId From Reports      
Else                
Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * From dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))      

Select @Rcode = RegisteredOwner From Setup    
    
Create Table #TmpSale (Sales nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)                                                  
    
Create Table #TmpDailySales(salesmancode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Distributor Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[SalesMan Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [Monthly Sales Objective] Decimal(18,6), [Monthly Objective From Coverage Plan] Decimal(18,6),    
[Booked Volume] Decimal(18,6), [Booked Volume To Date] Decimal(18,6), [Actual Volume To Date] Decimal(18,6), [Call Objective] Decimal(18,6), [Call Objective To Date] Decimal(18,6),                                        
[Actual Calls] Decimal(18,6), [Actual Calls To Date] Decimal(18,6), [Actual Calls To Date Index Percentage] Decimal(18,6), [Productive Calls] Decimal(18,6), [Productive Calls To Date] Decimal(18,6) ,                                      
[% Productive Call To Date] Decimal(18,6), [Avg Pre OHD] Decimal(18,6), [Avg Pre OHD To Date] Decimal(18,6),                            
[Ohd Objective] Decimal(18,6), [Ohd] Decimal(18,6), [Ohd To Date] Decimal(18,6), [MDSG Sip Objective] Decimal(18,6), [MDSG Sip] Decimal(18,6),                             
[MDSG Sip To Date] Decimal(18,6), [MDSG Pos Objective] Decimal(18,6), [MDSG Pos] Decimal(18,6), [MDSG Pos To Date] Decimal(18,6))                                        
                                                 
If @Salesmanid = N'%'                                                   
 Insert Into #TmpSale Select SalesmanCode From Salesman                                                
Else                                                  
 Insert Into #TmpSale Select * From DBO.sp_SplitIn2Rows(@Salesmanid,@Delimeter)                                                  
                                                
Set @SODate_Tmp = Cast('01' As NVarChar(2)) +'-'+  Cast(DatePart(MM, @SalesDate)  As NVarChar) +'-'+Cast(DatePart(YYYY, @SalesDate) As NVarChar)
    
Insert INTO #TmpDailySales (salesmancode,[Distributor Code],[SalesMan Name], [Monthly Sales Objective], [Monthly Objective From Coverage Plan], [Booked Volume], [Booked Volume To Date],                                       
[Actual Volume To Date], [Call Objective], [Call Objective To Date], [Actual Calls], [Actual Calls To Date],                                       
[Actual Calls To Date Index Percentage], [Productive Calls], [Productive Calls To Date],[% Productive Call To Date],                                       
[Avg Pre OHD], [Avg Pre OHD To Date],                            
[Ohd Objective], [Ohd], [Ohd To Date], [MDSG Sip Objective], [MDSG Sip], [MDSG Sip To Date],                            
[MDSG Pos Objective], [MDSG Pos], [MDSG Pos To Date])                                        
                      
 Select WAB.salesmanid + @RCode,@RCode, SM.Salesman_Name,                                             
                        
--[Monthly Sales Objective]                        
(Select IsNull(Sum(Volume),0) From SalesmanScopeDetail SSDT Where SalesmanCode = WAB.salesmanID And ObjMonth = Datepart(mm,@SalesDate) And OBJYear =  Datepart(yyyy,@SalesDate)),                                            
                        
--[Monthly Objective From Coverage Plan]                                  
(Select IsNull(Sum(COBJ.Volume),0) From CustomerObjective COBJ                         
 Where COBJ.customerID in (Select Distinct(CustomerID) From WcpDetail WDT, WCPAbstract WcpAb where WDT.Code = WCPAB.Code And WCPAB.SalesmanID =  WAB.salesmanID                
  And Dbo.StripDateFromTime(WDT.WcpDate) = Dbo.StripDateFromTime(@SalesDate))                         
   And Cobj.ObjMonth = Datepart(mm,@SalesDate) And COBJ.OBJYear =  Datepart(yyyy,@SalesDate)),                        
                        
--[Booked Volume]                        
 (Select IsNull(Sum(SVDT.ActualQty),0) From SvDetail SVDT  Where SVDT.SvNumber in(Select SvNumber From SvAbstract SVAB Where Salesmancode = WAB.salesmanID And ((IsNull(SVAB.Status,0) & 64) = 0)                 
 And ((IsNull(SVAB.Status,0) & 32) = 0)And Dbo.StripDateFromTime(SVAB.SvDate) = @SalesDate) ) ,                                            
                        
--[Booked Volume To Date]                        
 (Select IsNull(SUM(SVDT.ActualQty),0) From SvDetail SVDT  Where SVDT.SvNumber in(Select SvNumber From SvAbstract SVAB Where Salesmancode = WAB.salesmanID  And ((IsNull(SVAB.Status,0) & 64) = 0)                 
 And ((IsNull(SVAB.Status,0) & 32) = 0) And Dbo.StripDateFromTime(SVAB.SvDate) >= Dbo.StripDateFromTime(@SODate_Tmp)  And Dbo.StripDateFromTime(SVAB.SvDate) <= @SalesDate)),                           
                  
--[Actual Volume To Date]                                                
(Select
	 IsNull(Sum(                  
			Case invoicetype
			 When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVDET.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))                  
				When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVDET.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))                  
				When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVDET.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))                   
				Else (dbo.sp_Get_ReportingQty(INVDET.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End))
		 End
		),0)                            
 From
	 Items, InvoiceDetail INVDET, InvoiceAbstract INVABS
 Where
	 INVABS.InvoiceId = INVDET.InvoiceID
	 And INVDET.Product_Code In (Select Product_Code From SVDetail Where SVNumber In (Select SVNumber From SVAbstract Where SalesmanCode = WAB.SalesmanID And ((IsNull(SVAbstract.Status,0) & 64) = 0) And ((IsNull(SVAbstract.Status,0) & 32) = 0)))
		And Dbo.StripDateFromTime(INVABS.InvoiceDate)Between Dbo.StripDateFromTime(@SODate_Tmp) And @SalesDate
	 And INVDET.Product_Code = Items.Product_Code
		And INVABS.SalesmanID = (Select SalesmanID From Salesman SM Where SM.SalesmanCode = WAB.SalesmanID)
		And INVABS.Status & 192 = 0 
),         
                        
--[Call Objective]                        
 (Select Count(Distinct(WCPDT.Customerid)) From WcpDetail WCPDT, WcpAbstract WCPAB  Where WCPAB.Code = WCPDT.Code And WCPAB.SalesmanID = WAB.salesmanID And Dbo.StripDateFromTime(WCPDT.Wcpdate) = @SalesDate                 
And ((IsNull(WCPAB.Status,0) & 128) = 0) And ((IsNull(WCPAB.Status,0) & 32) = 0) ),                
                
--[Call Objective To Date]                                          
 (Select Count(WCPDT.Customerid) From WcpDetail WCPDT, WcpAbstract WCPAB  Where WCPAB.Code = WCPDT.Code And WCPAB.SalesmanID = WAB.salesmanID And Dbo.StripDateFromTime(WCPDT.Wcpdate) >= @SODate_Tmp  And Dbo.StripDateFromTime(WCPDT.Wcpdate) <= @SalesDate
And ((IsNull(WCPAB.Status,0) & 128) = 0) And ((IsNull(WCPAB.Status,0) & 32) = 0) ),                
                  
--[Actual Calls]                                           
 (Select Count(Distinct(SvNumber)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)),         
      
--[Actual Calls To Date]                                           
 (Select Count(Distinct(SvNumber)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                 
And ((IsNull(svabstract.Status,0) & 32) = 0)),                                            
                        
--[% Actual Calls To Date]
 (Cast((Select Cast(Count(Distinct(SvNumber))As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID and Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)               
And ((IsNull(svabstract.Status,0) & 32) = 0))/                                              
  (case (Select Cast(Count(WCPDT.Customerid)As Decimal(18,6)) From WcpDetail WCPDT, WcpAbstract WCPAB  Where WCPAB.Code = WCPDT.Code And WCPAB.SalesmanID = WAB.salesmanID And Dbo.StripDateFromTime(WCPDT.Wcpdate) >= @SODate_Tmp                       
 And Dbo.StripDateFromTime(WCPDT.Wcpdate) <= @SalesDate) when 0 then 1                                               
   else (Select Cast(Count(WCPDT.Customerid)As Decimal(18,6)) From WcpDetail WCPDT, WcpAbstract WCPAB  Where WCPAB.Code = WCPDT.Code And WCPAB.SalesmanID = WAB.salesmanID And Dbo.StripDateFromTime(WCPDT.Wcpdate) >= @SODate_Tmp                          
 And Dbo.StripDateFromTime(WCPDT.Wcpdate) <= @SalesDate )end)As Decimal(18,6)) * 100),                                              
                                           
                        
--[Productive Calls]                                          
 (Select Count(Distinct(SalesVisitNumber)) From SoAbstract               
Where SalesVisitNumber in               
(Select SvNumber From SvAbstract               
Where Salesmancode = WAB.salesmanID               
And IsNull(Status,0) & 64=0 And IsNull(Status,0) & 32=0)                
And Dbo.StripDateFromTime(SoDate) = @SalesDate ),                      
                        
--[Productive Calls To Date]                                        
 (Select Count(Distinct(SalesVisitNumber)) From SoAbstract Where SalesVisitNumber in               
 (Select SvNumber From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SoDate) >= @SODate_Tmp                                   
  And Dbo.StripDateFromTime(SoDate) <= @SalesDate  And IsNull(Status,0) & 32=0 And IsNull(Status,0) & 64=0)),                                            
                        
--[% productive call to date]                        
 (Cast((Select cast(Count(Distinct(SalesVisitNumber))as Decimal(18,6)) From SoAbstract Where SalesVisitNumber in (Select SvNumber From SvAbstract Where Salesmancode = WAB.salesmanID                                             
  And Dbo.StripDateFromTime(SoDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SoDate) <= @SalesDate  And IsNull(Status,0) & 32=0 And IsNull(Status,0) & 64=0 ))/                                          
 (Case(Select Cast(Count(Distinct(SvNumber))as Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID and Dbo.StripDateFromTime(SVDate) >=@SODate_Tmp               
And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And IsNull(Status,0) & 32=0 And IsNull(Status,0) & 64=0 )  when 0 Then 1 Else               
(Select  Cast(Count(Distinct(SvNumber))as Decimal(18,6)) From SvAbstract Where Salesmancode  = WAB.salesmanID and Dbo.StripDateFromTime(SVDate) >=@SODate_Tmp               
And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And IsNull(Status,0) & 32=0 And IsNull(Status,0) & 64=0 )End)As Decimal(18,6))* 100),
                        
                       
--[Avg Pre OHD]                          
((Select Cast(Count(Product_Code) As Decimal(18,6)) From svDetail Where SvNumber in (Select SvNumber From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SVDate) =@SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                     
 And ((IsNull(svabstract.Status,0) & 32) = 0) )And svDetail.StockCount > 0 )           
/ (Case(Select Cast(Count(SvNumber) As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0) )                                
 When 0 Then 1 Else (Select Count(SvNumber) From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                     
And ((IsNull(svabstract.Status,0) & 32) = 0))End )),                                              
                          
--[Avg Pre OHD To Date]                          
 ((Select Cast(Count(Product_Code) As Decimal(18,6)) From svDetail Where SvNumber in (Select SvNumber From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SvDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SvDate) <= @SalesDate                   
And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0) )And svDetail.StockCount > 0)          
 / (Case(Select Cast(Count(SvNumber)As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                     
And ((IsNull(svabstract.Status,0) & 32) = 0))When 0 Then 1                            
  Else (Select Cast(Count(SvNumber)As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanid And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                     
And ((IsNull(svabstract.Status,0) & 32) = 0))End )),
                       
--Ohd Objective                      
 IsNull((select Max(Isnull(CampaignMaster.Objective,0))                                    
 From CampaignMaster, SvAbstract                      
 Where sVabstract.salesmancode = WAB.salesmanId                       
 And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                      
 And CampaignMaster.CampaignId = 'C001'                                         
 And CampaignMaster.Active =1        
 And ((IsNull(SvAbstract.Status,0) & 64) = 0)                                  
 And ((IsNull(SvAbstract.Status,0) & 32) = 0)),0 ),                      
                      
--Ohd                      
 Isnull(((select Sum(Isnull(CampaignDrives.response,0))                                    
 From CampaignDrives,sVabstract                                  
 Where sVabstract.salesmancode = WAB.salesmanId                                   
      And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                                  
      And sVabstract.Svnumber = CampaignDrives.svnumber                                  
      And ((IsNull(svabstract.Status,0) & 64) = 0)                                  
      And ((IsNull(svabstract.Status,0) & 32) = 0)                                  
      And CampaignDrives.CampaignID =  'C001' )                      
 / (Select Count(SvNumber) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))),0),                           
                      
--Ohd To Date                        
 Isnull(((select Cast(Sum(Isnull(CampaignDrives.response,0)) As Decimal(18,6))
 From CampaignDrives,sVabstract                                    
 Where sVabstract.salesmancode = WAB.salesmanId                                  
  And Dbo.StripDateFromTime(sVabstract.svdate) between @SODate_Tmp And @SalesDate            
    And ((IsNull(svabstract.Status,0) & 64) = 0)           
    And ((IsNull(svabstract.Status,0) & 32) = 0)          
    And sVabstract.Svnumber = CampaignDrives.svnumber          
    And CampaignDrives.CampaignID = 'C001')                      
 / (Select Cast(Count(SvNumber) As Decimal(18,6))  From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)           
And ((IsNull(svabstract.Status,0) & 32) = 0))),0),                      
                      
--Merchandising Sip Objective                      
 IsNull((select Max(Isnull(CampaignMaster.Objective,0))                                    
 From CampaignMaster, SvAbstract                      
 Where sVabstract.salesmancode = WAB.salesmanId                       
  And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                      
 And CampaignMaster.Active =1        
 And CampaignMaster.CampaignId = 'C002'              
 And ((IsNull(SvAbstract.Status,0) & 64) = 0)                                  
 And ((IsNull(SvAbstract.Status,0) & 32) = 0)),0 ),                      
                      
--Merchandising Sip                      
 Isnull(((select Cast(Sum(Isnull(CampaignDrives.response,0)) As Decimal(18,6))                                    
 From CampaignDrives,sVabstract                                  
 Where sVabstract.salesmancode = WAB.salesmanId                                   
      And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                                  
      And sVabstract.Svnumber = CampaignDrives.svnumber                                  
      And ((IsNull(svabstract.Status,0) & 64) = 0)                                  
      And ((IsNull(svabstract.Status,0) & 32) = 0)                                  
   And CampaignDrives.CampaignID =  'C002' )                      
 / (Select Cast(Count(SvNumber) As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))),0),                           
                      
--Merchandising Sip To Date                        
 Isnull(((select Cast(Sum(Isnull(CampaignDrives.response,0))  As Decimal(18,6))                                   
 From CampaignDrives,sVabstract                                    
 Where sVabstract.salesmancode = WAB.salesmanId                                  
    And Dbo.StripDateFromTime(sVabstract.svdate) between @SODate_Tmp And @SalesDate                                  
    And ((IsNull(svabstract.Status,0) & 64) = 0)                                  
    And ((IsNull(svabstract.Status,0) & 32) = 0)                                  
    And sVabstract.Svnumber = CampaignDrives.svnumber                                  
    And CampaignDrives.CampaignID = 'C002')                      
 / (Select CAst(Count(SvNumber) As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)          
 And ((IsNull(svabstract.Status,0) & 32) = 0))),0),                      
                      
--Merchandising Pos Objective                      
 IsNull((select Max(Isnull(CampaignMaster.Objective,0))                                    
 From CampaignMaster, SvAbstract                      
 Where sVabstract.salesmancode = WAB.salesmanId                       
 And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                      
 And CampaignMaster.Active =1        
 And CampaignMaster.CampaignId = 'C003'                                         
 And ((IsNull(SvAbstract.Status,0) & 64) = 0)                                  
 And ((IsNull(SvAbstract.Status,0) & 32) = 0)),0 ),                      
  
--Merchandising Pos                      
 Isnull(((select Cast(Sum(Isnull(CampaignDrives.response,0)) As Decimal(18,6))    
 From CampaignDrives,sVabstract                        
 Where sVabstract.salesmancode = WAB.salesmanId                                   
      And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                                  
      And sVabstract.Svnumber = CampaignDrives.svnumber                                  
      And ((IsNull(svabstract.Status,0) & 64) = 0)                                  
      And ((IsNull(svabstract.Status,0) & 32) = 0)                                  
   And CampaignDrives.CampaignID =  'C003' )                      
 / (Select Cast(Count(SvNumber) As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)           
And ((IsNull(svabstract.Status,0) & 32) = 0))),0),                           
                
--Merchandising Sip To Date                        
 Isnull(((select Cast(Sum(Isnull(CampaignDrives.response,0)) As Decimal(18,6))                                  
 From CampaignDrives,sVabstract                                    
 Where sVabstract.salesmancode = WAB.salesmanId                                  
    And Dbo.StripDateFromTime(sVabstract.svdate) between @SODate_Tmp And @SalesDate                                
    And ((IsNull(svabstract.Status,0) & 64) = 0)                                  
    And ((IsNull(svabstract.Status,0) & 32) = 0)                                  
    And sVabstract.Svnumber = CampaignDrives.svnumber                                  
    And CampaignDrives.CampaignID = 'C003')                      
 / (Select Cast(Count(SvNumber) As Decimal(18,6)) From SvAbstract Where Salesmancode = WAB.salesmanID And Dbo.StripDateFromTime(SVDate) >= @SODate_Tmp And Dbo.StripDateFromTime(SVDate) <= @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)           
And ((IsNull(svabstract.Status,0) & 32) = 0))),0)                      
                      
From WCPAbstract WAB, WCPDetail WDT, Salesman SM                          
Where WAB.salesmanId = SM.SalesmanCode                        
 And Dbo.StripDateFromTime(WDT.WCPDate) = @SalesDate                                            
 And WAB.salesmanID in (Select Sales From #TmpSale)                                   
 And ((IsNull(WAB.Status,0) & 128) = 0)                 
 And ((IsNull(WAB.Status,0) & 32) = 0)                
Group By WAB.salesmanid, SM.Salesman_Name                        
                            
Select SalesmanCode,[Distributor Code], [SalesMan Name],[Monthly Sales Objective],[Monthly Objective From Coverage Plan],                                        
[Booked Volume],[Booked Volume To Date],[Actual Volume To Date],[Call Objective],[Call Objective To Date],                                          
[Actual Calls], [Actual Calls To Date], [Actual Calls To Date Index Percentage],[Productive Calls],    
[Productive Calls To Date],[% Productive Call To Date],[Avg Pre OHD],[Avg Pre OHD To Date],    
[Ohd Objective],[Ohd],[Ohd To Date],    
[MDSG Sip Objective],[MDSG Sip],    
[MDSG Sip To Date],[MDSG Pos Objective],    
[MDSG Pos],[MDSG Pos To Date]    
From #TmpDailySales                                        
    
Union All    
    
Select     
Cast(RecordID as Varchar),    
CompanyID,    
ReportAbstractReceived.Field1,    
ReportAbstractReceived.Field2,    
ReportAbstractReceived.Field3,    
ReportAbstractReceived.Field4,    
ReportAbstractReceived.Field5,    
ReportAbstractReceived.Field6,    
ReportAbstractReceived.Field7,    
ReportAbstractReceived.Field8,    
ReportAbstractReceived.Field9,    
ReportAbstractReceived.Field10,    
ReportAbstractReceived.Field11,    
ReportAbstractReceived.Field12,    
ReportAbstractReceived.Field13,    
ReportAbstractReceived.Field14,    
ReportAbstractReceived.Field15,    
ReportAbstractReceived.Field16,    
ReportAbstractReceived.Field17,    
ReportAbstractReceived.Field18,    
ReportAbstractReceived.Field19,    
ReportAbstractReceived.Field20,    
ReportAbstractReceived.Field21,    
ReportAbstractReceived.Field22,    
ReportAbstractReceived.Field23,    
ReportAbstractReceived.Field24,    
ReportAbstractReceived.Field25    
From Reports,ReportAbstractReceived     
Where     
 Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = (N'Daily Sales Report') And    
 ParameterID In (Select ParameterID From dbo.GetReportParameters_DSR(N'Daily Sales Report')     
 Where FromDate = @FromDateBh) Group by CompanyId)    
 And Reports.ReportID = ReportAbstractReceived.ReportID     
 And Reports.CompanyID In (Select CompanyId From #TmpBranch)      
 And Field1 <> N'Salesman Name' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'    
 And ReportName = N'Daily Sales Report'     
Drop table #TmpDailySales                                        
Drop table #TmpSale    
Drop table #TmpBranch    

