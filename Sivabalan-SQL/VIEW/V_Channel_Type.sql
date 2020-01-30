CREATE VIEW  [V_Channel_Type]
([Channel_Type_ID],[Channel_Type_Name],[Active])
AS
SELECT     ChannelType, ChannelDesc, Active
FROM         dbo.Customer_Channel
