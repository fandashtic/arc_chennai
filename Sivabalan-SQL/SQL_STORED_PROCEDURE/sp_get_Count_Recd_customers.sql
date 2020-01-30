CREATE Procedure sp_get_Count_Recd_customers  
As    
Select Distinct Count(ForumCode) From receivedcustomers  
Where Status & 192 = 0 
