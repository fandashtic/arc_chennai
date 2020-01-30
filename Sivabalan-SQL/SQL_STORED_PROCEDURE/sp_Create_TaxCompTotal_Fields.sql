Create Procedure sp_Create_TaxCompTotal_Fields
As
Select '"' + Case LST_Flag When 1 Then 'LT_' Else 'CT_' End + TaxComponentDetail.TaxComponent_Desc + '_Total_Value' + '" = ' +
'dbo.GetInvoiceTaxComponentTotalValue(@INVNO, ' + Cast(TaxComponentDetail.TaxComponent_Code AS nvarchar) + ' , ' + Cast(Case LST_Flag When 1 Then 1 Else 2 End As nvarchar) + ')'
From TaxComponents, TaxComponentDetail
Where TaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code
Group By TaxComponentDetail.TaxComponent_Code, TaxComponentDetail.TaxComponent_Desc, LST_Flag
Order By LST_Flag
