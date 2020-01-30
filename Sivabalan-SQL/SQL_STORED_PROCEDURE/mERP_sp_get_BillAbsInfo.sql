CREATE PROCEDURE mERP_sp_get_BillAbsInfo(@BillID INT)
AS

Declare @BPreFix nVarChar(50)
Declare @BAPreFix nVarChar(50)

SELECT @BPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL'
SELECT @BAPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL AMENDMENT'


Select 
"BillNumber" = Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
"InvoiceRef" = B.InvoiceReference,
"CreditTerm" = B.CreditTerm,
"BillDate" = B.BillDate,
"GRNID" = B.GRNID,
"GRNDate"  = (Select Max(GRNDate) From  GRNAbstract Where BillID = B.BillID),
"PaymentDate" = B.PaymentDate,
"OvrDisc" = B.Discount,
"AdjAmount" = B.AdjustmentAmount,
"Remarks" = B.Remarks,
"DocType" = B.DocSerialType,
"DocID" = B.DocIDReference,
"PaymentID" = B.PaymentID,
"BillDocumentID" = Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
"ComputeTaxOption" = B.Flags,
"VendorID" = B.VendorID,
"Balance" = B.Balance,
"TaxType" = IsNull(B.TaxType,1)
,"GSTFlag"=GSTFlag ,"StateType"=StateType ,"FromStateCode"=FromStateCode ,"ToStateCode"=ToStateCode ,"GSTIN"=GSTIN 
,"ODNumber" = B.ODNumber
From BillAbstract B
Where B.BILLID = @BillID
