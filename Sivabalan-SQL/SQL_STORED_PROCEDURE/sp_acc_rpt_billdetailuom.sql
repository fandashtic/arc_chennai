CREATE PROCEDURE [dbo].[sp_acc_rpt_billdetailuom](@BILLID int)  
AS  
DECLARE @SPECIALCASE2 INT  
SET @SPECIALCASE2=5  
  
SELECT  "Item Code" = BillDetail.Product_Code,   
 "Item Name" = Items.ProductName,"Description" = UOM.[Description],  
 "UOM Qty" = BillDetail.UOMQty,"UOM Price" = BillDetail.UOMPrice,  
 "Rate" = BillDetail.PurchasePrice, 
 "Discount" = 
 case
		when billabstract.discountoption = 1 then cast((BillDetail.discount + dbo.sp_acc_getItemLevelDiscount(@BILLID,BillDetail.Serial,1)) as nvarchar(200)) + dbo.LookupDictionaryItem(' %',Default)
		when billabstract.discountoption = 2 then cast((BillDetail.discount + dbo.sp_acc_getItemLevelDiscount(@BILLID,BillDetail.Serial,2)) as nvarchar(200))
 end,
 "Gross Amount" = BillDetail.Amount,  
 "Tax Suffered" = BillDetail.TaxSuffered, "Tax Amount" = BillDetail.TaxAmount,  
 "Total" = BillDetail.Amount + BillDetail.TaxAmount,@SPECIALCASE2  
 FROM BillDetail
 Left Join Items on BillDetail.Product_Code = Items.Product_Code
 Left Join UOM on BillDetail.UOM = UOM.UOM
 Left Join BillAbstract on Billdetail.Billid = Billabstract.Billid 
 WHERE BillDetail.BillID = @BILLID 
 --AND BillDetail.Product_Code *= Items.Product_Code  
 --and BillDetail.UOM *= UOM.UOM  and
 --Billdetail.Billid *= Billabstract.Billid  
