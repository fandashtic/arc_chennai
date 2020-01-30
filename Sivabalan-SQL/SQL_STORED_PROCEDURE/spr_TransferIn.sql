Create Procedure spr_TransferIn (   
@WareHouse nVarchar(2550),  
@FromDate DateTime,  
@ToDate  DateTime  
)  
As  
Declare @Delimeter Char(1)      
Declare @OPEN As NVarchar(50)  
Declare @AMENDED As NVarchar(50)  
Declare @AMENDMENT As NVarchar(50)  
Declare @CANCELLED As NVarchar(50)  
Declare @DIRECTSTOCKTRANSFERIN As NVarchar(50)  
Declare @STOCKTRANSFERINFROMOUT As NVarchar(50)  

Set	@OPEN = dbo.LookupDictionaryItem(N'',Default)  --Open
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)  
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)  
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)  
Set @DIRECTSTOCKTRANSFERIN = dbo.LookupDictionaryItem(N'Direct Stock Transfer In', Default)  
Set @STOCKTRANSFERINFROMOUT = dbo.LookupDictionaryItem(N'Stock Transfer In From Out', Default)  
  
Set @Delimeter=Char(15)      
  
Create Table #tmpWareHouse(WareHouse_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
If @WareHouse=N'%'    
   Insert Into #tmpWareHouse Select WareHouse_Name From WareHouse  
Else    
   Insert Into #tmpWareHouse Select * From dbo.sp_SplitIn2Rows(@WareHouse,@Delimeter)    
  
Select   
 StockTransferInAbstract.DocSerial,   
  
 "Stock Transfer ID" =  IsNull(StockTransferInAbstract.DocPrefix, N'')   
     + Cast(StockTransferInAbstract.DocumentID as nVarchar),  
  
 "Date"    =  StockTransferInAbstract.DocumentDate,  
  
 "WareHouse"   =  WareHouse.WareHouse_Name,  
  
 "Reference"   =  IsNull(StockTransferInAbstract.ReferenceSerial, N''),  
  
 "User Name"   =  StockTransferInAbstract.UserName,  
  
 "Value"   = StockTransferInAbstract.NetValue,  
  
 "Type"    =  Case DocReference  
      When N'' Then  
       @DIRECTSTOCKTRANSFERIN  
      Else  
       @STOCKTRANSFERINFROMOUT  
     End,  
  
 "Status"   =  (

		Select
		Case
		 when IsNull(Status,0) & 64 <> 0 then @CANCELLED
		 when isnull(status & 128,0 ) = 128 and isnull(reference,0) <> 0 then @AMENDED
		 when isnull(status & 128,0 ) = 128 and isnull(reference,0) = 0  then @AMENDED
		 when isnull(status & 128,0 ) = 0 and isnull(reference,0) <> 0  then @AMENDMENT
		 when isnull(status & 128,0 ) = 0 and isnull(reference,0) = 0  then @OPEN
		End
     )  
   
From   
 StockTransferInAbstract,WareHouse  
  
Where   
 StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate And  
 StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID And  
 WareHouse.WareHouse_Name In (Select WareHouse_Name From #tmpWareHouse)  
  
Order By   
 StockTransferInAbstract.DocumentID,   
 StockTransferInAbstract.DocumentDate,  
 WareHouse.WareHouse_Name  
