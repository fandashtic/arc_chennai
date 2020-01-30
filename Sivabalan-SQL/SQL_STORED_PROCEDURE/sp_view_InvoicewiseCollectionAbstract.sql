CREATE procedure [dbo].[sp_view_InvoicewiseCollectionAbstract](@CollectionID int)            
as  
Create Table #Temp (TotDocVal Decimal(18,6),TotBal Decimal(18,6),TotDue Decimal(18,6))

Insert into #Temp
Select sum(IsNull(cld.DocumentValue,0)),
sum(IsNull(ia.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)),
sum(IsNull(ia.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) - sum(IsNull(cld.AdjustedAmount,0)) 
From InvoicewiseCollectionDetail iwcd,Collections cl, CollectionDetail cld, InvoiceAbstract ia 
where iwcd.collectionid=1 and iwcd.DocumentType=1 and iwcd.documentid=cl.documentid and cl.documentid=cld.collectionid 
and cld.documentid=ia.invoiceid
Union
Select sum(IsNull(cld.DocumentValue,0)),sum(IsNull(dn.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)),
sum(IsNull(dn.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) - sum(IsNull(cld.AdjustedAmount,0)) 
From InvoicewiseCollectionDetail iwcd,Collections cl, CollectionDetail cld, DebitNote dn 
where iwcd.collectionid=1 and iwcd.DocumentType=2 and iwcd.documentid=cl.documentid and cl.documentid=cld.collectionid 
and cld.documentid=dn.DebitID

Select "CollectionDate" = iwca.CollectionDate,"FullDocID" = vp.Prefix+Convert(Nvarchar,DocumentID),
"FullDocRef" = case IsNull(DocSerialType,N'') when N'' then vp.Prefix+N'-'+DocReference else DocSerialType+DocReference end,
"DocumentType" = case DocType when 1 then dbo.LookUpDictionaryItem(N'InvoicewiseCollections',Default) when 2 then dbo.LookUpDictionaryItem(N'Credit to Cash/Cheque',Default) end, 
"ReferenceNumber" = ReferenceNumber,"TotalDocValue" = (Select sum(TotDocVal)From #Temp),"TotalDocBalance" = (Select sum(TotBal)From #Temp),
"TotalCollectedAmt" = TotalValue,"TotalOutStanding" = (Select sum(TotDue)From #Temp),"SalesmanName" = IsNull(Salesman_Name,N'')
From InvoicewiseCollectionAbstract iwca,Salesman sm,VoucherPrefix vp 
Where iwca.CollectionID=1 And iwca.SalesmanID *= sm.SalesmanID And vp.TranID=dbo.LookUpDictionaryItem(N'INVOICEWISE COLLECTION',Default)

Drop Table #Temp
