CREATE Procedure Sp_Acc_SavePriceList  
(@PriceListID integer, @PriceListName nVarchar(255),@Description nVarchar(255),  
@PriceListFor Int ,@Active int)  
as  
/*if @PriceListID = 0 then its ADD NEW MODE , Else UPDATE MODE */  
if @PriceListID = 0  
Begin  
	 insert into PriceList(PriceListName,Description,PriceListFor,CreationDate,Active)  
	 values (@PriceListName,@Description,@PriceListFor,Getdate(),@Active)  
	 Select @@Identity  
End  
Else  
Begin  
	 Update PriceList  
	 set   
	 Description  = @Description,  
	 PriceListFor  = @PriceListFor,  
	 LastModifyDate = Getdate(),  
	 Active   = @Active  
	 Where PriceListID  = @PriceListID  
	 
	 Delete from PriceListBranch where PriceListID = @PriceListID  
	 Delete from PriceListItem  where PriceListID = @PriceListID  
	 Select @@ROWCOUNT  
End  




