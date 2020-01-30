
CREATE procedure sp_insert_Subchannel(@SubChannelDesc nVarchar(255))    
As    
If Not Exists(Select SubChannelID From SubChannel Where Description=@SubChannelDesc)    
Begin    
 Insert Into SubChannel (Description) Values (@SubChannelDesc)    
 Select @@IDENTITY  
End  
Else  
  Select 0  
    
