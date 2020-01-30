CREATE procedure sp_update_VoucherStatus @SequenceNo nvarchar(250),@RedAmount Decimal(18,6),@RedeemID int        
as            
begin            
  declare @SerialNo int        
  declare @AvailAmount decimal(18,6)      
  insert into GiftVoucherRedeemIDS(SequenceNo,RedeemID, RedeemAmount) 
		values(@SequenceNo,@RedeemID, @RedAmount)      
    
   if exists(select serialNo from GiftVoucherDetail where sequenceNumber=@SequenceNo)    
  begin    
   select @SerialNo=SerialNo from GiftVoucherDetail where SequenceNumber=@SequenceNo        
   select @AvailAmount=(AmountReceived-AmountRedeemed) from  GiftVoucherDetail where SequenceNumber=@SequenceNo            
    -- update issueGiftVoucher set RedeemID=@RedeemID where  SerialNo=@SerialNo            
        
   Update GiftVoucherDetail set AmountRedeemed=isnull(AmountRedeemed,0)+@RedAmount where SequenceNumber=@SequenceNo            
   if @RedAmount=@AvailAmount             
   update GiftVoucherDetail set status=4 where SerialNo=@SerialNo --fully redeemed            
   else if @RedAmount<@AvailAmount             
      update GiftVoucherDetail set status=3 where SerialNo=@SerialNo  --Partially redeemed          
  End    
 end      



