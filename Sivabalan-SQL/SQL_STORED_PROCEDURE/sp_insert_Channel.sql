CREATE procedure sp_insert_Channel(@ChannelDesc nvarchar(255))    
AS    
insert into Customer_Channel(ChannelDesc, Active) values(@ChannelDesc,1)    
Select @@identity  

