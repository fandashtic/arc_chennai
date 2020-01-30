Create Procedure [dbo].[sp_print_DandDInvAbs_CG_Inter](@DnDID INT)
AS
Set dateformat DMY
DECLARE @TotalSalvage Decimal(18,6)
Declare @TotalTax Decimal(18,6)
Declare @TotalAmount Decimal(18,6)


Declare @ItemCount int
Declare @DnDInvID Int
Declare @WDPhoneNumber As NVarchar(20)
Declare @CompanyGSTIN as Nvarchar(30)
Declare @CompanyPAN as Nvarchar(200)
Declare @CIN as Nvarchar(50)
--Declare @CompanyState Nvarchar(200)
--Declare @CompanySC	Nvarchar(50)
Declare @UTGST_flag  int
Declare @CompanyName as Nvarchar(255)
Declare @CompanyAddress as Nvarchar(255)
Declare @CustomerAddress as Nvarchar(255)
Declare @CustomerId as Nvarchar(255)
Declare @CustomerName as Nvarchar(255)
Declare @CustomerGSTIN as Nvarchar(30)
Declare @DocumentID nVarChar(255)

select @UTGST_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

Select @WDPhoneNumber=Telephone,@CompanyName = OrganisationTitle , @CompanyAddress = BillingAddress  from Setup
Select @CompanyGSTIN=GSTIN from Setup
Select @CompanyPAN =PANNumber from Setup

--Select TOP 1 @CompanyState=StateName,@CompanySC=ForumStateCode from StateCode
--inner join Setup on Setup.ShippingStateID=StateCode.StateID

Create Table #tempItemCount(ItemCount Int)

select @DnDInvID = DandDInvID  from DandDInvAbstract where DandDID  = @DnDID

/*While counting the number of items in the invoice
Same product free item will not be considered as a separate item as the free item will be
shown under the free column in the same row along with the saleable item */
insert #tempItemCount(ItemCount)
exec sp_print_DandDInvItems_RespectiveUOM_CG_Inter @DnDID,1
--exec sp_print_DandDInvItems_RespectiveUOM @DnDInvID,1


Select @ItemCount = max(ItemCount)*2 From #tempItemCount

Drop Table #tempItemCount

Declare @MonthRemark nVarchar(255)

-------------------------Temp Tax Details

select @CustomerAddress = CustomerAddress , @CustomerId = CustomerID , @CustomerName = CustomerName  , @DocumentID = DocumentID,
@MonthRemark = Case When OptSelection = 2 Then
Case When Isnull(RemarksDescription,'') = '' Then  '' Else Cast('Remarks: '+ Cast(Isnull(FromMonth,'') as nVarchar(50)) + ' To '+ Cast(Isnull(ToMonth,'') as nVarchar(50)) as nVarchar(150)) End
Else
Case When Isnull(Remarks,'') = '' Then  Isnull(Remarks,'') Else 'Remarks: '+ Isnull(Remarks,'') End
End
From DandDAbstract where ID = @DnDID


Select  DandDID , Product_Code, Batch_Code,Tax_Code  ,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value  Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From DandDTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where ITC.DandDID  = @DnDID
Group By DandDID, Product_Code,Batch_Code , Tax_Code

--Temp Invoice Detail
Select Batch_Code=ID.Batch_code  , TaxID=ID.TaxID,
TaxableValue = ID.BatchTaxableAmount ,
SGSTPer= (Select SGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
SGSTAmt= (Select Sum(SGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code = ID.Batch_code ),
CGSTPer=(Select CGSTPer From #TempTaxDet Where DandDID = ID.ID  And Product_Code = ID.Product_Code  And Batch_Code= ID.Batch_code ) ,
CGSTAmt=(Select Sum(CGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
IGSTPer=(Select IGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code) ,
IGSTAmt=(Select Sum(IGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
UTGSTPer=(Select UTGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
UTGSTAmt=(Select Sum(UTGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
CESSPer=(Select CESSPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
CESSAmt=(Select Sum(CESSAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ),
ADDLCESSPer=(Select ADDLCESSPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code )
into #TempInvDet2
from DandDDetail ID Where ID = @DnDID

select @TotalSalvage = SUM(SalvageValue ), @TotalTax  = SUM(TotalTaxAmount ), @TotalAmount = SUM(RebateValue )
from DandDInvDetail where DandDInvID = @DnDInvID

--Select * from #TempInvDet2
Select TaxableValue=Sum(TaxableValue),SGSTPer=Max(SGSTPer),SGSTAmt =Sum(SGSTAmt ), CGSTPer=Max(CGSTPer),CGSTAmt=SUM(CGSTAmt),
IGSTPer=MaX(IGSTPer), IGSTAmt=Sum(IGSTAmt), UTGSTPer=Max(UTGSTPer),UTGSTAmt=Sum(UTGSTAmt),
CESSPer=Max(CESSPer),CESSAmt=Sum(CESSAmt), ADDLCESSPer=Max(ADDLCESSPer),ADDLCESSAmt=Sum(ADDLCESSAmt),
Total= SUM(IGSTAmt +CESSAmt+ADDLCESSAmt)
Into #GSTaxSummary
From #TempInvDet2
Group By TaxID

Declare @GSTTaxSumText nVarChar(25)
Declare @GSTTaxComp nVarChar(Max)
Declare @GSTTaxComp_DOS nVarChar(Max)
Declare @GSTTaxCompText nVarChar(200)
Declare @GSTTaxCompText_DOS nVarChar(200)
Set @GSTTaxSumText = 'Tax Summary :'
Set @GSTTaxCompText =  'Tax Summary/GST  Component' + space(32) + 'TaxableVal' + Space(14) + 'IGST' + Space(10) + 'Cess' +  Space(6) + 'AddlCess'+ + Space(4) + 'Total Tax'
Set @GSTTaxCompText_DOS=  'Tax Summary/GST  Component' + space(19) + 'TaxableVal ' + Space(6) + 'IGST ' + Space(6) + 'Cess ' +  Space(2) + 'AddlCess '+ + Space(1) + 'Total Tax'
Set @GSTTaxComp = '  '+ + Char(13) + Char(10) + '  |  Tax Summary/GST  Component' + space(34) + 'TaxableVal' + Space(10) + 'IGST' + Space(12) + 'Cess' +  Space(4) + 'AddlCess'+ + Space(6) + 'Total Tax' + Char(13) + Char(10)
Select @GSTTaxComp = @GSTTaxComp
+ '  |  IGST' + Replicate('  ',5-LEN(Cast(Cast(IGSTPer   As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5))
--+ '%+SGST' + Replicate('  ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
+ '% + Cess' + Replicate('  ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
+ '% + AddlCess ' +Replicate('  ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate('  ',10-LEN(Cast(SGSTAmt as Decimal(10,2)))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(Cast(CESSAmt as Decimal(10,2)))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(Cast(ADDLCESSAmt as Decimal(10,2)))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + Char(13) + Char(10)--+ SPACE(2)
From #GSTaxSummary

Set @GSTTaxComp_DOS  = ''
Select @GSTTaxComp_DOS  = @GSTTaxComp_DOS
+ 'IGST' + Replicate(' ',5-LEN(Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5))
--+ '%+SGST' + Replicate(' ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
+ '% + Cess' + Replicate(' ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
+ '% + AddlCess ' +Replicate(' ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate(' ',10-LEN(Cast(SGSTAmt as Decimal(10,2)))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(Cast(CESSAmt as Decimal(10,2)))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(Cast(ADDLCESSAmt as Decimal(10,2)))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + SPACE(2)
From #GSTaxSummary

Drop Table #TempTaxDet
Drop Table #TempInvDet2
----------------------------------------------------------------


SELECT
"WDName" = @CompanyName,
"WDAddress" = @CompanyAddress,
"CompanyState" = FromState.StateName,--@CompanyState,
"CompanySC" = FromState.ForumStateCode ,--@CompanySC ,

"CompanyGSTIN" = @CompanyGSTIN,
"WDPhoneNumber" = 'Phone: ' + @WDPhoneNumber,
"CompanyPAN" = @CompanyPAN,

"InvoiceDate" = convert(varchar(10),Inv.DandDInvDate ,103),
"InvoiceNo." = Inv.GSTFullDocID ,
"Task Number" = @DocumentID ,
"BillingCustomerName" = 'ITC Limited', --C.Company_Name,
"BillingCustomerCode" = C.CustomerID ,
"BillingAddress" = C.BillingAddress ,
"BillingGSTIN" = C.GSTIN ,
"BillingState" =  ToState.StateName,
"BillingStateCode" =  ToState.ForumStateCode ,

"ShippingCustomerName" = Case When @CustomerName = '' Then 'ITC Limited' Else Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else @CustomerName End End ,
"ShippingCustomerCode" = Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else @CustomerId End ,
"ShippingAddress" = Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else @CustomerAddress End ,
"ShippingGSTIN" = Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else Inv.GSTIN End  ,
"ShippingState" =  Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else ToState.StateName End,
"ShippingStateCode" =  Case when RTrim(LTrim(@CustomerName)) = '.' Then '' Else ToState.ForumStateCode End  ,

"ITEM COUNT" = @ItemCount,

"Total SalvageVal" = @TotalSalvage,
"Total Tax" = @TotalTax  ,
"Total Amount" = @TotalAmount ,

"Net Amount Payable" = Inv.ClaimAmount,
"SGST/UTGST Rate" = case @UTGST_flag when 1 then 'UTGST Rate'  else 'SGST Rate' end,
"SGST/UTGST Amt" = case @UTGST_flag when 1 then 'UTGST Amt'  else 'SGST Amt' end,
"S/UT GST" = case @UTGST_flag when 1 then 'UTGST'  else 'SGST' end,

"Tax Summary Text" = @GSTTaxSumText  ,
"TaxComp Text" = @GSTTaxCompText  ,
"GSTTaxComp" = @GSTTaxComp    ,
"Tax Summary Text_DOS" = @GSTTaxCompText_DOS,
"GSTTaxComp_DOS" = @GSTTaxComp_DOS
,"Remarks" = @MonthRemark
FROM DandDInvAbstract Inv
Inner Join Customer C On Inv.CustomerID = C.CustomerID
--StateCode SCBilling ,StateCode SCShipping
Left Outer Join StateCode ToState On Inv.ToStateCode  = ToState.StateID
Left Outer Join StateCode FromState On Inv.FromStateCode  = FromState.StateID
WHERE  Inv.DandDInvID  = @DnDInvID


Drop Table #GSTaxSummary
