Create Procedure mERP_sp_list_AdminUsers (@AuthType Int)  
As    
Select UserName From Users Where Active=1  And GroupName In (  
  SELECT GroupName FROM Groups   
  WHERE Case @AuthType When 1 then CHARINDEX('Back Dated Transaction', Permission)  
        When 2 then CHARINDEX('Purchase Bill - PTR Changes', Permission)  
        When 3 then CHARINDEX('Credit Management', Permission)   
        When 4 then CHARINDEX('Day close', Permission) 
        When 5 then CHARINDEX('View Performance Metrics', Permission) 
		When 6 then CHARINDEX('CLO Credit Note', Permission) 
		When 7 then CHARINDEX('D & D', Permission)
		When 8 then CHARINDEX('DSType Planning', Permission) 
		End > 0  
  And GroupName = Case When @AuthType in (5,6,7,8)  Then 'Administrator' Else  GroupName End
)
