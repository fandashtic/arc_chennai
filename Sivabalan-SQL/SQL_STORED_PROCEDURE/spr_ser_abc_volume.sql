CREATE procedure [dbo].[spr_ser_abc_volume]
			      (@Category varchar(2550),  
                	       @CusType Varchar(50),  
                               @FROMDATE DateTime,  
                               @TODATE DateTime,  
                               @AmountA Decimal(18,6),  
                               @AmountB Decimal(18,6),
                               @MesType VarChar(50),
                               @UOM VarChar(255))
AS  
  
DECLARE @TOTALSALES Decimal(18, 6)  
Declare @UOMDescription VarChar(255)

Create Table #tempCategory(CategoryID Int,  Status Int)
Exec sp_ser_GetLeafCategories '%', @Category
Select Distinct CategoryID InTo #temp1 From #tempCategory

Create Table #temp(  
 CustomerID varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 CustomerName Varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 TotalSales Decimal(18, 6),
 UOMDescription VarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  


If IsNull((Select Case @UOM When 'Sales UOM' Then Count(Distinct it.UOM) 
                            When 'UOM1'      Then Count(Distinct it.UOM1)
                            When 'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
           InvoiceAbstract ia, InvoiceDetail ids, #temp1 Where ia.InvoiceID = ids.InvoiceID And
           ids.Product_Code = it.Product_Code And It.CategoryID = #temp1.CategoryID And
           ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0)
           , 0) = 1
Begin
  Select @UOMDescription = IsNull(u.[Description], '') From UOM u, Items it, 
  InvoiceAbstract ia, InvoiceDetail ids, #temp1 Where 
  u.UOM = (Case @UOM When 'Sales UOM' Then IsNull(it.UOM, 0) 
                     When 'UOM1'      Then IsNull(it.UOM1, 0)
                     When 'UOM2'      Then IsNull(it.UOM2, 0) End) And 
  ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And 
  It.CategoryID = #temp1.CategoryID And
  ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0 

End
Else
Begin
  Set @UOMDescription = ''
End


If IsNull((Select Case @UOM When 'Sales UOM' Then Count(Distinct it.UOM) 
                            When 'UOM1'      Then Count(Distinct it.UOM1)
                            When 'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
           ServiceInvoiceAbstract isa, ServiceInvoiceDetail isds, #temp1 Where isa.ServiceInvoiceID = isds.ServiceInvoiceID And
           isds.spareCode = it.Product_Code And It.CategoryID = #temp1.CategoryID And
           isa.ServiceInvoiceDate Between @FromDate And @ToDate And IsNull(isa.Status, 0) & 192 = 0), 0) = 1
Begin
  Select @UOMDescription = IsNull(u.[Description], '') From UOM u, Items it, 
  ServiceInvoiceAbstract isa, ServiceInvoiceDetail isds, #temp1 Where 
  u.UOM = (Case @UOM When 'Sales UOM' Then IsNull(it.UOM, 0) 
                     When 'UOM1'      Then IsNull(it.UOM1, 0)
                     When 'UOM2'      Then IsNull(it.UOM2, 0) End) And 
  isa.ServiceInvoiceID = isds.ServiceInvoiceID And isds.spareCode = it.Product_Code And 
  It.CategoryID = #temp1.CategoryID And
  isa.ServiceInvoiceDate Between @FromDate And @ToDate And IsNull(isa.Status, 0) & 192 = 0 

End
Else
Begin
  Set @UOMDescription = ''
End


Insert into #temp  
Select Case IsNull(InvoiceType, '0') 
When 2 Then 'Other Customer' 
Else IsNull(InvoiceAbstract.CustomerID, '') End, 

IsNull(Customer.Company_Name, 'Other Customer') , 
Case @MesType When 'Value' Then Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End 
* Sum(IsNull(Amount, 0))
When 'Volume' Then Case @UOM When 'Sales UOM' Then 
Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) 
When 'UOM1' Then 
Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / Case When IsNull(UOM1_Conversion, 0) = 0 Then 1 Else UOM1_Conversion End
When 'UOM2' Then 
Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / Case When IsNull(UOM2_Conversion, 0) = 0 Then 1 Else UOM2_Conversion End End End,

Case @MesType When 'Value' Then '' 
When 'Volume' Then @UOMDescription End
From InvoiceAbstract,
Customer, InvoiceDetail, Items, #temp1 
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code AND
InvoiceAbstract.CustomerID *= Customer.CustomerID And
Items.CategoryID = #temp1.CategoryID AND
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND IsNull(InvoiceType, 0) In 
  (Select Case When @CusType = 'Trade' Then 1 End Union Select Case When @CusType = 'Trade' Then 3 End
  Union Select Case When @CusType = 'Trade' Then 4 End Union Select Case When @CusType = 'Retailer' 
  Then  2 End) AND IsNull(Status, 0) & 192 = 0
  Group By InvoiceAbstract.CustomerID, Customer.Company_Name, InvoiceType,
  Items.UOM, Items.UOM1, Items.UOM2, Items.UOM1_Conversion, Items.UOM2_Conversion


--insert into #Temp



Insert into #temp  
Select Case IsNull(ServiceInvoiceType, '0') 
When 2 Then 'Other Customer' 
Else IsNull(ServiceInvoiceAbstract.CustomerID, '') End, 

IsNull(Customer.Company_Name, 'Other Customer') , 
Case @MesType When 'Value' Then Case IsNull(ServiceInvoiceType, 0) When 1 then 1 else 1 End 
* Sum(IsNull(serviceinvoicedetail.NetValue, 0))
When 'Volume' Then Case @UOM When 'Sales UOM' Then 
Sum(Case IsNull(ServiceInvoiceType, 0) When 1 Then 1 Else 1 End * IsNull(Serviceinvoicedetail.Quantity, 0)) 
When 'UOM1' Then 
Sum(Case IsNull(ServiceInvoiceType, 0) When 1 Then 1 Else 1 End * IsNull(Serviceinvoicedetail.Quantity, 0)) / Case When IsNull(UOM1_Conversion, 0) = 0 Then 1 Else UOM1_Conversion End
When 'UOM2' Then 
Sum(Case IsNull(ServiceInvoiceType, 0) When 4 Then 1 Else 1 End * IsNull(Serviceinvoicedetail.Quantity, 0)) / Case When IsNull(UOM2_Conversion, 0) = 0 Then 1 Else UOM2_Conversion End End End,

Case @MesType When 'Value' Then '' 
When 'Volume' Then @UOMDescription End
From ServiceInvoiceAbstract,
Customer, ServiceInvoiceDetail, Items, #temp1 
WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND
ServiceInvoiceDetail.spareCode = Items.Product_Code AND
ServiceInvoiceAbstract.CustomerID *= Customer.CustomerID And
isnull(sparecode,'')<>'' and
Items.CategoryID = #temp1.CategoryID AND
ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE AND IsNull(ServiceInvoiceType, 0) In 
  (Select Case When @CusType = 'Trade' Then 1 End Union Select Case When @CusType = 'Trade' Then 3 End
  Union Select Case When @CusType = 'Trade' Then 4 End Union Select Case When @CusType = 'Retailer' 
  Then  2 End) AND IsNull(Status, 0) & 192 = 0
  Group By ServiceInvoiceAbstract.CustomerID, Customer.Company_Name, ServiceInvoiceType,
  Items.UOM, Items.UOM1, Items.UOM2, Items.UOM1_Conversion, Items.UOM2_Conversion

Select CustomerID, CustomerID, "Customer" = CustomerName, 
  "Total Sales" = Sum(TotalSales),  
  "UOM Description" = @UOMDescription,
  "Classification" = case  
  when Sum(TotalSales) >= @AmountA then  
  'A'  
  when Sum(TotalSales) >= @AmountB And Sum(TotalSales) <= @AmountA then  
  'B'  
  else  
  'C'  
  end  
From #temp Group By CustomerID, CustomerName, UOMDescription
Order By "Classification"  

Drop table #temp  
Drop table #tempCategory  
Drop table #temp1
