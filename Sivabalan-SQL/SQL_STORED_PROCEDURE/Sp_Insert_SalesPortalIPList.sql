CREATE Procedure Sp_Insert_SalesPortalIPList(@IPAddress NVarchar(100)) As    
If Not Exists ( Select * From SalesPortalIPList Where IPAddress = @IPAddress)    
Begin  
 Insert into SalesPortalIPList Values(@IPAddress)    
End     
  
  


