Create Procedure spr_list_TransferIn_Detail_Consolidated(@DocSerial NVarchar(50))  
As  
Declare @FREE As NVarchar(50)  
Declare @ComIDReport NVarchar(50)
Declare @ComIDSetup NVarchar(50)
Declare @DocID Int
Select @ComIDReport = Right(@DocSerial,(Select Len(RegisteredOwner) From Setup))
Select @ComIDSetup = RegisteredOwner From Setup 
If @ComIDReport = @ComIDSetup 
Begin  
Select @DocID=Left(@DocSerial,Len(@DocSerial)-(Select Len(RegisteredOwner) From Setup))
Select StockTransferInDetail.Product_Code,  
"Item Code" = StockTransferInDetail.Product_Code,  
"Item Name" = Items.ProductName, "Quantity" = Sum(StockTransferInDetail.Quantity),  
"Rate" = StockTransferInDetail.Rate, "Amount" = Sum(StockTransferInDetail.Amount),   
"Batch" = StockTransferInDetail.Batch_Number,  
"Expiry" = StockTransferInDetail.Expiry, "PKD" = StockTransferInDetail.PKD,   
"PTS" = StockTransferInDetail.PTS, "PTR" = StockTransferInDetail.PTR,  
"ECP" = StockTransferInDetail.ECP  
From StockTransferInDetail, Items  
Where StockTransferInDetail.DocSerial = @DocID And  
StockTransferInDetail.Product_Code = Items.Product_Code  
Group By StockTransferInDetail.Product_Code, Items.ProductName,  
StockTransferInDetail.Batch_Number, StockTransferInDetail.Expiry, StockTransferInDetail.PKD,  
StockTransferInDetail.PTS, StockTransferInDetail.PTR, StockTransferInDetail.ECP,  
StockTransferInDetail.Rate  
End
Else
Begin
Select 
'',
"Item Code" = ReportDetailReceived.Field1,
"Item Name" = ReportDetailReceived.Field2,
"Quantity" = ReportDetailReceived.Field3,
"Rate" =ReportDetailReceived.Field4,
"Amount"=ReportDetailReceived.Field5,
"Batch" = ReportDetailReceived.Field6,
"Expiry" = ReportDetailReceived.Field7,
"PKD" = ReportDetailReceived.Field8,
"PTS" = ReportDetailReceived.Field9,
"PTR" = ReportDetailReceived.Field10,
"ECP" = ReportDetailReceived.Field11
From ReportDetailReceived
Where 
ReportDetailReceived.Field1 <> N'Item Code' And ReportDetailReceived.Field1 <> N'SubTotal:' And
ReportDetailReceived.Field1 <> N'GrandTotal:' And ReportDetailReceived.RecordID = @DocSerial 
End
