CREATE Procedure sp_Get_Count_CustomerReceived
As
Select Count(*) from ReceivedCustomers Where isnull(Status,0)=0





