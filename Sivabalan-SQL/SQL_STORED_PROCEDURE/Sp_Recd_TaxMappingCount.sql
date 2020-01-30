Create Procedure Sp_Recd_TaxMappingCount
As
Begin

If Exists (Select 'x' From Recd_ItemTaxMapping Where Status = 8 or IsNull(Status,0) = 0)
Begin
Update Recd_ItemTaxMapping Set Status = 0 Where Status = 8
Exec sp_ProcessItemTaxMap 1
End
Select Count(*) NoOfTaxMaster From Recd_ItemTaxMapping   Where Isnull(AlertCount,0) = 1
Update Recd_ItemTaxMapping   Set AlertCount = 32 Where Isnull(AlertCount,0) = 1
End
