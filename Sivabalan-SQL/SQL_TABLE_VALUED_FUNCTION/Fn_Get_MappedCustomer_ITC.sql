CREATE Function Fn_Get_MappedCustomer_ITC        
(        
 @SalesManID nVarchar(500)=N'',        
 @BeatID nVarchar(500) = N'',        
 @ChannelID Int = 0,    
 @SubChannelID Int = 0    
)        
Returns @MappingTable Table        
(        
 SalesManID Int,        
 SalesMan_Name NVarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 BeatID Int,        
 BeatName NVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,      
 CustomerID NVarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 Company_Name NVarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 Address  NVarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS        
)        
As        
Begin        
Declare @TSalesMan Table (SalesManID Int)        
Declare @TBeat Table (BeatID Int)        
Declare @TChannel Table(ChannelID Int)    
Declare @TSubChannel Table(SubChannelID Int)    
Declare @Delimeter as nvarchar(1)      
Declare @TCustomer Table (CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Declare @CustomerID As NVarChar(30)        
DECLARE @CurrentStr nvarchar(2000)          
DECLARE @ItemStr nvarchar(200)        
DECLARE @Salesman TABLE (ItemValue nVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS)         
DECLARE @Beat TABLE (ItemValue nVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS)         
Set @Delimeter = ','      
      
      
 /* Splits salesmanID and stores in a table   */  
 SET @CurrentStr = @SalesManID          
    WHILE Datalength(@CurrentStr) > 0          
  BEGIN          
    IF CHARINDEX(@delimeter, @CurrentStr,1) > 0           
  BEGIN          
         SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@delimeter, @CurrentStr,1) - 1)          
            SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@delimeter, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@delimeter, @CurrentStr,1) + 1))          
      INSERT @Salesman (ItemValue) VALUES (@ItemStr)          
     END          
     ELSE          
     BEGIN                          
   INSERT @Salesman (ItemValue) VALUES (@CurrentStr)              
   BREAK;      
  END      
 END      
      
      
 /* Splits BeatID and stores in a table */  
 SET @CurrentStr = @BeatID          
 WHILE Datalength(@CurrentStr) > 0          
 BEGIN          
  IF CHARINDEX(@delimeter, @CurrentStr,1) > 0           
     BEGIN          
      SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@delimeter, @CurrentStr,1) - 1)          
         SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@delimeter, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@delimeter, @CurrentStr,1) + 1))          
   INSERT @Beat (ItemValue) VALUES (@ItemStr)          
  END          
  ELSE          
     BEGIN                          
      INSERT @Beat (ItemValue) VALUES (@CurrentStr)              
   BREAK;      
  END      
 END      
      
        
 If @SalesManID = N''         
  Insert Into @TSalesMan Select SalesManID from SalesMan Where Active = 1         
 Else        
  Insert Into @TSalesMan  SELECT ITEMVALUE FROM @Salesman     
      
        
 If @BeatID =N''        
  Insert Into @TBeat Select BeatID from Beat Where Active = 1         
 Else        
  Insert Into @TBeat SELECT ITEMVALUE FROM @Beat      
        
    
 If @ChannelID = 0    
 Begin  
  Insert Into @TChannel Values(0)  
  Insert Into @TChannel Select ChannelType From Customer_Channel Where Active = 1     
 End  
 Else    
  Insert Into @TChannel Values (@ChannelID)    
    
 If @SubChannelID = 0    
 Begin  
  Insert Into @TSubChannel Values(0)  
  Insert Into @TSubChannel Select SubChannelID From SubChannel Where Active = 1    
 End  
 Else    
  Insert Into @TSubChannel Values (@SubChannelID)    
    
        
 If @SalesManID <>N'' And @BeatID = '' And @ChannelID = 0 And @SubChannelID = 0    
  Insert Into @MappingTable        
   Select         
     Beat_SalesMan.SalesManID,"SalesMan_Name"=dbo.GetSalesManNameFromID(SalesManID),        
   BeatID,"Description"=dbo.GetBeatDescriptionFromID(BeatID),         
   Beat_SalesMan.CustomerID,"Company_Name"=dbo.GetCustomerNameFromID(Beat_SalesMan.CustomerID),      
   Customer.BillingAddress as Address  
  From         
   Beat_SalesMan, Customer         
  Where    
   SalesManID In (Select SalesmanID From @TSalesMan)      
   And Beat_SalesMan.CustomerID = Customer.CustomerID  
  Order By        
   Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,        
   Description,Beat_SalesMan.CustomerID,Company_Name        
 Else        
  Insert Into @MappingTable        
   Select         
   Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,        
   Beat.Description,Customer.CustomerID,Company_Name,        
   Customer.BillingAddress as Address  
  From         
   Beat_salesMan, Beat, SalesMan,Customer         
  Where        
   Beat_SalesMan.BeatID = Beat.BeatID         
   And Beat_SalesMan.SalesManID = SalesMan.SalesManID        
   And Beat_SalesMan.CustomerID=Customer.CustomerID        
   And Beat.Active=1         
   And SalesMan.Active=1        
   And Beat_SalesMan.SalesManID In (Select SalesManID From @TSalesMan)        
   And Beat_SalesMan.BeatID In (Select BeatID from @TBeat)        
   And IsNull(Customer.ChannelType,0) In (Select ChannelID From @TChannel)    
   And IsNull(Customer.SubChannelID,0) In (Select SubChannelID From @TSubChannel)     
  Order By        
   Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,        
   Beat.Description,Customer.CustomerID,Company_Name        
Return        
End        
