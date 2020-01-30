Create Procedure spr_list_TransferOut_Consolidated  
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
Declare @Rcode NVarChar(255)      
    
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)        
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)        
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)        
Set @Delimeter=Char(15)     
         
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)            
If @WareHouse = N'%'                
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports      
Else                
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@WareHouse,@Delimeter))      
      
Select @Rcode = RegisteredOwner From Setup      
      
Select         
 Cast(StockTransferOutAbstract.DocSerial As NVarChar) + @Rcode,        
 "Distributor code"=@RCode,      
 "Stock Transfer ID"=IsNull(StockTransferOutAbstract.DocPrefix,N'')+Cast(StockTransferOutAbstract.DocumentID as NVarChar),        
 "Date"=StockTransferOutAbstract.DocumentDate,"WareHouse"=WareHouse.WareHouse_Name,        
 "Value"=StockTransferOutAbstract.NetValue,"Reference"=StockTransferOutAbstract.Reference,        
 "User Name"=StockTransferOutAbstract.UserName,        
 "Status"=  
  Case         
   When Status & 64 <> 0 Then @CANCELLED        
   When Status & 128 <> 0 Then @AMENDED        
   When Status & 16 <> 0 Then @AMENDMENT        
   Else N''        
  End        
From         
 StockTransferOutAbstract, WareHouse      
Where         
 dbo.StripDateFromTime(StockTransferOutAbstract.DocumentDate) = @FromDate And       
 dbo.StripDateFromTime(StockTransferOutAbstract.DocumentDate) = @FromDate And        
 StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID
  
Union All      
  
Select       
 Cast(RAR.RecordID as NVarChar),Reports.CompanyID,RAR.Field1,RAR.Field2,RAR.Field3,      
 RAR.Field4,RAR.Field5,RAR.Field6,RAR.Field7      
From      
 Reports,ReportAbstractReceived RAR      
Where       
 Reports.ReportID in (select Max(ReportID) from Reports where ReportName = (N'Stock Transfer - Out')    
 And ParameterID In (Select ParameterID From dbo.GetReportParameters_Consolidated(N'Stock Transfer - Out') Where FromDate = Dbo.Stripdatefromtime(@FromDate) And ToDate = Dbo.Stripdatefromtime(@ToDate)) group by CompanyId) And   
 Reports.ReportID = RAR.ReportID And      
 Field1 <> N'Stock Transfer ID' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'    
 And CompanyID In (Select CompanyId From #TmpBranch)    
