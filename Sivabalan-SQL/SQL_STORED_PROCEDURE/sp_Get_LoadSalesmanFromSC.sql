CREATE Procedure sp_Get_LoadSalesmanFromSC(@SCNum NVarChar(15),@mode int) As   
Begin  
Select * into #TempSC from dbo.sp_splitin2rows(@SCNum,',')  
  
if (@mode=1)  
 select Top 1 sm.Salesman_name from Salesman sm,DispatchAbstract da,SOAbstract soa   
where da.DispatchID in (Select ItemValue From #TempSC)   
and da.RefNumber=soa.SONumber   
and soa.SalesmanID=sm.SalesmanID  
else  
 select Top 1 sm.Salesman_name from Salesman sm,SOAbstract soa where soa.SONumber in (Select ItemValue From #TempSC) and soa.SalesmanID=sm.SalesmanID and sm.Active=1  
  
drop table #TempSC  
End  

