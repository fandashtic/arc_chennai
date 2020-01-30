CREATE PROCEDURE spr_stock_ageing_report(@ProductCode as nvarchar(15))    
AS    
Declare @MLOpeningStockSalesReturnSaleable NVarchar(50)
Declare @MLOpeningDamagesStockAdjDamages NVarchar(50)
Declare @MLSalesReturnDamages NVarchar(50)
Set @MLOpeningStockSalesReturnSaleable = dbo.LookupDictionaryItem(N'Opening Stock/Sales Return Saleable', Default)
Set @MLOpeningDamagesStockAdjDamages = dbo.LookupDictionaryItem(N'Opening Damages/Stock Adj Damages', Default)
Set @MLSalesReturnDamages = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)

 SELECT Items.Product_Code,     
 "GRNID" = case    
 WHEN GRN_ID IS NULL THEN     
 	Case     
 	When StockTransferID Is Null Then     
 		Case  IsNull(Damage,0)
 		WHEN 0 then
		@MLOpeningStockSalesReturnSaleable
		WHEN 1 then
		@MLOpeningDamagesStockAdjDamages
		WHEN 2 then
		@MLSalesReturnDamages
		End 
	Else    
	IsNull(DocPrefix, N'')     
	+ Cast(StockTransferInAbstract.DocumentID As nvarchar)      
	End    
 ELSE VoucherPrefix.Prefix + CAST(GRNAbstract.DocumentID AS nvarchar) 
 END,     
 "Age (Days)" = Case
        When (GRNAbstract.GRNID IS NULL) And (StockTransferInAbstract.DocSerial Is Null) Then DateDiff(dd, Batch_Products.CreationDate, getdate())
		Else
		case 
			WHEN GRN_ID IS NULL THEN
			case when StockTransferID Is Not Null Then DATEDIFF(dd, DocumentDate, GETDATE())
            End
			ELSE DATEDIFF(dd, GRNAbstract.GRNDate, GETDATE()) 
            END 
        END,
 "On Hand Qty" = Batch_Products.Quantity, 
 "Quantity Received" = Batch_Products.QuantityReceived,

 "SIT Qty" = (Select Sum(IDR.Quantity) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR
				where IDR.InvoiceID IN (Select RecdInvoiceID from GRNAbstract where GRNAbstract.GRNID = Batch_Products.GRN_ID)
				And IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0)  -
			(select Sum(A.QuantityReceived) from Batch_Products A
			where A.grn_id <= Batch_Products.GRN_ID
			And ((A.Grn_Id IN (Select B.GRNID from GRNABstract B, InvoiceDetailReceived  c, InvoiceAbstractReceived d
			where B.RecdInvoiceID = C.InvoiceId And C.Product_Code = Items.Product_Code And c.InvoiceID = d.InvoiceID And d.Status & 64 = 0
            and B.Grnid <= Batch_Products.GRN_ID 
			And B.RecdInvoiceID = GRNAbstract.RecdInvoiceID )
			Or A.grn_id = Batch_Products.GRN_ID))
			And A.Product_Code = Items.Product_Code
			And A.grn_id Not In (Select Distinct GRNID From GRNAbstract Where grnstatus & 32 = 32 OR grnstatus & 64 = 64 )),

 "Vendor Name" = (select vendor_name from vendors where vendorid = GRNAbstract.VEndorID),
 "Doc Ref" = GRNAbstract.DocRef
FROM  Items, VoucherPrefix, 
	Batch_Products LEFT OUTER JOIN GRNAbstract on Batch_Products.GRN_ID = GRNAbstract.GRNID 
		       LEFT OUTER JOIN StockTransferInAbstract on Batch_Products.StockTransferID =  StockTransferInAbstract.DocSerial
WHERE    
	(ISNULL(Batch_Products.Quantity, 0) + ISNULL(Batch_Products.QuantityReceived, 0)) > 0 AND
	Batch_Products.Product_Code = Items.Product_Code AND
	VoucherPrefix.TranID = N'GOODS RECEIVED NOTE' AND
	Items.Product_Code = @ProductCode AND
	Batch_Products.GRN_ID Not In (Select Distinct GRNID From GRNAbstract Where grnstatus & 32 = 32 OR grnstatus & 64 = 64 )

