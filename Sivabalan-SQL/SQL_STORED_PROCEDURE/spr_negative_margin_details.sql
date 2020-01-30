CREATE Procedure spr_negative_margin_details (@ItemCode_Invoice nvarchar(255))
as
declare @Invid int  
declare @ItemCode nvarchar(15)  
DECLARE @Pos int  
  
set @Pos = charindex (N';', @ItemCode_Invoice)  
Set @ItemCode = Cast(SubString(@ItemCode_Invoice, 1, @Pos-1) as nvarchar)  
Set @Invid = Cast(SubString(@ItemCode_Invoice, @Pos+1, 50) as int)  
declare @GRNID Int
declare @vGRNID as nvarchar(25)

create table #temp (GRNID int, GRN_ID nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,GRNDate DATETIME, VendorID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,   
     VendorName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, BillID nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, InvoiceRef VarChar(255),   
     BillDate DATETIME, Value Decimal(18,6))  
INSERT INTO #TEMP  
  select GRNID, a.Prefix + cast(DocumentID as nvarchar), grndate, grnabstract.VendorId, vendor_Name, null,null,null,0   
  from grnabstract, vendors, VoucherPrefix a where grnid in   
   (select grn_id from batch_products where batch_code in  
		(select batch_code from invoicedetail   
     where invoiceid = @invid and   
     product_code = @Itemcode) and   
     vendors.vendorid = grnabstract.Vendorid ) and a.TranID = N'GOODS RECEIVED NOTE'  
--SELECT * FROM #TEMP  
  DECLARE Neg_Mar CURSOR FOR   
   SELECT grnid FROM #temp  
   OPEN Neg_Mar   
   FETCH NEXT FROM Neg_Mar INTO @GRNID 
   Set @vGRNID = Cast(@GRNID as nvarchar) 
   WHILE @@FETCH_STATUS = 0  
   BEGIN  
 update #temp set #temp.billid = VoucherPrefix.Prefix + Cast(Billabstract.DocumentID as nvarchar),   
   #temp.InvoiceRef = Billabstract.invoicereference,  
   #temp.billdate = billabstract.Billdate,   
   #temp.value = billabstract.value  
 from billabstract, VoucherPrefix  
 where 
   --billabstract.grnid = @GRNID 
   (@vGRNID = Cast(BillAbstract.GRNid as nvarchar) Or
   (billabstract.GRNID like (@vGrnID + N',%') or billabstract.GRNID like (N'%,' + @vGrnID + N',%') 
    or billabstract.GRNID like (N'%,' + @vGrnID)))
   and #temp.grnid = @Grnid 
   and VoucherPrefix.TranID = N'BILL'  
     FETCH NEXT FROM Neg_Mar INTO @GRNID  
     Set @vGRNID = Cast(@GRNID as nvarchar) 
   END  
   CLOSE Neg_Mar   
   DEALLOCATE Neg_Mar   
SELECT * FROM #TEMP  
DROP TABLE #TEMP  

