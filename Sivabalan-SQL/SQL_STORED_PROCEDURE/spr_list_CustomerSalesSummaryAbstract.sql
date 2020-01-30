CREATE Procedure spr_list_CustomerSalesSummaryAbstract(@FromDate DateTime,@Todate DateTime)
As

Declare @OPEN As NVarchar(50)
Declare @CLOSED As NVarchar(50)

Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default)

Select DocumentNumber,"Document Number "= DocumentNumber,"Document Date "= DocumentDate,
	"Company "= CompanyForumCode, "Status "= (Case status when 1 then @CLOSED Else @OPEN end)
	From CustomerSalesSummaryAbstract Where DocumentDate BetWeen @FromDate and @Todate


