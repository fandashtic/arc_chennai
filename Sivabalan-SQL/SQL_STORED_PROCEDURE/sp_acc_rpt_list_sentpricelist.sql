CREATE Procedure sp_acc_rpt_list_sentpricelist 
(
@ProductHierarchy nVarchar(250),
@Category nVarchar(250),
@FromDate Datetime,
@ToDate Datetime
)
As

Create Table #PriceListAbstract
(
	PLDesc 		nVarchar(255),
	PLDate 		Datetime,
	SentTo 		nVarchar(4000),
	NoOfItems	Int Default 0
)


Create Table #tempCategory
(CategoryID int,Status int)
Exec dbo.GetLeafCategories @ProductHierarchy, @Category

Declare @Prefix nVarchar(50)
Select @Prefix = Prefix from VoucherPrefix where [TranID]= N'SEND PRICE LIST'

Select Distinct 
ltrim(rtrim(@ProductHierarchy)) + N'€' + 
ltrim(rtrim(@Category)) + N'€' + 
ltrim(rtrim(Cast(SPL.DocumentID as nvarchar(50)))),
@Prefix + ltrim(rtrim(Cast(SPL.SendPriceListID  as nvarchar(50)))) as 'Sent Price List ID',
SPL.PriceListDate as 'Price List Date',
case 
	When SPL.PriceListFor = 0 then dbo.LookupDictionaryItem('Customer',Default)
	Else dbo.LookupDictionaryItem('Branch',Default)
End
as 'Customer/Branch',
dbo.sp_acc_GetCustBR(SPL.DocumentID) as 'Sent To',
(Select count(1) from SendPriceListItem where DocumentID = SPL.DocumentID) as 'No. of Items'
From 
SendPriceList SPL,SendPriceListItem SPLI
Where SPL.PriceListDate between @FromDate and @ToDate
and SPL.DocumentID = SPLI.DocumentID
and SPLI.Product_Code in 
(select Product_code from items where categoryid In (Select CategoryID From #tempCategory))

Drop Table #PriceListAbstract






