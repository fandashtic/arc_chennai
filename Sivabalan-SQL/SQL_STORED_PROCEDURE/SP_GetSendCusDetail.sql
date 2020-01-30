CREATE procedure [dbo].[SP_GetSendCusDetail](@Cusid nvarchar(30))                                
As                              
Set DateFormat DMY                 
Select "ID"=Customer.CustomerID,"Name"=Customer.Company_Name,                  
 "Cntperson"=Customer.ContactPerson,"Catdesc"=CustomerCategory.CategoryName,                                  
 "BillAdd"=Customer.BillingAddress,"ShipAdd"=Customer.ShippingAddress,                                  
 "CityDesc"=Isnull(City.CityName,N''),"StateDesc"=Isnull(State.State,N''),"CountryDesc"=Isnull(Country.Country,N''),                                  
 "AreaDesc"=IsNull(Areas.Area,N''),"Phone"=Customer.Phone,"Email"=Customer.Email,                                  
 "Discount"=Customer.Discount,"TNGST"=Customer.TNGST,"CreditType"=Isnull(CreditTerm.Type,0),                                  
 "CreditID"=Isnull(Creditterm.Description,0),"CreditValue"=Isnull(CreditTerm.Value,0),                                  
 "DlNum"=Customer.DLNumber,"dlnum21"=Customer.DLNumber21,                                  
 "Beatdesc"=Case dbo.Fn_getbeatdescforcus(Customer.CustomerID) When N'No Beat' then NULL Else dbo.Fn_getbeatdescforcus(Customer.CustomerID) End ,                                  
 "CST"=Customer.CST,"Creditlimit"=Customer.CreditLimit,"Forumcode"=Customer.AlternateCode,                                  
 "Creditrating"=Customer.CreditRating,"ChannelDesc"=Customer_Channel.ChannelDesc,                                  
 "Locality"=Customer.Locality,                                  
 "PayModeID"=Customer.Payment_Mode,"Password"=Customer_Password,"Active"=Customer.Active,                                
"District"=Isnull(District.DistrictName,N''),                          
"TownClassify"=Isnull(Customer.TownClassify,0),                          
"TIN_NUMBER"=Isnull(Customer.TIN_Number,N''),                          
"Alternate_Name"=Isnull(Customer.Alternate_Name,N''),                          
"SubChannel"=Isnull(SubChannel.Description,N''),                          
"Potential"=Isnull(Customer.Potential,N''),                          
"MobileNumber"=Isnull(Customer.MobileNumber,N''),                    
"SequenceNumber"=Isnull(Customer.SequenceNo,0),            
"TrackPoints"=Isnull(Customer.TrackPoints,0),            
"CollectedPoints"=Isnull(Customer.CollectedPoints,0),                  
"Residence"=Isnull(Customer.Residence,N''),                          
"DOB"=Customer.DOB,                                
"ReferredBy"=Isnull(Doctor.Name,N''),                                
"MembershipCode"=Customer.MembershipCode,                                
"Fax"=Customer.Fax,                                
"RetailCategory"=Isnull(RetailCustomerCategory.CategoryName,N''),                                
"Salutation"=Isnull(Salutation.Description,N''),                                
"FirstName"=Customer.First_Name,                                
"SecondName"=Customer.Second_Name,                                
"PinCode"=Customer.PinCode,                                
"Occupation"=Isnull(Occupation.Occupation,N''),                                
"Awareness"=dbo.sp_CombineDataIDFromName(Customer.Awareness,N','),                                      
"CitySTDCode"=Isnull(City.STDCode,N''),          
"SegmentCode"=Isnull(CustomerSegment.SegmentCode,N''),
"DefaultBeat" = (Case When IsNull(Customer.DefaultBeatId,0) = 0 Then N'' Else (Select Description From Beat Where BeatId = Customer.DefaultBeatId) End)
From Customer,Customer_Channel,CustomerCategory,Areas,City,State,Country,Beat_SalesMan,CreditTerm,                                
District, SubChannel, RetailCustomerCategory, Doctor, Salutation, Occupation,CustomerSegment                                
 Where Customer.ChannelType*=Customer_Channel.ChannelType And                                  
 Customer.CustomerCategory*=CustomerCategory.CategoryID And                                  
 Customer.AreaID*=Areas.AreaId And                                  
 Customer.CityID*=City.CityID And                                  
 Customer.StateID*=State.StateID And                                  
 Customer.CountryID*=Country.CountryID And                                  
 Customer.CreditTerm*=CreditTerm.CreditID And                                  
 Customer.CustomerID*=Beat_Salesman.CustomerID And                                  
 Customer.CustomerID=@Cusid And                                
Customer.District*=District.DistrictID And                              
Customer.SubChannelID*=SubChannel.SubChannelID And                              
Customer.RetailCategory*=RetailCustomerCategory.CategoryID And                                
Customer.ReferredBy*=Doctor.[ID] And                                 
Customer.SalutationID*=salutation.SalutationID And                                 
Customer.Occupation*=Occupation.OccupationID And           
Customer.SegmentID*=CustomerSegment.SegmentId
