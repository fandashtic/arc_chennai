CREATE Procedure sp_get_NextCollectionID (@CurCollectionID int, @Previous int = 1)
As

-- if @Retail=1
-- 	begin
-- 		If @Previous = 1 
-- 		Begin
-- 			Select Top 1 DocumentID From Collections Where DocumentID < @CurCollectionID
-- 			and isnull(status,0) & 32 = 32	Order By DocumentID Desc
-- 		End
-- 		Else
-- 		Begin
-- 			Select Top 1 DocumentID From Collections Where DocumentID > @CurCollectionID
-- 			and isnull(status,0) & 32 = 32 Order By DocumentID
-- 		End
-- 	end
-- else
-- 	begin
		If @Previous = 1 
		Begin
			Select Top 1 DocumentID From Collections Where DocumentID < @CurCollectionID
			and CustomerId <> 'GIFT VOUCHER'
			Order By DocumentID Desc
		End
		Else
		Begin
			Select Top 1 DocumentID From Collections Where DocumentID > @CurCollectionID
			and CustomerId <> 'GIFT VOUCHER'
			Order By DocumentID
		End
-- 	end

