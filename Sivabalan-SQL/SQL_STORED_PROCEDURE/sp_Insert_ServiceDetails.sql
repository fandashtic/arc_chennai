CREATE procedure sp_Insert_ServiceDetails
(
@InvoiceId int,
@ServiceNameAndCode nvarchar(50),
@Remarks nvarchar(50),
@Amount decimal(18, 6),
@Tax_Percentage decimal(18, 6),
@Tax_Amount decimal(18, 6),
@Net_Amount decimal(18, 6),
@MapTaxId int,
@ServiceCodeid int,
@ServiceName nvarchar(250),
@ServiceCode   nvarchar(250),
@TaxableValue decimal(18,6),
@DiscAmt decimal(18,6),
@GrossAmt decimal(18,6),
@TaxType Int
)
As
BEGIN

Declare @Taxid int
Declare @rowcount int

Select @rowcount=isnull(max(SerialNo),0)+1 from ServiceDetails where InvoiceId=@InvoiceId
Create table #tblClaimDetails(id int identity(1,1),TaxComponent_Code int, Tax_Percentage decimal(18,6),SP_Percentage decimal(18,6),TaxSplitup decimal(18,6),LST_flag int,
TaxComp nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS )

Insert into ServiceDetails(InvoiceId,ServiceNameAndCode,Remarks,Amount,Tax_Percentage,Tax_Amount,Net_Amount,MapTaxId,serviceCodeid,ServiceName,ServiceCode,SerialNo,TaxableValue,GrossAmt,DiscountAmt)
Values (@InvoiceId,ltrim(rtrim(@ServiceNameAndCode)),@Remarks,@Amount,@Tax_Percentage,@Tax_Amount,@Net_Amount,@MapTaxId,@ServiceCodeid,ltrim(rtrim(@ServiceName)),ltrim(rtrim(@ServiceCode)),@rowcount,@TaxableValue,@GrossAmt,@DiscAmt)


insert into #tblClaimDetails (TaxComponent_Code , Tax_Percentage, SP_Percentage, TaxSplitup, LST_flag, TaxComp)
Select TC.TaxComponent_Code, Tax_Percentage, SP_Percentage,(@TaxableValue * Tax_Percentage) /100,TC.CSTaxType , TCd.TaxComponent_desc
from Tax T
Join  TaxComponents TC on TC.Tax_Code=T.Tax_Code
Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where T.Tax_Code = @MapTaxId
And CSTaxType = Case When @TaxType = 1 Then 1 Else 2 End
order by TC.TaxComponent_Code

insert into ServiceInvoicesTaxSplitup
select @ServiceNameAndCode,@ServiceCodeid,@InvoiceId,@MapTaxId,TaxComponent_Code,Tax_Percentage,SP_Percentage,TaxSplitup,LST_flag, TaxComp,@rowcount
from #tblClaimDetails
drop table #tblClaimDetails
END
