CREATE procedure Sp_Update_CampaignMaster(@Code nvarchar(15), @Description nvarchar(510),@fromdate datetime,          
@ToDate Datetime,@Memo1 nvarchar(510), @Memo2 nvarchar(510),@Memo3 nvarchar(510),@Response int,@Objective Decimal(18,6), @ModifiedDate datetime, @Active int, @CustAll int)as          
          
update CampaignMaster set Description= @Description,FromDate=@FromDate,ToDate=@ToDate,Memo1 =@Memo1,Memo2=@Memo2,Memo3=@Memo3,          
ResponseType=@response, objective=@objective,Active=@Active,ModifiedDate=@ModifiedDate, CustomerID = @CustAll where CampaignId=@Code         
        
      
    
    
  


