CREATE procedure [dbo].[spr_list_Datewise_RetailCustomers](@FROMDATE datetime,  
         @TODATE datetime)      
AS    
SELECT CustomerID, CustomerID, "Customer Name" = Company_Name, "Membership Code" = MembershipCode,    
"Category" = CategoryName, "Occupation" = Occupation.Occupation, "Address1" = BillingAddress,   
"Address2" = ShippingAddress, "Contact Person" = ContactPerson,  "City" = CityName,   
"STD Code" = STDCode, "Pin Code" = PinCode, "Phone" = Phone, "Fax" = Fax, 
"Mobile" = MobileNumber, "Referred By" = Doctor.Name, "EMail" = EMail,  
DOB, "Awareness"=dbo.sp_CombineDataIDFromName(Customer.Awareness,',')   
FROM Customer, Doctor, RetailCustomerCategory, Occupation, City  
WHERE Customer.RetailCategory *= RetailCustomerCategory.CategoryID And    
CustomerCategory = 4 And Customer.ReferredBy *= Doctor.ID  
And Customer.Occupation *= Occupation.OccupationID   
And Customer.CityID *= City.CityId  
And (Customer.CreationDate Between @FromDate and @ToDate OR   
Customer.ModifiedDate Between @FromDate and @ToDate)
