CREATE procedure Sp_Display_salesmanDetails
(@salesmancode nvarchar(15))  
as  
declare @salescode nvarchar(255)
 select @salescode =salesmancode from salesman where salesmancode = @salesmancode  
if @salescode = @salesmancode  
 select tm.MeasureId ,sr.scopeid,Tp.periodid,tm.description,SR.SCOPEVALUE,tp.period from salesmantarget as st,  
 scopemaster as sr,Targetmeasure as tm,Targetperiod as Tp  
 where  sr.scopeid  = st.scopeid and  tm.MeasureId = st.Measureid and tp.periodid = st.period and st.salesmancode =@salesmancode  
  
else  
begin  
 select @salescode =salesmancode from salesman where salesman_name = @salesmancode  

 select tm.MeasureId ,sr.scopeid,Tp.periodid,tm.description,SR.SCOPEVALUE,tp.period from salesmantarget as st,  
 scopemaster as sr,Targetmeasure as tm,Targetperiod as Tp  
 where  sr.scopeid  = st.scopeid and  tm.MeasureId = st.Measureid and tp.periodid = st.period and st.salesmancode =@salescode  
end  




