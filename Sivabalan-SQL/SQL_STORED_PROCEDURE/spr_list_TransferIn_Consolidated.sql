Create Procedure spr_list_TransferIn_Consolidated  
(       
 @WareHouse NVarChar(2550),      
 @FromDate  DateTime,      
 @ToDate  DateTime      
)      
As      
Declare @Delimeter Char(1)          
Declare @AMENDED As NVarChar(50)      
Declare @AMENDMENT As NVarChar(50)      
Declare @CANCELLED As NVarChar(50)      
Declare @DIRECTSTOCKTRANSFERIN As NVarChar(50)      
Declare @STOCKTRANSFERINFROMOUT As NVarChar(50)     
Declare @FromDateBh DateTime    
Declare @ToDateBh DateTime    
Declare @Rcode NVarChar(255)    
  
Set @FromDateBh = dbo.StripDateFromTime(@FromDate)          
Set @ToDateBh = dbo.StripDateFromTime(@ToDate)        
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)      
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)      
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)      
Set @DIRECTSTOCKTRANSFERIN = dbo.LookupDictionaryItem(N'Direct Stock Transfer In', Default)      
Set @STOCKTRANSFERINFROMOUT = dbo.LookupDictionaryItem(N'Stock Transfer In From Out', Default)      
Set @Delimeter=Char(15)          
  
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)            
If @WareHouse = N'%'                
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports      
Else                
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@WareHouse,@Delimeter))      
      
Select @Rcode = RegisteredOwner From Setup  
    
Select       
 Cast(StockTransferInAbstract.DocSerial As Varchar) + @Rcode,      
 "Distributor code" = @RCode,    
 "Stock Transfer ID" =  IsNull(StockTransferInAbstract.DocPrefix, N'') + Cast(StockTransferInAbstract.DocumentID as NVarChar),      
 "Date"=StockTransferInAbstract.DocumentDate,"WareHouse"=WareHouse.WareHouse_Name,      
 "Reference"=IsNull(StockTransferInAbstract.ReferenceSerial, N''),      
 "User Name"=StockTransferInAbstract.UserName,"Value"=StockTransferInAbstract.NetValue,      
 "Type"=  
  Case ReferenceSerial  
   When N'' Then @DIRECTSTOCKTRANSFERIN      
   Else @STOCKTRANSFERINFROMOUT      
  End,      
 "Status"=   
  Case         
   When Status & 64 <> 0 Then @CANCELLED      
   When Status & 16 <> 0 Then @AMENDMENT      
   When Status & 128 <> 0 Then @AMENDED      
  End       
From       
 StockTransferInAbstract,WareHouse      
Where       
 dbo.StripDateFromTime(StockTransferInAbstract.DocumentDate) = @FromDateBh And    
 dbo.StripDateFromTime(StockTransferInAbstract.DocumentDate) = @ToDateBh And      
 StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID --And      
    
Union All    
    
Select     
 Cast(RAR.RecordID as NVarChar),Reports.CompanyID,RAR.Field1,RAR.Field2,  
 RAR.Field3,RAR.Field4,RAR.Field5,RAR.Field6,RAR.Field7,RAR.Field8    
From    
 Reports,ReportAbstractReceived RAR  
Where     
  Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = (N'Stock Transfer - In') And      
	ParameterID In (Select ParameterID From dbo.GetReportParameters_Consolidated( N'Stock Transfer - In') Where  dbo.StripDateFromTime(FromDate) = @FromDateBh And dbo.StripDateFromTime(ToDate) =  @ToDateBh) Group by companyid)	  
    And RAR.ReportID = Reports.ReportID    
    And Field1 <> N'Stock Transfer ID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'     
    And CompanyID In (Select CompanyId From #TmpBranch)
