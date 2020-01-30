CREATE Procedure SP_GetSendCusDetail_ITC(@Cusid nvarchar(30))                                
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
 "Beatdesc"=(Case When IsNull(Customer.DefaultBeatId,0) = 0 Then N'' Else (Select Description From Beat Where BeatId = Customer.DefaultBeatId) End),  
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
"SegmentCode"=Isnull(CustomerSegment.SegmentCode,N'')
From Customer
Left Outer Join Customer_Channel On Customer.ChannelType =Customer_Channel.ChannelType
Left Outer Join CustomerCategory On  Customer.CustomerCategory=CustomerCategory.CategoryID
Left Outer Join Areas On Customer.AreaID =Areas.AreaId 
Left Outer Join City On  Customer.CityID=City.CityID
Left Outer Join State On Customer.StateID=State.StateID
Left Outer Join Country On  Customer.CountryID=Country.CountryID 
Left Outer Join CreditTerm On  Customer.CreditTerm=CreditTerm.CreditID
Left Outer Join District On Customer.District=District.DistrictID
Left Outer Join SubChannel On Customer.SubChannelID=SubChannel.SubChannelID
Left Outer Join RetailCustomerCategory On Customer.RetailCategory=RetailCustomerCategory.CategoryID
Left Outer Join Doctor On Customer.ReferredBy =Doctor.[ID]
Left Outer Join Salutation On Customer.SalutationID=salutation.SalutationID
Left Outer Join Occupation On Customer.Occupation=Occupation.OccupationID
Left Outer Join CustomerSegment On Customer.SegmentID=CustomerSegment.SegmentId                                       
 Where Customer.CustomerID=@Cusid
 -- Customer.CustomerID*=Beat_Salesman.CustomerID And                                    
