CREATE Procedure [dbo].[spr_Cur_Retail_Universe_Detail] (@ProductInfo nVarchar(255),      
       @FromDate Datetime,      
       @ToDate Datetime)      
As      
Declare @ProductHierarchy nVarchar(255)      
Declare @Category nVarchar(255)      
Declare @UOM nVarchar(255)      
Declare @ChannelID int      
Declare @StartPos int      
Declare @NextPos int      
Declare @UOMDescCount int      
Declare @UOMDescription nVarchar(255)      
Declare @UOMFactor Decimal(18,6)      
      
Set @StartPos = CharIndex(N';', @ProductInfo)      
Set @ProductHierarchy = SubString(@ProductInfo, 1, @StartPos - 1)      
Set @NextPos = CharIndex(N';', @ProductInfo, @StartPos + 1)      
Set @Category = SubString(@ProductInfo, @StartPos + 1, @NextPos - @StartPos - 1)      
Set @StartPos = CharIndex(N';', @ProductInfo, @NextPos + 1)      
Set @UOM = SubString(@ProductInfo, @NextPos + 1, @StartPos - @NextPos - 1)      
Set @ChannelID = Cast(SubString(@ProductInfo, @StartPos + 1, Len(@ProductInfo) - @StartPos + 1) As Int)      
Create Table #tempCategory(CategoryID int,      
      Status int)      
Exec dbo.GetLeafCategories @ProductHierarchy, @Category      
  
Create Table #temp(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,      
     InvoiceDate Datetime,      
     InvoiceValue Decimal(18,6))      
Insert Into #temp      
Select Inv.CustomerID, dbo.StripDateFromTime(Inv.InvoiceDate),      
Sum(IsNull(Inv.NetValue, 0) - IsNull(Inv.Freight, 0))       
From InvoiceAbstract As Inv      
Where Inv.InvoiceID In (Select Distinct Inv.InvoiceID       
 From InvoiceAbstract, InvoiceDetail, Items, Customer      
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 InvoiceAbstract.Status & 128 = 0 And      
 InvoiceAbstract.CustomerID = Customer.CustomerID And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And      
 InvoiceDetail.Product_Code = Items.Product_Code And      
 Items.CategoryID In (Select CategoryID From #tempCategory)      
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)) And      
 Inv.InvoiceType In (1, 3, 4) And Inv.Status & 128 = 0       
Group By Inv.CustomerID, dbo.StripDateFromTime(Inv.InvoiceDate)      
  
     
If @UOM = N'Sales UOM'      
Begin      
 Select @UOMDescCount  = Count(Distinct Items.UOM)      
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
 Left Outer Join UOM On Items.UOM = UOM.UOM      
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.Status & 128 = 0 And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 Items.CategoryID In (Select CategoryID From #tempCategory) 
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), Items.UOM      
      
 If @UOMDescCount <= 1       
 Begin      
  Select Top 1 @UOMDescription  = UOM.Description      
  From InvoiceAbstract
  Inner Join  InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join  UOM On Items.UOM = UOM.UOM      
  Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
  InvoiceAbstract.Status & 128 = 0 And      
  InvoiceAbstract.InvoiceType In (1, 3, 4) And      
  IsNull(Customer.ChannelType, 0) = @ChannelID And      
  Items.CategoryID In (Select CategoryID From #tempCategory) 
  Group By InvoiceAbstract.CustomerID,      
  Customer.Company_Name,  
  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), UOM.Description      
 End      
 Else      
 Begin      
  Set @UOMDescription = N''      
 End      
 Select InvoiceAbstract.CustomerID,      
 "CustomerID" = InvoiceAbstract.CustomerID,      
 "Customer" = Customer.Company_Name,      
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity),      
 "Sales UOM" = @UOMDescription,      
      
 "Invoice Value" = (Select InvoiceValue From #temp       
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And      
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),      
      
 "Product Value" = Sum(InvoiceDetail.Amount)      
 From InvoiceAbstract, InvoiceDetail, Items, Customer      
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.Status & 128 = 0 And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 InvoiceAbstract.CustomerID = Customer.CustomerID And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And      
 InvoiceDetail.Product_Code = Items.Product_Code And      
 Items.CategoryID In (Select CategoryID From #tempCategory)      
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)      
 Order By InvoiceAbstract.CustomerID      
End      
Else If @UOM = N'Conversion Factor'      
Begin    
 
SELECT "CustomerID"  = InvAbs.CustomerID, "Quantity" = case when Item.ConversionFactor = 0 then sum(InvDet.Quantity) else sum(invDet.Quantity * Item.ConversionFactor) end INTO #temp1 FROM   
Items Item, Invoiceabstract InvAbs, Invoicedetail InvDet WHERE   
InvDet.InvoiceID = InvAbs.InvoiceID And  
Item.Product_Code = InvDet.Product_Code and  
InvAbs.InvoiceDate Between @FromDate And @ToDate And      
InvAbs.Status & 128 = 0 And      
InvAbs.InvoiceType In (1, 3, 4) 
group by InvAbs.CustomerID, Item.ConversionFactor
  
 Select @UOMDescCount  = Count(Distinct Items.ConversionUnit)      
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join  ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.Status & 128 = 0 And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 Items.CategoryID In (Select CategoryID From #tempCategory)      
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),       
 Items.ConversionUnit   
 If @UOMDescCount <= 1       
 Begin      
  Select Top 1 @UOMDescription  = ConversionTable.ConversionUnit,      
  @UOMFactor = Case IsNull(Items.ConversionFactor, 0)      
  When 0 Then 0 Else IsNull(Items.ConversionFactor, 0) End        
  From InvoiceAbstract
  Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID             
  Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
  InvoiceAbstract.Status & 128 = 0 And      
  IsNull(Customer.ChannelType, 0) = @ChannelID And      
  InvoiceAbstract.InvoiceType In (1, 3, 4) And      
  Items.CategoryID In (Select CategoryID From #tempCategory) 
  Group By InvoiceAbstract.CustomerID,      
  Customer.Company_Name,       
  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),       
  ConversionTable.ConversionUnit,ConversionTable.ConversionUnit,      
  Items.ConversionFactor      
 End      
 Else      
 Begin      
  Set @UOMDescription = N''      
  Set @UOMFactor = 1      
 End      
      
 Select InvoiceAbstract.CustomerID,      
 "CustomerID" = InvoiceAbstract.CustomerID,      
 "Customer" = Customer.Company_Name,      
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
 "Qty Of Purchase" = (SELECT SUM(Quantity) FROM #temp1 WHERE #Temp1.CustomerID = InvoiceAbstract.CustomerID group by #Temp1.CustomerID),
 "Conversion Units" = (SELECT TOP 1 ConTab.ConversionUnit FROM   
Items Item
Inner Join  Invoicedetail InvDet On Item.Product_Code = InvDet.Product_Code
Inner Join Invoiceabstract InvAbs On InvDet.InvoiceID = InvAbs.InvoiceID 
Left Outer Join ConversionTable ConTab  On ConTab.ConversionID = Item.ConversionUnit 
WHERE   
 InvAbs.Status & 128 = 0 And      
 InvAbs.InvoiceType In (1, 3, 4) And  
InvAbs.InvoiceDate Between @FromDate And @ToDate And
InvAbs.CustomerID = InvoiceAbstract.CustomerID order by ConTab.ConversionUnit),      
 "Invoice Value" = (Select InvoiceValue From #temp       
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And      
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),      
      
 "Product Value" = Sum(InvoiceDetail.Amount)      
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID          
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.Status & 128 = 0 And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 Items.CategoryID In (Select CategoryID From #tempCategory)
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,  
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)      
 Order By InvoiceAbstract.CustomerID      
End      
Else If @UOM = N'Reporting UOM'      
Begin      
 Select @UOMDescCount  = Count(Distinct Items.ReportingUOM)      
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join UOM On Items.ReportingUOM = UOM.UOM             
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
 InvoiceAbstract.Status & 128 = 0 And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 Items.CategoryID In (Select CategoryID From #tempCategory) 
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
 Items.ReportingUOM      
      
 If @UOMDescCount <= 1       
 Begin      
  Select  @UOMDescription  = UOM.Description,      
  @UOMFactor = Case IsNull(Items.ReportingUnit, 0)      
  When 0 Then 0 Else IsNull(Items.ReportingUnit, 0) End        
  From InvoiceAbstract
  Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join UOM On Items.ReportingUOM = UOM.UOM             
  Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
  InvoiceAbstract.Status & 128 = 0 And      
  InvoiceAbstract.InvoiceType In (1, 3, 4) And      
  IsNull(Customer.ChannelType, 0) = @ChannelID And      
  Items.CategoryID In (Select CategoryID From #tempCategory)
  Group By InvoiceAbstract.CustomerID,      
Customer.Company_Name,       
  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
  UOM.Description,      
  Items.ReportingUnit      
 End      
 Else      
 Begin      
  Set @UOMDescription = N''      
  Set @UOMFactor = 1      
 End      
 Select InvoiceAbstract.CustomerID,      
 "CustomerID" = InvoiceAbstract.CustomerID,      
 "Customer" = Customer.Company_Name,      
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
 "Qty Of Purchase" =Sum(InvoiceDetail.Quantity) /  @UOMFactor,      
 "Reporting UOM" = @UOMDescription,      
      
 "Invoice Value" = (Select InvoiceValue From #temp       
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And      
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),      
 "Product Value" = Sum(InvoiceDetail.Amount)      
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join UOM On Items.ReportingUOM = UOM.UOM 
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And      
InvoiceAbstract.Status & 128 = 0 And      
 InvoiceAbstract.InvoiceType In (1, 3, 4) And      
 IsNull(Customer.ChannelType, 0) = @ChannelID And      
 Items.CategoryID In (Select CategoryID From #tempCategory)      
 Group By InvoiceAbstract.CustomerID,      
 Customer.Company_Name,       
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)      
 Order By InvoiceAbstract.CustomerID      
End      
Drop Table #tempCategory      
Drop Table #temp      
Drop Table #temp1      


