CREATE PROCEDURE spr_list_customers_detail_Bunge(@BeatID int, @FROMDATE datetime, @TODATE datetime)  
AS  
IF @BeatID = 0  
BEGIN  
 Select CustomerID, "CustomerID" = CustomerID, "Customer Name" = Company_Name,   
 "Channel Type" = Customer_Channel.ChannelDesc, "Contact Person"=ContactPerson,  
 "Salesman" =(select salesman_name from salesman, Beat_Salesman  
 Where Salesman.SalesmanID = Beat_Salesman.SalesmanID And  
 Beat_Salesman.BeatID = @BeatID And  
 Beat_Salesman.CustomerID = Customer.CustomerID),  
 "Forum Code" = AlternateCode,
 "Town/District" = (Select DistrictName From District Where DistrictID =  Customer.District),
 "State" = (Select State From State Where StateID = Customer.StateId)  
 From Customer, Customer_Channel Where CustomerID Not In   
 (Select CustomerID From Beat_Salesman) And  
 CreationDate Between @FROMDATE AND @TODATE  
 And Customer.ChannelType = Customer_Channel.ChannelType  
END  
ELSE  
BEGIN  
 Select CustomerID, "CustomerID" = CustomerID, "Customer Name" = Company_Name,   
 "Channel Type" = Customer_Channel.ChannelDesc, "Contact Person"=ContactPerson,   
 "Salesman" =(select salesman_name from salesman, Beat_Salesman  
 Where Salesman.SalesmanID = Beat_Salesman.SalesmanID And  
 Beat_Salesman.BeatID = @BeatID And  
 Beat_Salesman.CustomerID = Customer.CustomerID),  
 "Forum Code" = ALternateCode,  
 "Town/District" = (Select DistrictName From District Where DistrictID =  Customer.District),
 "State" = (Select State From State Where StateID = Customer.StateId)  
 From Customer, Customer_Channel Where CustomerID In   
 (Select CustomerID From Beat_Salesman Where BeatID = @BeatID) And  
 CreationDate Between @FROMDATE AND @TODATE  
 And Customer.ChannelType = Customer_Channel.ChannelType  
END  
  



