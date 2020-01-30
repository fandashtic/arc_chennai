CREATE Procedure spr_ser_negative_margin_details (@ItemCode_Invoice varchar(255))
as
declare @Invid int
declare @ItemCode varchar(15)
DECLARE @Pos int

set @Pos = charindex (';', @ItemCode_Invoice)
Set @ItemCode = Cast(SubString(@ItemCode_Invoice, 1, @Pos-1) as varchar)
Set @Invid = Cast(SubString(@ItemCode_Invoice, @Pos+1, 50) as int)
declare @GRNID int
create table #temp (GRNID int, GRN_ID varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,GRNDate DATETIME, VendorID VARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		   VendorName VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS, BillID varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, InvoiceRef INT, 
		   BillDate DATETIME, Value Decimal(18,6))
INSERT INTO #TEMP
		select GRNID, a.Prefix + cast(DocumentID as varchar), grndate, grnabstract.VendorId, vendor_Name, null,null,null,0 
		from grnabstract, vendors, VoucherPrefix a where grnid in 
			(select grn_id from batch_products where batch_code in
				(select batch_code from invoicedetail 
				 where invoiceid = @invid and 
				 product_code = @Itemcode) and 
				 vendors.vendorid = grnabstract.Vendorid ) and a.TranID = 'GOODS RECEIVED NOTE'



INSERT INTO #TEMP
		select GRNID, a.Prefix + cast(DocumentID as varchar), grndate, grnabstract.VendorId, vendor_Name, null,null,null,0 
		from grnabstract, vendors, VoucherPrefix a where grnid in 
			(select grn_id from batch_products where batch_code in
				(select batch_code from serviceinvoicedetail 
				 where serviceinvoiceid = @invid and 
				 sparecode = @Itemcode) and 
				 vendors.vendorid = grnabstract.Vendorid ) and a.TranID = 'GOODS RECEIVED NOTE'


--SELECT * FROM #TEMP

DECLARE Neg_Mar CURSOR FOR 
   SELECT grnid FROM #temp
   OPEN Neg_Mar 
   FETCH NEXT FROM Neg_Mar INTO @GRNID
   WHILE @@FETCH_STATUS = 0
   BEGIN
	update #temp set #temp.billid = VoucherPrefix.Prefix + Cast(Billabstract.DocumentID as varchar), 
			#temp.InvoiceRef = Billabstract.invoicereference,
			#temp.billdate = billabstract.Billdate, 
			#temp.value = billabstract.value
	from billabstract, VoucherPrefix
	where billabstract.grnid = @GRNID and #temp.grnid = @Grnid and VoucherPrefix.TranID = 'BILL'
      FETCH NEXT FROM Neg_Mar INTO @GRNID
   END
   CLOSE Neg_Mar 
   DEALLOCATE Neg_Mar 
SELECT * FROM #TEMP
DROP TABLE #TEMP
