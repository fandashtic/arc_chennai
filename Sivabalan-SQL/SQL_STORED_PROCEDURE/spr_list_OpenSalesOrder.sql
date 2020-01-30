CREATE procedure [dbo].[spr_list_OpenSalesOrder](@FROMDATE datetime,  
         @TODATE datetime)  
AS  
SELECT SONumber, "SC Number" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),   
 "Customer" = Customer.Company_Name, "SC Date" = SODate,  
 "Delivery Date" = DeliveryDate, Value,"PO Reference" = PODocReference,  
 "Status" = (Case When (isnull(SoRef,0) >0) then 'Amendment'   
      Else 'Open' End)  
FROM SOAbstract, Customer, VoucherPrefix
WHERE SODate BETWEEN @FROMDATE AND @TODATE   
 AND (Status & 256) =0 AND (Status & 128) =0       
 AND SOAbstract.CustomerID *= Customer.CustomerID  
 AND VoucherPrefix.TranID = 'SALE CONFIRMATION'
