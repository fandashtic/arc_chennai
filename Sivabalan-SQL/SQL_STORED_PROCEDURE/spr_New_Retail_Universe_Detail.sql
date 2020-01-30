CREATE procedure [dbo].[spr_New_Retail_Universe_Detail] (@ProductInfo nvarchar(255),    
       @ComFromDate Datetime,    
       @ComToDate Datetime)    
As    
Declare @ProductHierarchy nvarchar(255)    
Declare @Category nvarchar(2550)    
Declare @UOM nvarchar(255)    
Declare @ChannelID int    
Declare @StartPos int    
Declare @NextPos int    
Declare @RefFromDate Datetime    
Declare @RefToDate Datetime    
Declare @UOMDescCount int    
Declare @UOMDescription nvarchar(255)    
Declare @UOMFactor Decimal(18,6)    
    
Set @StartPos = CharIndex(N';', @ProductInfo)    
Set @ProductHierarchy = SubString(@ProductInfo, 1, @StartPos - 1)    
Set @NextPos = CharIndex(N';', @ProductInfo, @StartPos + 1)    
Set @Category = SubString(@ProductInfo, @StartPos + 1, @NextPos - @StartPos - 1)    
Set @StartPos = CharIndex(N';', @ProductInfo, @NextPos + 1)    
Set @UOM = SubString(@ProductInfo, @NextPos + 1, @StartPos - @NextPos - 1)    
Set @NextPos = CharIndex(N';', @ProductInfo, @StartPos + 1)    
Set @RefFromDate = Cast(SubString(@ProductInfo, @StartPos + 1, @NextPos - @StartPos - 1) As DateTime)    
Set @StartPos = CharIndex(N';', @ProductInfo, @NextPos + 1)    
Set @RefToDate = Cast(SubString(@ProductInfo, @NextPos + 1, @StartPos - @NextPos - 1) As DateTime)    
Set @ChannelID = Cast(SubString(@ProductInfo, @StartPos + 1, Len(@ProductInfo) - @StartPos + 1) As Int)    
Create Table #tempCategory(CategoryID int,    
      Status int)    
Exec dbo.GetLeafCategories @ProductHierarchy, @Category    
    
Create Table #temp(CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
     InvoiceDate Datetime,    
     InvoiceValue Decimal(18,6))    
Insert Into #temp    
Select Inv.CustomerID, dbo.StripDateFromTime(Inv.InvoiceDate),    
Sum(IsNull(Inv.NetValue, 0) - IsNull(Inv.Freight, 0))     
From InvoiceAbstract As Inv    
Where Inv.InvoiceID In (Select Distinct Inv.InvoiceID     
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
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
 Inv.InvoiceType In (1, 3, 4)    
Group By Inv.CustomerID, dbo.StripDateFromTime(Inv.InvoiceDate)    
    
If @UOM = N'Sales UOM'    
Begin    
 Select @UOMDescCount  = Count(Distinct Items.UOM)    
 From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory) And    
 Items.UOM *= UOM.UOM    
 Group By InvoiceAbstract.CustomerID,    
 Customer.Company_Name,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), Items.UOM    
    
 If @UOMDescCount <= 1     
 Begin    
  Select Top 1 @UOMDescription  = UOM.Description    
  From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM    
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
  InvoiceAbstract.Status & 128 = 0 And    
  InvoiceAbstract.CustomerID = Customer.CustomerID And    
  InvoiceAbstract.InvoiceType In (1, 3, 4) And    
  IsNull(Customer.ChannelType, 0) = @ChannelID And    
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And 
 InvoiceDetail.Product_Code = Items.Product_Code And    
  Items.CategoryID In (Select CategoryID From #tempCategory) And    
  Items.UOM *= UOM.UOM    
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
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory) And    
     
 InvoiceAbstract.CustomerID Not In (Select Distinct InvoiceAbstract.CustomerID    
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory)    
 Group By InvoiceAbstract.CustomerID)    
 Group By InvoiceAbstract.CustomerID,    
 Customer.Company_Name,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)    
 Order By InvoiceAbstract.CustomerID    
End    
Else If @UOM = N'Conversion Factor'    
Begin    
 Select @UOMDescCount  = Count(Distinct Items.ConversionUnit)    
 From InvoiceAbstract, InvoiceDetail, Items, Customer, ConversionTable    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.ConversionUnit *= ConversionTable.ConversionID And    
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
  From InvoiceAbstract, InvoiceDetail, Items, Customer, ConversionTable    
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
  InvoiceAbstract.Status & 128 = 0 And    
  InvoiceAbstract.InvoiceType In (1, 3, 4) And    
  InvoiceAbstract.CustomerID = Customer.CustomerID And    
  IsNull(Customer.ChannelType, 0) = @ChannelID And    
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
  InvoiceDetail.Product_Code = Items.Product_Code And    
  Items.CategoryID In (Select CategoryID From #tempCategory) And    
  Items.ConversionUnit *= ConversionTable.ConversionID    
  Group By InvoiceAbstract.CustomerID,    
  Customer.Company_Name,     
  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),     
  ConversionTable.ConversionUnit,    
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
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) * @UOMFactor,    
 "Conversion Unit" = @UOMDescription,    
 "Invoice Value" = (Select InvoiceValue From #temp     
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And    
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),    
    
 "Product Value" = Sum(InvoiceDetail.Amount)    
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory) And    
     
 InvoiceAbstract.CustomerID Not In (Select Distinct InvoiceAbstract.CustomerID    
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory)    
 Group By InvoiceAbstract.CustomerID)    
 Group By InvoiceAbstract.CustomerID,    
 Customer.Company_Name,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)    
 Order By InvoiceAbstract.CustomerID    
End    
Else If @UOM = N'Reporting UOM'    
Begin    
 Select @UOMDescCount  = Count(Distinct Items.ReportingUOM)    
 From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory) And    
 Items.ReportingUOM *= UOM.UOM    
 Group By InvoiceAbstract.CustomerID,    
 Customer.Company_Name,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 Items.ReportingUOM    
    
 If @UOMDescCount <= 1     
 Begin    
  Select Top 1 @UOMDescription  = UOM.Description,    
  @UOMFactor = Case IsNull(Items.ReportingUnit, 0)    
  When 0 Then 0 Else IsNull(Items.ReportingUnit, 0) End      
  From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM    
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
  InvoiceAbstract.Status & 128 = 0 And    
  InvoiceAbstract.InvoiceType In (1, 3, 4) And    
  InvoiceAbstract.CustomerID = Customer.CustomerID And    
  IsNull(Customer.ChannelType, 0) = @ChannelID And    
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
InvoiceDetail.Product_Code = Items.Product_Code And    
  Items.CategoryID In (Select CategoryID From #tempCategory) And    
  Items.ReportingUOM *= UOM.UOM    
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
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) / @UOMFactor,    
 "Reporting UOM" = @UOMDescription,    
 "Invoice Value" = (Select InvoiceValue From #temp     
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And    
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),    
    
 "Product Value" = Sum(InvoiceDetail.Amount)    
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory) And    
     
 InvoiceAbstract.CustomerID Not In (Select Distinct InvoiceAbstract.CustomerID    
 From InvoiceAbstract, InvoiceDetail, Items, Customer    
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 InvoiceAbstract.InvoiceType In (1, 3, 4) And    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 IsNull(Customer.ChannelType, 0) = @ChannelID And    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
 InvoiceDetail.Product_Code = Items.Product_Code And    
 Items.CategoryID In (Select CategoryID From #tempCategory)    
 Group By InvoiceAbstract.CustomerID)    
 Group By InvoiceAbstract.CustomerID,    
 Customer.Company_Name,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)    
 Order By InvoiceAbstract.CustomerID    
End    
Drop Table #tempCategory    
Drop Table #temp
