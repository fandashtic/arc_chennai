Create  Procedure [dbo].[mERP_Sp_Insert_RecdChannel_ITC]          
(
	@ChannelDocSerial Int,
    @Channelcode Nvarchar(50), 
	@ChannelName Nvarchar(50),	
	@Active Int 	
)

AS          
          
Begin Tran PortCCD          
  declare @flag int 
  set @flag=0 
--Channel Code Exists 
  If (Select count(*) from Customer_Channel Where code =@Channelcode) <> 0
  BEGIN   
  if (Select count(*) from Customer_Channel Where channeldesc =@Channelname and code <> @Channelcode ) <> 0  
  begin 
  set @flag=1 
  end 
  else 
  begin 
  Update Customer_channel set Active=@Active,ChannelDesc=@Channelname
  From  tbl_mERP_RecdChannlDetail RR,tbl_mERP_RecdChannlAbstract RCC      
                Where RR.ID=@ChannelDocSerial And      
  RR.ID=RCC.ID and
  Customer_channel.Code=@Channelcode and  
  Customer_channel.Code=RR.ChannelCode       
  end
  END  

 --Channel Code Does not Exists 
  If (Select count(*) from Customer_Channel Where code =@Channelcode) = 0
  BEGIN 
  If (Select count(*) from Customer_Channel Where channeldesc =@Channelname) <> 0  
  begin 
  set @flag=1 
  end 
  else 
  begin  
  Insert into Customer_channel (ChannelDesc,Active,Code) 
  Select RR.ChannelName,RR.Active, RR.ChannelCode   
  From tbl_mERP_RecdChannlDetail RR,tbl_mERP_RecdChannlAbstract RCC      
  Where RR.ID = RCC.ID          
  AND RR.ChannelCode=@Channelcode and 
  RR.ID=@ChannelDocSerial      
  end 
  END 
If @@Error = 0           
 Begin        
  If @flag=1 
  begin   
  Update tbl_mERP_RecdChannlDetail Set Status = 64 Where id=@ChannelDocSerial and channelcode=@Channelcode     
  end
  else
  begin 
  Update tbl_mERP_RecdChannlDetail Set Status = 32 Where id=@ChannelDocSerial and channelcode=@Channelcode     
  end
  Commit Tran PortCCD          
  Goto TheEnd          
 End          
Else           
 RollBack Tran PortCCD          
TheEnd:         
