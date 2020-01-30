CREATE Procedure spr_Receipts_Dispatches(@FromDate DateTime, @ToDate DateTime)    
As    
Declare @Receipts nvarchar(100)    
Declare @Dispatches nvarchar(100)    
Declare @G nvarchar(100)    
Declare @CFA nvarchar(100)    
Declare @FAC nvarchar(100)    
    
set @Receipts = dbo.LookupDictionaryItem('Receipts', Default)    
set @Dispatches = dbo.LookupDictionaryItem('Dispatches', Default)    
set @G = dbo.LookupDictionaryItem('G', Default)    
set @CFA = dbo.LookupDictionaryItem('CFA', Default)    
set @FAC = dbo.LookupDictionaryItem('FAC', Default)    
-- Select @STI = Prefix From Voucherprefix Where TranID = N'Stock Transfer In'    
-- Select @STO = Prefix From Voucherprefix Where TranID = N'Stock Transfer Out'    
    
Select "RecordType" = @Receipts,  "RecordType" = @Receipts,     
"StockType" = @G, ReceiverType = @CFA,     
"ReceiverCode" = IsNull((Select Top 1 IsNull(DL20, N'') From Setup), N''),     
"SenderType" = @FAC,     
"SenderCode" = IsNull(STIA.WareHouseID, N''), "STNNO" = IsNull(STIA.ReferenceSerial, N''),    
"STNDate" = STIA.DocumentDate, "ItemCode" = ic.Category_Name,     
"LOT" = IsNull(STID.Batch_Number, N''),    
"PKM" = IsNull(STID.PKD, N''),     
"QTYKGS" = STID.Quantity * 1000 / (Case IsNull(Items.ReportingUnit, 1)     
   When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End),     
"QTYCASES" = STID.Quantity,     
"QTYUNITS" = STID.Quantity * (Case IsNull(Items.ConversionFactor, 1)     
   When 0 Then 1 Else IsNull(Items.ConversionFactor, 1) End),     
"ItemValue" = STID.Quantity * STID.Rate,     
"ItemDescription" = Items.ProductName,   
"FromState" =IsNull((Select Name From BranchState Where ID = (Select StateInfo From WareHouse Where WareHouseID=STIA.WareHouseID)),0),   
"ToState" =IsNull((Select  Name From BranchState Where ID = (Select StateInfo From Setup)),0),     
"GRNNO" = STIA.DocPrefix + Cast(STIA.DocumentID As nVarChar), "GRNDATE" = STIA.DocumentDate From     
StockTransferInAbstract STIA, StockTransferInDetail STID, Items, ItemCategories ic    
Where STIA.DocSerial = STID.DocSerial And STID.Product_Code = Items.Product_Code     
And Items.CategoryID = ic.CategoryID And     
STIA.DocumentDate Between @FromDate And @ToDate And IsNull(STIA.Status, 0) & 192 = 0    
Union    
Select "RecordType" = @Dispatches, "RecordType" = @Dispatches, "StockType" = @G, ReceiverType = @CFA,     
"ReceiverCode" = IsNull(STOA.WareHouseID, N''),     
"SenderType" = @CFA,     
"SenderCode" = IsNull((Select Top 1 IsNull(DL20, N'') From Setup), N''),     
"STNNO" = IsNull(STOA.Reference, N''),    
"STNDate" = STOA.DocumentDate, "ItemCode" = ic.Category_Name,     
"LOT" = IsNull(STOD.Batch_Number, N''),    
"PKM" = IsNull(bp.PKD, N''),     
"QTYKGS" = STOD.Quantity * 1000 / (Case IsNull(Items.ReportingUnit, 1)     
    When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End),     
"QTYCASES" = STOD.Quantity,     
"QTYUNITS" = STOD.Quantity * (Case IsNull(Items.ConversionFactor, 1)     
    When 0 Then 1 Else IsNull(Items.ConversionFactor, 1) End),     
"ItemValue" = STOD.Quantity * STOD.Rate,     
"ItemDescription" = Items.ProductName,   
"FromState" =IsNull((Select  Name From BranchState Where ID = (Select StateInfo From Setup)),0),     
"ToState" =IsNull((Select Name From BranchState Where ID = (Select StateInfo From WareHouse Where WareHouseID=STOA.WareHouseID)),0),   
"GRNNO" = STOA.DocPrefix + Cast(STOA.DocumentID As nVarChar), "GRNDATE" = STOA.DocumentDate From     
StockTransferOutAbstract STOA, StockTransferOutDetail STOD, Items, ItemCategories ic,    
batch_products bp    
Where STOA.DocSerial = STOD.DocSerial And STOD.Product_Code = Items.Product_Code     
And Items.CategoryID = ic.CategoryID And STOD.Batch_code = bp.Batch_code And     
STOA.DocumentDate Between @FromDate And @ToDate And IsNull(STOA.Status, 0) & 192 = 0    
