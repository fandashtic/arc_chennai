/*
--o.[BeatID] 'Order_BeatID',
If BeatID is empty then Customer & Salesman related BeatID should be considered for creating SC
Revisit on 19 FEB 2009
*/
Create Procedure sp_han_GetOrders      
as   
Set dateformat dmy
Declare @DayCloseDate Datetime
Select @DayCloseDate=dbo.StripDateFromTime(LastInventoryUpload) from Setup
   
Select o.[OrderNUMBER],   
o.[Order_DATE],   
o.[DELIVERY_DATE],   
o.[SALESMANID] 'Order_SALESMANID',  
(Case when Isnull(o.[BeatID], '') = '' or o.[BeatID] = 0 then   
 (  
 Select top 1 BS.BeatID from Beat_SalesMan BS   
 Inner Join Beat B On B.BeatID = BS.BeatID and B.Active = 1  
 where BS.SalesmanID = o.[SALESMANID] and BS.CustomerID = o.[OUTLETID]  
 )  
else o.[BeatID] end) 'Order_BeatID',  
o.[OUTLETID] 'Order_CustID',  
o.[PROFITCENTER] 'CompanyID',  
o.[CreationDate],  
o.[Processed],   
Isnull(o.[VanOrder],'') 'Order_VanOrder',   
isnull(o.[VanLoadingSlipNumber],0) 'Order_VanLoadSlipNumber',        
Isnull(c.Customerid, '') 'C_Customerid',   
Isnull(c.Company_name, '') 'C_Customername',           
case when  isnull (c.CreditTerm,0) <= 0   then  
 isnull (CT.CreditID,0)    
else  
 isnull (c.CreditTerm ,0)  
end 'C_CreditTerm' ,  
Isnull(s.SalesmanID, 0) 'S_SalesmanID',          
IsNull(c.Locality, 1) 'C_Locality',   
c.BillingAddress 'C_BillingAddress',           
c.ShippingAddress 'C_ShippingAddress',   
Isnull(c.CreditLimit, 0) 'C_CreditLimit',          
c.CustomerCategory 'C_CustomerCategory',   
(Select Count(*) From Order_Header u Where u.OrderNUMBER = o.OrderNUMBER and u.Order_DATE>@DayCloseDate) 'Count',   
o.PaymentType 'Payment_Type',   
o.DiscountAmt 'Discount_Amt',   
o.DiscountPer 'Discount_Per' ,  
(Case When OrderNUMBER  Like'ORD%' Then OrderNUMBER Else (Case isNull(o.OrderRefNumber,'') When '' Then  OrderNUMBER Else o.OrderRefNumber End) End) 'OrderRefNumber'  
From Order_Header o          
left outer join Customer c On c.CustomerID = o.[OUTLETID]   
left outer join (select top 1 creditid, active from creditterm where active = 1 ) CT On 1 = 1 and CT.Active = 1   
left outer join Salesman s On Cast(s.SalesmanID as nvarchar)= o.[SALESMANID]          
Where o.[Processed] = 0  
Order by o.CreationDate

