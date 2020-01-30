CREATE PROCEDURE spr_list_customers_detail_ex(@BeatID int, @FROMDATE datetime, @TODATE datetime)  
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
 "SegmentCode"=(Select Isnull(SegmentCode,'') From CustomerSegment Where SegmentID=Customer.SegmentID),
 "City" = (Select CityName From City Where City.CityId=Customer.CityId)
 From Customer, Customer_Channel Where CustomerID Not In   
 (Select CustomerID From Beat_Salesman) And  
 Customer.CreationDate Between @FROMDATE AND @TODATE  And 
 Customer.ChannelType = Customer_Channel.ChannelType  
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
 "SegmentCode"=(Select Isnull(SegmentCode,'') From CustomerSegment Where SegmentID=Customer.SegmentID),
 "City" = (Select CityName From City Where City.CityId=Customer.CityId)
 From Customer, Customer_Channel Where CustomerID In   
 (Select CustomerID From Beat_Salesman Where BeatID = @BeatID) And  
 Customer.CreationDate Between @FROMDATE AND @TODATE  And 
 Customer.ChannelType = Customer_Channel.ChannelType  
END  

