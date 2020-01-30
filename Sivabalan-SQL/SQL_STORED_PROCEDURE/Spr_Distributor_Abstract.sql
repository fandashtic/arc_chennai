CREATE Procedure Spr_Distributor_Abstract (@HierarchyName nVarchar(255),                                       
 @Category nvarchar(255), @Channel nvarchar(255),@UOM nVarchar(50),                                      
 @FromDate Datetime, @Todate DateTime) as                                      
                                      
Declare @Delimeter as Char(1)                                              
Set @Delimeter=Char(15)                                      
                    
Set @FromDate= dbo.StripDateFromTime(@FromDate)                    
Set @Todate= dbo.StripDateFromTime(@Todate)                    
                    
Create Table #TempCategory(CategoryID int,Status int)  --Table Used for Product hierachy Filter                                                              
Exec dbo.GetLeafCategories @HierarchyName, @Category  -- Stores CategoryID to Temp Table #tempCategory                                                
Select Distinct CategoryID INTO #Temp From #TempCategory                                      
                                      
Create Table #TmpChannel( ChannelType nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS)              
Insert into #TmpChannel(ChannelType) Values('')
if @Channel ='%'  
   Insert into #TmpChannel select ChannelType from customer
Else                      
   Insert into #TmpChannel Select ChannelType From customer_channel Where ChannelDesc In (select * from dbo.sp_SplitIn2Rows(@Channel,@Delimeter))                      
                      
Create Table #TmpDistribut(Product_code nVarchar(15),[Item Code] nVarchar(15), [Item Name] nVarchar(250),[Sales Quantity] Decimal(18,6),[Sales Value] Decimal(18,6),                      
[Available At] Bigint,[% Dist On Active Reach] Decimal(18,6),[% Called Reach] Decimal(18,6), [% Productive Reach] Decimal(18,6))                      
                      
Insert into #TmpDistribut(Product_code,[Item Code],[Item Name],[Sales Quantity],[Sales Value],                       
[Available At],[% Dist On Active Reach],[% Called Reach], [% Productive Reach])                      
                      
Select IT.Product_Code,IT.Product_Code, It.ProductName ,                                      
--Sales Quantity                      
(                                    
 case @UOM                                          
   when 'Conversion Factor' then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end) * (case when isnull(IT.conversionfactor,0)=0 then 1            
   else IT.conversionfactor end)),0)                                                  
   when 'Reporting UOM'     then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end)                                 
/ (case when isnull(IT.reportingunit,0)=0  then 1  else IT.reportingunit end)),0)                                                  
   When 'UOM 1'             then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end)                                 
/ (Case when isnull(IT.uom1_conversion,0)=0  then 1  else IT.uom1_conversion end)),0)                                                  
   when 'UOM 2'             then isnull(sum((case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end)                                
/ (case when isnull(IT.uom2_conversion,0)=0 then 1 else IT.uom2_conversion end)),0)                                                  
   else isnull(sum( case invoicetype when 4 then (0 - (INVDT.Quantity))when 5 then (0 - (INVDT.Quantity))when 6 then (0 - (INVDT.Quantity)) else (INVDT.Quantity) end),0)  end),                                      
--Sales Value                      
  SUM(Case When INVAB.InvoiceType In (4,5,6) Then (0 - INVDT.Amount) Else INVDT.Amount End),                
         
--Available At                      
	Count(Distinct INVAB.CustomerID),
                     
--% Distribution On Active Reach                
 (( Select cast(Count(Distinct(CustomerID))as decimal(18,6)) From SvAbstract Where SvNumber in(Select svnumber From SvDetail Where StockCount >0 And Product_Code = IT.Product_Code) And dbo.StripDateFromTime(SvDate) >=@FromDate        
 And dbo.StripDateFromTime(SvDate) <= @Todate)                 
/ (Select Case cast(Count(Distinct(CustomerID))as decimal(18,6)) When 0  Then 1 Else cast(Count(Distinct(CustomerID))as decimal(18,6)) End From Customer Where CustomerCategory <>4 And customerCategory <>5 And Active=1)) * 100,                                      
                     
--% Called Reach                      
((Select cast(Count(Distinct(CustomerID))as decimal(18,6)) From SvAbstract Where SvNumber  in(Select svnumber From SvDetail Where StockCount >0 )And dbo.StripDateFromTime(SvDate) >=@FromDate And dbo.StripDateFromTime(SvDate) < =@Todate)            
/ (Select Case cast(Count(Distinct(CustomerID))as decimal(18,6)) When 0  Then 1 Else cast(Count(Distinct(CustomerID))as decimal(18,6)) End From Customer Where CustomerCategory <>4 And customerCategory <>5 And Active=1)) * 100,                                                          

--Percentage Productive Reach                      
((Select cast(Count(Distinct(CustomerID))as decimal(18,6)) From Invoiceabstract  Where InvoiceID in (Select InvoiceID From InvoiceDetail Where Product_code = IT.Product_Code) And dbo.StripDateFromTime(InvoiceDate) >= @FromDate                     
And dbo.StripDateFromTime(InvoiceDate) <= @Todate And IsNull(Invoiceabstract.Status,0) & 192 = 0)                                
/(
Select 
	Case Count(Distinct(CustomerID))
		When 0 Then 1 
		Else cast(Count(Distinct(CustomerID))as decimal(18,6))
	End
From SvAbstract Where SvNumber in  (Select svnumber From SvDetail Where StockCount >0 )         
 And ((IsNull(svabstract.Status,0) & 64) = 0)  And ((IsNull(svabstract.Status,0) & 32) = 0)   And dbo.StripDateFromTime(SvDate) >=@FromDate And dbo.StripDateFromTime(SvDate) <= @Todate)*100)                                      
                                    
From Invoiceabstract INVAB , InvoiceDetail INVDT , Items IT , #Temp, Customer Cust
Where INVAB.InvoiceID = INVDT.InvoiceID                                        
And INVDT.Product_code = IT.Product_code                                        
AND  (ISNULL(INVAB.Status,0) & 128) = 0                 
And dbo.StripDateFromTime(INVAB.InvoiceDate) >= @FromDate                                       
And dbo.StripDateFromTime(INVAB.InvoiceDate) <= @Todate                                      
And IT.Categoryid = #Temp.CategoryID                                     
And INVAB.CustomerID = CUST.CustomerID                                      
And Cust.CustomerCategory <>4                                       
And Cust.customerCategory <>5                                      
And IsNull(CUST.ChannelType,'') In (Select ChannelType collate SQL_Latin1_General_CP1_CI_AS From #TmpChannel)              
group by IT.Product_code, It.ProductName
                                      
Select * from #TmpDistribut                      
Drop Table #TmpDistribut                      
Drop Table #TempCategory                                      
Drop Table #Temp
Drop Table #TmpChannel

