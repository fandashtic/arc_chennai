CREATE PROCEDURE [dbo].[spr_list_goods_received_note](@VENDOR nvarchar(2550),  
           @FROMDATE datetime,  
           @TODATE datetime)  
AS  
Declare @AMENDED	As NVarchar(50)
Declare @CANCELLED	As NVarchar(50)
Declare @CLOSED		As NVarchar(50)
Declare @AMENDMENT	As NVarchar(50)
Declare @OPEN		As NVarchar(50)
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)    
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended',Default)	
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled',Default)
Set @CLOSED	= dbo.LookupDictionaryItem(N'Closed',Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment',Default)
set @OPEN = dbo.LookupDictionaryItem(N'Open',Default)

Create table #tmpVendor(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @VENDOR='%'   
	Insert into #tmpVendor select Vendor_Name from Vendors  
Else  
	Insert into #tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)  
  
SELECT  GRNID, "GRNID" =  GRNPrefix.Prefix + CAST(DocumentID AS nvarchar),   
 "GRN Date" = GRNDate, "Vendor" = Vendors.Vendor_Name,  
 "PO No" = CAST(PONumbers AS nvarchar),   
 "Doc Ref" = DocRef,  
 "Status" =   
 CASE   
 WHEN (GRNStatus & 32) <> 0 THEN @AMENDED
 WHEN (GRNStatus & 64) <> 0 THEN @CANCELLED
 WHEN (GRNStatus & 128) <> 0 THEN @CLOSED 
 WHEN (GRNStatus & 16) <> 0 THEN @AMENDMENT  
 ELSE @OPEN  
 END,  
 "Original GRN" = DocumentIDRef,  
 "Branch" = ClientInformation.Description  
FROM    GRNAbstract
Inner Join Vendors on GRNAbstract.VendorID = Vendors.VendorID
Inner Join VoucherPrefix GRNPrefix on GRNPrefix.TranID = 'GOODS RECEIVED NOTE'
Left Outer Join ClientInformation on GRNAbstract.ClientID = ClientInformation.ClientID
WHERE   GRNDate BETWEEN @FROMDATE AND @TODATE AND  
 Vendors.Vendor_Name IN (Select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpVendor) 
 --AND  GRNAbstract.VendorID = Vendors.VendorID AND  
 --GRNPrefix.TranID = 'GOODS RECEIVED NOTE' AND  
 --GRNAbstract.ClientID *= ClientInformation.ClientID  
Drop Table #tmpVendor 

