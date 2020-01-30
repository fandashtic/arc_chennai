CREATE procedure sp_GetServiceMasterMappedtax
(
@Code nvarchar(50),
@TaxType nvarchar(20),
@ServiceName nvarchar(500),
@AppConfig nvarchar(20)
)
AS
IF @AppConfig = 'ITC'
BEGIN
IF @TaxType = '1'
BEGIN
Select Sum(TC.Tax_percentage) as Percentage,ST.MapTaxId
from ServiceTypeMaster ST
Join TaxComponents TC ON ST.MapTaxId=TC.tax_code where ST.ServiceAccountCode=@Code and ST.ServiceName=@ServiceName and TC.CSTaxType = 1
group by ST.MapTaxId
END
ELSE IF @TaxType = '0'
BEGIN
Select Sum(TC.Tax_percentage) as Percentage,ST.MapTaxId
from ServiceTypeMaster ST
Join TaxComponents TC ON ST.MapTaxId=TC.tax_code where ST.ServiceAccountCode=@Code and ST.ServiceName=@ServiceName and TC.CSTaxType = 2
group by ST.MapTaxId
END
END
ELSE
BEGIN
select
Case  when @TaxType = '1' then TM.percentage
when @TaxType = '0' then TM.CST_Percentage end as Percentage,
ST.MapTaxId,ServiceName,ServiceAccountCode
from ServiceTypeMaster ST
Join Tax TM ON ST.MapTaxId=TM.tax_code where ST.ServiceAccountCode=@Code and ST.ServiceName=@ServiceName
END
