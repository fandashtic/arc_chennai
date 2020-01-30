CREATE procedure Sp_GetRev_Beat(@Custid NVarchar (200))            
as            
Declare @Delimeter as Char(1)                
Set @Delimeter=Char(15)            
Create Table #tmpCust (Cust NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)            
  
Insert into  #tmpCust Select * From dbo.sp_SplitIn2Rows(@Custid,@Delimeter)            
Create Table #TmpBeat (Beat int)    
            
Insert into #TmpBeat Select Distinct( bet.BeatID)          
From customer cus, beat_salesman bet, Beat Bt             
Where cus.customerid = bet.customerid and            
 bt.beatid= bet.beatid and          
 bet.Customerid in(Select Cust COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCust)    
      
If exists (Select Cust  From #TmpCust Where Cust not in (Select CustomerID From Beat_Salesman))    
Insert Into #TmpBeat Values(0)    
    
select * from #TmpBeat    
Drop table #TmpBeat    


