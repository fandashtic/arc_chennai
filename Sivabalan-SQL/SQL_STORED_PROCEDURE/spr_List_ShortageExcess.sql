CREATE Procedure spr_List_ShortageExcess (@FromDate datetime,
					  @ToDate datetime)
As
Select 1, "Addln. Adj (Rs)" = Sum(ExtraCollection),
"Write Off (Rs)" = Sum(Adjustment),
"Net Value (Rs)" = Sum(ExtraCollection) - Sum(Adjustment)
From Collections, CollectionDetail
Where Collections.DocumentID = CollectionDetail.CollectionID And
Collections.DocumentDate Between @FromDate And @ToDate And
(IsNull(CollectionDetail.ExtraCollection, 0) <> 0 Or 
IsNull(CollectionDetail.Adjustment, 0) <> 0) And
IsNull(Collections.Status, 0) & 128 = 0
