CREATE PROCEDURE spr_list_StkAdjReturnAbstract(@VENDOR nvarchar(2550),  
            @FROMDATE datetime,  
            @TODATE datetime)  
AS  
Declare @Delimeter as Char(1)  
Declare @AMENDED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)

Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @Delimeter=Char(15)
    
Create table #tmpVendor(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @VENDOR=N'%'   
	Insert into #tmpVendor select Vendor_Name from Vendors  
Else  
	Insert into #tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)  
  
SELECT  "Doc Serial" = AdjustmentID,   
"AdjustmentID" = AdjPrefix.Prefix + CAST(DocumentID AS nvarchar),   
"Date" = AdjustmentDate,  
"Vendor" = Vendors.Vendor_Name,  
"Value" = AdjustmentReturnAbstract.Value,  
"Balance" = AdjustmentReturnAbstract.Balance,  
"Status" = Case   
When (IsNull(Status, 0) & 192) = 192 Then  
@CANCELLED
When (IsNull(Status, 0) & 128) = 128 Then  
@AMENDED
Else  
N''  
End,  
Reference  
FROM AdjustmentReturnAbstract, Vendors, VoucherPrefix BillPrefix,  
 VoucherPrefix AdjPrefix  
WHERE   AdjustmentDate BETWEEN @FROMDATE AND @TODATE AND  
 Vendors.Vendor_Name IN (Select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpVendor) AND  
 AdjustmentReturnAbstract.VendorID = Vendors.VendorID AND  
 BillPrefix.TranID = N'BILL' AND  
 AdjPrefix.TranID = N'STOCK ADJUSTMENT PURCHASE RETURN'  
Drop Table #tmpVendor  




