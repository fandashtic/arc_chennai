Create proc [dbo].[sp_Get_Customer_RegisterationStatus] (@CustomerName nvarchar(255))
AS

Declare @CustomerShippingStateID int
Declare @CompanyShippingStateID int
Declare @CustomerLocality int
Declare @GSTIN nvarchar(30)
Declare @RegisteredFlag int
Declare @FromStateCode int
Declare @ToStateCode int
Declare @CustomerID nVarchar(30)

Begin
Select @CustomerShippingStateID = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where Isnull(DnDFlag,0) = 1
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

Select @RegisteredFlag RegisteredFlag
