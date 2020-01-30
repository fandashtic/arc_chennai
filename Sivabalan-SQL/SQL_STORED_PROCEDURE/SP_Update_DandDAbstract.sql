
Create Procedure SP_Update_DandDAbstract(@ID int, @FromMonth nvarchar(25), @ToMonth nvarchar(25), @Remarks nvarchar(1000),
@Value decimal(18,6),@OptSelection int = 1, @UserName nvarchar(50) = '', @Customer nvarchar(150) = '',
@Address nvarchar(255) = '', @DandDGreen int = 0, @LegendInfo nvarchar(1000) = '', @ClaimDate Datetime = Null)
AS
Begin

Declare @CustomerID nvarchar(30)
Declare @GSTIN nvarchar(30)
Declare @FromStateCode int
Declare @ToStateCode int

Select Top 1 @FromStateCode = isnull(ShippingStateID,0) From Setup
Select Top 1 @CustomerID = CustomerID, @ToStateCode = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where isnull(DnDFlag,0) = 1

Update DandDAbstract Set
Remarks = @Remarks,
ClaimValue=@Value,
UserName = @UserName,
CustomerName = @Customer,
CustomerAddress = @Address,
DandDGreen = @DandDGreen,
CustomerID = @CustomerID,
GSTIN = @GSTIN,
FromStateCode = @FromStateCode,
ToStateCode = @ToStateCode,
LegendInfo = @LegendInfo
,DandDDate = @ClaimDate
Where
ID = @ID

End
