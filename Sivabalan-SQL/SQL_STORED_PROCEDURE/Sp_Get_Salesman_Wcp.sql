CREATE Procedure Sp_Get_Salesman_Wcp(@CustomerID NVarchar(15), @SVDate DateTime) As  
Select WCPAB.SalesmanID From WcpAbstract  WCPAB, WcpDetail WCPDT   
Where WCPAB.Code = WCPDT.Code  
 And WCPDT.Customerid =@CustomerID  
 And WCPDT.WcpDate =dbo.StripDateFromTime(@SVDate) 
 And (IsNull(WCPAB.Status,0) & 128) =0 and  (IsNull(WCPAB.Status,0) & 32) =0 
   
  
  


