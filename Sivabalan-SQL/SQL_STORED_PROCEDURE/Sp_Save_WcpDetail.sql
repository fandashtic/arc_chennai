CREATE procedure Sp_Save_WcpDetail( @Code Bigint, @WcpDate DateTime,   
@CustomerId nvarchar(30), @Serial Bigint)  
as  
  
Insert into WcpDetail( Code, WcpDate, CustomerId, Serial)  
Values(@Code, @WcpDate, @CustomerId, @Serial)  
  
  


