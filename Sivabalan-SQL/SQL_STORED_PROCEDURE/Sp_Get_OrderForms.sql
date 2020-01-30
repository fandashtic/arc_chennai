CREATE Procedure Sp_Get_OrderForms As  
Select * from OrderAbstract Where   
Active = 1 Order by DocSerial  


