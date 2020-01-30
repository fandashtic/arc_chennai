CREATE PROCEDURE [dbo].[spr_beatwise_customers_detail](@BEATID int)  
AS  
Declare @OTHERS As NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)  
Select 1,     
"CustomerID" = Customer.CustomerID,     
"Customer Name" = Company_Name,    
"Channel Type" = Isnull(Customer_Channel.ChannelDesc,@OTHERS)    
FROM Customer
left Outer Join Customer_Channel on Customer.ChannelType = Customer_Channel.ChannelType
WHERE 
--Customer.ChannelType *= Customer_Channel.ChannelType And 
Customer.CustomerID in 
(Select CustomerID from Beat_Salesman where BeatID = @BEATID 
and isnull(CustomerID,N'') <> N'') and 
Customer.Active = 1     
order by customerID
