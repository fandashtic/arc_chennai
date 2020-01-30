Create Procedure sp_FreeSKU_Master_report(
@SPLSKUMonth nvarchar(10)
)
AS
Begin

Create Table #tmpDuplicate(Duplicate Int)
Insert into #tmpDuplicate Values (1)
Insert into #tmpDuplicate Values (2)

Select ID,
UniqueID As 'Central ID',
Period As 'Effective Month' ,
Case When Duplicate = 1 Then Isnull(BilledSKU,'') Else Isnull(FreeSKU,'') End As 'SKU Details',
Case When Duplicate = 1 Then (select isnull(productname,'') from items where Product_Code= Isnull(BilledSKU,'')) Else
(select isnull(productname,'') from items where Product_Code= Isnull(FreeSKU,'')) End As 'SKU Name',
Case When Duplicate = 1 Then 'Billable SKU' Else 'DDS' End As 'SKU Type',
--Case When Duplicate = 1 Then Cast('' As nvarchar(10)) Else Cast(Isnull(DistributionPercentage,0) As nvarchar(50)) End As 'Distribution Percentage Cap'
Case When Duplicate = 1 Then Null Else Isnull(DistributionPercentage,0) End As 'Distribution Percentage Cap'
from SpecialSKUMaster
Inner Join #tmpDuplicate on 1 = 1
Where Cast('01-' + [Period] as Datetime) = cast('01-'+ @SPLSKUMonth as Datetime)
And Active = 1

Drop Table #tmpDuplicate

End
