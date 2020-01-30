Create Procedure Sp_Recd_SplFreeSKU
As
Begin
Select Count(*) from SpecialSKUMaster_Received Where Isnull(RecFlag,0) = 0
Update SpecialSKUMaster_Received Set RecFlag = 1 Where Isnull(RecFlag,0) = 0
End
