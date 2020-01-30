CREATE procedure [dbo].[spr_list_SalesDay_Book]
(
 @BranchName NVarChar(4000),  
 @Manufacturer NVarChar(2550),     
 @Product_Code NVarChar(2550),     
 @UOM NVarChar(100),    
 @FromDate DateTime,     
 @ToDate DateTime
)     
As    

Declare @Units NVarChar(5)    
Declare @Kg NVarChar(2)    
Declare @Case NVarChar(4)    
Set @Units = N'Units'    
Set @Kg = N'kg'    
Set @case = N'case'    

Declare @Delimeter as Char(1) 
Set @Delimeter=Char(15)      

Set @FromDate = dbo.StripDateFromTime(@FromDate)      
Set @ToDate = dbo.StripDateFromTime(@ToDate)   
 
Create Table #TmpMfr(Manufacturer_Name NVarChar(255) Collate SQL_Latin1_General_CP1_CI_AS)          
If @Manufacturer='%'       
 Insert InTo #TmpMfr Select Manufacturer_Name From Manufacturer      
Else      
 Insert InTo #TmpMfr Select * From dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)    

Create Table #TmpProd(Product_Code NVarChar(255) Collate SQL_Latin1_General_CP1_CI_AS)        
If @Product_Code='%'    
 Insert InTo #TmpProd Select Product_Code From Items    
Else    
 Insert InTo #TmpProd Select * From dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter) 

CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
If @BranchName = N'%'            
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
Else            
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  
        
Create Table #Temp
(
	Product_Code NVarChar(15) Collate SQL_Latin1_General_CP1_CI_AS,
	Price Decimal(18,6),Quantity Decimal(18,6),CountInvoice Int, SaleID Int
)     
Insert InTo #Temp(Product_Code,Price,Quantity,CountInvoice, SaleID)    
Select 
	a.Product_Code, Sum(Amount), Sum(IsNull(a.Quantity,0)), 1, a.SaleID 
From     
	InvoiceDetail a,InvoiceAbstract b, Items, Manufacturer    
Where 
	a.InvoiceId = b.InvoiceId     
	And a.Product_Code = Items.Product_Code     
	And Items.ManufacturerId = Manufacturer.ManufacturerId    
	And dbo.StripDateFromTime(b.InvoiceDate) = @FromDate 
	And dbo.StripDateFromTime(b.InvoiceDate) = @ToDate    
	And b.InvoiceType <> 4 And (status & 128 ) = 0 
	And a.Product_Code In(Select Product_Code Collate SQL_Latin1_General_CP1_CI_AS From #TmpProd)    
	And Manufacturer.Manufacturer_Name In (Select Manufacturer_Name Collate SQL_Latin1_General_CP1_CI_AS From #TmpMfr)    
Group By 
	a.Product_Code,a.InvoiceId, a.SaleID    

Create Table #TmpSummation
(
	ItemCode NVarChar(255) Collate SQL_Latin1_General_CP1_CI_AS,      
	ItemName NVarChar(255)Collate SQL_Latin1_General_CP1_CI_AS,
	FirstSale Decimal(18,6),SecondSale Decimal(18,6),OtherSales Decimal(18,6),
	TotalQuantity Decimal(18,6),NoOfInvoices Decimal(18,6)    
)    

Insert InTo #TmpSummation
(
	ItemCode,ItemName,FirstSale,SecondSale,OtherSales,TotalQuantity,NoOfInvoices    
)    

Select  
	#Temp.Product_Code,ProductName,Sum(Price),0,0,Sum(Quantity),Count(#Temp.Product_Code)   
From 
	#Temp,Items
Where 
	#Temp.Product_Code = Items.Product_Code And #Temp.SaleID = 1   
Group by 
	#Temp.Product_Code,ProductName,#Temp.SaleID

Union All
    
Select  
	#Temp.Product_Code,ProductName,0,Sum(Price),0,Sum(Quantity),Count(#Temp.Product_Code)     
From 
	#Temp, Items
Where 
	#Temp.Product_Code = Items.Product_Code And #Temp.SaleID = 2     
Group By 
	#Temp.Product_Code,ProductName, #Temp.SaleID

Union All

Select  
	#Temp.Product_Code,ProductName,0,0,Sum(Price),Sum(Quantity),Count(#Temp.Product_Code)   
From 
	#Temp, Items
Where 
	#Temp.Product_Code = Items.Product_Code And #Temp.SaleID = 3
Group By 
	#Temp.Product_Code,ProductName, #Temp.SaleID   

Union All

Select 
	RAR.Field1,RAR.Field2,
	Sum
	((Case 
 			When RAR.Field3 = '' Then Cast(0 As Decimal(18,6))
 			When RAR.Field3 = NULL Then Cast(0 As Decimal(18,6))
 			Else Cast(RAR.Field3 As Decimal(18,6)) 
		End)),
	Sum
	((Case 
 			When RAR.Field4 = '' Then Cast(0 As Decimal(18,6))
 			When RAR.Field4 = NULL Then Cast(0 As Decimal(18,6))
 			Else Cast(RAR.Field4 As Decimal(18,6)) 
		End)),
	Sum
	((Case 
 			When RAR.Field5 = '' Then Cast(0 As Decimal(18,6))
 			When RAR.Field5 = NULL Then Cast(0 As Decimal(18,6))
 			Else Cast(RAR.Field5 As Decimal(18,6)) 
		End)),  
	Sum
	((Case 
 			When RAR.Field6 = '' Then Cast(0 As Decimal(18,6))
 			When RAR.Field6 = NULL Then Cast(0 As Decimal(18,6))
 			Else Cast(Left(RAR.Field6,CharIndex(' ',RAR.Field6)-1) As Decimal(18,6)) 
		End)),
	Sum(Cast(RAR.Field9 As Decimal(18,6)))
From 
	Reports, ReportAbstractReceived RAR        
Where 
  Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Sales Day Book'
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Sales Day Book') Where dbo.StripDateFromTime(FromDate) = @FromDate And dbo.StripDateFromTime(ToDate) = @ToDate) Group by CompanyId)
  And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
  And RAR.ReportID = Reports.ReportID  
  And Field1 <> N'Item Code' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
		And 	Field1 In  (Select Product_Code From #TmpProd)   
Group By 
	RAR.Field1,RAR.Field2

Select 
	ItemCode,      
	"Item Code" = ItemCode,      
	"Item Name" = ItemName,      
	"First Sale (%c)" =  Sum(Cast(IsNull(FirstSale,0) As Decimal(18,6))) ,        
	"Second Sale (%c)" = Sum(Cast(IsNull(SecondSale,0) As Decimal(18,6))),     
	"Other Sales  (%c)" =  Sum(Cast(IsNull(OtherSales,0) As Decimal(18,6))),  
	"Total Quantity" = 	
	Cast((
		Case @UOM 
			When 'Sales UOM' Then Sum(TotalQuantity)   
	  When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(TotalQuantity), UOM1_Conversion)  
	  When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(TotalQuantity), UOM2_Conversion)  
		End) AS NVarChar)+ ' ' + Cast(UOM.Description AS NVarChar),   
	"Conversion Factor" = Cast(Cast(Sum(TotalQuantity * Items.ConversionFactor) AS Decimal(18,6)) As NVarChar) + ' ' + Cast(ConversionTable.ConversionUnit As NVarChar),  
	"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(ItemCode, Sum(IsNull(TotalQuantity, 0))) As NVarChar)+ ' ' + Cast((Select Description From UOM Where UOM = Items.ReportingUOM) As NVarChar),  
	"No of Invoices" = Sum(Cast(NoOfInvoices As Decimal(18,6)))   
From 
	#TmpSummation,Items,UOM,ConversionTable,Manufacturer    
Where 
	Items.Product_Code=#TmpSummation.ItemCode 
	And Items.ManufacturerId = Manufacturer.ManufacturerId    
	And Manufacturer.Manufacturer_Name in (Select Manufacturer_Name Collate SQL_Latin1_General_CP1_CI_AS From #TmpMfr) And
	(Case @UOM 
		When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1   
  When 'UOM2' Then Items.UOM2 
	End) *= UOM.UOM  And
	Items.ConversionUnit*=ConversionTable.ConversionID
Group By 
	#TmpSummation.ItemCode,#TmpSummation.ItemName,UOM.Description,Items.ReportingUOM,
	ConversionTable.ConversionUnit,UOM1_Conversion,UOM2_Conversion  

Drop Table #Temp    
Drop Table #TmpSummation
