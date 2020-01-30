Create Procedure spr_list_SalesPaymentMode_Detail_ITC
(
 @CreditId NVarChar(100),
 @FromDate DateTime,
 @ToDate DateTime,
 @Base nVarchar(50)
)
As
Declare @LenStr Int
Declare @PayMode NVarChar(10)
Declare @InvOrCust NVarChar(10)

Set @LenStr = CharIndex(',', @CreditID)
Set @PayMode = SubString(@CreditID,1,@LenStr - 1)
Set @InvOrCust = SubString(@CreditID,(@LenStr + 1),1)

If @InvOrCust  = '1' 
 Select
  IsNull(IA.DocumentID,''),
  "Invoice ID" = IsNull((Select Prefix From VoucherPrefix Where TranId = N'INVOICE'),'') + Cast(IsNull(IA.DocumentID,'') As NVarChar),
  "Invoice Date" = IsNull(IA.InvoiceDate,''),
  "Customer" = IsNull((Select Company_Name From Customer Where CustomerId = IA.CustomerID),''),
  "Net Value (%c)" = IsNull(NetValue,0),
  "Amount Adjusted (%c) " = IsNull(AdjustedAmount,0)
 From
  InvoiceAbstract IA
 Where
  (IsNull(IA.Status,0) & 128) = 0 
  And IA.InvoiceType In (1, 3) 
  And IA.InvoiceDate Between @FromDate And @ToDate 
  And IA.PaymentMode = @PayMode

Else
 Select
  IsNull(IA.DocumentID,''),
  "Customer" = IsNull((Select Company_Name From Customer Where CustomerId = IA.CustomerID),''),
  "Net Value (%c)" = IsNull(NetValue,0),
  "Amount Adjusted (%c) " = IsNull(AdjustedAmount,0)
 From
  InvoiceAbstract IA
 Where
  (IsNull(IA.Status,0) & 128) = 0 
  And IA.InvoiceType In (1, 3) 
  And IA.InvoiceDate Between @FromDate And @ToDate
  And IA.PaymentMode = @PayMode

