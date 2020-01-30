CREATE Function fn_GetBeatForSalesMan_ITC(@SalesMan_Names nvarchar(4000),@ParamDelimiter Char(1) = ',')          
Returns @BeatID Table (BeatID int)          
As          
Begin          
      Declare @Delimiter as Char(1)  
--       Set @Delimiter = Char(44)          
       Set @Delimiter = @ParamDelimiter  
  
      --N'%' will come from Rpt Viewer Procedures  
      --N'%%' will come from Rpt Viewer AutoComplete  
      if @SalesMan_Names = N'%%'  or @SalesMan_Names = N'%'        
          Begin        
               Insert into @BeatID         
               select Beat.BeatID From Beat        
          End          
      Else         
          Begin         
               Insert into @BeatID         
               select Distinct Beat.BeatID   
               from  Beat_SalesMan, SalesMan, Beat   
               where Beat_SalesMan.SalesManID = SalesMan.SalesManID   
                     and Beat_SalesMan.BeatID = Beat.BeatID     
                     and SalesMan.SalesMan_Name in (Select * from dbo.sp_SplitIn2Rows(@SalesMan_Names,@Delimiter))        
          End                      
      Return          
End  
  


