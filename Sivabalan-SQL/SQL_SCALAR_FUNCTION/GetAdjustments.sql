CREATE Function [dbo].[GetAdjustments] (@CollectionID int, @InvNo int) 
Returns nvarchar(1000)
As
Begin
Declare @AdjDocs nvarchar(1000)
Declare @DocID nvarchar(50)
Declare @DocumnetID nvarchar(50)
Declare @DocType nvarchar(30)
Declare @AdjAmount Decimal(18,2)
Declare @AdjAmtTot Decimal(18,2)

Set @AdjDocs='  |Credit Adjustments' + Space(32-Len(RTRIM(LTRIM('Credit Adjustments'))))  + '|' + Space(9-len('Value')) + 'Value' + Space(10-len('Value')) + '|;'
Set @AdjDocs= @AdjDocs + '|' + REPLICATE('-',47) + '|;'

set @AdjAmtTot=0.00

Declare Adjustments Cursor Keyset For
Select DocumentID,OriginalID,
Case DocumentType
When 1 then 'Sales Return ('  + OriginalID + ')'
When 2 then (Select Case When isnull(Memo,'')='' then 'Credit Note (' + OriginalID + ')'  else Memo End From CreditNote Where CreditID=CollectionDetail.DocumentID)
else 'Others' End as DocType,
AdjustedAmount from CollectionDetail Where CollectionID = @CollectionID And
DocumentID <> @InvNo
Open Adjustments
Fetch From Adjustments into @DocumnetID,@DocID,@DocType,@AdjAmount
While @@Fetch_Status = 0
Begin

Set @AdjDocs = @AdjDocs + '|' + RTRIM(LTRIM(@DocType)) + Space(32-Len(RTRIM(LTRIM(@DocType))))  + '|' + 'Rs.' + Space(11-Len(RTRIM(lTRIM(cast(Round(@AdjAmount,2,2) as nVarchar)))))  
+ cast(Round(@AdjAmount,2,2) as nVarchar) + '|' + ';'
Set @AdjAmtTot = @AdjAmtTot + Round(@AdjAmount,2,2)
Fetch Next From Adjustments into @DocumnetID,@DocID,@DocType,@AdjAmount
End

--Set @AdjDocs= @AdjDocs + '|' + REPLICATE('-',47) + '|;'

Set @AdjDocs= @AdjDocs + '|Total' + Space(42-Len(@AdjAmtTot)) +  cast(Round(@AdjAmtTot,2,2) as nVarchar) + '|;'

Set @AdjDocs = SubString(@AdjDocs, 3, Len(@AdjDocs) - 2)
Close Adjustments
Deallocate Adjustments
Return @AdjDocs
End
