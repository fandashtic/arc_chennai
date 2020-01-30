CREATE procedure [dbo].[Spr_Sales_DailySales_Det_Upload]( @Salesmanid nvarchar(30), @SalesDate DateTime, @Unused1 nVarchar(30),@Unused2 nVarchar(30))                 
As                              
                
Declare @SODate_Tmp  as DateTime                            
Declare @Delimeter  Char(1)                              
Declare @Exec_Sql nVarchar(500)                              
Declare @SalesDate_Camp Datetime                
                
Set @SalesDate_Camp = @SalesDate                
Set @SalesDate = Dbo.StripDateFromTime(@SalesDate)                                  
                            
Create Table #TmpDailyDet ( CustomerId nVarchar(15), [Cust ID] nVarchar(15), [Cust Name] nVarchar(150), Channel nvarchar(255), [Sub Channel] nVarchar(100),                                
[Visited Y/N] nVarchar(10), Inventory Decimal(18,6), [Customer Purchase During Last 2 Visits] Decimal(18,6),[Inventory During Last SV] Decimal(18,6),                 
[Customer Sales During Last 2 Visits]  Decimal(18,6),OffTake Decimal(18,6), [Suggested Order] Decimal(18,6), [Actual Order] Decimal(18,6),                 
[Volume Objective This Month] Decimal(18,6), [Volume Till Date] Decimal(18,6),[Ohd Pre] Bigint, [Ohd Objective] Decimal(18,6), [Ohd] Decimal(18,6),                 
[MDSG Sip Objective] Decimal(18,6), [MDSG Sip] Decimal(18,6),[MDSG Pos Objective] Decimal(18,6),[MDSG Pos] Decimal(18,6))                                
                                
                                
Insert Into #TmpDailyDet  (                              
CustomerId, [Cust ID], [Cust Name], Channel, [Sub Channel],                                
[Visited Y/N], Inventory, [Customer Purchase During Last 2 Visits], [Inventory during last SV],                
[Customer Sales During Last 2 Visits], OffTake, [Suggested Order], [Actual Order],                
[Volume Objective This Month],[Volume Till Date],[Ohd Pre], [Ohd Objective], [Ohd],                 
[MDSG Sip Objective], [MDSG Sip],[MDSG Pos Objective],                
[MDSG Pos] )                              
                
Select WDT.CustomerID, WDT.CustomerID, CUST.Company_Name, CHNL.ChannelDesc as Channel, SCH.Description As Subchannel,                                          
                       
--Visited Y/N                         
 Case (Select Count(SVNumber) From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate 
And ((IsNull(Status,0) & 64) = 0) And ((IsNull(Status,0) & 32) = 0)) When 0 Then 'No' Else 'Yes' End,
--Inventory                                        
 (Select IsNull(Sum(              
case invoicetype when 4 then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
when 5 then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
when 6 then (0 - (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
else (dbo.sp_Get_ReportingQty(INVDT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) end),0)                        
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
 case invoicetype when 4 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 5 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 6 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
 else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) end),0)                        
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
 case invoicetype when 4 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 5 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 6 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
 else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) end),0)                        
 From Items, InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
 And Dbo.StripDateFromTime(INVA.InvoiceDate) = Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
 And Dbo.StripDateFromTime(SvDate) <= @SalesDate )) And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                          
 And Items.Product_code = INVD.Product_Code                      
 And INVD.Product_Code in( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
 And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))),
--Customer Sales During Last 2 Visits      
 (IsNull(((Select IsNull(Sum(              
 case invoicetype when 4 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))        
 when 5 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 6 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
 else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) end),0)                        
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
 case invoicetype when 4 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 5 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))              
 when 6 then (0 - (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)))               
 else (dbo.sp_Get_ReportingQty(INVD.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)) end),0)                        
 From Items, InvoiceAbstract INVA, InvoiceDetail INVD Where INVA.InvoiceID= INVD.InvoiceID                         
 And Dbo.StripDateFromTime(INVA.InvoiceDate) = Dbo.StripDateFromTime((Select max(SVDate) From SvAbstract Where SalesmanCode = @Salesmanid                         
 And Dbo.StripDateFromTime(SvDate) <= @SalesDate )) And INVA.CustomerID = WDT.CustomerID And IsNull(INVA.Status,0)&192=0                         
 And Items.Product_code = INVD.Product_Code                       
 And INVD.Product_Code in ( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
 And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))))),0)),
--Off Take                        
(Select IsNull(Sum(OffTake),0) From SVDetail Where SvNumber In(Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate)),
--Suggested Quantity                 
(Select IsNull(Sum(dbo.sp_Get_ReportingQty(SuggestedQty,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0)From SVDetail, Items Where SvNumber In(Select SVNumber  From SvAbstract 
Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SVDate) = @SalesDate And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0))                    
  And Items.Product_Code = SVDetail.Product_Code ),
--Actual Qunntity                
 (Select IsNull(Sum(dbo.sp_Get_ReportingQty(ActualQty,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0)
From SVDetail, Items Where SvNumber In(Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId
And Dbo.StripDateFromTime(SVDate) = @SalesDate And ((IsNull(svabstract.Status,0) & 64) = 0) 
And ((IsNull(svabstract.Status,0) & 32) = 0))                    
And Items.Product_Code = SVDetail.Product_Code),
--Volume Objective This Month                         
 (Select IsNull(Sum(COBJ.Volume),0) From CustomerObjective COBJ Where COBJ.CustomerID = WDT.customerID And Cobj.ObjMonth = Datepart(mm,@SalesDate_Camp) And COBJ.OBJYear =  Datepart(yyyy,@SalesDate_Camp)),
--Volume Till Date                                  
 (Select IsNull(Sum(dbo.sp_Get_ReportingQty(SODT.Quantity,Case When IsNull(Items.reportingunit, 0) = 0 Then 1 Else Items.reportingunit End)),0)                        
 From Items, SoAbstract SOAB, SoDetail SODT Where SOAB.SoNumber = SODT.soNumber                                         
 And SalesVisitNumber in ( Select SVNumber From SvAbstract Where SalesmanCode = WAb.SalesmanId And  SvAbstract.CustomerId = WDT.CustomerId 
 And Dbo.StripDateFromTime(SVDate) = @SalesDate And ((IsNull(svabstract.Status,0) & 64) = 0)                   
 And ((IsNull(svabstract.Status,0) & 32) = 0))
 And Dbo.StripDateFromTime(SoDate) <=  Dbo.StripDateFromTime(@SalesDate) 
 And Items.Product_code = SODT.Product_Code                      
 And SODT.Product_Code in ( Select Product_Code From SvDetail Where SvNumber in ( Select SvNumber From SvAbstract Where Salesmancode = WAB.Salesmanid And  SvAbstract.CustomerId = WDT.CustomerId And Dbo.StripDateFromTime(SvDate) = @SalesDate                   
 And ((IsNull(svabstract.Status,0) & 128) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0)))),
--[Ohd Pre]                          
 (Select Count(Product_Code) From svDetail Where SvNumber in (Select SvNumber From SvAbstract Where Customerid = WDT.CustomerID And Dbo.StripDateFromTime(SVDate) = @SalesDate                   
	And svDetail.StockCount > 0 
 And ((IsNull(svabstract.Status,0) & 64) = 0) And ((IsNull(svabstract.Status,0) & 32) = 0) )),
                       
--[OHD Objective]                
 (IsNull((select Isnull(CampaignMaster.Objective,0)                      
 From CampaignMaster, Customer                
 Where Customer.CustomerID = WDT.CustomerId                
 And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                
 And CampaignMaster.Active =1    
 And CampaignMaster.CampaignId = 'C001'),0 )),                
                
--[OHD]                
 (Isnull((Select Sum(Isnull(CampaignDrives.response,0))                                
 From CampaignDrives,sVabstract                              
 Where sVabstract.Customerid = WDT.CustomerId                            
    And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                              
    And sVabstract.Svnumber = CampaignDrives.svnumber                              
    And ((IsNull(svabstract.Status,0) & 64) = 0)                              
    And ((IsNull(svabstract.Status,0) & 32) = 0)                              
    And CampaignDrives.CampaignID =  'C001' ),0)),                              
                
--[Merchandising Sip Objective]                
 (IsNull((select Isnull(CampaignMaster.Objective,0)                              
 From CampaignMaster, Customer                
 Where Customer.CustomerID =  WDT.CustomerId                  
 And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                
 And CampaignMaster.Active =1    
 And CampaignMaster.CampaignId = 'C002'),0)),                
                
--[Merchandising Sip]                
 (Isnull((Select Sum(Isnull(CampaignDrives.response,0))                                
 From CampaignDrives,sVabstract                              
 Where sVabstract.Customerid = WDT.CustomerId                           
    And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                              
    And sVabstract.Svnumber = CampaignDrives.svnumber                              
    And ((IsNull(svabstract.Status,0) & 64) = 0)                              
    And ((IsNull(svabstract.Status,0) & 32) = 0)                 
 And CampaignDrives.CampaignID =  'C002' ),0)),                   
             
--[Merchandising Pos Objective]                
 (IsNull((select Isnull(CampaignMaster.Objective,0)
 From CampaignMaster, Customer                
 Where Customer.CustomerID =  WDT.CustomerId                 
 And Dbo.StripDateFromTime(Todate) >= Dbo.StripDateFromTime(@SalesDate)                
 And CampaignMaster.Active =1    
 And CampaignMaster.CampaignId = 'C003'),0 )),                
                
--[Merchandising Pos]                
  (Isnull((Select Sum(Isnull(CampaignDrives.response,0))                                
 From CampaignDrives,sVabstract                              
 Where sVabstract.Customerid = WDT.CustomerId                            
 And Dbo.StripDateFromTime(sVabstract.svdate) = @SalesDate                 
And sVabstract.Svnumber = CampaignDrives.svnumber                              
 And ((IsNull(svabstract.Status,0) & 64) = 0)                             
 And ((IsNull(svabstract.Status,0) & 32) = 0)                              
 And CampaignDrives.CampaignID = 'C003'),0))                   
                
From WcpAbstract WAb, WcpDetail WDt, Customer CUST,                                      
 Customer_Channel CHNL, SubChannel SCH                
                      
where WAb.Code = WDt.Code                
 And WAb.SalesmanId = @Salesmanid                  
 And WDT.CustomerId = CUST.CustomerId                                      
 And CUST.ChannelType *= CHNL.ChannelType                                    
 And CUST.SubChannelID *= SCH.SubChannelID                               
 And ((IsNull(WAB.Status,0) & 128) = 0)                   
 And ((IsNull(WAB.Status,0) & 32) = 0)
 And Dbo.StripDateFromTime(WDT.WCPDate) = @SalesDate        

Group by   WDT.CustomerID, CHNL.ChannelDesc, SCH.Description, CUST.Company_Name, WAb.SalesmanId                      
                  
Select * From #TmpDailyDet                            
                              
drop table #TmpDailyDet
