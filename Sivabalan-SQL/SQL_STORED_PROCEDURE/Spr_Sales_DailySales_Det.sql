CREATE procedure [dbo].[Spr_Sales_DailySales_Det](@Salesmanid nVarChar(30),@SalesDate DateTime, @Unused1 nVarChar(30),@Unused2 nVarChar(30))
As                                      
Declare @SODate_Tmp  DateTime                                    
Declare @Delimeter  Char(1)                                      
Declare @curCustomerID nVarChar(15)                                      
Declare @CurCampaignID nVarChar(15)                                      
Declare @CurCampaigndate DateTime                                      
Declare @distrubutionCall Decimal(18,6)                        
Declare @CampObjective Decimal(18,6)                                      
Declare @Exec_Sql nVarChar(500)                                      
Declare @DistrubutionDate Int                                      
Declare @CampaignAvgCall Decimal(18,6)                                      
Declare @CurCampaignName nVarChar(255)                                             
Declare @SalesDate_Camp DateTime                  
Declare @OffTake_Tmp Int                
                  
Set @SalesDate_Camp = @SalesDate                  
Set @SalesDate = Dbo.StripDateFromTime(@SalesDate)                                    
                  
Create Table #TmpDailyDet 
(
 CustomerId nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Cust ID] nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Cust Name] nVarChar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
 Channel nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Visited Y/N] nVarChar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Inventory] Decimal(18,6),
 [Customer Purchase During Last 2 Visits] Decimal(18,6),
	[Inventory During Last SV] Decimal(18,6),
 [Customer Sales During Last 2 Visits]  Decimal(18,6),
	OffTake Decimal(18,6),                            
	[Suggested Order] Decimal(18,6),
 [Actual Order] Decimal(18,6),
 [Volume Objective This Month] Decimal(18,6),
 [Volume Till Date] Decimal(18,6),
	[OHD Pre] BigInt,
	[Remarks] NVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
)
                                       
Insert InTo #TmpDailyDet
(                                      
	CustomerId, [Cust ID], [Cust Name], Channel,[Visited Y/N],[Inventory],
 [Customer Purchase During Last 2 Visits], [Inventory during last SV],
	[Customer Sales During Last 2 Visits],OffTake,[Suggested Order],[Actual Order],                        
	[Volume Objective This Month],[Volume Till Date],[Ohd Pre],[Remarks]
)                                      
Select 
	WDT.CustomerID,WDT.CustomerID,CUST.Company_Name,CHNL.ChannelDesc as Channel,
	--Visited Y/N                         
	Case (Select Count(SVNumber) From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate 
	And ((IsNull(Status,0) & 64) = 0) And ((IsNull(Status,0) & 32) = 0)) 
	When 0 Then N'No' Else N'Yes' End,
	--Inventory                                        
	(Select IsNull(Sum(              
	Case invoicetype When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
	Else (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) End),0)                        
	From Items,InvoiceAbstract INVAB, InvoiceDetail INVDT Where INVAB.InvoiceID = INVDT.InvoiceID                                         
	And INVAB.Customerid = WDT.Customerid And  IsNull(INVAB.Status,0)&192=0                
	And Dbo.StripDateFromTime(INVAB.InvoiceDate) <= @SalesDate     
	And Items.Product_code = INVDT.Product_Code                 
	And INVDT.Product_Code in( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid                     
	And Dbo.StripDateFromTime(SvDate) = @SalesDate And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))
	And INVAB.SalesmanID = (Select SalesmanID From Salesman SM Where SM.SalesmanCode = WAb.SalesmanID)
	And INVAB.Status & 192 = 0 


),
	--Customer Purchase During Last 2 Visits      
	(Select IsNull(Sum(              
	Case invoicetype When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
	Else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) End),0)                        
	From Items,InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) >= Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
	And Dbo.StripDateFromTime(SvDate) < Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid And Dbo.StripDateFromTime(SvDate) <= @SalesDate ))))                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) <= Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid And Dbo.StripDateFromTime(SvDate) <= @SalesDate ))                         
	And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                        
	And Items.Product_code = INVD.Product_Code                      
	And INVD.Product_Code in( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))),
	--Inventory during last visit                        
	(Select IsNull(Sum(              
	Case invoicetype When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
	Else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) End),0)                        
	From Items, InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) = Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
	And Dbo.StripDateFromTime(SvDate) <= @SalesDate )) And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                          
	And Items.Product_code = INVD.Product_Code                      
	And INVD.Product_Code in( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))),
	--Customer Sales During Last 2 Visits      
	(IsNull(((Select IsNull(Sum(              
	Case invoicetype When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))        
	When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
	Else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) End),0)                        
	From Items, InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) >= Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
	And Dbo.StripDateFromTime(SvDate) < Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid And Dbo.StripDateFromTime(SvDate) <= @SalesDate))))                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) <= Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
	And Dbo.StripDateFromTime(SvDate) <= @SalesDate )) And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                         
	And Items.Product_code = INVD.Product_Code                      
	And INVD.Product_Code in( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))))                         
	-                        
	(Select IsNull(Sum(              
	Case invoicetype When 4 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 5 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
	When 6 Then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
	Else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) End),0)                        
	From Items, InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
	And Dbo.StripDateFromTime(INVA.InvoiceDate) = Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
	And Dbo.StripDateFromTime(SvDate) <= @SalesDate )) And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                         
	And Items.Product_code = INVD.Product_Code                       
	And INVD.Product_Code in ( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))))),0)),
	--Off Take                        
	(Select IsNull(Sum(OffTake),0) From SVDetail Where SvNumber In(Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate)),
	--Suggested Quantity                 
	(Select IsNull(Sum(dbo.sp_Get_ReportingQty(SuggestedQty,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0)From SVDetail, Items Where SvNumber In(Select SVNumber  From SvAbstract Where SalesmanCode = WAb.SalesmanId 
	And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)) And Items.Product_Code = SVDetail.Product_Code ),
	--Actual Quantity                
	(Select IsNull(Sum(dbo.sp_Get_ReportingQty(ActualQty,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0) From SVDetail, Items Where SvNumber In(Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId 
	And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))And Items.Product_Code = SVDetail.Product_Code),
	--Volume Objective This Month                         
	(Select IsNull(Sum(COBJ.Volume),0) From CustomerObjective COBJ Where COBJ.CustomerID = WDT.customerID And Cobj.ObjMonth = Datepart(mm,@SalesDate_Camp) And COBJ.OBJYear =  Datepart(yyyy,@SalesDate_Camp)),
	--Volume Till Date                                  
	(Select IsNull(Sum(dbo.sp_Get_ReportingQty(SODT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0)                        
	From Items, SoAbstract SOAB, SoDetail SODT Where SOAB.SoNumber = SODT.soNumber                                         
	And SalesVisitNumber in ( Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId 
	And Dbo.StripDateFromTime(SVDate) = @SalesDate  And ((IsNull(svabstract.Status,0) & 64) = 0)                   
	And ((IsNull(svabstract.Status,0) & 32) = 0))
	And Dbo.StripDateFromTime(SoDate) <=  Dbo.StripDateFromTime(@SalesDate) 
	And Items.Product_code = SODT.Product_Code                      
	And SODT.Product_Code in ( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
	And ((IsNull(svabstract.Status,0) & 128) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))),
	--[Ohd Pre]                          
	(Select Count(Product_Code) From svDetail Where SvNumber in (Select SvNumber From SvAbstract Where Customerid = WDT.CustomerID And Dbo.StripDateFromTime(SVDate) = @SalesDate                   
	And svDetail.StockCount > 0 
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0) )),                        
	--[Salesman Remarks]                          
	(Select Top 1 SalesmanRemarks From SVAbstract Where Customerid = WDT.CustomerID And Dbo.StripDateFromTime(SVDate) = Dbo.StripDateFromTime(@SalesDate)                   
	And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0) And SVAbstract.SalesmanCode = @Salesmanid)                        

From 
	WcpAbstract WAb, WcpDetail WDt, Customer CUST,                                          
 Customer_Channel CHNL, SubChannel SCH                    
Where 
	WAb.Code = WDt.Code                    
 And WAb.SalesmanId = @Salesmanid                      
 And WDT.CustomerId = CUST.CustomerId                                          
 And CUST.ChannelType *= CHNL.ChannelType                                        
 And CUST.SubChannelID *= SCH.SubChannelID 
 And ((IsNull(WAB.Status,0) & 128) = 0)                   
 And ((IsNull(WAB.Status,0) & 32) = 0)
 And Dbo.StripDateFromTime(WDT.WCPDate) = @SalesDate        
Group by   
	WDT.CustomerID, CHNL.ChannelDesc, SCH.Description, CUST.Company_Name, WAb.SalesmanId                          
                          
Create Table #TmpCampaign
(
	CampaignID nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CampaignName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerId nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
)                                          
                                      
Insert InTo #TmpCampaign(CampaignID,CampaignName,CustomerID)                         
	Select  
		Distinct campaignMaster.campaignId,campaignMaster.campaignName,campaigncustomers.customerid                   
 From 
		campaignMaster, CampaignCustomers, SVABSTRACT,CampaignDrives                  
 Where  
		SVABSTRACT.customerid = campaigncustomers.customerid                                           
	 And campaignMaster.campaignId = campaigncustomers.CampaignId                                
 	And campaignMaster.Customerid=1                                    
	 And Dbo.StripDateFromTime(campaignMaster.ToDate) >= Dbo.StripDateFromTime(@SalesDate)                        
 	And CampaignDrives.CampaignID = CampaignMaster.CampaignID    
	 And CampaignDrives.SVNumber = SVABSTRACT.SVNumber    
Union              
	Select  
		Distinct  campaignMaster.campaignId,campaignMaster.campaignName, Customer.customerid                   
 From 
		campaignMaster, Customer, CampaignDrives, SVABSTRACT                 
 Where  
		campaignMaster.Customerid=0    
	 And SVABSTRACT.customerid = Customer.customerid                        
	 And Dbo.StripDateFromTime(campaignMaster.ToDate) >= Dbo.StripDateFromTime(@SalesDate)                        
	 And CampaignDrives.CampaignID = CampaignMaster.CampaignID    
	 And CampaignDrives.SVNumber = SVABSTRACT.SVNumber    
                              
Declare Salesman_Cursor Cursor For Select Distinct CampaignName From #TmpCampaign                                     
Open Salesman_Cursor                                                
 Fetch Next From Salesman_Cursor InTo @CurCampaignName                                          
 While @@Fetch_Status = 0                           
 Begin                                    
		Set @Exec_Sql = 'Alter Table #TmpDailyDet Add [' + @CurCampaignName + ' Objective] Decimal(18,6)'                                         
		Exec sp_executesql @Exec_Sql                                      
		
		Set @Exec_Sql = 'Alter Table #TmpDailyDet Add [' + @CurCampaignName + '] nVarChar(255)'                  
		Exec sp_executesql @Exec_Sql                                      
 	Fetch Next From Salesman_Cursor InTo @CurCampaignName                                        
 End                                          
Close Salesman_Cursor                                                
DeAllocate Salesman_Cursor                               

Set @distrubutionCall =0                                      

Declare Salesman_Cursor Cursor For Select Distinct  CampaignID,CampaignName,CustomerID From #TmpCampaign                                          
Open Salesman_Cursor                                                
 Fetch Next From Salesman_Cursor InTo @CurCampaignID,@CurCampaignName,@curCustomerID                 
 While @@Fetch_Status = 0                                                
 Begin                                                    
		Set @CampObjective = IsNull((Select IsNull(CustomerObjective,0)                           
		From CampaignMaster,CampaignCustomers                    
		Where Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                        
		And CampaignMaster.CampaignId = CampaignCustomers.CampaignId
		And CampaignMaster.CampaignId = @CurCampaignID 
		And CampaignCustomers.CustomerID = @curCustomerID	), 0 )                        
		Set @Exec_Sql = 'Update #TmpDailyDet Set [' + @CurCampaignName + ' Objective] = ' + cast(@CampObjective as varchar) + ''                                      
		+ ' Where #TmpDailyDet.CustomerID = ''' + @curCustomerID + ''''                                      
		Print @Exec_Sql                                      
		Exec sp_executesql @Exec_Sql                                           
		Set @distrubutionCall = IsNull((Select Sum(IsNull(CampaignDrives.response,0))                                        
		From CampaignDrives,sVabstract                               
		Where sVabstract.Customerid = @curCustomerID                                    
		And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                                      
		And sVabstract.Svnumber = CampaignDrives.svnumber                                      
		And ((IsNull(svabstract.Status,0) & 64) = 0)                                      
		And ((IsNull(svabstract.Status,0) & 32) = 0)                
		And CampaignDrives.CampaignID =  @CurCampaignID ),0)                                      
		Set @Exec_Sql = 'Update #TmpDailyDet Set [' + @CurCampaignName + '] = ' + cast(@distrubutionCall as varchar) + ''                                      
		+ ' Where #TmpDailyDet.CustomerID = ''' + @curCustomerID + ''''                                      
		Print @Exec_Sql                                      
		Exec sp_executesql @Exec_Sql                                           
		Fetch Next From Salesman_Cursor InTo  @CurCampaignID,@CurCampaignName,@curCustomerID                  
 End                                          
Close Salesman_Cursor                                                
DeAllocate Salesman_Cursor                                       
                                      
Select * From #TmpDailyDet                                    
                                      
Drop Table #TmpCampaign        
Drop Table #TmpDailyDet
