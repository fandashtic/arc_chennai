CREATE VIEW  [V_Sub_Channel_Type]
([SubChannel_Type_ID],[SubChannel_Type_Name],[Active])
AS
SELECT     SubChannelID, Description, Active
FROM       SubChannel
