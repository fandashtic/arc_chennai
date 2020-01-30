CREATE procedure sp_save_PRDetailReceived 
(	@DocSerial int , @Product_Code	nvarchar(15) , @Batch_Number nvarchar (128) , 
	@BatchCode nvarchar(25),	@Rate Decimal(18,6) ,	@Quantity Decimal(18,6), 
	@Amount Decimal(18,6) , @ForumCode nvarchar(25) , @Billid int
)
as
insert into AdjustmentReturnDetail_Received values (@DocSerial , @Product_Code	, @Batch_Number 
	, @BatchCode , @Quantity,  @ForumCode , @Rate ,@Amount , @Billid  , getdate())
