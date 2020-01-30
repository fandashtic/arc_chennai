CREATE procedure [dbo].[sp_print_DispatchAbstract](@DISPATCHID INT)
AS
SELECT "Dispatch Date" = DispatchDate, 
"Customer" = Customer.Company_Name, 
"CustomerID" = Customer.CustomerID,
"Address" = DispatchAbstract.BillingAddress, 
"Shipping Address" = DispatchAbstract.ShippingAddress,
"Reference" = CASE Status & 7
WHEN 4 THEN
PO.Prefix
WHEN 1 THEN
SO.Prefix
Else
N''
END
+ CAST(RefNumber AS nvarchar), 
"Invoice No" = Inv.Prefix + CAST(InvoiceID AS nvarchar), 
"Dispatch No" = Dis.Prefix + CAST(DocumentID AS nvarchar), 
"MemoLabel1" = MemoLabel1, "MemoLabel2" = MemoLabel2, "MemoLabel3" = MemoLabel3, 
"Memo1" = Memo1, "Memo2" = Memo2, "Memo3" = Memo3,
"Salesman Name" = (SELECT Salesman.SalesMan_Name FROM SalesMan Where SalesmanID = Beat_Salesman.SalesManID),
"ST" = TNGST,"CST" = CST,
"Doc ID" = DispatchAbstract.DocRef,
"TIN Number" = TIN_Number,
"Alternate Name" = Alternate_Name,
"Doc Type" = DocSerialType
FROM DispatchAbstract, Customer, VoucherPrefix Dis, VoucherPrefix Inv, Beat_SalesMan,
VoucherPrefix PO, VoucherPrefix SO
WHERE DispatchAbstract.DispatchID = @DISPATCHID AND
DispatchAbstract.CustomerID = Customer.CustomerID AND
DispatchAbstract.CustomerID *= Beat_Salesman.CustomerID And
PO.TranID = N'PURCHASE ORDER' AND SO.TranID = N'SALE CONFIRMATION' AND
Inv.TranID = N'INVOICE' AND Dis.TranID = N'DISPATCH'
