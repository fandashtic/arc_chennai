Create  Procedure sp_update_Customer_creation_date(@CustomerID [nvarchar](255), @Dt_Creation DateTime)
As
  BEGIN
  Update Customer Set CreationDate= @Dt_Creation Where CustomerID = @CustomerID
  END 
