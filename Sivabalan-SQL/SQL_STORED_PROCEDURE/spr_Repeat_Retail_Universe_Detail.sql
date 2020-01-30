CREATE procedure [dbo].[spr_Repeat_Retail_Universe_Detail] (@ProductInfo nVarchar(255),  
       @ComFromDate Datetime,  
       @ComToDate Datetime)  
As  
Declare @ProductHierarchy nVarchar(255)  
Declare @Category nVarchar(2550)  
Declare @UOM nVarchar(255)  
Declare @ChannelID int  
Declare @StartPos int  
Declare @NextPos int  
Declare @RefFromDate Datetime  
Declare @RefToDate Datetime  
Declare @UOMDescCount int  
Declare @UOMDescription nVarchar(255)  
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
  
Create Table #temp1(CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Customer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
FirstDate Datetime,  
FirstQty Decimal(18, 6))  
Create Table #temp2(CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Customer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
SecondDate Datetime,  
SecondQty Decimal(18, 6))  
Create Table #temp(ID Int Identity,  
CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Customer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
FirstDate Datetime Null,  
FirstQty Decimal(18, 6) Null,  
SecondDate Datetime Null,  
SecondQty Decimal(18, 6) Null)  
  
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
  InvoiceAbstract.InvoiceType In (1, 3, 4) And  
  InvoiceAbstract.CustomerID = Customer.CustomerID And  
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
   
 Insert Into #temp1(CustomerID, Customer, FirstDate, FirstQty)  
 Select InvoiceAbstract.CustomerID,  
 Customer.Company_Name,  
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 Sum(InvoiceDetail.Quantity)  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
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
  
 Insert Into #temp2(CustomerID, Customer, SecondDate, SecondQty)  
 Select InvoiceAbstract.CustomerID,  
 Customer.Company_Name,  
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 Sum(InvoiceDetail.Quantity)  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
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
  
 Insert Into #temp1(CustomerID, Customer, FirstDate, FirstQty)  
 Select InvoiceAbstract.CustomerID,  
 "Customer" = Customer.Company_Name,  
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) * @UOMFactor  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
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
  
 Insert Into #temp2(CustomerID, Customer, SecondDate, SecondQty)  
 Select InvoiceAbstract.CustomerID,  
 "Customer" = Customer.Company_Name,  
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) * @UOMFactor  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
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
  
 Insert Into #temp1(CustomerID, Customer, FirstDate, FirstQty)  
 Select InvoiceAbstract.CustomerID,  
 "Customer" = Customer.Company_Name,  
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) / @UOMFactor  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
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
  
 Insert Into #temp2(CustomerID, Customer, SecondDate, SecondQty)  
 Select InvoiceAbstract.CustomerID,  
 "Customer" = Customer.Company_Name,  
 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),  
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) / @UOMFactor  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And  
 InvoiceAbstract.Status & 128 = 0 And  
 InvoiceAbstract.InvoiceType In (1, 3, 4) And  
 InvoiceAbstract.CustomerID = Customer.CustomerID And  
 IsNull(Customer.ChannelType, 0) = @ChannelID And  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.CategoryID In (Select CategoryID From #tempCategory) And  
   
 InvoiceAbstract.CustomerID In (Select InvoiceAbstract.CustomerID  
 From InvoiceAbstract, InvoiceDetail, Items, Customer  
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And  
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
Insert Into #temp(CustomerID, Customer, FirstDate, FirstQty)  
Select CustomerID, Customer, FirstDate, FirstQty From #temp1  
Declare @SecCustomerID nVarchar(20)  
Declare @SecCustomer nVarchar(255)  
Declare @SecDate Datetime  
Declare @SecQty Decimal(18, 6)  
Declare @RowID Int  
  
Declare ReleaseSales Cursor KeySet For  
Select CustomerID, Customer, SecondDate, SecondQty From #temp2  
Open ReleaseSales  
Fetch From ReleaseSales Into @SecCustomerID, @SecCustomer, @SecDate, @SecQty  
While @@Fetch_Status = 0  
Begin  
 Select Top 1 @RowID = ID From #temp   
 Where CustomerID = @SecCustomerID And SecondDate Is Null  
 update #temp Set SecondDate = @SecDate, SecondQty = @SecQty  
 Where CustomerID = @SecCustomerID And SecondDate Is Null And ID = @RowID  
 IF @@RowCount = 0  
 Insert into #temp(CustomerID, Customer, SecondDate, SecondQty)  
 Values (@SecCustomerID, @SecCustomer, @SecDate, @SecQty)  
 Fetch Next From ReleaseSales Into @SecCustomerID, @SecCustomer, @SecDate, @SecQty  
End  
Close ReleaseSales  
DeAllocate ReleaseSales  
Drop Table #tempCategory  
Drop Table #temp1  
Drop Table #temp2  
Select CustomerID, CustomerID, Customer, FirstDate, FirstQty, SecondDate, SecondQty from #temp  
Drop Table #temp
