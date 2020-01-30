CREATE Procedure spr_Cash_Parties_Detail_MUOM (@ChannelType int,    
       @FromDate Datetime,    
       @ToDate Datetime, @UOMDesc nvarchar(50))    
As    
Declare @UOMDescCount as int    
Declare @UOMFactor as Decimal(18,1)    
If @UOMDesc = N'' or @UOMDesc = N'%'    
Begin    
 Set @UOMDesc = N'Base UOM'    
End    
    
Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

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

if @UOMDesc = N'Base UOM'    
Begin    
Select InvoiceAbstract.CustomerID,    
"CustomerID" = InvoiceAbstract.CustomerID,    
"Customer" = Customer.Company_Name,    
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

"Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
"Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0)),    
"Volume" = Sum(InvoiceDetail.Quantity)    
From InvoiceAbstract
 inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 inner join Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID     
 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code      
  right outer join  #OLClassMapping olcm    on  olcm.CustomerID = Customer.CustomerID
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
InvoiceAbstract.Status & 128 = 0 And    
IsNull(Customer.ChannelType, 0) = @ChannelType And    
InvoiceAbstract.InvoiceType in (1, 3) And    
InvoiceAbstract.PaymentMode = 1 
Group By InvoiceAbstract.CustomerID,     
dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
Customer.Company_Name, olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)

End    
else if @UOMDesc = N'UOM 1'    
Begin    
--  Select @UOMDescCount  = Count(Distinct Items.UOM1)          
--   From InvoiceAbstract, Customer, InvoiceDetail, Items    
--   Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
--   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
--   InvoiceDetail.Product_Code = Items.Product_Code And    
--   InvoiceAbstract.Status & 128 = 0 And    
--   InvoiceAbstract.CustomerID = Customer.CustomerID And    
--   IsNull(Customer.ChannelType, 0) = @ChannelType And    
--   InvoiceAbstract.InvoiceType in (1, 3) And    
--   InvoiceAbstract.PaymentMode = 1    
--   Group By InvoiceAbstract.CustomerID,     
--   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--   Customer.Company_Name--, Items.UOM1    
--        
--  If @UOMDescCount <= 1           
--  Begin          
--   Select Top 1 @UOMFactor = Case IsNull(Items.UOM1_Conversion, 0)          
--   When 0 Then 1 Else Items.UOM1_Conversion End          
--    From InvoiceAbstract, Customer, InvoiceDetail, Items    
--    Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
--    InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
--    InvoiceDetail.Product_Code = Items.Product_Code And    
--    InvoiceAbstract.Status & 128 = 0 And    
--    InvoiceAbstract.CustomerID = Customer.CustomerID And    
--    IsNull(Customer.ChannelType, 0) = @ChannelType And    
--    InvoiceAbstract.InvoiceType in (1, 3) And    
--    InvoiceAbstract.PaymentMode = 1    
--    Group By InvoiceAbstract.CustomerID,     
--    dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--    Customer.Company_Name, Items.UOM1_Conversion    
--  End          
--  Else          
--  Begin          
--   Set @UOMFactor = 1      
--  End          
 Select InvoiceAbstract.CustomerID,    
 "CustomerID" = InvoiceAbstract.CustomerID,    
 "Customer" = Customer.Company_Name,    
"Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 "Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0)),    
-- "Volume" = SUM(InvoiceDetail.Quantity) / @UOMFactor
 "Volume" = SUM(InvoiceDetail.Quantity / Case When IsNull(Items.UOM1_Conversion, 1) = 0 Then 1 Else Items.UOM1_Conversion End)
 --From InvoiceAbstract, Customer, InvoiceDetail, Items, #OLClassMapping olcm
 From InvoiceAbstract
 inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 inner join Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID     
 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code      
  right outer join  #OLClassMapping olcm    on  olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And     
 InvoiceAbstract.Status & 128 = 0 And    
 IsNull(Customer.ChannelType, 0) = @ChannelType And    
 InvoiceAbstract.InvoiceType in (1, 3) And    
 InvoiceAbstract.PaymentMode = 1  
 Group By InvoiceAbstract.CustomerID,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 Customer.Company_Name, 
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
End    
else if @UOMDesc = N'UOM 2'    
Begin    
--  Select @UOMDescCount  = Count(Distinct Items.UOM2)          
--   From InvoiceAbstract, Customer, InvoiceDetail, Items    
--   Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
--   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
--   InvoiceDetail.Product_Code = Items.Product_Code And    
--   InvoiceAbstract.Status & 128 = 0 And    
--   InvoiceAbstract.CustomerID = Customer.CustomerID And    
--   IsNull(Customer.ChannelType, 0) = @ChannelType And    
--   InvoiceAbstract.InvoiceType in (1, 3) And    
--   InvoiceAbstract.PaymentMode = 1    
--   Group By InvoiceAbstract.CustomerID,     
--   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--   Customer.Company_Name--, Items.UOM2    
       
--  If @UOMDescCount <= 1           
--  Begin          
--   Select Top 1 @UOMFactor = Case IsNull(Items.UOM2_Conversion, 0)          
--   When 0 Then 1 Else Items.UOM2_Conversion End          
--    From InvoiceAbstract, Customer, InvoiceDetail, Items    
--    Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
--    InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
--    InvoiceDetail.Product_Code = Items.Product_Code And    
--    InvoiceAbstract.Status & 128 = 0 And    
--    InvoiceAbstract.CustomerID = Customer.CustomerID And    
--    IsNull(Customer.ChannelType, 0) = @ChannelType And    
--    InvoiceAbstract.InvoiceType in (1, 3) And    
--    InvoiceAbstract.PaymentMode = 1    
--    Group By InvoiceAbstract.CustomerID,     
--    dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--    Customer.Company_Name, Items.UOM2_Conversion    
--  End          
--  Else          
--  Begin          
--   Set @UOMFactor = 1      
--  End          
 Select InvoiceAbstract.CustomerID,    
 "CustomerID" = InvoiceAbstract.CustomerID,    
 "Customer" = Customer.Company_Name,    
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 "Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0)),    
-- "Volume" = SUM(InvoiceDetail.Quantity) / @UOMFactor
 "Volume" = SUM(InvoiceDetail.Quantity / Case When IsNull(Items.UOM2_Conversion, 1) = 0 Then 1 Else Items.UOM2_Conversion End)
 --From InvoiceAbstract, Customer, InvoiceDetail, Items, #OLClassMapping olcm
 From InvoiceAbstract
 inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 inner join Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID     
 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code      
  right outer join  #OLClassMapping olcm    on  olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
 InvoiceAbstract.Status & 128 = 0 And      
 IsNull(Customer.ChannelType, 0) = @ChannelType And    
 InvoiceAbstract.InvoiceType in (1, 3) And    
 InvoiceAbstract.PaymentMode = 1 
 Group By InvoiceAbstract.CustomerID,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 Customer.Company_Name,
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)    
End    
else if @UOMDesc = N'Reporting UOM'    
Begin    
 Select @UOMDescCount  = Count(Distinct Items.ReportingUOM)          
  From InvoiceAbstract, Customer, InvoiceDetail, Items
  Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
  InvoiceDetail.Product_Code = Items.Product_Code And    
  InvoiceAbstract.Status & 128 = 0 And    
  InvoiceAbstract.CustomerID = Customer.CustomerID And    
  IsNull(Customer.ChannelType, 0) = @ChannelType And    
  InvoiceAbstract.InvoiceType in (1, 3) And    
  InvoiceAbstract.PaymentMode = 1
--   Group By InvoiceAbstract.CustomerID,     
--   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--   Customer.Company_Name--, Items.UOM1    
       
 If @UOMDescCount <= 1           
 Begin          
  Select Top 1 @UOMFactor = Case IsNull(Items.ReportingUnit, 1)          
  When 0 Then 1 Else Items.ReportingUnit End          
   From InvoiceAbstract, Customer, InvoiceDetail, Items 
   Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
   InvoiceDetail.Product_Code = Items.Product_Code And    
   InvoiceAbstract.Status & 128 = 0 And    
   InvoiceAbstract.CustomerID = Customer.CustomerID And    
   IsNull(Customer.ChannelType, 0) = @ChannelType And    
   InvoiceAbstract.InvoiceType in (1, 3) And    
   InvoiceAbstract.PaymentMode = 1
   Group By InvoiceAbstract.CustomerID,     
   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
   Customer.Company_Name, Items.ReportingUnit    
 End          
 Else          
 Begin          
  Set @UOMFactor = 1      
 End          
 Select InvoiceAbstract.CustomerID,    
 "CustomerID" = InvoiceAbstract.CustomerID,    
 "Customer" = Customer.Company_Name,    
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 

 "Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 "Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0)),    
 "Volume" = SUM(InvoiceDetail.Quantity) / @UOMFactor
 --From InvoiceAbstract, Customer, InvoiceDetail, Items, #OLClassMapping olcm 
 From InvoiceAbstract
 inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 inner join Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID     
 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code      
  right outer join  #OLClassMapping olcm    on  olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 IsNull(Customer.ChannelType, 0) = @ChannelType And    
 InvoiceAbstract.InvoiceType in (1, 3) And    
 InvoiceAbstract.PaymentMode = 1   
 Group By InvoiceAbstract.CustomerID,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 Customer.Company_Name,
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
End    
else if @UOMDesc = N'Conversion Factor'    
Begin    
 Select @UOMDescCount  = Count(Distinct Items.ConversionUnit)          
  From InvoiceAbstract, Customer, InvoiceDetail, Items
  Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
  InvoiceDetail.Product_Code = Items.Product_Code And    
  InvoiceAbstract.Status & 128 = 0 And    
  InvoiceAbstract.CustomerID = Customer.CustomerID And    
  IsNull(Customer.ChannelType, 0) = @ChannelType And    
  InvoiceAbstract.InvoiceType in (1, 3) And    
  InvoiceAbstract.PaymentMode = 1
--   Group By InvoiceAbstract.CustomerID,     
--   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
--   Customer.Company_Name    
       
 If @UOMDescCount <= 1           
 Begin          
  Select Top 1 @UOMFactor = Case IsNull(Items.ConversionFactor, 0)          
  When 0 Then 1 Else Items.ConversionFactor End            
   From InvoiceAbstract, Customer, InvoiceDetail, Items
   Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And    
   InvoiceDetail.Product_Code = Items.Product_Code And    
   InvoiceAbstract.Status & 128 = 0 And    
   InvoiceAbstract.CustomerID = Customer.CustomerID And    
   IsNull(Customer.ChannelType, 0) = @ChannelType And    
   InvoiceAbstract.InvoiceType in (1, 3) And    
   InvoiceAbstract.PaymentMode = 1
   Group By InvoiceAbstract.CustomerID,     
   dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
   Customer.Company_Name, Items.ConversionFactor    
 End          
 Else          
 Begin          
  Set @UOMFactor = 1      
 End          
 Select InvoiceAbstract.CustomerID,    
 "CustomerID" = InvoiceAbstract.CustomerID,    
 "Customer" = Customer.Company_Name,  
 "Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
 "Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
 "Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED), 
  
 "Invoice Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 "Value" = Sum(IsNull(InvoiceAbstract.NetValue, 0) - IsNull(InvoiceAbstract.Freight, 0)),    
 "Volume" = SUM(InvoiceDetail.Quantity) * @UOMFactor
 From InvoiceAbstract
 inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 inner join Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID     
 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code      
  right outer join  #OLClassMapping olcm    on  olcm.CustomerID = Customer.CustomerID
 Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And    
 InvoiceAbstract.Status & 128 = 0 And    
 IsNull(Customer.ChannelType, 0) = @ChannelType And    
 InvoiceAbstract.InvoiceType in (1, 3) And    
 InvoiceAbstract.PaymentMode = 1  

 Group By InvoiceAbstract.CustomerID,     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),    
 Customer.Company_Name,
 olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], IsNull(olcm.OLClassID, 0)
End    
    


