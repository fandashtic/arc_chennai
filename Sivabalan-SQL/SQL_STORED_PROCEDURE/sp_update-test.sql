CREATE procedure [dbo].[sp_update-test]  
       (@CustomerID_1  [nvarchar],  
 @Phone_2  [nvarchar](50))  
As 
Update [Customer]  
Set [Phone]=@Phone_2  
where ([CustomerID]=@customerID_1)
