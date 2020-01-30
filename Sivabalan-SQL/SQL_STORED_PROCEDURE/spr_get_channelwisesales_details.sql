Create procedure spr_get_channelwisesales_details(
@ChannelCumMrcType nVarchar(2500),
@FromDate datetime,
@ToDate datetime)
as
DECLARE @CHANNEL nVarchar(255)
DECLARE @MrcTypeList nVarchar(2000)
DECLARE @Prefix nvarchar(50)
Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)
Create Table #tmpMerchandiseType (ID Integer Identity(1,1), MerchandiseType nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpResult (CustID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, InvoiceDate DateTime, TotalSales Decimal(18,6), MapFlag int Default 0)

If Len(@ChannelCumMrcType) > 1
Begin
Select @CHANNEL = Substring(@ChannelCumMrcType,1, CHARINDEX(@Delimeter,@ChannelCumMrcType)-1)
Select @MrcTypeList = Substring(@ChannelCumMrcType,CHARINDEX(@Delimeter,@ChannelCumMrcType)+1,Len(@ChannelCumMrcType))
End

If @MrcTypeList=N'%'
Begin
Insert into #tmpMerchandiseType select Merchandise from Merchandise Order By Merchandise
End
Else
Begin
Insert into #tmpMerchandiseType select * from dbo.sp_SplitIn2Rows(@MrcTypeList,@Delimeter)
End

SELECT @Prefix = Prefix From VoucherPrefix
 Where TranID = 'INVOICE'
Insert into #tmpResult
Select customer.customerid, customer.customerid, customer.company_name, Case IsNull(GSTFlag,0) when 0 then @Prefix+cast(invoiceabstract.documentid as nvarchar)else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, invoiceabstract.invoicedate,
Case invoicetype
when 4 then
0-invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)
else
invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)
END, 0
from customer,invoiceabstract where invoiceabstract.customerid=customer.customerid and
IsNull(customer.channeltype, 0)= IsNull(@channel, 0) and
invoiceabstract.invoicedate between @FromDate and @ToDate and
invoiceabstract.InvoiceType in (1, 3,4) AND( (Status & 128) = 0)


Declare @MrcTypeCnt Int
Declare @RecCnt Int, @tmpMrcType nVarchar(255)
Declare @QryString nVarchar(4000), @VarString3 nVarchar(2000)
Declare @ColSelected nVarchar(2000)
Select @MrcTypeCnt = Count(*) From #tmpMerchandiseType
Set @QryString = N''
Set @ColSelected = N''
SET @RecCnt = 1
While @RecCnt <= @MrcTypeCnt
Begin
Select @tmpMrcType = MerchandiseType From #tmpMerchandiseType Where ID = @RecCnt
Set @VarString3 = N'Alter table #tmpResult Add [' + @tmpMrcType + N'] nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS'
Exec sp_executesql @VarString3

Set @VarString3 = 'Update tmp Set [' + @tmpMrcType + '] = '+ CHAR(39)+ N'Yes' +CHAR(39)+ ', MapFlag = 1 From #tmpResult tmp, CustMerchandise CustMrc
Where tmp.CustomerID = CustMrc.CustomerID and
CustMrc.MerchandiseID = (select MerchandiseID From Merchandise Where Merchandise =N' + CHAR(39)+@tmpMrcType + CHAR(39)+')'
Exec sp_executesql @VarString3

Set @VarString3 = 'Update #tmpResult Set [' + @tmpMrcType + '] = '+ CHAR(39)+ N'No' +CHAR(39)+  ' Where [' + @tmpMrcType + '] Is Null'
Exec sp_executesql @VarString3
Set @RecCnt = @RecCnt + 1
Set @ColSelected = @ColSelected + ',['+ @tmpMrcType +']'
End

SET @QryString = 'Select CustId, CustomerID, "Customer Name" = CustomerName, InvoiceID, "Invoice Date" = InvoiceDate, "Total Sales (%c)" = TotalSales ' +  @ColSelected  + ' From #tmpResult '
If Not @MrcTypeList =N'%'
SET @QryString = @QryString + ' Where MapFlag=1'



Exec sp_ExecuteSQL @QryString

Drop Table #tmpResult
Drop Table #tmpMerchandiseType


