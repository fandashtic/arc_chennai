CREATE Procedure spr_list_Sales_Vat_Report_Abstract_ITC(@FromDate DateTime,@ToDate DateTime,@TaxCBrkUP varchar(10)='No')                                  
As                            
Begin                                  
Declare @CustCnt as int                                  
Declare @found as int                                  
Declare @taxcnt as int                                  
Declare @counter as int                                  
Declare @counter1 as int                                  
Declare @CustId as Nvarchar(255)                                  
Declare @tmpSql as nvarchar(4000)                   
If @TaxCBrkUP='Yes'                                 
	Declare @TaxTCB as nVarchar(255)
Else                  
	Declare @Tax as Decimal(18,6)
Declare @taxid as Decimal(18,6)
Declare @VatTax as Decimal(18,6)                                  
Declare @VatCnt as int                                  
Declare @cur_VatTax as cursor                                  
Declare @cur_Customer as cursor                                  
Declare @TempSql nVarchar(4000)                                    
Declare @cust_id as nvarchar(300)                                
Declare @totAmt as decimal(18,6)                                
Declare @totTax as decimal(18,6)  
declare @temp datetime 

Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
	select 0,'This report cannot be generated for GST period' as Reason
	goto GSTOut
end               
                 
if(@TODATE > @temp )
begin
	set @TODATE  = @temp 
	--goto GSTOut
end                                  
                                  
Create Table #tmpVatAbstract([CustomerId] nvarchar(30),[Customer Id] nvarchar(30) ,[Customer Name] nvarchar(300),[Billing Address] nvarchar(510),[Tin No] nvarchar(20))                                  
Create Table #tmpcust(CustomerId nvarchar(300))                                  
if @TaxCBrkUP='Yes'                   
Begin                  
	Create Table #tmpVatTaxTCB(taxid Decimal(18,6),taxType nvarchar(255),taxpercent decimal(18,6),lstflag int)                                  
	Create Table #tmpCustTaxTCB(invid int,CustomerId nvarchar(30),taxid Decimal(18,6),TaxType nvarchar(255),VatTaxAmount Decimal(18,6),VatTax Decimal(18,6),lstflag int)                                  
	Create Table #tmpCustTax1TCB(CustomerId nvarchar(30),taxid Decimal(18,6),TaxType nvarchar(255),VatTaxAmount Decimal(18,6),VatTax Decimal(18,6),lstflag int)                                  
End                  
Else                  
Begin                  
	Create Table #tmpVatTax(taxType Decimal(18,6), taxid Int)                              
	Create Table #tmpCustTax(CustomerId nvarchar(300),TaxType Decimal(18,6),VatTaxAmount Decimal(18,6),VatTax Decimal(18,6), taxid int)                              
	Create Table #tmpCustTax1(CustomerId nvarchar(300),TaxType Decimal(18,6),VatTaxAmount Decimal(18,6),VatTax Decimal(18,6), taxid int)                              
End                  
Create Table #tmpTotTax(CustomerId nvarchar(300),TotSalesAmount Decimal(18,6),TotTax Decimal(18,6))                                
        
Create Table #tmpExempt(CustomerId nvarchar(30),[Customer Name] nvarchar(300),[Billing Address] nvarchar(510),[Tin No] nvarchar(20),ExemptAmount Decimal(18,6),ExemptTax Decimal(18,6))        
        
Insert Into #tmpExempt        
Select Exmp.CustomerId,Exmp.Company_Name,        
Exmp.BillingAddress,Exmp.TIN_Number,sum(Exmp.amount) Amount,Exmp.taxamount        
From(          
Select Distinct ia.invoiceid,C.CustomerId,C.Company_Name,        
C.BillingAddress,C.TIN_Number,case when ia.invoicetype=4 then -1 else 1 end * amount amount        
,taxamount        
From InvoiceAbstract Ia ,InvoiceDetail Id,Customer C        
Where Invoicedate   between @FromDate and @ToDate               
And Ia.InvoiceType Not In (2,5,6)                      
And   IsNull(Ia.Status, 0) & 192 = 0                           
And Ia.InvoiceID=Id.InvoiceId         
And Ia.customerid=C.customerid         
and taxamount=0) Exmp        
group by Exmp.CustomerId,Exmp.Company_Name,        
Exmp.BillingAddress,Exmp.TIN_Number,Exmp.taxamount        
--     
--select * from #tmpExempt        
Declare @ChkExemp as int           
Set @ChkExemp=0          
                    
if exists (Select (amount)          
 From InvoiceAbstract Ia,InvoiceDetail Id                              
 Where Ia.InvoiceId=Id.InvoiceId                               
 And InvoiceDate Between  @FromDate and @ToDate                             
 And Ia.InvoiceType Not In (2,5,6)                                 
 and IsNull(Ia.Status, 0) & 192 = 0                       
 And Taxamount=0)           
Begin          
Set @ChkExemp=1          
Set @tmpSql='Alter Table #tmpVatAbstract Add Exempt Decimal(18, 6) Default(0)'                                    
Exec sp_executesql @tmpSql          
end                      
          
if (@TaxCBrkUP='Yes')                      
Begin                      
 --Code For tax coponent splitup                                      
Create table #TaxComp(taxid int,customerid nvarchar(300),taxcomponent_desc nvarchar(255),taxcomponent_code nvarchar(255)                      
,lst_flag int,Tax_description nvarchar(255),tax_value decimal(18,6),taxpercentage decimal(18,6))                      
          
Insert into #TaxComp                      
Select distinct taxid,CustomerId,                  
(select taxcomponent_desc from taxcomponentdetail   
where taxcomponent_code=ITaxc.tax_component_code)                
,ITaxC.tax_component_code                
,case when id.taxcode<>0 then 1 else 0 end lst_flag                 
,tax_description Tax_desc                                  
,(case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End)* sum(ITaxC.tax_value) tax_value                               
,T.percentage               
 From InvoiceAbstract Ia,  
(select distinct invoiceid,product_code,taxid,taxcode,taxcode2 from InvoiceDetail) Id,                
 invoicetaxcomponents ITaxC          
,tax T                 
 Where Ia.InvoiceId=Id.InvoiceId                                   
 And InvoiceDate Between  @FromDate and @ToDate               
 And Ia.InvoiceType Not In (2,5,6)                                     
 and IsNull(Ia.Status, 0) & 128 = 0                           
 And (TaxCode+Taxcode2)<>0                     
 And ITaxC.invoiceid=ia.invoiceid   
and Itaxc.product_code=id.product_code                   
 And ITaxC.tax_code=id.taxid                
 And T.tax_code=taxid                
 and tax_value <> 0     
group by  taxid,CustomerId,ITaxC.tax_component_code,id.taxcode,Ia.InvoiceType,tax_description,T.percentage   
   
order by ITaxC.tax_component_code                 
 --code end                      
End                      

--select * from #TaxComp  
                      
Insert Into #tmpcust Select Distinct CustomerId From InvoiceAbstract Ia ,InvoiceDetail Id                                  
Where Invoicedate   between @FromDate and @ToDate               
And Ia.InvoiceType Not In (2,5,6)                                     
And   IsNull(Ia.Status, 0) & 192 = 0                           
And Ia.InvoiceID=Id.InvoiceId                          
And (TaxCode+Taxcode2)<>0                                  

if (@TaxCBrkUP='Yes')                   
Begin                        
Insert  InTo #tmpVatTaxTCB Select distinct ide.taxid,                  
(select tax_description from tax where tax_code=taxid) Tax_desc                  
,Taxpercent = (TaxCode + TaxCode2),case when stpayable<>0 then 1 else 0 end lst_flag                            
From InvoiceAbstract ia
Inner Join InvoiceDetail ide On ia.InvoiceID = ide.InvoiceID               
Left Outer Join invoicetaxcomponents ITaxC On ITaxC.invoiceid= ia.invoiceid and itaxc.tax_code= ide.taxid                             --,Taxcomponents TC                        
Where 
 ia.InvoiceDate Between @FromDate And @ToDate And                          
ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 192 = 0                          
And (TaxCode+Taxcode2)<>0                  
and taxamount<>0                 
End                  
Else                  
Begin                  
--Insert Into #tmpVatTax Select Distinct Percentage From Tax                       
Insert  InTo #tmpVatTax Select Distinct Tax = (TaxCode + TaxCode2), TaxID                        
From InvoiceAbstract ia, InvoiceDetail ide                       
Where ia.InvoiceID = ide.InvoiceID         
And ia.InvoiceDate Between @FromDate And @ToDate And                      
ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 192 = 0                      
And (TaxCode+Taxcode2)<>0                   
End                  

--select * from tmpVatTaxTCB
                 
if (@TaxCBrkUP='Yes')                   
Begin           
 Insert Into #tmpCustTaxTCB                  
     
select ia.invoiceid,CustomerId,taxid,   
 (select tax_description from tax where tax_code=taxid) Tax_desc,  
(Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) *   
sum((IsNull(Amount, 0) -(IsNull(STPayable, 0) + Isnull(TaxSuffAmount,0)  
 + IsNull(CSTPayable, 0)))),  
 (Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End) * sum(Isnull(IsNull(STPayable, 0)                   
 + IsNull(CSTPayable, 0),0))                  
 ,case when sum(stpayable)<>0 then 1 else 0 end lst_flag     
 From InvoiceAbstract Ia,InvoiceDetail Id  
where Ia.InvoiceId=Id.InvoiceId                                   
 And InvoiceDate Between  @FromDate and @ToDate                                 
 And Ia.InvoiceType Not In (2,5,6)                                     
 and IsNull(Ia.Status, 0) & 192 = 0                           
 And (TaxCode+Taxcode2)<>0       
 and id.taxamount<>0     
group by ia.invoiceid,Ia.InvoiceType,taxid,CustomerId      
End                  
Else                       
Begin                  
 Insert Into #tmpCustTax Select CustomerId,Taxcode+Taxcode2,                              
 (Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * (IsNull(Amount, 0) -(IsNull(STPayable, 0) + Isnull(TaxSuffAmount,0)                              
         + IsNull(CSTPayable, 0)))  ,                       
     (Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 End) * Isnull(IsNull(STPayable, 0) +                                 
         IsNull(CSTPayable, 0),0), TaxID                              
 From InvoiceAbstract Ia,InvoiceDetail Id                              
 Where Ia.InvoiceId=Id.InvoiceId                               
 And InvoiceDate Between  @FromDate and @ToDate                             
 And Ia.InvoiceType Not In (2,5,6)                                 
 and IsNull(Ia.Status, 0) & 192 = 0                       
 And (TaxCode+Taxcode2)<>0            
 and id.taxamount<>0                 
End                  
  
--select * from #tmpCustTaxTCB where customerid='SDC30030'  

if (@TaxCBrkUP='Yes')                   
Begin                  
 Insert Into #tmpCustTax1TCB Select CustomerId,taxid,TaxType,Sum(VatTaxAmount),Sum(VatTax),lstflag                                  
 From #tmpCustTaxTCB --Where TaxType <> 0                   
 Group By  CustomerId,taxid,TaxType,lstflag                                  
 Insert Into #tmpTotTax  Select CustomerId,Sum(VatTaxAmount),Sum(VatTax)                                  
 From #tmpCustTaxTCB --Where TaxType <> 0                   
 Group By  CustomerId                                
End                  
Else                  
Begin                  
 Insert Into #tmpCustTax1 Select CustomerId,TaxType,Sum(VatTaxAmount),Sum(VatTax), TaxID                              
 From #tmpCustTax Where TaxType <> 0 Group By  CustomerId,TaxType, TaxID
 Insert Into #tmpTotTax  Select CustomerId,Sum(VatTaxAmount),Sum(VatTax)
 From #tmpCustTax Where TaxType <> 0 Group By  CustomerId
End                 

Select [ID] = Identity(Int, 1, 1), CustomerId InTo #tmpCust1 From #tmpCust                                   
if (@TaxCBrkUP='Yes')                   
Select [ID] = Identity(Int, 1, 1), TaxType,Taxid,taxpercent,lstflag InTo #tmpVatTax1TCB From #tmpVatTaxTCB Order By lstflag desc,taxid                                  
Else
Select [ID] = Identity(Int, 1, 1), TaxType, TaxID InTo #tmpVatTax1 From #tmpVatTax Order By TaxType                  

Select @custCnt=count(*) From #tmpCust1                    

if  (@TaxCBrkUP='Yes')                  
Select @taxCnt=count(*) From #tmpVatTax1TCB                     
Else
Select @taxCnt=count(*) From #tmpVatTax1                                  

Set @counter=1                                  
While @taxCnt >=@counter                                  
Begin                    
                     
if (@TaxCBrkUP='Yes')                      
Begin                      
 ---code to include for Tax Component Breakup................                      
 Declare @tax_desc as nvarchar(255),@lstflag as int,@taxpercent as decimal(18,6)                  
 Select @tax_desc =TaxType,@taxid=taxid,@taxpercent=taxpercent,@lstflag=lstflag from #tmpVatTax1TCB where id=@counter order by lstflag                                 
                  
 set @tmpSql='Alter Table #tmpVatAbstract Add ['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] Decimal(18, 6) Default(0)'
 Exec sp_executesql @tmpSql                                   
                  
 set @tmpSql='Alter Table #tmpVatAbstract Add ['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                     
                 
Declare @Count as int                      
Select distinct taxid,taxcomponent_desc,tax_description,lst_flag into #TmpCntA from #TaxComp where taxid = @Taxid and lst_flag=@lstflag                 
Select @count=count(*) from #TmpCntA                     
drop table #TmpCntA                
              
if @count<1                      
goto SkipAlter                   
                
declare @lst_flag int,@taxcomponent_desc nvarchar(255),@taxcomponent_code int--,@tax_value decimal(18,6)                     
              
declare @CustomerID nvarchar(255),@tax_description nvarchar(255)                      
 Declare CurTaxComp Cursor for                       
 Select distinct taxcomponent_code,taxid,taxcomponent_desc,tax_description,lst_flag from #TaxComp       
 where taxid = @Taxid and lst_flag=@lstflag --and taxpercentage= @taxpercent              
 order by taxcomponent_code              
 Open CurTaxComp                        
  Fetch From CurTaxComp into @taxcomponent_code,@taxid,@taxcomponent_desc,@tax_description,@lst_flag                       
  While @@Fetch_Status = 0                        
  Begin                       
  set @tmpSql='Alter Table #tmpVatAbstract Add ['+ case when @lst_flag=1 then 'VAT_(' else 'CST_(' end + dbo.mERP_fn_GetTaxColFormat(@taxid, @taxcomponent_code) +')] Decimal(18, 6) Default(0)'
  Exec sp_executesql @tmpSql                       
  Fetch Next From CurTaxComp Into @taxcomponent_code,@taxid,@taxcomponent_desc,@tax_description,@lst_flag                      
 End                               
 Close CurTaxComp                      
 Deallocate CurTaxComp                      
 SkipAlter:                      
 ---End code.......................                                      
End                      
Else                  
Begin      
 Select @tax =TaxType, @taxid = TaxID from #tmpVatTax1 where id=@counter                              
 set @tmpSql='Alter Table #tmpVatAbstract Add [Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] Decimal(18, 6) Default(0)'                                
 Exec sp_executesql @tmpSql                               
 set @tmpSql='Alter Table #tmpVatAbstract Add [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0)  + ')_Tax] Decimal(18, 6) Default(0)'                                
 Exec sp_executesql @tmpSql                   
End                  
                
 set @counter1=1                                  
 While @CustCnt >= @counter1                  
 Begin                                  
  Select @CustId=CustomerId from #tmpCust1 where id=@counter1                                  
  If Not Exists(Select * From #tmpVatAbstract Where [Customer Id] =@CustId)                                  
 Begin                    
   if (@TaxCBrkUP='Yes')                  
   Begin                                
	Set @tmpSql  ='Insert InTo #tmpVatAbstract ([CustomerId],[Customer Id],[Customer Name],[Billing Address],[Tin No],                                  
	['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value],
	['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax])
	(select C.CustomerId,C.CustomerId,C.Company_Name,C.BillingAddress,C.TIN_Number,                                  
	isnull((select VatTaxAmount from #tmpCustTax1TCB where lstflag='+ cast(@lstflag as nvarchar) +' and CustomerId= '''+ cast(@CustId as nvarchar) + ''' And Taxid = ' + cast(@taxid as nVarchar) + '),0),                                  
	isnull((select VatTax from #tmpCustTax1TCB where lstflag='+ cast(@lstflag as nvarchar) +' and CustomerId= '''+ cast(@CustId as nvarchar) + ''' And Taxid = ' + cast(@taxid as nVarchar) + '),0)                                   
	from Customer C where C.CustomerId='''+ cast(@CustId as nvarchar) + ''')'                                  
	Exec sp_executesql @tmpSql                  
  End                  
   Else                  
   Begin
      Set @tmpSql  ='Insert InTo #tmpVatAbstract ([CustomerId],[Customer Id],[Customer Name],[Billing Address],[Tin No],                              
      [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0) + ')_Value],[Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0) + ')_Tax])
             (select C.CustomerId,C.CustomerId,C.Company_Name,C.BillingAddress,C.TIN_Number,                              
      isnull((select VatTaxAmount from #tmpCustTax1 where CustomerId= '''+ cast(@CustId as nvarchar) + ''' And TaxType = ' + cast(@tax as nVarchar) + ' And TaxID = ' + Cast(@taxid as nVarchar) +'),0),                              
      isnull((select VatTax from #tmpCustTax1 where CustomerId= '''+ cast(@CustId as nvarchar) + ''' And TaxType = ' + cast(@tax as nVarchar) + ' And TaxID = ' + Cast(@taxid as nVarchar) +'),0)                               
      from Customer C where C.CustomerId='''+ cast(@CustId as nvarchar) + ''')'                              
      Exec sp_executesql @tmpSql                  
   End                  
                
 End                                  
  Else                                   
 Begin                    
 if (@TaxCBrkUP='Yes')                  
 Begin                   
 Set @tmpSql = 'Update #tmpVatAbstract Set ['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] =                                     
 (Select VatTaxAmount from #tmpCustTax1TCB where lstflag='+ cast(@lstflag as nvarchar) +' and CustomerId= '''+ cast(@CustId as nvarchar) + ''' And Taxid = ' + cast(@taxid as nVarchar) + ')                                  
 where #tmpVatAbstract.[Customer Id]='''+ cast(@CustId as nvarchar) + ''''                
 Exec sp_executesql @tmpSql                 
                               
 Set @tmpSql = 'Update #tmpVatAbstract Set ['+ case when @lstflag=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax] =                                     
 (Select VatTax from #tmpCustTax1TCB where lstflag='+ cast(@lstflag as nvarchar) +' and CustomerId= ''' +cast(@CustId as nvarchar) + ''' And Taxid = '+ cast(@taxid as nVarchar) +')                                  
 where #tmpVatAbstract.[Customer Id]='''+ cast(@CustId as nvarchar) + ''''                                  
 Exec sp_executesql @tmpSql                    
 End                  
 Else                  
 Begin                  
 Set @tmpSql = 'Update #tmpVatAbstract Set [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0) + ')_Value] =                                 
 (Select VatTaxAmount from #tmpCustTax1 where CustomerId= '''+ cast(@CustId as nvarchar) + ''' And TaxType = ' + cast(@tax as nVarchar) + ' And TaxID = ' + Cast(@taxid as nVarchar) +')                              
 where #tmpVatAbstract.[Customer Id]='''+ cast(@CustId as nvarchar) + ''''                              
 Exec sp_executesql @tmpSql                               
 Set @tmpSql = 'Update #tmpVatAbstract Set [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0) + ')_Tax] =                      
 (Select VatTax from #tmpCustTax1 where CustomerId= ''' +cast(@CustId as nvarchar) + ''' And TaxType = '+ cast(@tax as nVarchar) +' And TaxID = ' + Cast(@taxid as nVarchar) +')                         
 where #tmpVatAbstract.[Customer Id]='''+ cast(@CustId as nvarchar) + ''''                              
 Exec sp_executesql @tmpSql                    
 End                  
                
 End                                  
              
Set @counter1=@counter1+1              
End                                  
                                   
              
Set @counter=@counter+1                                  
                     
if (@TaxCBrkUP='Yes')                      
Begin                      
 ---code to enter Tax component splitup                
                      
Select distinct taxid,taxcomponent_desc,tax_description,lst_flag into #TmpCntU from #TaxComp where taxid = @Taxid and lst_flag=@lstflag                 
Select @count=count(*) from #TmpCntU                     
drop table #TmpCntU                
if @count<1                      
goto SkipUpdate                      
Declare @taxid1 as int,@CustomerID1 as nvarchar(255),@taxcomponent_desc1 nvarchar(255)                  
declare @tax_description1 nvarchar(255),@lst_flag1 int,@tax_value1 decimal(18,6), @taxcomp_code1 Int                  
                
                
 Declare CurTaxCompUPD Cursor for                       
 Select distinct taxid,customerid,taxcomponent_desc,tax_description,lst_flag,sum(tax_value) tax_value, taxcomponent_code                   
 from #TaxComp where taxid = @Taxid and lst_flag=@lstflag-- and taxpercentage= @taxpercent                  
 group by taxid,customerid,taxcomponent_desc,tax_description,lst_flag, taxcomponent_code
 Open CurTaxCompUPD                        
 Fetch From CurTaxCompUPD into  @taxid1,@CustomerID1,@taxcomponent_desc1,@tax_description1,@lst_flag1,@tax_value1, @taxcomp_code1
 While @@Fetch_Status = 0                        
 Begin                      
  Set @tmpSql = 'Update #tmpVatAbstract Set ['+ case when @lst_flag=1 then 'VAT_(' else 'CST_(' end + dbo.mERP_fn_GetTaxColFormat(@taxid, @taxcomp_code1) +')] = '+ cast(@tax_value1 as varchar)+'                                     
             where #tmpVatAbstract.[Customer Id]='''+ cast(@CustomerID1 as nvarchar) + ''''                                      
  Exec sp_executesql @tmpSql                  
                
--print @tmpSql                 
                     
 Fetch Next From CurTaxCompUPD Into @taxid1,@CustomerID1,@taxcomponent_desc1,@tax_description1,@lst_flag1,@tax_value1, @taxcomp_code1                       
   End                  
 Close CurTaxCompUPD                      
 Deallocate CurTaxCompUPD                      
 SkipUpdate:                      
 ----code end tax component splitup                      
End                      
End                                  
        
        
if @ChkExemp=1        
Begin        
 Declare @cusid as varchar(30)    
 Declare CurUPDExempt Cursor for                       
 Select customerid from #tmpExempt        
 Open CurUPDExempt                        
 Fetch From CurUPDExempt into  @cusid        
 While @@Fetch_Status = 0                        
 Begin                      
  If Not Exists(Select * From #tmpVatAbstract Where [Customer Id] =@cusid)        
  Begin        
  set @tmpSql = 'Insert into #tmpVatAbstract ([CustomerId],[Customer Id],[Customer Name],[Billing Address],[Tin No],[Exempt])         
               (Select CustomerId,CustomerId,[Customer Name],[Billing Address],[Tin No],ExemptAmount from #tmpExempt where CustomerId='''+ cast(@cusid as nvarchar) + ''')'        
  Exec sp_executesql @tmpSql         
  End        
  Else        
  Begin        
  Set @tmpSql = 'Update #tmpVatAbstract Set Exempt= (select ExemptAmount from #tmpExempt where CustomerId= '''+ cast(@cusid as nvarchar) + ''') Where [Customer Id] ='''+ cast(@cusid as nvarchar) + ''''        
  Exec sp_executesql @tmpSql        
  End        
 Fetch Next From CurUPDExempt Into @cusid        
 End                               
 Close CurUPDExempt                      
 Deallocate CurUPDExempt                      
End        
        
        
        
        
Set @tmpSql='Alter Table #tmpVatAbstract Add [Total Sales] Decimal(18, 6) Default(0)'                          
Exec sp_executesql @tmpSql                                  
Set @tmpSql='Alter Table #tmpVatAbstract Add [Total Tax] Decimal(18, 6) Default(0)'                                    
Exec sp_executesql @tmpSql                                 
          
declare @totexemptamt as decimal(18,6)        
set @cur_VatTax=cursor for select CustomerId from #tmpVatAbstract             
open @cur_VatTax                                
Fetch next from @cur_VatTax into @cust_id                                
while @@fetch_status=0                                
Begin         
set @totexemptamt=0        
set @totAmt=0        
set @totTax=0      
 Select  @totAmt= TotSalesAmount,@totTax=TotTax from #tmpTotTax where customerID=@cust_id         
 Select @totexemptamt=ExemptAmount from  #tmpExempt where customerID=@cust_id         
 Set @tmpSql = 'Update #tmpVatAbstract Set [Total Sales] ='+cast((@totAmt + @totexemptamt)  as nvarchar)+ 'where CustomerId ='''+cast(@cust_id as nvarchar)+''''                                
 Exec sp_executesql @tmpSql         
 Set @tmpSql = 'Update #tmpVatAbstract Set [Total Tax] ='+cast(@totTax as nvarchar)+ 'where CustomerId ='''+cast(@cust_id as nvarchar)+''''                                
 Exec sp_executesql @tmpSql                                    
Fetch Next From @cur_VatTax Into @cust_id                                
End                                
Close @cur_VatTax                                
                          
          
Select * From #tmpVatAbstract                                
                              
Drop Table #tmpcust                   
Drop Table #tmpVatAbstract                                 
Drop Table #tmpTotTax                   
Drop Table #tmpCust1                   
drop table #tmpExempt                                   
        
if(@TaxCBrkUP='Yes')                       
Begin                  
drop table #TaxComp                                      
Drop Table #tmpVatTaxTCB                  
Drop Table #tmpCustTaxTCB                                    
Drop Table #tmpCustTax1TCB                             
Drop Table #tmpVatTax1TCB                              
End                  
Else                  
Begin                  
Drop Table #tmpVatTax                  
Drop Table #tmpCustTax                                    
Drop Table #tmpCustTax1                                  
Drop Table #tmpVatTax1                              
End 
GSTOut:                 
End  
