Create Procedure spr_list_TransferOut_Detail_Consolidated(@DocSerial NVarchar(50))  
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
Select max(StockTransferOutDetail.Product_Code),  
"Item Code" =  max(StockTransferOutDetail.Product_Code),  
"Item Name" = max(Items.ProductName), "Batch" = max(StockTransferOutDetail.Batch_Number),  
"PKD" = max(Batch_Products.PKD), "Expiry" = max(Batch_Products.Expiry),  
"Quantity" =  Sum(StockTransferOutDetail.Quantity),   
"Rate" = max(StockTransferOutDetail.Rate),  
"Amount" =  Sum(StockTransferOutDetail.Amount),  
"PTS" = max(StockTransferOutDetail.PTS),  
"PTR" = max(StockTransferOutDetail.PTR),  
"ECP" = max(StockTransferOutDetail.ECP)  
From StockTransferOutDetail, Batch_Products, Items  
Where StockTransferOutDetail.DocSerial = @DocID And  
StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code And  
StockTransferOutDetail.Product_Code = Items.Product_Code  
Group By StockTransferOutDetail.Serial  
Order By StockTransferOutDetail.Serial  
End
Else
Begin
Select 
'',
"Item Code" = ReportDetailReceived.Field1,
"Item Name" = ReportDetailReceived.Field2,
"Batch" = ReportDetailReceived.Field3,
"PKD" =ReportDetailReceived.Field4,
"Expiry"=ReportDetailReceived.Field5,
"Quantity" = ReportDetailReceived.Field6,
"Rate" = ReportDetailReceived.Field7,
"Amount" = ReportDetailReceived.Field8,
"PTS" = ReportDetailReceived.Field9,
"PTR" = ReportDetailReceived.Field10,
"ECP" = ReportDetailReceived.Field11
From ReportDetailReceived
Where 
ReportDetailReceived.Field1 <> N'Item Code' And ReportDetailReceived.Field1 <> N'SubTotal:' And
ReportDetailReceived.Field1 <> N'GrandTotal:' And ReportDetailReceived.RecordID = @DocSerial 
End
