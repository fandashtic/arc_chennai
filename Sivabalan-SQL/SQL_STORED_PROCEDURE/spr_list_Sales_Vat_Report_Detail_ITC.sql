
CREATE Procedure spr_list_Sales_Vat_Report_Detail_ITC(@CustId Nvarchar(30),@FromDate DateTime,@ToDate DateTime,@TaxCBrkUP nvarchar(20)='No')                              
As                              
Begin  

Declare @temp datetime 
Set DATEFormat DMY
Set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
If(@FROMDATE > @temp )
Begin
	Select 0,'This report cannot be generated for GST  period' as Reason
	GoTo GSTOut
End               
                 
If(@TODATE > @temp )
Begin
	set @TODATE  = @temp 
	--goto GSTOut
End 

                            
Declare @cur_InvoiceId as cursor                              
Declare @InvId as int                              
Declare @Prefix as nVarchar(255)                              
Declare @Taxcnt as int                              
Declare @Counter as int                   
if (@TaxCBrkUP='Yes')                                 
 Declare @taxid as Decimal(18,6)                                  
else                  
 Declare @Tax as Decimal(18,6)                              
                  
Declare @tmpSql nVarchar(4000)                              
Declare @InvCnt as int                              
Declare @Counter1 as int                                
Declare @cur_VatTax as cursor                            
Declare @totAmt as Decimal(18,6)                            
Declare @totTax as Decimal(18,6)                            
Declare @inv_Id as int                            
Declare @roundOff as decimal(18,6)                              
Select  @Prefix = Prefix From VoucherPrefix Where TranID Like 'INVOICE'                               
                   
If (@TaxCBrkUP='Yes')                              
Begin                  
Declare @tmpTaxTCB Table(customerid nvarchar(255),taxid Decimal(18,6),taxType nvarchar(255),taxpercent decimal(18,6),lstflag int)                                  
Declare @tmpVatTaxTCB Table(InvoiceId int,taxid int,TaxType Decimal(18,6),SalesAmount decimal(18,6),TaxAmount decimal(18,6),lst_flag int)                              
Declare @tmpTotTaxTCB Table(InvoiceId int,TotSalesAmt Decimal(18,6),TotTax decimal(18,6))                              
Create Table #tmpVatTax1TCB(InvoiceId int,taxid int,TaxType Decimal(18,6),SalesAmount decimal(18,6),TaxAmount decimal(18,6),lst_flag int)                              
End                  
Else                  
Begin                  
Declare @tmpTax Table(taxType Decimal(18,6), TaxID Int)                  
Declare @tmpVatTax Table(InvoiceId int,TaxType Decimal(18,6),SalesAmount decimal(18,6),TaxAmount decimal(18,6),TaxID Int)                              
Declare @tmpTotTax Table(InvoiceId int,TotSalesAmt Decimal(18,6),TotTax decimal(18,6))                              
Create Table #tmpVatTax1(InvoiceId int,TaxType Decimal(18,6),SalesAmount decimal(18,6),TaxAmount decimal(18,6),TaxID Int)                              
End                              
Declare @tmpInvoiceId Table(InvoiceId int)   
                               
Create Table #tmpVatDetail([InvoiceId] int,[Invoice Date] DateTime,[DocReference] nvarchar(255),[Invoice Id] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Invoice Type] nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS)                              
Create Table #tmpExempt([InvoiceId] int,[Invoice Date] DateTime,[DocReference] nvarchar(250),[Invoice Type] nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,[Invoice Id] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ExemptAmount decimal(18,6))          
          
Set @tmpSql='insert into #tmpExempt          
Select Distinct ia.invoiceid,ia.invoicedate,ia.DocReference 
,+''' + @Prefix + '''  +  cast(DocumentId as nVarchar),  
    (case isnull(InvoiceType,0) when 1 then '+'''Sales'''+'                              
    when 4 then '+'''Sales Return'''+'                              
    when 3 then '+'''Sales '''+ ' else '''' end),case when InvoiceType = 4 then -1 else 1 end * sum(amount) Amount          
From InvoiceAbstract Ia,InvoiceDetail Id           
Where Ia.InvoiceId=Id.InvoiceId                            
And InvoiceType Not In (2,5,6)                                 
And IsNull(Status, 0) & 192 = 0             
And Ia.InvoiceDate Between '''+ cast(@FromDate as varchar) +''' And '''+ cast(@ToDate as varchar)+''' 
And CustomerID='''+@CustId +'''          
and taxamount=0           
group by ia.invoiceid,ia.invoicedate,ia.invoicedate,DocumentId,DocReference,InvoiceType'  

Exec sp_executesql @tmpSql          
            
Declare @ChkExemp int           
Set @ChkExemp=0          
                    
if exists (select taxamount          
From InvoiceAbstract Ia,InvoiceDetail Id           
Where Ia.InvoiceId=Id.InvoiceId                            
And InvoiceType Not In (2,5,6)            
And IsNull(Status, 0) & 192 = 0                              
And Ia.InvoiceDate Between @FromDate And @ToDate                              
And CustomerID=@CustId                      
and taxamount=0)          
Begin          
Set @ChkExemp=1          
Set @tmpSql='Alter Table #tmpVatDetail Add Exempt Decimal(18, 6) Default(0)'                                    
Exec sp_executesql @tmpSql          
end                      
          
                  
--Insert Into #tmpTax Select Percentage From Tax                         
If (@TaxCBrkUP='Yes')                              
Begin                  
Insert  InTo @tmpTaxTCB                   
Select distinct ia.customerid,ide.taxid,                  
(select tax_description from tax where tax_code=taxid) Tax_desc                  
,Taxpercent = (TaxCode + TaxCode2)          
,case when stpayable<>0 then 1 else 0 end lst_flag                            
From InvoiceAbstract ia
Inner Join InvoiceDetail ide On ia.InvoiceID = ide.InvoiceID 
Left Outer Join invoicetaxcomponents ITaxC On ITaxC.invoiceid=ia.invoiceid And ITaxc.tax_code=ide.taxid                     
Where ia.InvoiceDate Between @FromDate And @ToDate And                          
ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 128 = 0                          
And (TaxCode+Taxcode2)<>0                  
--and ide.Product_code=ITaxC.product_code  
And CustomerID=@CustId            
and taxamount<>0                 
order by lst_flag desc                               
End                  
Else                  
Begin                  
Insert  InTo @tmpTax                   
Select Distinct Tax = (TaxCode + TaxCode2), TaxID                          
From InvoiceAbstract ia, InvoiceDetail ide                         
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And                        
ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 192 = 0                        
And (TaxCode+Taxcode2)<>0          
and taxamount<>0                  
End                  
            
          
If (@TaxCBrkUP='Yes')                              
Select [ID] = Identity(Int, 1, 1), TaxType,Taxid,taxpercent,customerid,lstflag InTo #tmpTax1TCB                   
From @tmpTaxTCB         
Else                  
Select [ID] = Identity(Int, 1, 1),TaxType, TaxID InTo #tmpTax1 From @tmpTax Order By TaxType                                      
                  
Insert Into @tmpInvoiceId Select Ia.InvoiceId                               
From InvoiceAbstract Ia,InvoiceDetail Id                              
Where Invoicedate Between @FromDate And @ToDate                              
And InvoiceType Not In (2,5,6)                                 
And IsNull(Status, 0) & 192 = 0                               
And CustomerID=@CustId                              
And Ia.InvoiceID=Id.InvoiceId                        
And (TaxCode+Taxcode2)<>0                                
           
    
Select [ID] = Identity(Int, 1, 1),InvoiceId  InTo #tmpInvoiceId1 From @tmpInvoiceId                              
                   
if (@TaxCBrkUP='Yes')                  
Begin                  
Insert Into @TmpVatTaxTCB                  
Select distinct                            
Ia.InvoiceId ,taxid,                            
Isnull(Taxcode,0)+Isnull(Taxcode2,0),                              
(Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * sum((IsNull(Amount, 0) - (IsNull(STPayable, 0) +  Isnull(TaxSuffAmount,0)                               
         +IsNull(CSTPayable, 0)))) VatAmount  ,                              
(Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * sum(IsNull(isnull(STPayable, 0) +                                 
        IsNull(CSTPayable, 0), 0)) VatTax                              
,case when sum(isnull(STPayable, 0))<>0 then 1 else 0 end lst_flag                  
From InvoiceAbstract Ia
Inner Join InvoiceDetail Id  On  Ia.InvoiceId=Id.InvoiceId                            
Left Outer Join (select distinct invoiceid,tax_code from invoicetaxcomponents) ITaxC On ITaxC.invoiceid=ia.invoiceid And ITaxc.tax_code=id.taxid                      
--,Taxcomponents TC                           
Where
 (Isnull(Taxcode,0)+Isnull(Taxcode2,0))<>0             
And InvoiceType Not In (2,5,6)                                 
And IsNull(Status, 0) & 128 = 0                              
And Ia.InvoiceDate Between @FromDate And @ToDate                              
And CustomerID=@CustId                      
--and ITaxC.product_code=id.Product_code                  

and taxamount<>0   
group by  Ia.InvoiceId ,taxid,Taxcode,Taxcode2,Ia.InvoiceType         
                  
Insert Into #TmpVatTax1TCB Select InvoiceId,taxid,TaxType,sum(SalesAmount),sum(TaxAmount),lst_flag                  
From @tmpVatTaxTCB Where TaxType<>0 Group By InvoiceId,TaxType,lst_flag,taxid                   
             
insert into @TmpTotTaxTCB Select InvoiceId,sum(SalesAmount),sum(TaxAmount)                             
From @TmpVatTaxTCB Where TaxType<>0 Group By InvoiceId                 
                 
End                  
Else                             
Begin                  
Insert Into @TmpVatTax                            
Select                             
Ia.InvoiceId ,                            
Isnull(Taxcode,0)+Isnull(Taxcode2,0),                              
(Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * (IsNull(Amount, 0) - (IsNull(STPayable, 0) +  Isnull(TaxSuffAmount,0)                               
         +IsNull(CSTPayable, 0))) VatAmount  ,                              
(Case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * IsNull(isnull(STPayable, 0) +                                 
        IsNull(CSTPayable, 0), 0) VatTax, Id.TaxID                              
From InvoiceAbstract Ia,InvoiceDetail Id                            
Where Ia.InvoiceId=Id.InvoiceId                            
And (Isnull(Taxcode,0)+Isnull(Taxcode2,0))<>0                            
And InvoiceType Not In (2,5,6)                                 
And IsNull(Status, 0) & 192 = 0                              
And Ia.InvoiceDate Between @FromDate And @ToDate                              
And CustomerID=@CustId                   
and taxamount<>0          
                  
Insert Into #TmpVatTax1 Select InvoiceId,TaxType,sum(SalesAmount),sum(TaxAmount),TaxID                             
From @tmpVatTax Where TaxType<>0 Group By InvoiceId,TaxType,TaxID
              
insert into @TmpTotTax Select InvoiceId,sum(SalesAmount),sum(TaxAmount)                             
From @TmpVatTax Where TaxType<>0 Group By InvoiceId                 
            
          
End                      

if (@TaxCBrkUP='Yes')                      
Begin                      
 --Code For tax coponent splitup           
Create table #TaxComp(taxid int,invoiceid int,customerid nvarchar(300),taxcomponent_desc nvarchar(255),taxcomponent_code nvarchar(255)                      
,lst_flag int,InvoiceType int,Tax_description nvarchar(255),tax_value decimal(18,6))                      
Insert into #TaxComp                      
Select distinct taxid,ia.invoiceid,CustomerId                  
,(select distinct taxcomponent_desc from taxcomponentdetail where taxcomponent_code=ITaxC.tax_component_code)                  
,ITaxC.tax_component_code          
,case when taxcode<>0 then 1 else 0 end LST_FLAG          
,Ia.InvoiceType                  
,(select distinct tax_description from tax where tax_code=taxid) Tax_desc                  
,(case IsNull(Ia.InvoiceType, 0) When 4 Then -1 Else 1 End)* sum(ITaxC.tax_value) tax_value                               
From InvoiceAbstract Ia,  
(select distinct invoiceid,product_code,taxid,taxcode,taxcode2 from InvoiceDetail) Id,invoicetaxcomponents ITaxC                                  
Where Ia.InvoiceId=Id.InvoiceId                                   
And InvoiceDate Between  @FromDate and @ToDate                                 
And Ia.InvoiceType Not In (2,5,6)                                     
and IsNull(Ia.Status, 0) & 192 = 0                           
And (TaxCode+Taxcode2)<>0                   
And ITaxC.invoiceid=Ia.InvoiceId                  
and ITaxC.product_code=id.Product_code  
And ia.customerid=@custid              
and id.taxid=ITaxc.tax_code             
and tax_value<>0                 
group by taxid,ia.invoiceid,CustomerId,ITaxC.tax_component_code,taxcode,Ia.InvoiceType   
order by CustomerId,Ia.InvoiceType,ITaxC.tax_component_code                     
 --code end                      
End                           
          
if  (@TaxCBrkUP='Yes')                  
Select @taxCnt=count(*) From #tmpTax1TCB --where customerid=@custid                                  
Else                              
Select  @Taxcnt = count(*) From #tmpTax1                              
                  
Select @InvCnt =count(*) From #tmpInvoiceId1                              
                              
Set @Counter1 =1                      
While @Taxcnt>= @Counter1                              
Begin                  
if (@TaxCBrkUP='Yes')                      
Begin                 
 ---code to include for Tax Component Breakup................                      
 Declare @tax_desc as nvarchar(255),@lstflag as int,@taxpercent as decimal(18,6)                  
 Select @tax_desc =TaxType,@taxid=taxid,@taxpercent=taxpercent,@lstflag=lstflag from #tmpTax1TCB where id=@Counter1 and customerid=@CustId                                  
                  
 set @tmpSql='Alter Table #tmpVatDetail Add ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] Decimal(18, 6) Default(0)'
 Exec sp_executesql @tmpSql                                   
                  
 set @tmpSql='Alter Table #tmpVatDetail Add ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                     
                   
Declare @Count as int                  
              
Select distinct taxid,taxcomponent_desc,tax_description,lst_flag into #TmpCntA from #TaxComp where taxid = @Taxid and lst_flag=@lstflag                 
select @count=count(*) from #TmpCntA          
drop table #TmpCntA                    
if @count<1                      
goto SkipAlter                   
declare @lst_flag int,@taxcomponent_desc nvarchar(255),@taxcomponent_code int--,@tax_value decimal(18,6)                     
declare @CustomerID nvarchar(255),@tax_description nvarchar(255)                      
 Declare CurTaxComp Cursor for        
 Select distinct taxcomponent_code,taxid,taxcomponent_desc,tax_description,lst_flag from #TaxComp     
 where taxid = @Taxid and lst_flag=@lstflag                      
     
 Open CurTaxComp                        
  Fetch From CurTaxComp into @taxcomponent_code,@taxid,@taxcomponent_desc,@tax_description,@lst_flag                       
  While @@Fetch_Status = 0                        
  Begin
  set @tmpSql='Alter Table #tmpVatDetail Add ['+ case when isnull(@lstflag,0)=1 then 'VAT_(' else 'CST_(' end + dbo.mERP_fn_GetTaxColFormat(@taxid, @taxcomponent_code) +')] Decimal(18, 6) Default(0)'
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
 Select @tax =TaxType, @taxid = TaxID From #tmpTax1 Where Id=@counter1                              
 Set @tmpSql='Alter Table #tmpVatDetail Add [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0)  + ')_Value] Decimal(18, 6) Default(0)'                                
 Exec Sp_ExecuteSQL @tmpSql                               
 Set @tmpSql='Alter Table #tmpVatDetail Add [Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0)  + ')_Tax] Decimal(18, 6) Default(0)'                                
 Exec Sp_ExecuteSQL @tmpSql                               
End                  
                  
          
 Set @Counter =1                              
 While @Invcnt >= @Counter                              
 Begin                    
                
  Select @InvId = InvoiceId From #tmpInvoiceId1 Where Id=@Counter                     
                
 If Not Exists(Select * From #tmpVatDetail Where [InvoiceId] =@InvId)                  
 Begin             
                 
 if (@TaxCBrkUP='Yes')                  
  Begin            
  Set @tmpSql ='insert into #tmpVatDetail([InvoiceId],[Invoice Date],[DocReference],[Invoice Id],[Invoice Type],
     ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value],
   ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax])                   
   (select InvoiceId,InvoiceDate,DocReference,+''' + @Prefix + '''  +  cast(DocumentId as nVarchar),
    (case isnull(InvoiceType,0) when 1 then '+'''Sales'''+'                              
    when 4 then '+'''Sales Return'''+'                       
    when 3 then '+'''Sales '''+ ' else '''' end),                              
   (select SalesAmount from #TmpVatTax1TCB where lst_flag ='+ cast(@lstflag as nvarchar) + ' and InvoiceId= '''+ cast(@InvId as nvarchar) + ''' And Taxid = ' + cast(@taxid as nVarchar)+'),                              
    (select TaxAmount from #TmpVatTax1TCB where lst_flag='+ cast(@lstflag as varchar) + ' and InvoiceId= ''' +cast(@InvId as nvarchar) + ''' And Taxid = '+ cast(@taxid as nVarchar) +')                              
    from InvoiceAbstract where InvoiceDate Between ''' + Cast(@FromDate As nVarchar)                                
    + ''' And ''' + Cast(@ToDate As nVarchar) + '''And InvoiceId =''' +cast(@InvId as nvarchar) + ''' And InvoiceType Not In (2) And                                 
    IsNull(Status, 0) & 192 = 0)'                              
  Exec Sp_ExecuteSQL @tmpSql                 
  End                  
 Else                  
  Begin                              
  Set @tmpSql ='insert into #tmpVatDetail([InvoiceId],[Invoice Date],[DocReference],[Invoice Id],[Invoice Type],[Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0)  + ')_Value],[Sales (' + dbo.mERP_fn_GetTaxColFormat(@taxid, 0)  + ')_Tax])
  (select InvoiceId,InvoiceDate,DocReference,+''' + @Prefix + '''  +  cast(DocumentId as nVarchar),                              
  (case isnull(InvoiceType,0) when 1 then '+'''Sales'''+'                              
  when 4 then '+'''Sales Return'''+'                              
  when 3 then '+'''Sales '''+ ' else '''' end),                              
  (select SalesAmount from #TmpVatTax1 where InvoiceId= '''+ cast(@InvId as nvarchar) + ''' And TaxType = ' + cast(@tax as nVarchar)+' And TaxID = '+ Cast(@taxid as nVarchar) +'),                              
  (select TaxAmount from #TmpVatTax1 where InvoiceId= ''' +cast(@InvId as nvarchar) + ''' And TaxType = '+ cast(@tax as nVarchar) +' And TaxID = '+ Cast(@taxid as nVarchar) +')                              
  from InvoiceAbstract where InvoiceDate Between ''' + Cast(@FromDate As nVarchar)                                
  + ''' And ''' + Cast(@ToDate As nVarchar) + '''And InvoiceId =''' +cast(@InvId as nvarchar) + ''' And InvoiceType Not In (2) And                                 
  IsNull(Status, 0) & 192 = 0)'                              
  Exec Sp_ExecuteSQL @tmpSql                               
     End                              
 End                  
   Else                  
    Begin                  
 if (@TaxCBrkUP='Yes')                  
  Begin                   
  Set @tmpSql = 'Update #tmpVatDetail Set 
  ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] = 
  (select SalesAmount from #TmpVatTax1TCB where  lst_flag='+ cast(@lstflag as nvarchar) + ' and InvoiceId= '''+ cast(@InvId as nvarchar) + ''' And Taxid = ' + cast(@taxid as nVarchar) +')                              
  where InvoiceId='''+ cast(@InvId as nvarchar) + ''''                               
  Exec Sp_ExecuteSQL @tmpSql                               
  Set @tmpSql = 'Update #tmpVatDetail Set 
  ['+ case when isnull(@lstflag,0)=1 then 'VAT_' else 'CST_' end +'Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax] = 
  (select TaxAmount from #TmpVatTax1TCB where  lst_flag='+ cast(@lstflag as nvarchar) + ' and InvoiceId= ''' +cast(@InvId as nvarchar) + ''' And Taxid = '+ cast(@taxid as nVarchar) +')                              
  where InvoiceId='''+ cast(@InvId as nvarchar) + ''''                               
  Exec Sp_ExecuteSQL @tmpSql                    
  End                  
 Else                              
     Begin                               
  Set @tmpSql = 'Update #tmpVatDetail Set [Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Value] = 
  (select SalesAmount from #TmpVatTax1 where InvoiceId= '''+ cast(@InvId as nvarchar) + ''' And TaxType = ' + cast(@tax as nVarchar) +' And TaxID = '+ Cast(@taxid as nVarchar) +')                              
  where InvoiceId='''+ cast(@InvId as nvarchar) + ''''                               
  Exec Sp_ExecuteSQL @tmpSql                               
  Set @tmpSql = 'Update #tmpVatDetail Set [Sales ('+ dbo.mERP_fn_GetTaxColFormat(@taxid, 0) +')_Tax] =                                 
  (select TaxAmount from #TmpVatTax1 where InvoiceId= ''' +cast(@InvId as nvarchar) + ''' And TaxType = '+ cast(@tax as nVarchar) +' And TaxID = '+ Cast(@taxid as nVarchar) +')                              
  where InvoiceId='''+ cast(@InvId as nvarchar) + ''''                               
  Exec Sp_ExecuteSQL @tmpSql                              
     End                              
 End                  
    set @counter=@counter+1                       
                     
                  
if (@TaxCBrkUP='Yes')                      
Begin                      
                  
Select distinct taxid,taxcomponent_desc,tax_description,lst_flag into #TmpCntU from #TaxComp where taxid = @Taxid and lst_flag=@lstflag          
select @count=count(*) from #TmpCntU          
drop table #TmpCntU                    

 ---code to enter Tax component splitup                      
if @count<1                      
goto SkipUpdate                      
Declare @taxid1 as int,@CustomerID1 as nvarchar(255),@taxcomponent_desc1 nvarchar(255)      
declare @tax_description1 nvarchar(255),@lst_flag1 int,@tax_value1 decimal(18,6), @TaxComp_Code1 Int
              
 Declare CurTaxCompUPD Cursor for                       
 Select distinct taxid,customerid,taxcomponent_desc,tax_description,lst_flag,sum(tax_value) tax_value, taxcomponent_code
 from #TaxComp where taxid = @Taxid and lst_flag=@lstflag and invoiceid=@invid                  
 group by taxid,customerid,taxcomponent_desc,tax_description,lst_flag, taxcomponent_code
 Open CurTaxCompUPD                        
 Fetch From CurTaxCompUPD into  @taxid1,@CustomerID1,@taxcomponent_desc1,@tax_description1,@lst_flag1,@tax_value1,@TaxComp_Code1
 While @@Fetch_Status = 0                        
 Begin                                       
  Set @tmpSql = 'Update #tmpVatDetail Set ['+ case when @lst_flag=1 then 'VAT_(' else 'CST_(' end + dbo.mERP_fn_GetTaxColFormat(@taxid1, @TaxComp_Code1) +')] = '+ cast(@tax_value1 as varchar)+'                                        
    where InvoiceId='''+ cast(@InvId as nvarchar) + ''''                  
  Exec sp_executesql @tmpSql                   
 Fetch Next From CurTaxCompUPD Into @taxid1,@CustomerID1,@taxcomponent_desc1,@tax_description1,@lst_flag1,@tax_value1, @TaxComp_Code1
   End                               
 Close CurTaxCompUPD                      
 Deallocate CurTaxCompUPD                      
 SkipUpdate:                      
 ----code end tax component splitup                      
End                    
End                            
 set @counter1=@counter1+1                  
End                       
      
--select * from #tmpExempt  
      
if @ChkExemp=1          
Begin          
 Declare CurUPDExempt Cursor for                         
 Select InvoiceId from #tmpExempt          
 Open CurUPDExempt                          
 Fetch From CurUPDExempt into  @invid          
 While @@Fetch_Status = 0                          
 Begin                        
  If Not Exists(Select * From #tmpVatDetail Where [InvoiceId] =@invid)          
  Begin          
--**  Set @tmpSql ='insert into #tmpVatDetail([InvoiceId],[Invoice Date],[Invoice Type],[Invoice Id],Exempt)          
  Set @tmpSql ='insert into #tmpVatDetail([InvoiceId],[Invoice Date],[DocReference],[Invoice Id],[Invoice Type],Exempt)  
  (select * from #tmpExempt where InvoiceId='+ cast(@invid as varchar) +')'          
  Exec sp_executesql @tmpSql           
  End          
  Else          
  Begin          
  Set @tmpSql = 'Update #tmpVatDetail Set Exempt= (select ExemptAmount from #tmpExempt where InvoiceId='+ cast(@invid as varchar) +') where InvoiceId='+ cast(@invid as varchar)          
  Exec sp_executesql @tmpSql           
  End          
 Fetch Next From CurUPDExempt Into @invid          
 End                                 
 Close CurUPDExempt                        
 Deallocate CurUPDExempt                        
End          
                        
Set @tmpSql='Alter Table #tmpVatDetail Add [Round Off Value] Decimal(18, 6) Default(0)'                                
Exec Sp_ExecuteSQL @tmpSql                              
Set @tmpSql='Alter Table #tmpVatDetail Add [Total Sales] Decimal(18, 6) Default(0)'                                
Exec Sp_ExecuteSQL @tmpSql                              
Set @tmpSql='Alter Table #tmpVatDetail Add [Total Tax] Decimal(18, 6) Default(0)'                                
Exec Sp_ExecuteSQL @tmpSql                             
           
Declare @Exmptot as decimal(18,6)          
          
declare @Exemptval decimal(18,6)          
Set @cur_VatTax=Cursor For Select InvoiceId From #tmpVatDetail                            
Open @cur_VatTax                            
Fetch Next From @cur_VatTax Into @inv_Id                            
While @@fetch_status=0                            
Begin                   
if @TaxCBrkUP='Yes'              
Begin          
Set @totAmt=0          
set @Exmptot=0         
set @totTax=0         
 Select  @totAmt= TotSalesAmt,@totTax=TotTax From @tmpTotTaxTCB Where InvoiceId=@inv_Id           
 Select  @Exmptot=ExemptAmount from #tmpExempt where InvoiceId=@inv_Id          
 Set  @totAmt=@totAmt+ @Exmptot                        
End          
Else            
Begin          
Set @totAmt=0          
set @Exmptot=0         
set @totTax=0         
 Select  @totAmt= TotSalesAmt,@totTax=TotTax From @tmpTotTax Where InvoiceId=@inv_Id                            
 Select  @Exmptot=ExemptAmount from #tmpExempt where InvoiceId=@inv_Id          
 Set  @totAmt=@totAmt+ @Exmptot                        
End          
            
 Select @roundOff =RoundOffAmount From InvoiceAbstract Where InvoiceId=@inv_Id                            
 Set @tmpSql = 'Update #tmpVatDetail Set [Round Off Value] ='+cast(@roundOff as nvarchar)+ 'Where InvoiceId ='+cast(@inv_Id as nvarchar)                            
     Exec sp_executesql @tmpSql                                
 Set @tmpSql = 'Update #tmpVatDetail Set [Total Sales] ='+cast(@totAmt as nvarchar)+ 'Where InvoiceId ='+cast(@inv_Id as nvarchar)                            
 Exec sp_executesql @tmpSql                        
 Set @tmpSql = 'Update #tmpVatDetail Set [Total Tax] ='+cast(@totTax as nvarchar)+ 'Where InvoiceId ='+cast(@inv_Id as nvarchar)                            
     Exec sp_executesql @tmpSql                                
Fetch Next From @cur_VatTax Into @inv_Id                            
End                            
Close @cur_VatTax              
          
Select * From #tmpVatDetail                   
                  
                  
Drop Table #tmpInvoiceId1                              
Drop Table #tmpVatDetail                              
Drop table  #tmpExempt                           
                   
if @TaxCBrkUP='Yes'                     
Begin                    
Drop Table #taxcomp                  
drop table #tmpTax1TCB                  
drop table #tmpVatTax1TCB                  
End                  
Else                  
Begin                  
drop table #tmpVatTax1                  
Drop Table #TmpTax1                   
End                  
     GSTOut:             
End                          
