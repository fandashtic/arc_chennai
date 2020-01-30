Create Function fn_GetSalesManName_ITC(@Supervisor_Names nvarchar(4000), @ParamDelimiter Char(1) = ',')            
Returns @SalesmanID Table (SalesmanID int)            
As            
Begin            
      Declare @Delimiter as Char(1)    
      Set @Delimiter = @ParamDelimiter    

     If @Supervisor_Names = N'%%'  or @Supervisor_Names = N'%'          
          Begin          
               Insert into @SalesmanID           
               select Salesman.SalesmanID From Salesman
          End            
     Else           
          Begin           
               Insert into @SalesmanID
				select Distinct Salesman.SalesmanID
				From Salesman, tbl_mERP_SupervisorSalesman, Salesman2   
				Where tbl_mERP_SupervisorSalesman.SalesManID = SalesMan.SalesManID
				and tbl_mERP_SupervisorSalesman.SupervisorID = Salesman2.SalesmanID 
				and Salesman2.SalesmanName in (Select * from dbo.sp_SplitIn2Rows(@Supervisor_Names, @Delimiter)) 
		 End
		 Return            
End	
