create PROCEDURE spr_list_cancelled_bills(@FROMDATE datetime,   
    @TODATE datetime)  
AS

Declare @CANCELLED As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)

SELECT  BillID, "BillID" = CASE   
 WHEN DocumentReference IS NULL THEN  
 BillPrefix.Prefix + CAST(DocumentID AS nvarchar)  
 ELSE  
 BillAPrefix.Prefix + CAST(DocumentID AS nvarchar)  
 END,  
 "Bill Date" = BillDate, "Vendor" = Vendors.Vendor_Name,   
 "Gross Amount" = Value, "Tax Amount" = TaxAmount,   
 "Adjustment Amount" = AdjustmentAmount,   
 "Net Amount" = Value + TaxAmount + AdjustmentAmount,  
 "GRNID" = GRNPrefix.Prefix + CAST(NewGRNID AS nvarchar),  
 "Status" =@CANCELLED,
 "InvoiceReference" = InvoiceReference,  
 "Original Bill" = CASE DocumentReference  
 WHEN NULL THEN N''  
 ELSE BillPrefix.Prefix + CAST(DocumentReference AS nvarchar)  
 END,  
 "Branch" = ClientInformation.Description,
 "Remarks" = BillAbstract.Remarks  ,
 "TaxType"= Case isnull(BillAbstract.taxtype,0) 
	when 1 then 'LST' 
	when 2 then 'CST' 
	when 3 then 'FLST'  
 	When 0 Then 
		Case when(BillAbstract.StateType>0) Then 'GST' Else '' End 
	Else '' End
FROM BillAbstract
Left Outer Join Vendors On BillAbstract.VendorID = Vendors.VendorID
Inner Join VoucherPrefix BillPrefix On  BillPrefix.TranID = N'BILL' 
Inner Join  VoucherPrefix GRNPrefix On GRNPrefix.TranID = N'GOODS RECEIVED NOTE'
Inner Join VoucherPrefix BillAPrefix  On BillAPrefix.TranID = N'BILL AMENDMENT' 
Left Outer Join ClientInformation On BillAbstract.ClientID = ClientInformation.ClientID
WHERE BillDate BETWEEN @FROMDATE AND @TODATE AND  
Status&64<>0
ORDER BY BillAbstract.BillDate  

