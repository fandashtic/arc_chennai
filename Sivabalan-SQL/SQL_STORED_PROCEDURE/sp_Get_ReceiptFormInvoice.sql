CREATE Procedure sp_Get_ReceiptFormInvoice (@Customer nvarchar(20),
											@FromDate DateTime,
											@ToDate DateTime,
											@FormFlag Int,
											@RecptFlag Int)
As
Declare @CForm Int
Declare @DForm Int

Set @CForm = 4
Set @DForm = 8

Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),
Customer.CustomerID, Customer.Company_Name, InvoiceAbstract.InvoiceDate, 
(Flags & 32), (Flags & 64), (Flags & @CForm), (Flags & @DForm), CFormNo, DFormNo
From InvoiceAbstract, Customer, VoucherPrefix
Where InvoiceAbstract.CustomerID = Customer.CustomerID
And InvoiceAbstract.CustomerID like @Customer
And (InvoiceAbstract.Flags & 12) = @FormFlag
And (InvoiceAbstract.Flags & @RecptFlag) <> @RecptFlag
And (InvoiceAbstract.Flags & 128) = 0
And (InvoiceAbstract.Status & 128) = 0
And InvoiceType In (1, 3, 4)
And VoucherPrefix.TranID = 'INVOICE'
And InvoiceDate Between @FromDate And @ToDate
Order By Customer.CustomerID



