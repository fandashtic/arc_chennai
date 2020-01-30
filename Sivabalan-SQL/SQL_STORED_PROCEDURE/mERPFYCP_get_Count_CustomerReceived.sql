CREATE Procedure mERPFYCP_get_Count_CustomerReceived ( @yearenddate datetime )
As
Select Count(*) from ReceivedCustomers Where isnull(Status,0)=0 and CreationDate <= @yearenddate
