CREATE PROCEDURE sp_Get_QuotationCustomer_Detail(@QuotationID INT, @CustomerCategory nVarchar(50), @CustomerType nVarchar(50), @FilterType nvarchar(50), @FilterID nVarchar(50),@FromDate DateTime, @ToDate DateTime)            
As            
SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)
IF @FilterType = N'0' --All customer filter      
BEGIN      

 SELECT Distinct "CustomerID" = QuotationCustomers.CustomerID, "CustomerName" = Company_Name, QuotationName FROM Customer, QuotationAbstract, QuotationCustomers      
 WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID      
 And QuotationAbstract.QuotationID = @QuotationID      
  UNION ALL    
 SELECT Distinct "CustomerID" = Customer.CustomerId, "CustomerName" = Company_Name, N''  FROM Customer      
 WHERE Customer.CustomerID NOT IN (SELECT QuotationCustomers.CustomerID FROM QuotationCustomers, QuotationAbstract 
 				   WHERE QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or
					(@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate)) And
				   QuotationAbstract.QuotationID = QuotationCustomers.QuotationID
				   UNION
				   SELECT QuotationCustomers.CustomerID FROM Customer, QuotationAbstract, QuotationCustomers      
				   WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID      
				   And QuotationAbstract.QuotationID = @QuotationID)
 And Cast(CustomerCategory As nVarchar) Like @CustomerCategory 
 And Cast(Locality As nVarchar) Like @CustomerType
 And Customer.Active = 1      
END      
ELSE IF @FilterType = N'1' --Beat Filter      
BEGIN      
 SELECT Distinct "CustomerID" = QuotationCustomers.CustomerID, "CustomerName" = Company_Name, QuotationName FROM Customer, QuotationAbstract, QuotationCustomers      
 WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID      
 And QuotationAbstract.QuotationID = @QuotationID      
 UNION ALL      
 SELECT Distinct "CustomerID" = Customer.CustomerID, "CustomerName" = Company_Name, N'' FROM Customer, Beat_SalesMan       
 WHERE Customer.CustomerID = Beat_SalesMan.CustomerID       
 And Beat_SalesMan.CustomerID NOT IN (SELECT QuotationCustomers.CustomerID FROM QuotationCustomers, QuotationAbstract 
 				   WHERE QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or
					(@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate)) And
				   QuotationAbstract.QuotationID = QuotationCustomers.QuotationID
				   UNION
				   SELECT QuotationCustomers.CustomerID FROM Customer, QuotationAbstract, QuotationCustomers      
				   WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID      
				   And QuotationAbstract.QuotationID = @QuotationID)
 And Cast(Beat_SalesMan.BeatID As nVarchar) LIKE @FilterID           
 And Cast(CustomerCategory As nVarchar) Like @CustomerCategory             
 And Cast(Locality As nVarchar) Like @CustomerType            
 And Customer.Active = 1    
END      
ELSE --channel filter      
BEGIN      
 SELECT Distinct "CustomerID" = QuotationCustomers.CustomerID, "CustomerName" = Company_Name, QuotationName FROM Customer, QuotationAbstract, QuotationCustomers      
 WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID    
 And QuotationAbstract.QuotationID = @QuotationID      
 UNION ALL      
 SELECT Distinct "CustomerID" = Customer.CustomerID, "CustomerName" = Company_Name, N'' FROM Customer      
 WHERE Customer.CustomerID NOT IN (SELECT QuotationCustomers.CustomerID FROM QuotationCustomers, QuotationAbstract 
 				   WHERE QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or
					(@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate)) And
				   QuotationAbstract.QuotationID = QuotationCustomers.QuotationID
				   UNION
				   SELECT QuotationCustomers.CustomerID FROM Customer, QuotationAbstract, QuotationCustomers      
				   WHERE QuotationCustomers.CustomerID = Customer.CustomerID And QuotationCustomers.QuotationID = QuotationAbstract.QuotationID      
				   And QuotationAbstract.QuotationID = @QuotationID)
 And Cast(Customer.ChannelType As nVarchar) LIKE @FilterID          
 And Cast(CustomerCategory As nVarchar) Like @CustomerCategory             
 And Cast(Locality As nVarchar) Like @CustomerType            
 And Customer.Active = 1    
END      
   
  






