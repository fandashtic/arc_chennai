Create PROCEDURE sp_print_BillAbstract(@BillNo INT)      
AS      
  
Declare @CANCELLED As NVarchar(50)  
Declare @AMENDED As NVarchar(50)  
Declare @AMENDMENT As NVarchar(50)  
  
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)  
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)  
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)  
  
Declare @ItemCount int  
SELECT @ItemCount = Count(*) FROM BillDetail, Items  
WHERE BillDetail.BillID = @BillNo AND   
BillDetail.Product_Code = Items.Product_Code    
  
SELECT "Bill Date" = BillDate, "GRNID" = GRN.Prefix + CAST(NewGRNID AS nvarchar),       
"Vendor" = Vendors.Vendor_Name, "VendorID" = BillAbstract.VendorID,      
"Value" = BillAbstract.Value,       
"Reference" = InvoiceReference,       
"Status" = Case When (Status & 192)=192 then @CANCELLED  
 When (Status & 128)=128 then @AMENDED  
 When (BillAbstract.Billreference)<>0 then @AMENDMENT  
Else N'' End,   
"Bill No" = Bill.Prefix + CAST(DocumentID AS nvarchar),       
"Tax Amount" = BillAbstract.TaxAmount,      
"Adjustment Amount" = BillAbstract.AdjustmentAmount,   
"Write Off" = (Select Sum(Amount) from AdjustmentReference Where InvoiceID = @BillNo  
And TransactionType = 1 and DocumentType = 2),  
"Additional Adjustment" = (Select Sum(Amount) from AdjustmentReference Where InvoiceID = @BillNo  
And TransactionType = 1 and DocumentType = 5),  
"Net Amount" = BillAbstract.Value + BillAbstract.TaxAmount,    
"Doc ID" = BillAbstract.DocIDReference,    
"TIN Number" = TIN_Number,    
"Doc Type" = DocSerialType,  
"ITEM COUNT" = @ItemCount,   
"Bill Discount %" = ISNull(BillAbstract.Discount,0),  
"Bill Disc Amount" = (ISNull(BillAbstract.Value,0)/(100-ISNull(BillAbstract.Discount,0))*100) -IsNull(BillAbstract.Value,0),
--"Tax Type" = IsNull(TaxType.taxType,'')
"Tax Type" = Case When isnull(StateType,0) > 0 Then 'GST' 
				Else Case When IsNull(BillAbstract.TaxType,1) = 1 Then 'LST' When IsNull(BillAbstract.TaxType,1) = 2 Then 'CST' 
						When IsNull(BillAbstract.TaxType,1) = 3 Then 'FLST' End 
			End
FROM BillAbstract, Vendors, VoucherPrefix GRN, VoucherPrefix Bill --, tbl_merp_TaxType TaxType      
WHERE BillAbstract.BillID = @BillNo       
AND BillAbstract.VendorID = Vendors.VendorID      
--AND IsNull(BillAbstract.TaxType,1) = TaxType.TaxID
AND GRN.TranID = N'GOODS RECEIVED NOTE'      
AND Bill.TranID = N'BILL'

