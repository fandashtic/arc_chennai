CREATE Procedure spr_list_Vendor_OutStanding (	@Vendor nvarchar(2550),
						@FromDate datetime,
						@ToDate datetime)
As
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Vendor='%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@Vendor,@Delimeter)

Create Table #temp
(
	VendorID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocCount int null,
	Value Decimal(18,6) null
)
Insert #temp(VendorID, DocCount, Value)
Select BillAbstract.VendorID, Count(BillID), Sum(BillAbstract.Balance)
From BillAbstract, Vendors
Where BillAbstract.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
BillAbstract.BillDate Between @FromDate And @ToDate And
BillAbstract.Balance > 0 And
BillAbstract.Status & 128 = 0
Group By BillAbstract.VendorID

Insert #temp(VendorID, DocCount, Value)
Select AdjustmentReturnAbstract.VendorID, Count(AdjustmentID), 
0 - Sum(AdjustmentReturnAbstract.Balance) From AdjustmentReturnAbstract, Vendors
Where AdjustmentReturnAbstract.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate And
AdjustmentReturnAbstract.Balance > 0 And IsNull(Status,0) & 64 = 0
Group By AdjustmentReturnAbstract.VendorID

Insert #temp(VendorID, DocCount, Value)
Select CreditNote.VendorID, Count(CreditID), Sum(Balance) From CreditNote, Vendors
Where CreditNote.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
CreditNote.Balance > 0 And 
CreditNote.DocumentDate Between @FromDate And @ToDate
Group By CreditNote.VendorID

Insert #temp(VendorID, DocCount, Value)
Select Payments.VendorID, Count(DocumentID), 0 - Sum(Balance) From Payments, Vendors
Where Payments.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
Payments.Balance > 0 And 
Payments.DocumentDate Between @FromDate And @ToDate
Group By Payments.VendorID

Insert #temp(VendorID, DocCount, Value)
Select DebitNote.VendorID, Count(DebitID), 0 - Sum(Balance) From DebitNote, Vendors
Where DebitNote.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
DebitNote.Balance > 0 And
DebitNote.DocumentDate Between @FromDate And @ToDate
Group By DebitNote.VendorID

Insert #temp(VendorID, DocCount, Value)
Select ClaimsNote.VendorID, Count(ClaimID), 0 - Sum(IsNull(Balance, 0)) 
From ClaimsNote, Vendors
Where ClaimsNote.VendorID = Vendors.VendorID And
Vendors.Vendor_Name In (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) And
IsNull(ClaimsNote.Balance, 0) > 0 And
ClaimsNote.ClaimDate Between @Fromdate And @ToDate
Group By ClaimsNote.VendorID

Select #temp.VendorID, "VendorID" = #temp.VendorID, "Vendor" =  Vendors.Vendor_Name,
"No. Of Purchases" = Sum(DocCount), "OutStanding Value (%c)" = Sum(Value)
From #temp, Vendors
Where #temp.VendorID collate SQL_Latin1_General_Cp1_CI_AS = Vendors.VendorID
Group By #temp.VendorID, Vendors.Vendor_Name
Drop Table #temp
drop table #tmpVen



