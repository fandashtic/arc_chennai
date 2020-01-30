CREATE Procedure [dbo].[sp_view_DSwiseBeatwiseCollectionAbstract](@CollectionID int)            
as  
Declare @ItemCount As Int
Create Table #Temp (TotDocVal Decimal(18,6),TotBal Decimal(18,6),TotDue Decimal(18,6))
Create Table #Temp_One (ItemCount Int)

Insert InTo #Temp_One 
Select Count(*) From Collections cl 
Inner Join CollectionDetail cld ON cl.DocumentID=cld.CollectionID
Inner Join Customer ON cl.CustomerID = Customer.CustomerID
Left Outer Join BankMaster ON cl.BankCode = BankMaster.BankCode
Left Outer Join BranchMaster ON cl.BranchCode = BranchMaster.BranchCode
where cl.DocumentID in 
(Select DocumentID From InvoicewiseCollectionDetail Where CollectionID=@CollectionID) 

Select  @ItemCount = IsNull(ItemCount, 0) From #Temp_One 

Insert into #Temp
Select sum(IsNull(cld.DocumentValue,0)),
sum(IsNull(ia.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)),
sum(IsNull(ia.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) - sum(IsNull(cld.AdjustedAmount,0)) 
From InvoicewiseCollectionDetail iwcd,Collections cl, CollectionDetail cld, InvoiceAbstract ia 
where iwcd.collectionid=@CollectionID and iwcd.DocumentType=1 and iwcd.documentid=cl.documentid and cl.documentid=cld.collectionid 
and cld.documentid=ia.invoiceid
Union
Select sum(IsNull(cld.DocumentValue,0)),sum(IsNull(dn.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)),
sum(IsNull(dn.balance,0) + IsNull(cld.AdjustedAmount,0)+ IsNull(cld.Adjustment,0)) - sum(IsNull(cld.AdjustedAmount,0)) 
From InvoicewiseCollectionDetail iwcd,Collections cl, CollectionDetail cld, DebitNote dn 
where iwcd.collectionid=@CollectionID and iwcd.DocumentType=2 and iwcd.documentid=cl.documentid and cl.documentid=cld.collectionid 
and cld.documentid=dn.DebitID

Select "CollectionDate" = iwca.CollectionDate,"FullDocID" = vp.Prefix+Convert(Nvarchar,DocumentID),
"FullDocRef" = case IsNull(DocSerialType,N'') when N'' then vp.Prefix+N'-'+DocReference else DocSerialType+DocReference end,
"DocumentType" = case DocType when 1 then dbo.LookUpDictionaryItem(N'DSwiseBeatwiseCollections',Default) when 2 then dbo.LookUpDictionaryItem(N'Credit to Cash/Cheque',Default) end, 
"ReferenceNumber" = ReferenceNumber,"TotalDocValue" = (Select sum(TotDocVal)From #Temp),"TotalDocBalance" = (Select sum(TotBal)From #Temp),
"TotalCollectedAmt" = TotalValue,"TotalOutStanding" = (Select sum(TotDue)From #Temp),"SalesmanName" = IsNull(Salesman_Name,N''),
"ITEM COUNT" = @ItemCount
From InvoicewiseCollectionAbstract iwca
Inner Join VoucherPrefix vp ON vp.TranID=dbo.LookUpDictionaryItem(N'DSWISE BEATWISE COLLECTION',Default)
Left Outer Join Salesman sm ON iwca.SalesmanID = sm.SalesmanID 
Where iwca.CollectionID=@CollectionID

Drop Table #Temp
Drop Table #Temp_One

