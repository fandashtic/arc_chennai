CREATE Procedure spr_New_Retail_Universe_Detail_MUOM (@ProductInfo nvarchar(255),              
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
Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)
              

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
     OLClassID Int, InvoiceDate Datetime,              
     InvoiceValue Decimal(18,6))              

-- Channel type name changed, and new channel classifications added

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1  

Insert Into #temp              
Select Inv.CustomerID, IsNull(olcm.OLClassID, 0), dbo.StripDateFromTime(Inv.InvoiceDate), 
Sum(IsNull(Inv.NetValue, 0) - IsNull(Inv.Freight, 0))               
From InvoiceAbstract As Inv
Left Outer Join  #OLClassMapping olcm On olcm.CustomerID = Inv.CustomerID 
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
Group By Inv.CustomerID, dbo.StripDateFromTime(Inv.InvoiceDate), olcm.OLClassID
        
If @UOM = N'' or @UOM = N'%'        
Begin        
 Set @UOM = N'Base UOM'        
End        
              
If @UOM = N'Base UOM'              
Begin              
 Select @UOMDescCount  = Count(Distinct Items.UOM)              
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
 Left Outer Join UOM On Items.UOM = UOM.UOM                           
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
 InvoiceAbstract.Status & 128 = 0 And              
 InvoiceAbstract.InvoiceType In (1, 3, 4) And              
 IsNull(Customer.ChannelType, 0) = @ChannelID And              
 Items.CategoryID In (Select CategoryID From #tempCategory)               
--  Group By InvoiceAbstract.CustomerID,              
--  Customer.Company_Name,               
--  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), Items.UOM              
     
 If @UOMDescCount <= 1               
 Begin              
  Select Top 1 @UOMDescription  = UOM.Description              
  From InvoiceAbstract
  Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join UOM On Items.UOM = UOM.UOM                           
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
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
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),              
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity),              
 "Base UOM" = @UOMDescription,              
 "Invoice Value" = (Select InvoiceValue From #temp               
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And              
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) And 
 IsNull(#temp.OLClassID, 0) = IsNull(olcm.OLClassID, 0)),              
              
 "Product Value" = Sum(InvoiceDetail.Amount)              
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join  #OLClassMapping olcm On olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
 InvoiceAbstract.Status & 128 = 0 And              
 InvoiceAbstract.InvoiceType In (1, 3, 4) And              
 IsNull(Customer.ChannelType, 0) = @ChannelID And     
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
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
 Order By InvoiceAbstract.CustomerID              
End              
Else If @UOM = N'UOM 1'              
Begin              
--  Select @UOMDescCount  = Count(Distinct Items.UOM1)              
--  From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM 
--  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
--  InvoiceAbstract.Status & 128 = 0 And              
--  InvoiceAbstract.InvoiceType In (1, 3, 4) And              
--  InvoiceAbstract.CustomerID = Customer.CustomerID And              
--  IsNull(Customer.ChannelType, 0) = @ChannelID And              
--  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And              
--  InvoiceDetail.Product_Code = Items.Product_Code And              
--  Items.CategoryID In (Select CategoryID From #tempCategory) And              
--  Items.UOM1 *= UOM.UOM              
--  Group By InvoiceAbstract.CustomerID,              
--  Customer.Company_Name,               
--  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)--, Items.UOM1              
              
--  If @UOMDescCount <= 1               
--  Begin              
--   Select Top 1 @UOMDescription  = UOM.Description,          
--   @UOMFactor = Case IsNull(Items.UOM1_Conversion, 0)              
--   When 0 Then 1 Else IsNull(Items.UOM1_Conversion, 1) End              
--   From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM              
--   Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
--   InvoiceAbstract.Status & 128 = 0 And              
--   InvoiceAbstract.CustomerID = Customer.CustomerID And              
--   InvoiceAbstract.InvoiceType In (1, 3, 4) And              
--   IsNull(Customer.ChannelType, 0) = @ChannelID And              
--   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And           
--   InvoiceDetail.Product_Code = Items.Product_Code And              
--   Items.CategoryID In (Select CategoryID From #tempCategory) And              
--   Items.UOM1 *= UOM.UOM              
--   Group By InvoiceAbstract.CustomerID,              
--   Customer.Company_Name,               
--   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), UOM.Description,          
--   Items.UOM1_Conversion              
--  End              
--  Else              
--  Begin              
--   Set @UOMDescription = ''              
--   Set @UOMFactor = 1          
--  End              
              
 Select InvoiceAbstract.CustomerID,              
 "CustomerID" = InvoiceAbstract.CustomerID,              
 "Customer" = Customer.Company_Name,              
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),              
-- "Qty Of Purchase" = Sum(InvoiceDetail.Quantity)/@UOMFactor,    
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity / Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End),  
-- "UOM1" = @UOMDescription,              
 "UOM1" = N'',
 "Invoice Value" = (Select InvoiceValue From #temp               
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And              
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) And 
 IsNull(#temp.OLClassID, 0) = IsNull(olcm.OLClassID, 0)),              
              
 "Product Value" = Sum(InvoiceDetail.Amount)              
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join #OLClassMapping olcm On olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
 InvoiceAbstract.Status & 128 = 0 And              
 InvoiceAbstract.InvoiceType In (1, 3, 4) And              
 IsNull(Customer.ChannelType, 0) = @ChannelID And              
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
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
 Order By InvoiceAbstract.CustomerID              
End              
Else If @UOM = N'UOM 2'              
Begin              
--  Select @UOMDescCount  = Count(Distinct Items.UOM2)              
--  From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM              
--  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
--  InvoiceAbstract.Status & 128 = 0 And              
--  InvoiceAbstract.InvoiceType In (1, 3, 4) And              
--  InvoiceAbstract.CustomerID = Customer.CustomerID And              
--  IsNull(Customer.ChannelType, 0) = @ChannelID And              
--  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And              
--  InvoiceDetail.Product_Code = Items.Product_Code And              
--  Items.CategoryID In (Select CategoryID From #tempCategory) And              
--  Items.UOM2 *= UOM.UOM              
--  Group By InvoiceAbstract.CustomerID,           
--  Customer.Company_Name,               
--  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)--, Items.UOM2              
--               
--  If @UOMDescCount <= 1               
--  Begin              
--   Select Top 1 @UOMDescription  = UOM.Description,          
--   @UOMFactor = Case IsNull(Items.UOM2_Conversion, 0)              
--   When 0 Then 1 Else IsNull(Items.UOM2_Conversion, 1) End              
--   From InvoiceAbstract, InvoiceDetail, Items, Customer, UOM              
--   Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
--   InvoiceAbstract.Status & 128 = 0 And              
--   InvoiceAbstract.CustomerID = Customer.CustomerID And              
--   InvoiceAbstract.InvoiceType In (1, 3, 4) And              
--   IsNull(Customer.ChannelType, 0) = @ChannelID And              
--   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And           
--  InvoiceDetail.Product_Code = Items.Product_Code And              
--   Items.CategoryID In (Select CategoryID From #tempCategory) And              
--   Items.UOM2 *= UOM.UOM              
--   Group By InvoiceAbstract.CustomerID,              
--   Customer.Company_Name,               
-- dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), UOM.Description,          
--   Items.UOM2_Conversion          
--  End              
--  Else              
--  Begin              
--   Set @UOMDescription = ''              
--   Set @UOMFactor = 1          
--  End              
              
 Select InvoiceAbstract.CustomerID,              
 "CustomerID" = InvoiceAbstract.CustomerID,              
 "Customer" = Customer.Company_Name,              
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),              
-- "Qty Of Purchase" = Sum(InvoiceDetail.Quantity)/@UOMFactor,    
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity / Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End),
-- "UOM2" = @UOMDescription,              
 "UOM2" = N'',
 "Invoice Value" = (Select InvoiceValue From #temp               
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And              
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) And
 IsNull(#temp.OLClassID, 0) = IsNull(olcm.OLClassID, 0)),              
              
 "Product Value" = Sum(InvoiceDetail.Amount)              
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 Inner Join  Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID              
 Left Outer Join  #OLClassMapping olcm On olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And              
 InvoiceAbstract.Status & 128 = 0 And              
 InvoiceAbstract.InvoiceType In (1, 3, 4) And              
 IsNull(Customer.ChannelType, 0) = @ChannelID And              
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
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), 
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
 Order By InvoiceAbstract.CustomerID              
End              
Else If @UOM = N'Conversion Factor'        
Begin        
 Select @UOMDescCount  = Count(Distinct Items.ConversionUnit)        
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
 InvoiceAbstract.Status & 128 = 0 And        
 InvoiceAbstract.InvoiceType In (1, 3, 4) And        
 IsNull(Customer.ChannelType, 0) = @ChannelID And        
 Items.CategoryID In (Select CategoryID From #tempCategory)        
--  Group By InvoiceAbstract.CustomerID,        
--  Customer.Company_Name,         
--  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)--, Items.ConversionUnit        
        
 If @UOMDescCount <= 1         
 Begin        
  Select Top 1 @UOMDescription  = ConversionTable.ConversionUnit,        
  @UOMFactor = Case IsNull(Items.ConversionFactor, 0)        
  When 0 Then 1 Else Items.ConversionFactor End          
  From InvoiceAbstract
  Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join  ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID               
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
  InvoiceAbstract.Status & 128 = 0 And        
  InvoiceAbstract.InvoiceType In (1, 3, 4) And        
  IsNull(Customer.ChannelType, 0) = @ChannelID And        
  Items.CategoryID In (Select CategoryID From #tempCategory) 
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
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),        
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) * @UOMFactor,        
 "Conversion Unit" = @UOMDescription,        
 "Invoice Value" = (Select InvoiceValue From #temp         
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And        
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) And 
 IsNull(#temp.OLClassID, 0) = IsNull(olcm.OLClassID, 0)),        
        
 "Product Value" = Sum(InvoiceDetail.Amount)        
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
 Left Outer Join #OLClassMapping olcm On olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
 InvoiceAbstract.Status & 128 = 0 And        
 InvoiceAbstract.InvoiceType In (1, 3, 4) And        
 IsNull(Customer.ChannelType, 0) = @ChannelID And        
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
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
 Order By InvoiceAbstract.CustomerID        
End        
Else If @UOM = N'Reporting UOM'        
Begin        
 Select @UOMDescCount  = Count(Distinct Items.ReportingUOM)        
 From InvoiceAbstract
 Inner Join  InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
 Left Outer Join UOM On Items.ReportingUOM = UOM.UOM               
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
 InvoiceAbstract.Status & 128 = 0 And        
 InvoiceAbstract.InvoiceType In (1, 3, 4) And        
 IsNull(Customer.ChannelType, 0) = @ChannelID And        
 Items.CategoryID In (Select CategoryID From #tempCategory) 
--  Group By InvoiceAbstract.CustomerID,        
--  Customer.Company_Name,         
--  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)--, Items.ReportingUOM        
        
 If @UOMDescCount <= 1         
 Begin        
  Select Top 1 @UOMDescription  = UOM.Description,        
  @UOMFactor = Case IsNull(Items.ReportingUnit, 0)        
  When 0 Then 1 Else Items.ReportingUnit End          
  From InvoiceAbstract
  Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
  Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
  Left Outer Join UOM On Items.ReportingUOM = UOM.UOM              
  Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
  InvoiceAbstract.Status & 128 = 0 And        
  InvoiceAbstract.InvoiceType In (1, 3, 4) And        
  IsNull(Customer.ChannelType, 0) = @ChannelID And        
  Items.CategoryID In (Select CategoryID From #tempCategory) 
  Group By InvoiceAbstract.CustomerID,Customer.Company_Name,dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),UOM.Description,Items.ReportingUnit        
 End        
 Else        
 Begin        
  Set @UOMDescription = N''        
  Set @UOMFactor = 1        
 End        
         
 Select InvoiceAbstract.CustomerID,        
 "CustomerID" = InvoiceAbstract.CustomerID,        
 "Customer" = Customer.Company_Name,        
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Date Of Purchase" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),        
 "Qty Of Purchase" = Sum(InvoiceDetail.Quantity) / @UOMFactor,        
 "Reporting UOM" = @UOMDescription,        
 "Invoice Value" = (Select InvoiceValue From #temp         
 Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS  = InvoiceAbstract.CustomerID And        
 dbo.StripDateFromTime(#temp.InvoiceDate) = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) And 
 IsNull(#temp.OLClassID, 0) = IsNull(olcm.OLClassID, 0)),        
        
 "Product Value" = Sum(InvoiceDetail.Amount)        
 From InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code 
 Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
 Left Outer Join  #OLClassMapping olcm On olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And        
 InvoiceAbstract.Status & 128 = 0 And        
 InvoiceAbstract.InvoiceType In (1, 3, 4) And        
 IsNull(Customer.ChannelType, 0) = @ChannelID And        
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
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
 Order By InvoiceAbstract.CustomerID        
End        
Drop Table #tempCategory              
Drop Table #temp              
