CREATE PROCEDURE [dbo].[sp_acc_rpt_billdetail](@BILLID int)  
AS  
DECLARE @SPECIALCASE2 INT  
Declare @Version Int  
SET @SPECIALCASE2=5  
  
Set @Version = dbo.sp_acc_getversion()  

If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19 or @Version=11
 Execute sp_acc_rpt_billdetailuom @BILLID  
Else If @Version = 9 or @Version = 10  
 Execute sp_acc_rpt_billdetailserial @BILLID  
Else  
Begin  
 SELECT  "Item Code" = BillDetail.Product_Code,   
  "Item Name" = Items.ProductName, "Quantity" = BillDetail.Quantity,   
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
  Left Join Billabstract on Billdetail.Billid = Billabstract.Billid  
  WHERE   BillDetail.BillID = @BILLID 
  --AND  BillDetail.Product_Code *= Items.Product_Code  
  --and  Billdetail.Billid *= Billabstract.Billid
End  
