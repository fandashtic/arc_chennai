
Create Procedure Spr_LinesPerCall_ITC
(
	@FromDate DateTime,
	@ToDate DateTime
)
As
Declare @NetValue As Decimal(18,6)
Declare @SKU NVarchar(50)    
Declare @SUBTOTAL NVarchar(50)    
Declare @GRNTOTAL NVarchar(50)    
Declare @WDCode NVarchar(255), @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)    
Declare @SPRExist Int 
Declare @Category_Name nVarchar(510)

-- Set @FromDate = dbo.StripDateFromTime(@FromDate)
-- Set @ToDate = dbo.StripDateFromTime(@ToDate)

Set @SKU = dbo.LookupDictionaryItem(N'Total No. of DS', Default)     
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)     
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)     

-- Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
-- Select Top 1 @WDCode = RegisteredOwner From Setup      
    
-- If @CompaniesToUploadCode='ITC001'    
--  Set @WDDest= @WDCode    
-- Else    
-- Begin    
--  Set @WDDest= @WDCode    
--  Set @WDCode= @CompaniesToUploadCode    
-- End    

Create Table #TempConsolidate (ComID nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, --WDC As nVarChar(255),
DWD nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
NDS Int, LDS Int, IDS Int, VDS Decimal(18, 6), 
AVI Decimal(18, 6), ALI Decimal(18, 6))

Create Table #TempCategory(CategoryID Int, Status Int)   

-- If any of the unused categories are deleted and recreated, then the category id would be changed in the 
-- ItemCategories table but the same would not be updated in CategoryExceptional table. This issue 
-- has been fixed in the following code snippet.
	Update CategoryExceptional Set CategoryID = IC.CategoryID From ItemCategories IC, CategoryExceptional CE 
	Where CE.ReportID=786 And CE.Category_Name=IC.Category_Name 

-- Get the Category which is not to be considered for this report from CategoryExceptional table
Declare CAT_CURSOR CURSOR STATIC FOR 
Select Category_Name From ItemCategories Where CategoryID in (Select CategoryID From CategoryExceptional Where ReportID = 786 And Active=1)
Open CAT_CURSOR
Fetch Next From CAT_CURSOR Into @Category_Name
While @@Fetch_Status = 0
Begin
	Set @Category_Name=IsNull(@Category_Name,N'')
	Exec GetLeafCategories N'%', @Category_Name
	Fetch Next From CAT_CURSOR Into @Category_Name
End
Close CAT_CURSOR
Deallocate CAT_CURSOR

Create Table #Tmp
(
	CompanyID NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SalesmanID BigInt,
	Product_Code NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	InvoiceID BigInt
)

-- To get the details of the invoices for those items which are not in the category mentioned in the table CategoryExceptional
Insert Into #Tmp(CompanyID,SalesmanID,Product_Code,InvoiceID)
Select SU.RegisteredOwner,IA.SalesmanID,Product_Code,IA.InvoiceID
From InvoiceAbstract IA,InvoiceDetail IDE,SalesMan SM,SetUp SU
Where
IA.SalesmanID <> 0
And IA.InvoiceID = IDE.InvoiceID
And IDE.Product_Code Not In (Select Product_Code From Items Where CategoryID in (Select CategoryID From #TempCategory)) 
And IA.SalesmanID = SM.SalesmanID
And IsNull(IA.Status,0) & 192 = 0 
And IA.InvoiceType In (1,3)
And dbo.StripDateFromTime(InvoiceDate) Between @FromDate And @ToDate
Group By SU.RegisteredOwner,IA.SalesmanID,Product_Code,IA.InvoiceID

-- To get the netvalue of the invoices for those items which are not in the category mentioned in the table CategoryExceptional
Select @NetValue = Sum(IDE.Amount)
From InvoiceAbstract IA, InvoiceDetail IDE 
Where
IA.InvoiceID In (Select Distinct InvoiceID From #Tmp) 
And IA.InvoiceID=IDE.InvoiceID 
And IDE.Product_Code Not In (Select Product_Code From Items Where CategoryID in (Select CategoryID From #TempCategory)) 

Insert InTo #TempConsolidate (ComID, DWD, NDS, LDS, IDS, VDS, AVI, ALI) 
Select
CompanyID,
"WD Dest. Code" = CompanyID,
"Total No. of DS" = Count(Distinct SalesmanID), 
"Total No. of Lines For All DS" = Count(Product_Code),
"Total No. of Invoices For All DS" = Count(Distinct InvoiceID),
"Total Invoice Value For All DS (%c)" = @NetValue,
"Avg. Value of Invoice" = Cast(Cast(@NetValue As Decimal(18,6))/Cast(Count(Distinct InvoiceID)As Decimal(18,6)) As Decimal(18,6)),
"Avg. No of Lines Per Invoice" = Cast(Cast(Count(Product_Code) As Decimal(18,6))/Cast(Count(Distinct InvoiceID) As Decimal(18,6)) As Decimal(18,6))
From #Tmp
Group By CompanyID	

If (Select Count(*) From Reports Where ReportName = 'Lines Per Call Summary' 
And ParameterID In (Select ParameterID From 
dbo.GetReportParametersForChnLpNplCws('Lines Per Call Summary') Where     
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1    
Begin    
	set @SPRExist =1  
	Insert InTo #TempConsolidate (ComID, DWD, NDS , LDS , IDS , VDS , AVI , ALI )
	Select Field1, Field1, Cast(Field2 As Int), Cast(Field3 As Int), 
	Cast(Field4 As Int), Cast(Field5 As Decimal(18, 6)), 
	Cast(Field6 As Decimal(18, 6)), Cast(Field7 As Decimal(18, 6))
	From Reports, ReportAbstractReceived    
	Where Reports.ReportID in             
	(Select Distinct ReportID From Reports                   
	Where ReportName = 'Lines Per Call Summary'
	And ParameterID in (Select ParameterID From dbo.GetReportParametersForChnLpNplCws('Lines Per Call Summary') Where 
	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))    
	And ReportAbstractReceived.ReportID = Reports.ReportID                
	--And ReportAbstractReceived.Field3 In (Select * From #TempMarketSKU)    
	and ReportAbstractReceived.Field2 <> @SKU    
	and ReportAbstractReceived.Field1 <> @SUBTOTAL        
	and ReportAbstractReceived.Field1 <> @GRNTOTAL     
End

Select Top 1 @CompaniesToUploadCode = ForumCode From Companies_To_Upload 
Where ForumCode = 'ITC001'

Select Top 1 @WDCode = RegisteredOwner From Setup      

If @CompaniesToUploadCode='ITC001'    
Begin

	Update #Tempconsolidate Set DWD = @WDCode 
	Where DWD In (Select WareHouseID From Warehouse)
End

--Update #Tempconsolidate Set ComID =  RegisteredOwner , DWD = RegisteredOwner from setup where DWD in (Select WareHouseID From WareHouse)

Select DWD, "WD Dest. Code" = DWD, "Total No. of DS" = Sum(NDS),
"Total No. of Lines For All DS" =  Sum(LDS), 
"Total No. of Invoices For All DS" = Sum(IDS), 
"Total Invoice Value For All DS (%c)" = Sum(Cast(VDS as Decimal(18, 6))),
"Avg. Value of Invoice" = Sum(Cast(VDS As Decimal(18,6))) / Sum(Cast(IDS as Decimal(18, 6))),
"Avg. No of Lines Per Invoice" = Sum(Cast(LDS As Decimal(18, 6))) / Sum(Cast(IDS As Decimal(18, 6))) 
From #TempConsolidate 
Group By DWD

Drop Table #Tmp
Drop Table #TempCategory
