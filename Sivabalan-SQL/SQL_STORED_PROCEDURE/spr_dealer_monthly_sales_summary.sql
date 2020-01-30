CREATE procedure spr_dealer_monthly_sales_summary (@Hier nvarchar(255),
												   @Category nvarchar(2550),
												   @Customer nvarchar(2550),
--												   @City nvarchar(2550),
												   @Channel nvarchar(2550),
												   @Beat nvarchar(2550),
												   @UOM nvarchar(100),
												   @FromDate DateTime,
												   @ToDate DateTime)

As        

Declare @Delimeter as Char(1)  
Declare @FiscalYear Int
Declare @FiscalYear1 Int
Declare @i Int
Declare @VarMonth nvarchar(255)
Declare @UpdTab nvarchar(4000)
Declare @City nvarchar(2500)
Set @City = '%'
Set @Delimeter=Char(15)  
--Create table #tmpCat(CategoryName nvarchar(255))  
Create table #tmpCus(Customer nvarchar(255))
Create table #tmpCity(City nvarchar(255))
Create table #tmpChnl(Channel nvarchar(255))
Create table #tmpBeat(BeatName nvarchar(255))  

Create Table #tempCategory (CategoryID Int, Status Int)

Exec getleafcategories @Hier, @Category

Select Distinct CategoryID InTo #tmpC From #tempCategory
  
If @Customer = '%'  
   Insert InTo #tmpCus Select Company_Name From Customer
Else  
   Insert InTo #tmpCus Select * From dbo.sp_SplitIn2Rows(@Customer, @Delimeter)  

If @City = '%'  
   Insert InTo #tmpCity Select CityName From City
Else  
   Insert InTo #tmpCity Select * From dbo.sp_SplitIn2Rows(@City, @Delimeter)  

If @Channel = '%'
   Insert InTo #tmpChnl Select ChannelDesc From Customer_Channel
Else  
   Insert InTo #tmpChnl Select * From dbo.sp_SplitIn2Rows(@Channel, @Delimeter)

If @Beat = '%'  
   Insert InTo #tmpBeat Select [Description] From Beat  
Else  
   Insert InTo #tmpBeat Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter)  


Create Table #temp1 (CategoryID Int, CategoryName nvarchar(255), InvMonth Int, 
	NetValue Decimal(18,6))

Create Table #ccb (CustomerID nvarchar(255), CustomerName nvarchar(255))

If @City = '%' And @Beat != '%'
Begin
Insert InTo #ccb 
	Select Distinct inva.CustomerID, cus.Company_Name From 
	InvoiceAbstract inva LEFT JOIN Customer cus ON inva.CustomerID = cus.CustomerID 
	LEFT JOIN Customer_Channel cch ON cus.ChannelType = cch.ChannelType 
	LEFT JOIN  City ct ON cus.CityID = ct.CityID LEFT JOIN Beat_Salesman bs 
	ON cus.CustomerID = bs.CustomerID LEFT JOIN Beat bt ON bs.BeatID = bt.BeatId Where
	cus.Company_Name In (Select Customer From #tmpCus) And ct.CityName Like '%'
	And bt.[Description] In 
	(Select BeatName From #tmpBeat) And cch.ChannelDesc In (Select Channel From #tmpChnl)

End
Else If @City != '%' And @Beat = '%'
Begin
Insert InTo #ccb 
	Select Distinct inva.CustomerID, cus.Company_Name From 
	InvoiceAbstract inva LEFT JOIN Customer cus ON inva.CustomerID = cus.CustomerID 
	LEFT JOIN Customer_Channel cch ON cus.ChannelType = cch.ChannelType 
	LEFT JOIN  City ct ON cus.CityID = ct.CityID LEFT JOIN Beat_Salesman bs 
	ON cus.CustomerID = bs.CustomerID LEFT JOIN Beat bt ON bs.BeatID = bt.BeatId Where
	cus.Company_Name In (Select Customer From #tmpCus) And ct.CityName In 
	(Select City From #tmpCity) And bt.[Description] Like '%' 
	And cch.ChannelDesc In (Select Channel From #tmpChnl)

End
Else If @City = '%' And @Beat = '%'
Begin
Insert InTo #ccb 
	Select Distinct inva.CustomerID, cus.Company_Name From 
	InvoiceAbstract inva LEFT JOIN Customer cus ON inva.CustomerID = cus.CustomerID 
	LEFT JOIN Customer_Channel cch ON cus.ChannelType = cch.ChannelType 
	LEFT JOIN  City ct ON cus.CityID = ct.CityID LEFT JOIN Beat_Salesman bs 
	ON cus.CustomerID = bs.CustomerID LEFT JOIN Beat bt ON bs.BeatID = bt.BeatId Where
	cus.Company_Name In (Select Customer From #tmpCus) And ct.CityName Like '%' And
	bt.[Description] Like '%' And cch.ChannelDesc In (Select Channel From #tmpChnl)

End
Else
Begin
Insert InTo #ccb 
	Select Distinct inva.CustomerID, cus.Company_Name From 
	InvoiceAbstract inva LEFT JOIN Customer cus ON inva.CustomerID = cus.CustomerID
	LEFT JOIN Customer_Channel cch ON cus.ChannelType = cch.ChannelType  
	LEFT JOIN  City ct ON cus.CityID = ct.CityID LEFT JOIN Beat_Salesman bs 
	ON cus.CustomerID = bs.CustomerID LEFT JOIN Beat bt ON bs.BeatID = bt.BeatId Where
	cus.Company_Name In (Select Customer From #tmpCus) And ct.CityName In 
	(Select City From #tmpCity) And bt.[Description] In 
	(Select BeatName From #tmpBeat) And cch.ChannelDesc In (Select Channel From #tmpChnl)
	

End

--Select * From #ccb

Insert InTo #temp1    
	Select  its.CategoryID, 
		    itc.Category_Name,
            Month(inva.InvoiceDate),
            Case @UOM When 'Base UOM' Then Sum((Case inva.InvoiceType When 4 Then 0 - invd.Quantity Else invd.Quantity End))
					  When 'Conversion Factor' Then Sum((Case inva.InvoiceType When 4 Then 0 - invd.Quantity Else invd.Quantity End) * its.ConversionFactor)
					  Else Case @UOM When 'UOM 1' Then Sum((Case inva.InvoiceType When 4 Then 0 - invd.Quantity Else invd.Quantity End) / (Case IsNull(its.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM1_Conversion, 1) End))
						             When 'UOM 2' Then Sum((Case inva.InvoiceType When 4 Then 0 - invd.Quantity Else invd.Quantity End) / (Case IsNull(its.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM2_Conversion, 1) End))
									 When 'Reporting UOM' Then Sum((Case inva.InvoiceType When 4 Then 0 - invd.Quantity Else invd.Quantity End) / (Case IsNull(its.ReportingUnit, 1) When 0 Then 1 Else IsNull(its.ReportingUnit, 1) End)) End End
	From InvoiceAbstract inva, Invoicedetail invd, Items its, #ccb, #tmpC, ItemCategories itc
	Where  inva.InvoiceID = invd.InvoiceID And    
       inva.CustomerID = #ccb.CustomerID And
       its.Product_code = invd.Product_code And
       its.CategoryID = #tmpC.categoryid And
	   its.CategoryID = itc.CategoryID And
       (inva.Status & 192) = 0  And    
	   inva.InvoiceDate Between @FromDate And @ToDate
	Group By Month(inva.InvoiceDate), its.CategoryID, itc.Category_Name,
		inva.InvoiceType

Select Top 1 @FiscalYear = IsNull(FiscalYear, 1) From Setup
Set @FiscalYear1 = @FiscalYear

Create Table #Months ([ID] Int, Months nvarchar(255))

Insert InTo #Months Values (1, 'January')
Insert InTo #Months Values (2, 'February')
Insert InTo #Months Values (3, 'March')
Insert InTo #Months Values (4, 'April')
Insert InTo #Months Values (5, 'May')
Insert InTo #Months Values (6, 'June')
Insert InTo #Months Values (7, 'July')
Insert InTo #Months Values (8, 'August')
Insert InTo #Months Values (9, 'September')
Insert InTo #Months Values (10, 'October')
Insert InTo #Months Values (11, 'November')
Insert InTo #Months Values (12, 'December')

Create Table #temp2 (CategoryID nvarchar(255), CategoryName nvarchar(255))

Set @i = 1

While @i <= 12
Begin
	Select @VarMonth = Months From #Months Where [ID] = @FiscalYear
	Set @UpdTab = 'Alter Table #temp2 Add [' + @VarMonth + '] Decimal (18, 6)'
	Exec sp_executesql @UpdTab
	Set @FiscalYear = @FiscalYear + 1
	If @FiscalYear > 12 Set @FiscalYear = 1
	Set @i = @i + 1
End
     
Insert InTo #temp2    

Select Distinct CategoryID, CategoryName, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 From #temp1    
Declare @CustID nvarchar(255)     
Declare @Inv_month int    
Declare @Net_Volume Decimal(18,6)    
Declare @Jan Decimal(18,6),  @Feb Decimal(18,6), @Mar Decimal(18,6), @Apr Decimal(18,6) 
Declare  @May Decimal(18,6), @Jun Decimal(18,6), @Jul Decimal(18,6), @Aug Decimal(18,6)
Declare  @Sep Decimal(18,6), @Oct Decimal(18,6), @Nov Decimal(18,6), @Dec Decimal(18,6)

Declare cust_cursor Cursor For Select CategoryID, InvMonth, NetValue From #temp1  
Open cust_cursor    
Fetch Next From cust_cursor InTo @CustID , @Inv_month, @Net_Volume    
While @@Fetch_STATUS = 0    
Begin    
 set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0     
 set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0    
 if @Inv_month =  1  set @Jan = @Net_Volume     
 if @Inv_month =  2  set @Feb = @Net_Volume    
 if @Inv_month =  3  set @Mar = @Net_Volume    
 if @Inv_month =  4  set @Apr = @Net_Volume    
 if @Inv_month =  5  set @May = @Net_Volume    
 if @Inv_month =  6  set @Jun = @Net_Volume    
    
 if @Inv_month =  7  set @Jul = @Net_Volume    
 if @Inv_month =  8  set @Aug = @Net_Volume    
 if @Inv_month =  9  set @Sep = @Net_Volume    
 if @Inv_month =  10  set @Oct = @Net_Volume    
 if @Inv_month =  11  set @Nov = @Net_Volume    
 if @Inv_month =  12  set @Dec = @Net_Volume 
   
 UpDate #temp2 set January = isnull(January,0) + @Jan , 
 	February = isnull(February,0) + @Feb , March = isnull(March,0) + @Mar, 
	April = isnull(April,0) + @Apr, May = isnull(May,0) + @May, 
	June = isnull(June,0) + @Jun, July = isnull(July,0) + @Jul, 
	August = isnull(August,0) + @Aug, September = isnull(September, 0) + @Sep, 
	October = isnull(October,0) + @Oct, November = isnull(November,0) + @Nov, 
	December = isnull(December,0) + @Dec    
 Where CategoryID = @CustID
 set @Jan = 0  set @Feb = 0  set @Mar = 0 set @Apr = 0 set @May = 0 set @Jun = 0     
 set @Jul = 0 set @Aug = 0 set @Sep = 0 set @Oct = 0 set @Nov = 0 set @Dec = 0    
 Fetch Next From cust_cursor into @CustID , @Inv_month, @Net_Volume    
End    
select * from #temp2    
close cust_cursor    
Deallocate cust_cursor    

Drop Table #tmpCus
Drop Table #tmpCity
Drop Table #tmpChnl
Drop Table #tmpBeat
Drop Table #tempCategory
Drop Table #temp1
Drop Table #ccb
Drop Table #Months
Drop Table #temp2


