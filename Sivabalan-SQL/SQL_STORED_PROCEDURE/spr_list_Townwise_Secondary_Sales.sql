CREATE procedure [dbo].[spr_list_Townwise_Secondary_Sales]          
(           
@From_Date DateTime,           
@To_Date DateTime,           
@UOM nvarchar(256)          
 )          
AS     
Select Distinct City.CityID, CityName, District.DistrictName, State.State  
From City, District, State, Customer, DispatchAbstract  
Where Customer.CityID = City.CityID  
and Customer.District *= District.DistrictID   
And Customer.StateID *= State.StateID   
And DispatchAbstract.CustomerID = Customer.CustomerID  
and DispatchDate between @From_Date and @To_Date   
and Isnull(Status & 64,0) = 0   
union  
Select Distinct City.CityID, CityName, District.DistrictName, State.State  
From City, District, State, Customer, InvoiceAbstract  
Where Customer.CityID = City.CityID  
and Customer.District *= District.DistrictID   
And Customer.StateID *= State.StateID   
and Customer.CustomerID = InvoiceAbstract.CustomerID  
and InvoiceDate between @From_Date and @To_Date     
and Isnull(Status & 192,0) = 0     
and InvoiceType in (4)  
Order by City.CityName
