CREATE PROCEDURE [dbo].[sp_acc_prn_invoicedetailUOM_count](@INVOICEID int)  
AS
SELECT  count(1)  
FROM InvoiceDetail
Join Items on InvoiceDetail.Product_Code = Items.Product_Code 
Left Join UOM on InvoiceDetail.UOM = UOM.UOM 
--InvoiceDetail, Items,UOM   
WHERE   InvoiceDetail.InvoiceID = @INVOICEID 
--AND InvoiceDetail.Product_Code = Items.Product_Code 
--And InvoiceDetail.UOM *= UOM.UOM  
