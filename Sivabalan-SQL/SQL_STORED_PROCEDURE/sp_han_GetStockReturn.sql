CREATE Procedure sp_han_GetStockReturn      
as        
Select distinct SR.[ReturnNumber], SR.[DocumentDate], SR.[BillID], 
SR.[SALESMANID] 'SR_SALESMANID',             
SR.[BeatID] 'SR_BeatID',            
SR.[OUTLETID] 'SR_CustID', SR.[Processed],   
Isnull(c.Customerid, '') 'C_Customerid',             
Isnull(s.SalesmanID, 0) 'S_SalesmanID',            
c.CustomerCategory 'C_CustomerCategory',  
(Select Count(*)   
    From (select distinct t.ReturnNumber, t.OutletId, t.BeatID, t.SalesmanID, t.DocumentDate from Stock_Return t             
        Where t.ReturnNumber = SR.ReturnNumber) a) 'Count'  
From Stock_Return SR            
    left outer join Customer c On c.CustomerID = SR.[OUTLETID]            
    left outer join Salesman s On Cast(s.SalesmanID as nvarchar)= SR.[SALESMANID]            
Where SR.[Processed] = 0             
Order by SR.[DocumentDate]
