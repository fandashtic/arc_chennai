CREATE Procedure Sp_Acc_SendPriceList
(@Mode Int,@PriceListDate Datetime,@PriceListID integer)  
as      
Declare @SendPriceListID int  
declare @PriceListFor int  
Set dateformat DMY  
if @Mode = 0      
Begin      
	Select @SendPriceListID = DocumentID from documentnumbers where DocType = 61  
	Select @PriceListFor = PriceListFor from PriceList where PriceListID =  @PriceListID  
	
	Update documentnumbers set DocumentID = DocumentID + 1 where DocType = 61  
	
	insert into SendPriceList (SendPriceListID,PriceListDate,PriceListID,PriceListFor,CreationDate)  
	values (@SendPriceListID,@PriceListDate,@PriceListID,@PriceListFor,Getdate())  
	Select @@Identity,@SendPriceListID  
End      
Else if @Mode = 1   
Begin  
	Update SendPriceList  
	Set LastModifyDate = Getdate()   
	Where DocumentID = @PriceListID  
	Select @SendPriceListID = SendPriceListID from SendPriceList  
	Where DocumentID = @PriceListID 
	Select @PriceListID ,@SendPriceListID
End  





