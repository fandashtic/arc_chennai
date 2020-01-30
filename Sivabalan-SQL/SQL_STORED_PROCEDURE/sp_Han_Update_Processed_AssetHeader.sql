CREATE Procedure sp_Han_Update_Processed_AssetHeader(@AssetHeaderID int, @Flag int)
As  
Declare @NoRecs as Int

Update AssetInfoTracking_HH Set Status = @Flag, ModifiedDate = GetDate() Where AssetHeaderID = @AssetHeaderID

Set @NoRecs  = @@ROWCOUNT    
Select "Rows" =  @NoRecs    
  
