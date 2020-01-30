Create proc [dbo].[sp_Get_CustomerStatus] (@CustomerID nvarchar(30), @InvNo int = 0, @InvMode int = 0)
AS

Declare @CustomerShippingStateID int
Declare @CompanyShippingStateID int
Declare @CustomerLocality int
Declare @GSTIN nvarchar(30)
Declare @RegisteredFlag int
Declare @FromStateCode int
Declare @ToStateCode int

IF @InvMode = 0
Begin
Select @CustomerShippingStateID = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where CustomerID = @CustomerID
Select Top 1 @CompanyShippingStateID = isnull(ShippingStateID,0) From Setup

IF @CustomerShippingStateID =  @CompanyShippingStateID
Set @CustomerLocality = 1
Else
Set @CustomerLocality = 2

IF isnull(@GSTIN, '') = ''
Set @RegisteredFlag = 2
Else
Set @RegisteredFlag = 1
End
Else
Begin

Select @FromStateCode = FromStateCode, @ToStateCode = ToStateCode, @GSTIN = GSTIN
--, @RegisteredFlag = isnull(RegisterStatus,0)
From InvoiceAbstract Where InvoiceID = @InvNo

IF isnull(@FromStateCode,0) = isnull(@ToStateCode,0)
Set @CustomerLocality = 1
Else
Set @CustomerLocality = 2

IF isnull(@GSTIN, '') = ''
Set @RegisteredFlag = 2
Else
Set @RegisteredFlag = 1
End

Select @CustomerLocality GSTLocality, @RegisteredFlag RegisteredFlag
