Create Procedure sp_Create_TaxComp_Fields
As
Select --TaxComponentDetail.TaxComponent_Code, TaxComponentDetail.TaxComponent_Desc, LST_Flag,
'"' + Case LST_Flag When 1 Then 'LT_' Else 'CT_' End + TaxComponentDetail.TaxComponent_Desc + '_Percentage' + '" = ' +
'dbo.GetInvoiceTaxComponentPercentage(@INVNO, InvoiceDetail.Product_Code, InvoiceDetail.TaxID, ' + Cast(TaxComponentDetail.TaxComponent_Code AS nvarchar) + ' , ' + Cast(Case LST_Flag When 1 Then 1 Else 2 End As nvarchar) + '), ' +
'"' + Case LST_Flag When 1 Then 'LT_' Else 'CT_' End + TaxComponentDetail.TaxComponent_Desc + '_Value' + '" = ' +
'Case When (IsNull(Sum(#Temp1.SRQty * InvoiceDetail.STPayable), 0) + IsNull(Sum(#Temp1.SRQty * InvoiceDetail.CSTPayable), 0)) > 0 Then
 dbo.GetInvoiceTaxComponentValue(@INVNO, InvoiceDetail.Product_Code, InvoiceDetail.TaxID, ' + Cast(TaxComponentDetail.TaxComponent_Code AS nvarchar) + ' , ' + Cast(Case LST_Flag When 1 Then 1 Else 2 End As nvarchar) + ') Else 0.000000 End'
From TaxComponents, TaxComponentDetail
Where TaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code
Group By TaxComponentDetail.TaxComponent_Code, TaxComponentDetail.TaxComponent_Desc, LST_Flag
Order By LST_Flag

