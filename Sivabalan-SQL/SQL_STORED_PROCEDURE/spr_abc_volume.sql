CREATE PROCEDURE [dbo].[spr_abc_volume]
			      (@Category nvarchar(2550),  
                	       @CusType nvarchar(50),  
                               @FROMDATE DateTime,  
                               @TODATE DateTime,  
                               @AmountA Decimal(18,6),  
                               @AmountB Decimal(18,6),
                               @MesType nvarchar(50),
                               @UOM nvarchar(50))
AS  
  
DECLARE @TOTALSALES Decimal(18, 6)  
Declare @UOMDescription nvarchar(255)
Declare @OTHERCUSTOMER As NVarchar(50)

If @UOM = N'Base UOM' 
	Set @UOM = N'Sales UOM'

Set @OTHERCUSTOMER = dbo.LookupDictionaryItem(N'Other Customer',Default) 

Create Table #tempCategory(CategoryID Int,  Status Int)
Exec GetLeafCategories N'%', @Category
Select Distinct CategoryID InTo #temp1 From #tempCategory

Create Table #temp(  
 CustomerID nvarchar(15),  
 CustomerName nvarchar(150),  
 TotalSales Decimal(18, 6),
 UOMDescription nvarchar(50))  


If IsNull((Select Case @UOM When N'Sales UOM' Then Count(Distinct it.UOM) 
                            When N'UOM1'      Then Count(Distinct it.UOM1)
                            When N'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
           InvoiceAbstract ia, InvoiceDetail ids, #temp1 Where ia.InvoiceID = ids.InvoiceID And
           ids.Product_Code = it.Product_Code And It.CategoryID = #temp1.CategoryID And
           ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0)
           , 0) = 1
Begin
  Select @UOMDescription = IsNull(u.[Description], N'') From UOM u, Items it, 
  InvoiceAbstract ia, InvoiceDetail ids, #temp1 Where 
  u.UOM = (Case @UOM When N'Sales UOM' Then IsNull(it.UOM, 0) 
                     When N'UOM1'      Then IsNull(it.UOM1, 0)
                     When N'UOM2'      Then IsNull(it.UOM2, 0) End) And 
  ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And 
  It.CategoryID = #temp1.CategoryID And
  ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0 

End
Else
Begin
  Set @UOMDescription = N''
End



Insert into #temp  
Select Case IsNull(InvoiceType, N'0') When 2 Then @OTHERCUSTOMER Else IsNull(InvoiceAbstract.CustomerID, N'') End, 
         IsNull(Customer.Company_Name, @OTHERCUSTOMER) , 
Case @MesType When N'Value' Then Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End 
  * Sum(IsNull(Amount, 0))
              When N'Volume' Then Case @UOM When N'Sales UOM' Then 
                Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) 
              When N'UOM1' Then 
                Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / Case When IsNull(UOM1_Conversion, 0) = 0 Then 1 Else UOM1_Conversion End
              When N'UOM2' Then 
                Sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(Quantity, 0)) / Case When IsNull(UOM2_Conversion, 0) = 0 Then 1 Else UOM2_Conversion End End End,
Case @MesType When N'Value' Then N'' 
              When N'Volume' Then @UOMDescription End
From InvoiceAbstract
Inner Join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
left Outer Join Items on InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
Inner Join #temp1 on Items.CategoryID = #temp1.CategoryID
WHERE 
--InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
--InvoiceDetail.Product_Code = Items.Product_Code AND
--InvoiceAbstract.CustomerID *= Customer.CustomerID And
--Items.CategoryID = #temp1.CategoryID AND
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND IsNull(InvoiceType, 0) In 
  (Select Case When @CusType = N'Trade' Then 1 End Union Select Case When @CusType = N'Trade' Then 3 End
  Union Select Case When @CusType = N'Trade' Then 4 End Union Select Case When @CusType = N'Retailer' 
  Then  2 End) AND IsNull(Status, 0) & 192 = 0
  Group By InvoiceAbstract.CustomerID, Customer.Company_Name, InvoiceType,
  Items.UOM, Items.UOM1, Items.UOM2, Items.UOM1_Conversion, Items.UOM2_Conversion

Select CustomerID, CustomerID, "Customer" = CustomerName, 
  "Total Sales" = Sum(TotalSales),  
  "UOM Description" = @UOMDescription,
  "Classification" = case  
  when Sum(TotalSales) >= @AmountA then  
  N'A'  
  when Sum(TotalSales) >= @AmountB And Sum(TotalSales) <= @AmountA then  
  N'B'  
  else  
  N'C'  
  end  
From #temp Group By CustomerID, CustomerName, UOMDescription
Order By "Classification"  

Drop table #temp  
Drop table #tempCategory  
Drop table #temp1  

