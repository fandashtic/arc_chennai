
Create Procedure sp_View_StockTransferOutAbstract (@DocSerial int)  
As  
Declare @CANCELLED As NVarchar(50)  
Declare @AMENDED As NVarchar(50)  
Declare @AMENDMENT As NVarchar(50)  
  
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)  
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)  
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)  
  
Select DocSerial, DocPrefix + Cast(DocumentID As nvarchar),  
DocumentDate, StockTransferOutAbstract.WareHouseID, WareHouse.WareHouse_Name,  
NetValue, Case  
When (Status & 64) <> 0 Then  
@CANCELLED  
When (Status & 128) <> 0 Then  
@AMENDED  
When (Status & 16) <> 0 Then  
@AMENDMENT  
Else  
N''  
End, Reference, StockTransferOutAbstract.Address, IsNull(TaxAmount, 0),  
CancelRemarks, StockRequestNo, Sto_lr_no, Sto_tran_info, Sto_narration  
From StockTransferOutAbstract, WareHouse  
Where StockTransferOutAbstract.DocSerial = @DocSerial And  
StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID  

