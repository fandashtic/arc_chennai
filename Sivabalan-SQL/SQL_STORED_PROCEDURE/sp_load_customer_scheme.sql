CREATE procedure [dbo].[sp_load_customer_scheme](            
 @Category nvarchar(250),            
 @ChannelType nvarchar(250),            
 @BeatName nvarchar(250),        
 @Active integer,  
 @IsTradeCustomerOnly integer = 0            
 )            
as            
            
Create Table #CustMasterView         
(CustomerCode nvarchar(200), CustomerName nvarchar(200)         
 , Category integer, Channel integer, Salesman  integer, Beat nvarchar(200),CustCategory nvarchar(200))            
  
If @IsTradeCustomerOnly=0   
Begin            
 Insert into #CustMasterView             
 Select cu.CustomerID "CustID", cu.Company_Name "CustName", isnull(cu.CustomerCategory,0) "CatID", isnull(cu.ChannelType,0) "ChTypeID"             
 ,IsNull(bs.SalesmanID,0)  "SalesmanID",         
 (Select [Description] From Beat Where BeatID = isnull(bs.BeatID,0)) "BeatDesc"      
 ,CategoryName "CustCategory"            
 From customer cu , beat_salesman bs, CustomerCategory CC            
 Where cu.customerID *= bs.customerID And (cu.Active = 1 Or cu.Active = @Active)     
  And cu.CustomerCategory = CC.CategoryID --and CC.CategoryID <> 5        
End  
Else  
Begin            
 Insert into #CustMasterView             
 Select cu.CustomerID "CustID", cu.Company_Name "CustName", isnull(cu.CustomerCategory,0) "CatID", isnull(cu.ChannelType,0) "ChTypeID"             
 ,IsNull(bs.SalesmanID,0)  "SalesmanID",         
 (Select [Description] From Beat Where BeatID = isnull(bs.BeatID,0)) "BeatDesc"      
 ,CategoryName "CustCategory"            
 From customer cu , beat_salesman bs, CustomerCategory CC            
 Where cu.customerID *= bs.customerID And (cu.Active = 1 Or cu.Active = @Active)     
  And cu.CustomerCategory = CC.CategoryID and CC.CategoryID <> 4 and CC.CategoryID <> 5      
End  
Select CV.CustomerCode "CustomerCode", CV.CustomerName "CustomerName"            
,IsNull((Select IsNull(CS.Salesman_Name,N'') From SalesMan CS Where CV.SalesMan = CS.SalesManID),N'') "SalesMan"            
, Isnull(CV.Beat ,N'') "Beat"       
,CV.CustCategory "CustCategory" 
       
From #CustMasterView CV ,            
 customer_channel CC ,            
 customerCategory CT            
Where             
 CV.Channel = CC.ChannelType  --or (@Category=N'%' and @ChannelType=N'%') 
 And CV.Category = CT.CategoryID 
 And CC.ChannelDesc Like @ChannelType  
 And CT.CategoryName Like @Category            
 And IsNull(CV.Beat,N'') Like @BeatName            
Order By CV.Category          
Drop Table #CustMasterView
