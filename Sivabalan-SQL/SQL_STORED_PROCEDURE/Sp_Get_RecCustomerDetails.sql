Create Procedure Sp_Get_RecCustomerDetails(@ForumCode nvarchar(6))          
As          
    
Select "CusStatus"=Case dbo.fn_CanSaveCustomer(ID) When N'Y' then 2           
     When N'E' then 1          
     Else 0 end,          
"Customer ID"=CustomerID,"ID"=ID,"Customer Name"= Case When IsNull(MembershipCode,N'') = N'' Then Company_Name       
 Else FirstName + N' ' + SecondName End,          
"Forum Code"=ForumCode,"Contact Person"=ContactPerson,"Customer Category"=CustomerCategory,          
"Segment"=(Select SegmentName From     
  ReceivedSegments Where SegmentID=RC.SegmentID),    
"Channel Type"=ChannelType, "Beat"=Beat,"Area"=Area,"City"=City,"State"=State,          
"Country"=Country,"CreditTerm"=CreditTerm,          
"DOB"=DOB, "ReferredBy"=ReferredBy,"MemberShipCode"=MembershipCode,          
"RetailCategory"=RetailCategory,"Occupation"=Occupation,          
"Customer Type"=Case dbo.fn_CanSaveCustomer(ID) When N'Y' then N'New'           
     When N'E' then N'Existing'          
     Else N'Invalid' end,          
"REASON"=Case dbo.fn_CanSaveCustomer(ID)When N'N' then dbo.fn_getReasonForCustomer(ID)          
     Else N'' end          
From ReceivedCustomers RC Where BranchForumCode=@ForumCode          
And isnull(Status,0)=0 Order by CusStatus Desc      
