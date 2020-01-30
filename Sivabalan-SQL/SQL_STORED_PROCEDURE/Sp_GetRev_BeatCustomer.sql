CREATE procedure Sp_GetRev_BeatCustomer(@Custid Nvarchar (200))        
as        
Declare @Delimeter as Char(1)            
Set @Delimeter=Char(15)        
Create Table #tmpCust (Cust NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Insert Into  #tmpCust Select * From dbo.sp_SplitIn2Rows(@Custid,@Delimeter)        
        
Select cus.customerid, cus.company_name , bet.BEatID ,bt.Description      
From customer cus, beat_salesman bet, Beat Bt         
Where cus.customerid = bet.customerid and        
 bt.beatid= bet.beatid and   
 Cus.Active=1 And     
 bet.Customerid in(Select Cust COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust) Order By cus.CustomerId        
      
    
    
    
    
  
  


