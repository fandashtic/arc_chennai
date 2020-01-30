
Create Procedure Spr_ChannelwiseOutlet_ITC
(
	@FromDate DateTime,
	@ToDate DateTime
)
As
Declare @SKU NVarchar(50)    
Declare @SUBTOTAL NVarchar(50)    
Declare @GRNTOTAL NVarchar(50)    
Declare @WDCode NVarchar(255), @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)    
Declare @SPRExist Int 

-- Set @FromDate = dbo.StripDateFromTime(@FromDate)
-- Set @ToDate = dbo.StripDateFromTime(@ToDate)

Set @SKU = dbo.LookupDictionaryItem(N'Channel', Default)     
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

Create Table #TempConsolidate (ChanlType Int, 
-- WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Channel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TNOU Int, OFU1 Int, OFU2 Int, OFU3 Int, OFU4 Int, OFU5 Int, OFU6 Int, OFU7 Int, 
OFU8 Int, TNOB Int)

-- Create Table #TempMarketSKU (Category NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

Create Table #TmpChannel(CustomerCnt BigInt,ChannelType BigInt)

Insert Into #TmpChannel(CustomerCnt,ChannelType)
Select
 Count(IA.CustomerID),CC.ChannelType
From
 InvoiceAbstract IA,Customer CC
Where
	IA.CustomerID = CC.CustomerID
	And IsNull(IA.Status,0) & 192 = 0 
	And IA.InvoiceType In (1,3)
	And dbo.StripDateFromTime(InvoiceDate) Between @FromDate And @ToDate
Group by
	CC.ChannelType,IA.CustomerID

Insert InTo #TempConsolidate(ChanlType, -- WDCode, 
WDDest, Channel, TNOU, OFU1, OFU2, OFU3, OFU4, OFU5, OFU6, OFU7, 
OFU8, TNOB)
Select 
	CCH.ChannelType, -- "WD Code" = @WDCode, 
	"WD Dest. Code" = SU.RegisteredOwner,
	"Channel" = CCH.ChannelDesc,
	"Total No of Outlets in the Universe" = Count(CC.CustomerID),
	"No. of Outlets Billed With Frequency - 1" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 1),
	"No. of Outlets Billed With Frequency - 2" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 2),
	"No. of Outlets Billed With Frequency - 3" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 3),
	"No. of Outlets Billed With Frequency - 4" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 4),
	"No. of Outlets Billed With Frequency - 5" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 5),
	"No. of Outlets Billed With Frequency - 6" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 6),
	"No. of Outlets Billed With Frequency - 7" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt = 7),
	"No. of Outlets Billed With Frequency - 8 and above" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType And CustomerCnt >= 8),
	"Total No of outlets billed" = (Select Count(CustomerCnt) From #TmpChannel TC Where TC.ChannelType = CCH.ChannelType)
From
 Customer_Channel CCH
 left outer join Customer CC on CCH.ChannelType = CC.ChannelType
 ,Setup SU
Where
	  CCH.Active = 1
	And CC.Active = 1
Group By
	CCH.ChannelType,CCH.ChannelDesc,SU.RegisteredOwner

-- Insert into #TempMarketSKU values(@sku)  

If (Select Count(*) From Reports Where ReportName = 'Channel Wise Outlet Billing Frequency' 
And ParameterID In (Select ParameterID From 
dbo.GetReportParametersForChnLpNplCws('Channel Wise Outlet Billing Frequency') Where     
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1    
Begin    
	set @SPRExist =1  

	Insert InTo #TempConsolidate(ChanlType, 
	-- WDCode , 
	WDDest , Channel , 
	TNOU , OFU1 , OFU2 , OFU3 , OFU4 , OFU5 , OFU6 , OFU7 , 
	OFU8 , TNOB )
	Select IsNull((Select ChannelType From Customer_Channel Where ChannelDesc = IsNull(Field2, '')), 0),
	-- IsNull(Field1, ''), 
	IsNull(Field1, ''), IsNull(Field2, ''), Cast(IsNull(Field3, 0) As Int), 
	Cast(IsNull(Field4, 0) As Int), 
	Cast(IsNull(Field5, 0) As Int), Cast(IsNull(Field6, 0) As Int), 
	Cast(IsNull(Field7, 0) As Int), Cast(IsNull(Field8, 0) As Int), 
	Cast(IsNull(Field9, 0) As Int), Cast(IsNull(Field10, 0) As Int), 
	Cast(IsNull(Field11, 0) As Int), Cast(IsNull(Field12, 0) As Int)
	From Reports, ReportAbstractReceived    
	Where Reports.ReportID in             
	(Select Distinct ReportID From Reports                   
	Where ReportName = 'Channel Wise Outlet Billing Frequency' 
	And ParameterID in (Select ParameterID From dbo.GetReportParametersForChnLpNplCws('Channel Wise Outlet Billing Frequency') Where 
	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))    
	And ReportAbstractReceived.ReportID = Reports.ReportID                
	--And ReportAbstractReceived.Field3 In (Select * From #TempMarketSKU)    
	and ReportAbstractReceived.Field2 <> @SKU    
	and ReportAbstractReceived.Field1 <> @SUBTOTAL        
	and ReportAbstractReceived.Field1 <> @GRNTOTAL     
End

-- Select * From #TempConsolidate

Select Top 1 @CompaniesToUploadCode = ForumCode From Companies_To_Upload    
Where ForumCode = N'ITC001'
Select Top 1 @WDCode = RegisteredOwner From Setup      
    
If @CompaniesToUploadCode = 'ITC001'    
Begin

	Update #TempConsolidate Set WDDest = @WDCode 
	Where WDDest In (Select WareHouseID From Warehouse)

	Update #TempConsolidate Set Channel = N'Other Channels'
	Where Channel Not In (Select ChannelDesc From Customer_Channel Where Active = 1) 

-- select ChannelDesc, * from Customer_Channel
End

Select ChanlType, --"WD Code" = WDCode, 
"WD Dest. Code" = WDDest, 
"Channel" = Channel, "Total No of Outlets in the Universe" = Sum(TNOU), 
"No. of Outlets Billed With Frequency - 1" = Sum(OFU1), 
"No. of Outlets Billed With Frequency - 2" = Sum(OFU2), 
"No. of Outlets Billed With Frequency - 3" = Sum(OFU3), 
"No. of Outlets Billed With Frequency - 4" = Sum(OFU4), 
"No. of Outlets Billed With Frequency - 5" = Sum(OFU5), 
"No. of Outlets Billed With Frequency - 6" = Sum(OFU6), 
"No. of Outlets Billed With Frequency - 7" = Sum(OFU7), 
"No. of Outlets Billed With Frequency - 8 and above" = Sum(OFU8), 
"Total No of outlets billed" = Sum(TNOB) 
From #TempConsolidate
Group By ChanlType, WDDest, Channel
Order By Channel

