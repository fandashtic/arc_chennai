Create Function fn_getReasonForCustomer(@ID int)    
Returns nvarchar(100)    
As    
Begin    
Declare @CanStart nvarchar(1)    
Declare @RejReason nvarchar(100)    
Declare @Forumcode nvarchar(40)    
Declare @Cusid nvarchar(30)    
Declare @CusName nvarchar(256)    
Declare @tempMsg nvarchar(100)    
Declare @MembershipCode nvarchar(100)  
    
DEclare @LastMsg nvarchar(100)    
Declare @BCusid int    
Declare @BCusname int    
Declare @BForumcode int    
    
Set @LastMsg=dbo.lookupDictionaryItem(N' Already Exists',default)    
Set @BCusid=0    
Set @BCusname=0    
Set @BForumcode=0    
Set @TempMsg=N''    
    
Select @ForumCode=Forumcode,@Cusid=Customerid,@CusName=Company_name,  
 @MembershipCode=MemberShipCode From ReceivedCustomers Where Id=@ID    
    
    
Select @CanStart=dbo.fn_CanSaveCustomer(@ID)    
IF(@CanStart=N'N')    
begin    
 IF Exists(Select * from Customer Where Customerid=@Cusid)    
 begin    
    Set @TempMsg=dbo.lookupDictionaryItem(N'CustomerID',default)  
    Set @Bcusid=1     
 End    
   
 IF Exists(Select * from Customer Where MembershipCode=@MembershipCode)    
 begin    
    If (@BCusid=1)    
      Begin     
      Set @TempMsg=@TempMsg + N','     
      End    
      -- Set @TempMsg=@TempMsg + dbo.lookupDictionaryItem(N'MemberShip',default)  
	  Set @TempMsg= '-New Customer Rejected'
      Set @Bcusname=1       
 End    
 Else  
 Begin  
 IF Exists(Select * From Customer Where Company_Name=@CusName)     
 Begin    
  If (@BCusid=1)    
      Begin     
      Set @TempMsg=@TempMsg + N','     
      End    
     
      Set @TempMsg=@TempMsg + dbo.LookUpDictionaryItem(N'CustomerName',default)    
      Set @Bcusname=1     
        
 End    
     
 If Exists (Select * from Customer Where AlternateCode=@ForumCode)    
 Begin    
 If (@BCusname=1) or (@Bcusid=1)    
      Begin     
      Set @TempMsg=@TempMsg + N','     
      End    
     
      Set @TempMsg=@TempMsg + dbo.LookUpDictionaryItem( N'ForumCode',default)     
 End    
 End  
 Set @RejReason=@tempMsg --+ @LastMsg    
End    
Else    
Set @RejReason=N''    
    
Return (Select @RejReason)    
End    
