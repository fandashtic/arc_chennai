CREATE PROCEDURE spr_beatwise_customers_detail_ITC(@BEATID int)  
AS  
Select 1,   
"CustomerID" = Customer.CustomerID,   
"Customer Name" = Company_Name,  
"Channel Type" = Customer_Channel.ChannelDesc  
FROM Customer, Customer_Channel  
WHERE Customer.Active = 1 And  
Customer.DefaultBeatID = @BEATID and
Customer.ChannelType = Customer_Channel.ChannelType

