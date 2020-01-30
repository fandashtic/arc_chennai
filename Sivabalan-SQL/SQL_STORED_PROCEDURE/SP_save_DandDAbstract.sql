Create Procedure SP_save_DandDAbstract @ClaimID int,@ClaimDate Datetime,@DocumentID nvarchar(255),@ClaimValue int,
@DayCloseDate Datetime,@Status int,@ClaimStatus int,@FromMonth nvarchar(25),@ToMonth nvarchar(25),@Remarks nvarchar(1000),
@OptSelection int = 1,@UserName nvarchar(50) = '',@Customer nvarchar(150) = '', @Address nvarchar(255) = '', @DandDGreen int = 0, @LegendInfo nvarchar(1000) = ''
AS
BEGIN
Declare @FromDate Datetime
Declare @ToDate Datetime
Declare @RemarksDescription nvarchar(1000)
Declare @OpeningDate Datetime
Declare @CustomerID nvarchar(30)
Declare @GSTIN nvarchar(30)
Declare @FromStateCode int
Declare @ToStateCode int

Set DateFormat DMY

Select Top 1 @FromStateCode = isnull(ShippingStateID,0), @OpeningDate = OpeningDate From Setup
Select Top 1 @CustomerID = CustomerID, @ToStateCode = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where isnull(DnDFlag,0) = 1

--Select Top 1 @OpeningDate = OpeningDate From Setup
--Select @FromDate = dbo.mERP_fn_getFromDate(@FromMonth), @ToDate = dbo.mERP_fn_getToDate(@ToMonth)

Set @RemarksDescription = ''

IF @OptSelection = 2
Begin
Select @FromDate = dbo.mERP_fn_getFromDate(@FromMonth), @ToDate = dbo.mERP_fn_getToDate(@ToMonth)
Set @RemarksDescription = @Remarks + ' From ' + Convert(nvarchar(10),@FromDate,103) + ' To ' + Convert(nvarchar(10),@ToDate,103)
--Set @DayCloseDate = @ToDate
End
Else
Begin
Select @FromDate = @OpeningDate, @ToDate = @DayCloseDate
Set @RemarksDescription = @Remarks + ' As On ' + Convert(nvarchar(10), @DayCloseDate, 103)
End

Insert into DandDAbstract(ClaimID,VendorID,ClaimDate,DocumentID,ClaimValue,DayCloseDate,Status,ClaimStatus,FromMonth,
ToMonth,Remarks,OptSelection,FromDate,ToDate,RemarksDescription,UserName,CustomerName,CustomerAddress,DandDGreen,
CustomerID,GSTIN,FromStateCode,ToStateCode,LegendInfo,DandDDate)
Select @ClaimID,'ITC001',@ClaimDate,@DocumentID,@ClaimValue,@DayCloseDate,@Status,@ClaimStatus,@FromMonth,
@ToMonth,@Remarks,@OptSelection,@FromDate,@ToDate,@RemarksDescription,@UserName,@Customer,@Address,@DandDGreen,
@CustomerID,@GSTIN,@FromStateCode,@ToStateCode,@LegendInfo,@ClaimDate

Select @@Identity
END
