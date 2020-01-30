Create Procedure Sp_List_CustomerDetails(@FromDate datetime,@ToDate Datetime)          
As          
Declare @Delimeter as Char(1)                      
Set @Delimeter = Char(15)           
Select "Customer ID"=CustomerID,          
 "Customer Name"=dbo.sp_ConvertToSpace(Company_Name,@Delimeter,' '),          
 "Contact Person"=ContactPerson,          
 "Forum Code"=AlternateCode,          
 "Category"=(Select CategoryName from CustomerCategory Where CategoryID=Customer.CustomerCategory),          
 "Segment"=(Select SegmentName From CustomerSegment Where SegmentID=Customer.segmentID),    
 "ChannelType"=(Select ChannelDesc From Customer_Channel Where ChannelType=Customer.ChannelType),          
 "Locality"= dbo.LookupDictionaryItem(Case ISnull(Customer.Locality,1) When 1 then N'Local'       
    Else       
     Case Customer.CustomerCategory      
      When 4 then N''      
     Else       
      N'OutStation'       
     End      
    End, Default),       
 "Phone"=Phone,"Email ID"=Email,          
 "Area"=Case IsNull(AreaID,0) when 0 then N'' Else (Select Area from Areas where Areas.AreaID=Customer.AreaID) End,          
 "City"=Case IsNull(CityID,0) when 0 then N'' Else (Select CityName from City where City.CityID=Customer.CityID) End,          
 "State"=Case IsNull(StateID,0) when 0 then N'' Else (Select State from State where State.StateID=Customer.StateID) End,          
 "Country"=Case IsNull(CountryID,0) when 0 then N'' Else (Select Country from Country where Country.CountryID=Customer.CountryID) End,          
 "DOB"=DOB,          
 "ReferredBy"=Case IsNull(ReferredBy,0) when 0 then N'' Else (Select [Name] from Doctor where [ID]=Customer.ReferredBy) End,          
 "MembershipCode"=MembershipCode,          
 "Fax"=Fax,          
 "RetailCategory"=Case IsNull(RetailCategory,0) when 0 then N'' Else (Select CategoryName from RetailCustomerCategory where CategoryID=Customer.RetailCategory) End,          
--"Salutation"=(Select [Description] from Salutation where SalutationID=Customer.SalutationID),          
 "PinCode"=PinCode,          
 "Occupation"=Case IsNull(Occupation,0) when 0 then N'' Else (Select Occupation from Occupation where OccupationID=Customer.Occupation) End,          
 "MobileNumber"=MobileNumber,          
 "CitySTDCode"=Case IsNull(CityID,0) when 0 then N'' Else (Select STDCode from City where City.CityID=Customer.CityID) End          
 from Customer Where CustomerCategory <> 5 And CreationDate Between @FromDate And @Todate          
