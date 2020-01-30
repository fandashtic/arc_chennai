CREATE procedure sp_Cancel_GiftVoucherCollection @SequenceNo nvarchar(250),@Amount decimal(18,6),@RedeemID int,@Mode int    
as            
begin      
  declare @AvailAmount decimal(18,6)            
  declare @AmountRedeemed decimal(18,6)  
  declare @Value decimal(18,6)           
  declare @SerialNo int    
  select @SerialNo=SerialNo from giftvoucherdetail where SequenceNumber=@SequenceNo      
  if exists(select * from issuegiftvoucher where SerialNo = @SerialNo)    
     delete GiftVoucherRedeemIDS where RedeemID=@RedeemID    
  else    
  begin    
   if @Mode=0 --Amended    
   update GiftVoucherOthers set status=status|128   where SequenceNumber = @SequenceNo    
   else if @Mode=1     --cancel    
   update GiftVoucherOthers set status=status|192   where SequenceNumber = @SequenceNo       
  end       
  
  update GiftVoucherDetail set AmountRedeemed=isnull(AmountRedeemed,0)-@Amount where SequenceNumber=@SequenceNo      
  update issueGiftVoucher set RedeemID=0 where  SerialNo=@SerialNo            
  select @AvailAmount=(AmountReceived-AmountRedeemed),@AmountRedeemed=AmountRedeemed,  
  @Value=amount from  GiftVoucherDetail where SequenceNumber=@SequenceNo        
  if @Value=@AvailAmount             
     update GiftVoucherDetail set status=2 where SequenceNumber=@SequenceNo  --Issued          
  else if @Value=@AmountRedeemed  
     update GiftVoucherDetail set status=4 where SequenceNumber=@SequenceNo  --fully Redeemed  
  else if @Value>@AvailAmount             
     update GiftVoucherDetail set status=3 where SequenceNumber=@SequenceNo  --Partially redeemed          
end     

