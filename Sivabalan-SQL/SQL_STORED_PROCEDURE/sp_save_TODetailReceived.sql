CREATE procedure sp_save_TODetailReceived 
(@DocSerial int , 
@Product_Code	nvarchar(15), 
@Batch_Number nvarchar (128), 
@PTS decimal(18,6) , 
@PTR decimal(18,6), 
@ECP decimal(18,6), 
@SpecialPrice decimal(18,6),  
@Rate decimal(18,6), 
@Quantity Decimal(18,6), 
@Amount Decimal(18,6), 
@ForumCode nvarchar(20) , 
@Expiry datetime, 
@PKD Datetime, 
@Free Decimal(18,6),
@TaxSuffered Decimal(18,6),
@TaxAmount Decimal(18,6),
@TotalAmount Decimal(18,6),
@Applicableon int = 0,
@partoff decimal(18,6) = 100,
@Serial Integer=0
)
as
insert into stocktransferoutdetailreceived
(DocSerial,Product_Code,Batch_Number,PTS,PTR,ECP,SpecialPrice,Rate,Quantity,Amount,ForumCode,Expiry,PKD,CreationDate,
Free,TaxSuffered,TaxAmount,TotalAmount,Applicableon,Partoff,Serial)
 values (@DOCSERIAL, @Product_Code ,    
@Batch_Number , @PTS, @PTR  , @ECP  , @SpecialPrice  , @Rate ,@Quantity ,   
@Amount  , @ForumCode  , @Expiry ,  @PKD, getdate(),@Free, @TaxSuffered,   
@TaxAmount, @TotalAmount,@Applicableon,@partoff,@Serial)  

